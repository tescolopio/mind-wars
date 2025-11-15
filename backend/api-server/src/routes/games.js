const express = require('express');
const { body, validationResult } = require('express-validator');
const { query, transaction } = require('../utils/database');
const { AppError } = require('../middleware/errorHandler');
const { authenticate } = require('../middleware/auth');
const { standardLimiter } = require('../middleware/rateLimit');

const router = express.Router();

router.use(authenticate);
router.use(standardLimiter);

// GET /api/games - Get available games
router.get('/', async (req, res, next) => {
  try {
    // Return game catalog (this matches the Flutter app's game_catalog.dart)
    const games = [
      { id: 'memory-match', name: 'Memory Match', category: 'Memory', minPlayers: 2, maxPlayers: 4 },
      { id: 'sequence-recall', name: 'Sequence Recall', category: 'Memory', minPlayers: 2, maxPlayers: 6 },
      { id: 'pattern-memory', name: 'Pattern Memory', category: 'Memory', minPlayers: 2, maxPlayers: 8 },
      { id: 'sudoku-duel', name: 'Sudoku Duel', category: 'Logic', minPlayers: 2, maxPlayers: 4 },
      { id: 'logic-grid', name: 'Logic Grid', category: 'Logic', minPlayers: 2, maxPlayers: 6 },
      { id: 'code-breaker', name: 'Code Breaker', category: 'Logic', minPlayers: 2, maxPlayers: 4 },
      { id: 'spot-difference', name: 'Spot the Difference', category: 'Attention', minPlayers: 2, maxPlayers: 8 },
      { id: 'color-rush', name: 'Color Rush', category: 'Attention', minPlayers: 2, maxPlayers: 10 },
      { id: 'focus-finder', name: 'Focus Finder', category: 'Attention', minPlayers: 2, maxPlayers: 6 },
      { id: 'puzzle-race', name: 'Puzzle Race', category: 'Spatial', minPlayers: 2, maxPlayers: 4 },
      { id: 'rotation-master', name: 'Rotation Master', category: 'Spatial', minPlayers: 2, maxPlayers: 8 },
      { id: 'path-finder', name: 'Path Finder', category: 'Spatial', minPlayers: 2, maxPlayers: 6 },
      { id: 'word-builder', name: 'Word Builder', category: 'Language', minPlayers: 2, maxPlayers: 6 },
      { id: 'anagram-attack', name: 'Anagram Attack', category: 'Language', minPlayers: 2, maxPlayers: 8 },
      { id: 'vocabulary-showdown', name: 'Vocabulary Showdown', category: 'Language', minPlayers: 2, maxPlayers: 10 }
    ];

    res.json({
      success: true,
      data: { games }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/games/:id/submit - Submit game result
router.post('/:id/submit', [
  body('lobbyId').isUUID(),
  body('score').isNumeric(),
  body('timeTaken').isNumeric(),
  body('hintsUsed').isNumeric()
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: { message: 'Validation failed', errors: errors.array() }
      });
    }

    const { id: gameId } = req.params;
    const { lobbyId, score, timeTaken, hintsUsed, perfect } = req.body;
    const userId = req.user.id;

    // Validate game exists in lobby
    const lobbyCheck = await query(
      `SELECT id FROM lobbies WHERE id = $1 AND status = 'playing'`,
      [lobbyId]
    );

    if (lobbyCheck.rows.length === 0) {
      throw new AppError('Lobby not found or not in playing state', 404);
    }

    // Validate player is in lobby
    const playerCheck = await query(
      `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
      [lobbyId, userId]
    );

    if (playerCheck.rows.length === 0) {
      throw new AppError('Player not in lobby', 403);
    }

    // Calculate validated score (server-side validation to prevent cheating)
    const validatedScore = calculateScore(score, timeTaken, hintsUsed, perfect);

    // Save game result
    const result = await transaction(async (client) => {
      // Insert game result
      const gameResult = await client.query(
        `INSERT INTO game_results (lobby_id, user_id, game_id, score, time_taken, hints_used, perfect, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
         RETURNING *`,
        [lobbyId, userId, gameId, validatedScore, timeTaken, hintsUsed, perfect || false]
      );

      // Update user total score
      await client.query(
        `UPDATE users SET total_score = total_score + $1 WHERE id = $2`,
        [validatedScore, userId]
      );

      return gameResult.rows[0];
    });

    res.json({
      success: true,
      data: {
        id: result.id,
        validatedScore: result.score,
        originalScore: score,
        timeTaken: result.time_taken,
        hintsUsed: result.hints_used,
        perfect: result.perfect
      }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/games/:id/validate-move - Validate game move
router.post('/:id/validate-move', async (req, res, next) => {
  try {
    const { id: gameId } = req.params;
    const { move, gameState } = req.body;

    // Server-side move validation would go here
    // For now, we'll just acknowledge the move
    const isValid = true;

    res.json({
      success: true,
      data: {
        valid: isValid,
        gameId,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    next(error);
  }
});

// Helper: Calculate validated score (anti-cheat)
function calculateScore(rawScore, timeTaken, hintsUsed, perfect) {
  // Unified scoring formula from Flutter app:
  // Score = (90 - seconds) + (20 × noHints) + (15 × perfect) - (5 × hints)
  const timeBonus = Math.max(0, 90 - Math.floor(timeTaken / 1000));
  const noHintBonus = hintsUsed === 0 ? 20 : 0;
  const perfectBonus = perfect ? 15 : 0;
  const hintPenalty = hintsUsed * 5;

  const calculatedScore = timeBonus + noHintBonus + perfectBonus - hintPenalty;

  // Ensure score is not negative
  return Math.max(0, Math.min(calculatedScore, rawScore));
}

module.exports = router;
