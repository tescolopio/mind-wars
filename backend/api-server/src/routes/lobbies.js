const express = require('express');
const { body, validationResult } = require('express-validator');
const { query } = require('../utils/database');
const { AppError } = require('../middleware/errorHandler');
const { authenticate } = require('../middleware/auth');
const { standardLimiter } = require('../middleware/rateLimit');

const router = express.Router();

// All lobby routes require authentication
router.use(authenticate);
router.use(standardLimiter);

// GET /api/lobbies - List public lobbies
router.get('/', async (req, res, next) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    let queryText = `
      SELECT l.*, u.display_name as host_name,
             (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) as player_count
      FROM lobbies l
      JOIN users u ON l.host_id = u.id
      WHERE l.is_private = false
    `;

    const params = [];
    if (status) {
      params.push(status);
      queryText += ` AND l.status = $${params.length}`;
    }

    queryText += ` ORDER BY l.created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, offset);

    const result = await query(queryText, params);

    res.json({
      success: true,
      data: {
        lobbies: result.rows.map(lobby => ({
          id: lobby.id,
          code: lobby.code,
          name: lobby.name,
          hostId: lobby.host_id,
          hostName: lobby.host_name,
          maxPlayers: lobby.max_players,
          playerCount: parseInt(lobby.player_count),
          status: lobby.status,
          currentRound: lobby.current_round,
          totalRounds: lobby.total_rounds,
          createdAt: lobby.created_at
        })),
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: result.rowCount
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/lobbies/:id - Get lobby details
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const lobbyResult = await query(
      `SELECT l.*, u.display_name as host_name
       FROM lobbies l
       JOIN users u ON l.host_id = u.id
       WHERE l.id = $1`,
      [id]
    );

    if (lobbyResult.rows.length === 0) {
      throw new AppError('Lobby not found', 404);
    }

    const lobby = lobbyResult.rows[0];

    // Get players
    const playersResult = await query(
      `SELECT lp.*, u.display_name, u.avatar_url, u.level
       FROM lobby_players lp
       JOIN users u ON lp.user_id = u.id
       WHERE lp.lobby_id = $1
       ORDER BY lp.joined_at`,
      [id]
    );

    res.json({
      success: true,
      data: {
        id: lobby.id,
        code: lobby.code,
        name: lobby.name,
        hostId: lobby.host_id,
        hostName: lobby.host_name,
        maxPlayers: lobby.max_players,
        isPrivate: lobby.is_private,
        status: lobby.status,
        currentRound: lobby.current_round,
        totalRounds: lobby.total_rounds,
        votingPointsPerPlayer: lobby.voting_points_per_player,
        createdAt: lobby.created_at,
        players: playersResult.rows.map(p => ({
          userId: p.user_id,
          displayName: p.display_name,
          avatarUrl: p.avatar_url,
          level: p.level,
          isHost: p.user_id === lobby.host_id,
          joinedAt: p.joined_at
        }))
      }
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/lobbies - Create lobby (handled by Socket.io)
router.post('/', async (req, res, next) => {
  try {
    res.status(400).json({
      success: false,
      error: {
        message: 'Use Socket.io to create lobbies',
        socketEvent: 'create-lobby'
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
