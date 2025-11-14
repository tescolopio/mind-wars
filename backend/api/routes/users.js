const express = require('express');
const router = express.Router();
const { pool, logger } = require('../server');
const requireAuth = require('../middleware/auth');

/**
 * GET /users/:id
 * Get user profile
 */
router.get('/:id', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await pool.query(
      'SELECT id, username, email, display_name, avatar_id, role, created_at FROM users WHERE id = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json({ user: result.rows[0] });
  } catch (error) {
    logger.error('Get user error', { error: error.message });
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

/**
 * GET /users/:id/progress
 * Get user progress and stats
 */
router.get('/:id/progress', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get leaderboard stats
    const leaderboardResult = await pool.query(
      'SELECT * FROM leaderboards WHERE user_id = $1 AND period = $2',
      [id, 'all_time']
    );
    
    // Get badges
    const badgesResult = await pool.query(
      'SELECT * FROM badges WHERE user_id = $1 ORDER BY earned_at DESC',
      [id]
    );
    
    res.json({
      stats: leaderboardResult.rows[0] || {},
      badges: badgesResult.rows
    });
  } catch (error) {
    logger.error('Get progress error', { error: error.message });
    res.status(500).json({ error: 'Failed to fetch progress' });
  }
});

module.exports = router;
