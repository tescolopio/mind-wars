const express = require('express');
const router = express.Router();
const { pool, logger } = require('../server');
const requireAuth = require('../middleware/auth');

/**
 * POST /analytics/track
 * Track analytics event
 */
router.post('/track', requireAuth, async (req, res) => {
  try {
    const { eventType, properties, sessionId } = req.body;
    const userId = req.user.userId;
    
    await pool.query(
      `INSERT INTO analytics_events (user_id, session_id, event_type, event_properties)
       VALUES ($1, $2, $3, $4)`,
      [userId, sessionId, eventType, properties]
    );
    
    res.json({ message: 'Event tracked' });
  } catch (error) {
    logger.error('Track event error', { error: error.message });
    res.status(500).json({ error: 'Failed to track event' });
  }
});

/**
 * GET /analytics/events
 * Get analytics events (admin only)
 */
router.get('/events', requireAuth, async (req, res) => {
  try {
    const { startDate, endDate, eventType } = req.query;
    
    let query = 'SELECT * FROM analytics_events WHERE 1=1';
    const params = [];
    
    if (startDate) {
      params.push(startDate);
      query += ` AND created_at >= $${params.length}`;
    }
    
    if (endDate) {
      params.push(endDate);
      query += ` AND created_at <= $${params.length}`;
    }
    
    if (eventType) {
      params.push(eventType);
      query += ` AND event_type = $${params.length}`;
    }
    
    query += ' ORDER BY created_at DESC LIMIT 1000';
    
    const result = await pool.query(query, params);
    
    res.json({ events: result.rows });
  } catch (error) {
    logger.error('Get events error', { error: error.message });
    res.status(500).json({ error: 'Failed to fetch events' });
  }
});

module.exports = router;
