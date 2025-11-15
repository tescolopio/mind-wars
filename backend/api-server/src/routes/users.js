const express = require('express');
const { body, validationResult } = require('express-validator');
const { query } = require('../utils/database');
const { AppError } = require('../middleware/errorHandler');
const { authenticate } = require('../middleware/auth');
const { standardLimiter } = require('../middleware/rateLimit');

const router = express.Router();

router.use(authenticate);
router.use(standardLimiter);

// GET /api/users/:id - Get user profile
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await query(
      `SELECT id, email, display_name, avatar_url, level, total_score,
              current_streak, longest_streak, games_played, games_won,
              created_at, last_login_at
       FROM users WHERE id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      throw new AppError('User not found', 404);
    }

    const user = result.rows[0];

    res.json({
      success: true,
      data: {
        id: user.id,
        email: user.email,
        displayName: user.display_name,
        avatarUrl: user.avatar_url,
        level: user.level,
        totalScore: user.total_score,
        currentStreak: user.current_streak,
        longestStreak: user.longest_streak,
        gamesPlayed: user.games_played,
        gamesWon: user.games_won,
        createdAt: user.created_at,
        lastLoginAt: user.last_login_at
      }
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/users/:id/progress - Get user progress
router.get('/:id/progress', async (req, res, next) => {
  try {
    const { id } = req.params;

    // Get badges
    const badgesResult = await query(
      `SELECT b.*, ub.earned_at
       FROM badges b
       LEFT JOIN user_badges ub ON b.id = ub.badge_id AND ub.user_id = $1
       ORDER BY b.category, b.name`,
      [id]
    );

    // Get recent games
    const gamesResult = await query(
      `SELECT gr.*, g.name as game_name, l.name as lobby_name
       FROM game_results gr
       JOIN lobbies l ON gr.lobby_id = l.id
       WHERE gr.user_id = $1
       ORDER BY gr.created_at DESC
       LIMIT 20`,
      [id]
    );

    // Get statistics
    const statsResult = await query(
      `SELECT
         COUNT(*) as total_games,
         AVG(score) as avg_score,
         MAX(score) as best_score,
         SUM(CASE WHEN perfect THEN 1 ELSE 0 END) as perfect_games
       FROM game_results
       WHERE user_id = $1`,
      [id]
    );

    const stats = statsResult.rows[0];

    res.json({
      success: true,
      data: {
        badges: badgesResult.rows.map(b => ({
          id: b.id,
          name: b.name,
          description: b.description,
          category: b.category,
          icon: b.icon,
          earned: !!b.earned_at,
          earnedAt: b.earned_at
        })),
        recentGames: gamesResult.rows.map(g => ({
          id: g.id,
          gameName: g.game_name,
          lobbyName: g.lobby_name,
          score: g.score,
          timeTaken: g.time_taken,
          perfect: g.perfect,
          createdAt: g.created_at
        })),
        statistics: {
          totalGames: parseInt(stats.total_games),
          avgScore: parseFloat(stats.avg_score) || 0,
          bestScore: parseInt(stats.best_score) || 0,
          perfectGames: parseInt(stats.perfect_games)
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

// PATCH /api/users/:id - Update user profile
router.patch('/:id', [
  body('displayName').optional().trim().isLength({ min: 2, max: 50 }),
  body('avatarUrl').optional().isURL()
], async (req, res, next) => {
  try {
    const { id } = req.params;

    // Check if user is updating their own profile
    if (id !== req.user.id) {
      throw new AppError('Cannot update another user\'s profile', 403);
    }

    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const { displayName, avatarUrl } = req.body;
    const updates = [];
    const values = [];
    let paramCount = 1;

    if (displayName) {
      updates.push(`display_name = $${paramCount++}`);
      values.push(displayName);
    }

    if (avatarUrl) {
      updates.push(`avatar_url = $${paramCount++}`);
      values.push(avatarUrl);
    }

    if (updates.length === 0) {
      throw new AppError('No fields to update', 400);
    }

    updates.push(`updated_at = NOW()`);
    values.push(id);

    const result = await query(
      `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      values
    );

    const user = result.rows[0];

    res.json({
      success: true,
      data: {
        id: user.id,
        email: user.email,
        displayName: user.display_name,
        avatarUrl: user.avatar_url,
        updatedAt: user.updated_at
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
