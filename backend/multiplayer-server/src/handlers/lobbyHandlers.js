const { v4: uuidv4 } = require('uuid');
const { query } = require('../utils/database');
const { createLogger } = require('../utils/logger');

const logger = createLogger('lobby-handlers');

// Generate memorable lobby code
function generateLobbyCode() {
  const adjectives = ['SWIFT', 'BRIGHT', 'SMART', 'QUICK', 'SHARP', 'WISE', 'BOLD', 'KEEN'];
  const nouns = ['MIND', 'BRAIN', 'THINK', 'LOGIC', 'SPARK', 'FLASH', 'NOVA', 'APEX'];
  const adj = adjectives[Math.floor(Math.random() * adjectives.length)];
  const noun = nouns[Math.floor(Math.random() * nouns.length)];
  const num = Math.floor(Math.random() * 100);
  return `${adj}${noun}${num}`;
}

module.exports = (io, socket) => {
  // Create lobby
  socket.on('create-lobby', async (data, callback) => {
    try {
      const {
        name,
        maxPlayers = 10,
        isPrivate = true,
        totalRounds = 3,
        votingPointsPerPlayer = 10
      } = data;

      const lobbyId = uuidv4();
      const code = generateLobbyCode();

      // Create lobby in database
      await query(
        `INSERT INTO lobbies (id, code, name, host_id, max_players, is_private, status,
                              current_round, total_rounds, voting_points_per_player, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, 'waiting', 1, $7, $8, NOW())`,
        [lobbyId, code, name, socket.userId, maxPlayers, isPrivate, totalRounds, votingPointsPerPlayer]
      );

      // Add host as player
      await query(
        `INSERT INTO lobby_players (lobby_id, user_id, joined_at)
         VALUES ($1, $2, NOW())`,
        [lobbyId, socket.userId]
      );

      // Join lobby room
      socket.join(`lobby:${lobbyId}`);

      logger.info(`Lobby created: ${code} by user ${socket.userId}`);

      callback({
        success: true,
        lobby: {
          id: lobbyId,
          code,
          name,
          hostId: socket.userId,
          maxPlayers,
          isPrivate,
          status: 'waiting',
          currentRound: 1,
          totalRounds,
          votingPointsPerPlayer,
          skipRule: 'majority',  // Default skip rule
          skipTimeLimitHours: 24  // Default time limit
        }
      });
    } catch (error) {
      logger.error('Create lobby error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Join lobby
  socket.on('join-lobby', async (data, callback) => {
    try {
      const { lobbyId } = data;

      // Check if lobby exists and has space
      const lobbyResult = await query(
        `SELECT l.*,
                (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) as player_count
         FROM lobbies l WHERE l.id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      const lobby = lobbyResult.rows[0];

      if (parseInt(lobby.player_count) >= lobby.max_players) {
        return callback({ success: false, error: 'Lobby is full' });
      }

      if (lobby.status !== 'waiting') {
        return callback({ success: false, error: 'Lobby has already started' });
      }

      // Check if user already in lobby
      const existingPlayer = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (existingPlayer.rows.length > 0) {
        socket.join(`lobby:${lobbyId}`);
        return callback({ success: true, message: 'Already in lobby' });
      }

      // Add player to lobby
      await query(
        `INSERT INTO lobby_players (lobby_id, user_id, joined_at)
         VALUES ($1, $2, NOW())`,
        [lobbyId, socket.userId]
      );

      // Join lobby room
      socket.join(`lobby:${lobbyId}`);

      // Get user info
      const userResult = await query(
        `SELECT display_name, avatar_url, level FROM users WHERE id = $1`,
        [socket.userId]
      );

      const user = userResult.rows[0];

      // Notify other players
      socket.to(`lobby:${lobbyId}`).emit('player-joined', {
        userId: socket.userId,
        displayName: user.display_name,
        avatarUrl: user.avatar_url,
        level: user.level,
        timestamp: new Date().toISOString()
      });

      logger.info(`User ${socket.userId} joined lobby ${lobbyId}`);

      callback({ success: true, message: 'Joined lobby successfully' });
    } catch (error) {
      logger.error('Join lobby error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Join lobby by code
  socket.on('join-lobby-by-code', async (data, callback) => {
    try {
      const { code } = data;

      // Find lobby by code
      const lobbyResult = await query(
        `SELECT l.*,
                (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) as player_count
         FROM lobbies l WHERE l.code = $1`,
        [code.toUpperCase()]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found with that code' });
      }

      const lobby = lobbyResult.rows[0];

      // Use join-lobby logic
      socket.emit('join-lobby', { lobbyId: lobby.id }, callback);
    } catch (error) {
      logger.error('Join lobby by code error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Leave lobby
  socket.on('leave-lobby', async (data, callback) => {
    try {
      const { lobbyId } = data;

      // Remove player from lobby
      await query(
        `DELETE FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      // Leave lobby room
      socket.leave(`lobby:${lobbyId}`);

      // Notify other players
      socket.to(`lobby:${lobbyId}`).emit('player-left', {
        userId: socket.userId,
        timestamp: new Date().toISOString()
      });

      logger.info(`User ${socket.userId} left lobby ${lobbyId}`);

      callback({ success: true, message: 'Left lobby successfully' });
    } catch (error) {
      logger.error('Leave lobby error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Kick player (host only)
  socket.on('kick-player', async (data, callback) => {
    try {
      const { lobbyId, userId } = data;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can kick players' });
      }

      // Remove player
      await query(
        `DELETE FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, userId]
      );

      // Notify kicked player
      io.to(`user:${userId}`).emit('kicked-from-lobby', {
        lobbyId,
        reason: 'Kicked by host',
        timestamp: new Date().toISOString()
      });

      // Notify other players
      socket.to(`lobby:${lobbyId}`).emit('player-kicked', {
        userId,
        timestamp: new Date().toISOString()
      });

      logger.info(`User ${userId} kicked from lobby ${lobbyId} by host ${socket.userId}`);

      callback({ success: true, message: 'Player kicked successfully' });
    } catch (error) {
      logger.error('Kick player error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Transfer host (host only)
  socket.on('transfer-host', async (data, callback) => {
    try {
      const { lobbyId, newHostId } = data;

      // Verify requester is current host
      const lobbyResult = await query(
        `SELECT host_id FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can transfer host role' });
      }

      // Update host
      await query(
        `UPDATE lobbies SET host_id = $1 WHERE id = $2`,
        [newHostId, lobbyId]
      );

      // Notify all players
      io.to(`lobby:${lobbyId}`).emit('host-transferred', {
        oldHostId: socket.userId,
        newHostId,
        timestamp: new Date().toISOString()
      });

      logger.info(`Host transferred in lobby ${lobbyId}: ${socket.userId} -> ${newHostId}`);

      callback({ success: true, message: 'Host transferred successfully' });
    } catch (error) {
      logger.error('Transfer host error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Close lobby (host only)
  socket.on('close-lobby', async (data, callback) => {
    try {
      const { lobbyId } = data;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can close lobby' });
      }

      // Update lobby status
      await query(
        `UPDATE lobbies SET status = 'closed' WHERE id = $1`,
        [lobbyId]
      );

      // Notify all players
      io.to(`lobby:${lobbyId}`).emit('lobby-closed', {
        lobbyId,
        timestamp: new Date().toISOString()
      });

      logger.info(`Lobby ${lobbyId} closed by host ${socket.userId}`);

      callback({ success: true, message: 'Lobby closed successfully' });
    } catch (error) {
      logger.error('Close lobby error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Update lobby settings (host only)
  socket.on('update-lobby-settings', async (settings, callback) => {
    try {
      const {
        lobbyId,
        maxPlayers,
        totalRounds,
        votingPointsPerPlayer,
        skipRule,
        skipTimeLimitHours
      } = settings;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can update settings' });
      }

      // Validate skip rule if provided
      if (skipRule && !['majority', 'unanimous', 'time_based'].includes(skipRule)) {
        return callback({ success: false, error: 'Invalid skip rule. Must be majority, unanimous, or time_based' });
      }

      // Validate skip time limit if provided
      if (skipTimeLimitHours !== undefined && (skipTimeLimitHours < 1 || skipTimeLimitHours > 72)) {
        return callback({ success: false, error: 'Skip time limit must be between 1 and 72 hours' });
      }

      // Update settings
      const updates = [];
      const values = [];
      let paramCount = 1;

      if (maxPlayers) {
        updates.push(`max_players = $${paramCount++}`);
        values.push(maxPlayers);
      }

      if (totalRounds) {
        updates.push(`total_rounds = $${paramCount++}`);
        values.push(totalRounds);
      }

      if (votingPointsPerPlayer) {
        updates.push(`voting_points_per_player = $${paramCount++}`);
        values.push(votingPointsPerPlayer);
      }

      if (skipRule) {
        updates.push(`skip_rule = $${paramCount++}`);
        values.push(skipRule);
      }

      if (skipTimeLimitHours !== undefined) {
        updates.push(`skip_time_limit_hours = $${paramCount++}`);
        values.push(skipTimeLimitHours);
      }

      values.push(lobbyId);

      if (updates.length > 0) {
        await query(
          `UPDATE lobbies SET ${updates.join(', ')} WHERE id = $${paramCount}`,
          values
        );
      }

      // Notify all players
      socket.to(`lobby:${lobbyId}`).emit('lobby-settings-updated', {
        maxPlayers,
        totalRounds,
        votingPointsPerPlayer,
        skipRule,
        skipTimeLimitHours,
        timestamp: new Date().toISOString()
      });

      logger.info(`Lobby ${lobbyId} settings updated by host ${socket.userId}`, {
        skipRule,
        skipTimeLimitHours
      });

      callback({ success: true, message: 'Settings updated successfully' });
    } catch (error) {
      logger.error('Update lobby settings error', error);
      callback({ success: false, error: error.message });
    }
  });

  // List lobbies
  socket.on('list-lobbies', async (data, callback) => {
    try {
      const { status = 'waiting', limit = 20 } = data;

      const result = await query(
        `SELECT l.*, u.display_name as host_name,
                (SELECT COUNT(*) FROM lobby_players WHERE lobby_id = l.id) as player_count
         FROM lobbies l
         JOIN users u ON l.host_id = u.id
         WHERE l.is_private = false AND l.status = $1
         ORDER BY l.created_at DESC
         LIMIT $2`,
        [status, limit]
      );

      const lobbies = result.rows.map(lobby => ({
        id: lobby.id,
        code: lobby.code,
        name: lobby.name,
        hostName: lobby.host_name,
        maxPlayers: lobby.max_players,
        playerCount: parseInt(lobby.player_count),
        status: lobby.status,
        createdAt: lobby.created_at,
        skipRule: lobby.skip_rule || 'majority',
        skipTimeLimitHours: lobby.skip_time_limit_hours || 24
      }));

      callback({ success: true, lobbies });
    } catch (error) {
      logger.error('List lobbies error', error);
      callback({ success: false, error: error.message });
    }
  });
};
