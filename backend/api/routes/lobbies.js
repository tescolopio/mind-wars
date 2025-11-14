const express = require('express');
const router = express.Router();
const { pool, logger } = require('../server');

// Middleware to require authentication
const requireAuth = require('../middleware/auth');

/**
 * GET /lobbies
 * Get list of available lobbies
 */
router.get('/', requireAuth, async (req, res) => {
  try {
    const { status = 'waiting', isPrivate } = req.query;
    
    let query = 'SELECT * FROM lobbies WHERE status = $1';
    const params = [status];
    
    if (isPrivate !== undefined) {
      query += ' AND is_private = $2';
      params.push(isPrivate === 'true');
    }
    
    query += ' ORDER BY created_at DESC LIMIT 50';
    
    const result = await pool.query(query, params);
    
    res.json({ lobbies: result.rows });
  } catch (error) {
    logger.error('Get lobbies error', { error: error.message });
    res.status(500).json({ error: 'Failed to fetch lobbies' });
  }
});

/**
 * POST /lobbies
 * Create a new lobby
 */
router.post('/', requireAuth, async (req, res) => {
  try {
    const { name, maxPlayers = 10, numRounds = 5, isPrivate = true } = req.body;
    const userId = req.user.userId;
    
    // Generate unique lobby code
    const code = Math.random().toString(36).substring(2, 8).toUpperCase();
    
    const result = await pool.query(
      `INSERT INTO lobbies (code, name, host_id, max_players, num_rounds, is_private)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [code, name, userId, maxPlayers, numRounds, isPrivate]
    );
    
    const lobby = result.rows[0];
    
    // Add host to lobby players
    await pool.query(
      'INSERT INTO lobby_players (lobby_id, user_id) VALUES ($1, $2)',
      [lobby.id, userId]
    );
    
    logger.info('Lobby created', { lobbyId: lobby.id, code: lobby.code });
    
    res.status(201).json({ lobby });
  } catch (error) {
    logger.error('Create lobby error', { error: error.message });
    res.status(500).json({ error: 'Failed to create lobby' });
  }
});

/**
 * GET /lobbies/:id
 * Get lobby details
 */
router.get('/:id', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    
    const lobbyResult = await pool.query('SELECT * FROM lobbies WHERE id = $1', [id]);
    
    if (lobbyResult.rows.length === 0) {
      return res.status(404).json({ error: 'Lobby not found' });
    }
    
    const lobby = lobbyResult.rows[0];
    
    // Get players in lobby
    const playersResult = await pool.query(
      `SELECT u.id, u.username, u.display_name, u.avatar_id, lp.joined_at
       FROM lobby_players lp
       JOIN users u ON lp.user_id = u.id
       WHERE lp.lobby_id = $1 AND lp.is_active = true`,
      [id]
    );
    
    lobby.players = playersResult.rows;
    
    res.json({ lobby });
  } catch (error) {
    logger.error('Get lobby error', { error: error.message });
    res.status(500).json({ error: 'Failed to fetch lobby' });
  }
});

/**
 * POST /lobbies/:id/join
 * Join a lobby
 */
router.post('/:id/join', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    
    // Check if lobby exists and has space
    const lobbyResult = await pool.query(
      'SELECT * FROM lobbies WHERE id = $1 AND status = $2',
      [id, 'waiting']
    );
    
    if (lobbyResult.rows.length === 0) {
      return res.status(404).json({ error: 'Lobby not found or not available' });
    }
    
    const lobby = lobbyResult.rows[0];
    
    if (lobby.current_players >= lobby.max_players) {
      return res.status(400).json({ error: 'Lobby is full' });
    }
    
    // Add player to lobby
    await pool.query(
      'INSERT INTO lobby_players (lobby_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [id, userId]
    );
    
    // Update player count
    await pool.query(
      'UPDATE lobbies SET current_players = current_players + 1 WHERE id = $1',
      [id]
    );
    
    logger.info('User joined lobby', { lobbyId: id, userId });
    
    res.json({ message: 'Joined lobby successfully' });
  } catch (error) {
    logger.error('Join lobby error', { error: error.message });
    res.status(500).json({ error: 'Failed to join lobby' });
  }
});

/**
 * POST /lobbies/:id/leave
 * Leave a lobby
 */
router.post('/:id/leave', requireAuth, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    
    await pool.query(
      'UPDATE lobby_players SET is_active = false, left_at = NOW() WHERE lobby_id = $1 AND user_id = $2',
      [id, userId]
    );
    
    await pool.query(
      'UPDATE lobbies SET current_players = current_players - 1 WHERE id = $1',
      [id]
    );
    
    logger.info('User left lobby', { lobbyId: id, userId });
    
    res.json({ message: 'Left lobby successfully' });
  } catch (error) {
    logger.error('Leave lobby error', { error: error.message });
    res.status(500).json({ error: 'Failed to leave lobby' });
  }
});

module.exports = router;
