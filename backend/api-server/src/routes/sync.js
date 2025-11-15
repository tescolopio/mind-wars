const express = require('express');
const { body, validationResult } = require('express-validator');
const { query, transaction } = require('../utils/database');
const { AppError } = require('../middleware/errorHandler');
const { authenticate } = require('../middleware/auth');
const { standardLimiter } = require('../middleware/rateLimit');
const { createLogger } = require('../utils/logger');

const router = express.Router();
const logger = createLogger('sync-routes');

router.use(authenticate);
router.use(standardLimiter);

// POST /api/sync/game - Sync offline game data
router.post('/game', [
  body('lobbyId').isUUID(),
  body('gameId').notEmpty(),
  body('score').isNumeric(),
  body('timeTaken').isNumeric(),
  body('timestamp').isISO8601()
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const { lobbyId, gameId, score, timeTaken, hintsUsed, perfect, timestamp } = req.body;
    const userId = req.user.id;

    // Check if this game result already exists (prevent duplicates)
    const existing = await query(
      `SELECT id FROM game_results
       WHERE user_id = $1 AND lobby_id = $2 AND game_id = $3
       AND created_at = $4`,
      [userId, lobbyId, gameId, timestamp]
    );

    if (existing.rows.length > 0) {
      logger.info(`Duplicate sync request ignored for user ${userId}`);
      return res.json({
        success: true,
        data: {
          synced: true,
          duplicate: true,
          message: 'Game result already synced'
        }
      });
    }

    // Sync the game result
    const result = await transaction(async (client) => {
      const gameResult = await client.query(
        `INSERT INTO game_results (lobby_id, user_id, game_id, score, time_taken, hints_used, perfect, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING *`,
        [lobbyId, userId, gameId, score, timeTaken, hintsUsed || 0, perfect || false, timestamp]
      );

      // Update user total score
      await client.query(
        `UPDATE users SET total_score = total_score + $1 WHERE id = $2`,
        [score, userId]
      );

      return gameResult.rows[0];
    });

    logger.info(`Game result synced for user ${userId}: ${gameId}`);

    res.json({
      success: true,
      data: {
        synced: true,
        gameResultId: result.id,
        timestamp: result.created_at
      }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/sync/progress - Sync user progress
router.post('/progress', [
  body('currentStreak').optional().isNumeric(),
  body('longestStreak').optional().isNumeric(),
  body('lastPlayedAt').optional().isISO8601()
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const { currentStreak, longestStreak, lastPlayedAt } = req.body;
    const userId = req.user.id;

    const updates = [];
    const values = [];
    let paramCount = 1;

    if (currentStreak !== undefined) {
      updates.push(`current_streak = $${paramCount++}`);
      values.push(currentStreak);
    }

    if (longestStreak !== undefined) {
      updates.push(`longest_streak = GREATEST(longest_streak, $${paramCount++})`);
      values.push(longestStreak);
    }

    if (lastPlayedAt) {
      updates.push(`last_played_at = $${paramCount++}`);
      values.push(lastPlayedAt);
    }

    if (updates.length === 0) {
      throw new AppError('No progress data to sync', 400);
    }

    updates.push(`updated_at = NOW()`);
    values.push(userId);

    const result = await query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramCount}
       RETURNING current_streak, longest_streak, last_played_at`,
      values
    );

    const user = result.rows[0];

    logger.info(`Progress synced for user ${userId}`);

    res.json({
      success: true,
      data: {
        synced: true,
        currentStreak: user.current_streak,
        longestStreak: user.longest_streak,
        lastPlayedAt: user.last_played_at
      }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/sync/batch - Batch sync multiple games
router.post('/batch', [
  body('games').isArray({ min: 1, max: 50 })
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const { games } = req.body;
    const userId = req.user.id;

    const results = await transaction(async (client) => {
      const syncedGames = [];
      let totalScore = 0;

      for (const game of games) {
        const { lobbyId, gameId, score, timeTaken, hintsUsed, perfect, timestamp } = game;

        // Check for duplicates
        const existing = await client.query(
          `SELECT id FROM game_results
           WHERE user_id = $1 AND lobby_id = $2 AND game_id = $3 AND created_at = $4`,
          [userId, lobbyId, gameId, timestamp]
        );

        if (existing.rows.length > 0) {
          syncedGames.push({ gameId, duplicate: true });
          continue;
        }

        // Insert game result
        const result = await client.query(
          `INSERT INTO game_results (lobby_id, user_id, game_id, score, time_taken, hints_used, perfect, created_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
           RETURNING id`,
          [lobbyId, userId, gameId, score, timeTaken, hintsUsed || 0, perfect || false, timestamp]
        );

        syncedGames.push({
          gameId,
          gameResultId: result.rows[0].id,
          duplicate: false
        });

        totalScore += score;
      }

      // Update user total score
      if (totalScore > 0) {
        await client.query(
          `UPDATE users SET total_score = total_score + $1 WHERE id = $2`,
          [totalScore, userId]
        );
      }

      return { syncedGames, totalScore };
    });

    logger.info(`Batch sync completed for user ${userId}: ${games.length} games`);

    res.json({
      success: true,
      data: {
        synced: true,
        totalGames: games.length,
        newGames: results.syncedGames.filter(g => !g.duplicate).length,
        duplicates: results.syncedGames.filter(g => g.duplicate).length,
        totalScore: results.totalScore,
        games: results.syncedGames
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
