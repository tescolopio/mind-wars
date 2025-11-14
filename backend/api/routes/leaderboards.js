const express = require('express');
const router = express.Router();
const { pool, logger } = require('../server');
const requireAuth = require('../middleware/auth');

/**
 * GET /leaderboard/weekly
 * Get weekly leaderboard
 */
router.get('/weekly', requireAuth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT l.*, u.username, u.display_name, u.avatar_id
       FROM leaderboards l
       JOIN users u ON l.user_id = u.id
       WHERE l.period = 'weekly' AND l.week_start = DATE_TRUNC('week', CURRENT_DATE)
       ORDER BY l.rank ASC
       LIMIT 100`
    );
    
    res.json({ leaderboard: result.rows });
  } catch (error) {
    logger.error('Get weekly leaderboard error', { error: error.message });
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

/**
 * GET /leaderboard/all-time
 * Get all-time leaderboard
 */
router.get('/all-time', requireAuth, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT l.*, u.username, u.display_name, u.avatar_id
       FROM leaderboards l
       JOIN users u ON l.user_id = u.id
       WHERE l.period = 'all_time'
       ORDER BY l.total_score DESC
       LIMIT 100`
    );
    
    res.json({ leaderboard: result.rows });
  } catch (error) {
    logger.error('Get all-time leaderboard error', { error: error.message });
    res.status(500).json({ error: 'Failed to fetch leaderboard' });
  }
});

module.exports = router;
