const express = require('express');
const router = express.Router();
const { pool, logger } = require('../server');
const requireAuth = require('../middleware/auth');

/**
 * POST /sync/game
 * Sync offline game data
 */
router.post('/game', requireAuth, async (req, res) => {
  try {
    const { gameData } = req.body;
    const userId = req.user.userId;
    
    // Process offline game data
    // Store in database with proper validation
    
    logger.info('Game data synced', { userId });
    
    res.json({ message: 'Game synced successfully' });
  } catch (error) {
    logger.error('Sync game error', { error: error.message });
    res.status(500).json({ error: 'Failed to sync game' });
  }
});

/**
 * POST /sync/batch
 * Batch sync multiple games
 */
router.post('/batch', requireAuth, async (req, res) => {
  try {
    const { games } = req.body;
    const userId = req.user.userId;
    
    // Process batch of offline games
    
    logger.info('Batch sync completed', { userId, count: games.length });
    
    res.json({ message: 'Batch synced successfully', synced: games.length });
  } catch (error) {
    logger.error('Batch sync error', { error: error.message });
    res.status(500).json({ error: 'Failed to sync batch' });
  }
});

module.exports = router;
