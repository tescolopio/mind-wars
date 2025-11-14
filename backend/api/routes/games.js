const express = require('express');
const router = express.Router();
const { pool, logger } = require('../server');
const requireAuth = require('../middleware/auth');

/**
 * POST /games/:id/submit
 * Submit game result
 */
router.post('/:id/submit', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const { score, turnData } = req.body;
    const userId = req.user.userId;
    
    // Validate and store game submission
    const result = await pool.query(
      `INSERT INTO game_turns (game_id, user_id, turn_number, turn_data, score)
       VALUES ($1, $2, (SELECT COALESCE(MAX(turn_number), 0) + 1 FROM game_turns WHERE game_id = $1), $3, $4)
       RETURNING *`,
      [id, userId, turnData, score]
    );
    
    logger.info('Game result submitted', { gameId: id, userId, score });
    
    res.json({ turn: result.rows[0] });
  } catch (error) {
    logger.error('Submit game error', { error: error.message });
    res.status(500).json({ error: 'Failed to submit game result' });
  }
});

/**
 * POST /games/:id/validate-move
 * Validate a game move
 */
router.post('/:id/validate-move', requireAuth, async (req, res) => {
  try {
    const { moveData } = req.body;
    
    // Server-side validation logic would go here
    const isValid = true; // Placeholder
    
    res.json({ isValid, message: 'Move validated' });
  } catch (error) {
    logger.error('Validate move error', { error: error.message });
    res.status(500).json({ error: 'Failed to validate move' });
  }
});

/**
 * GET /games/:id/state
 * Get current game state
 */
router.get('/:id/state', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await pool.query('SELECT * FROM games WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }
    
    res.json({ game: result.rows[0] });
  } catch (error) {
    logger.error('Get game state error', { error: error.message });
    res.status(500).json({ error: 'Failed to fetch game state' });
  }
});

module.exports = router;
