const { query } = require('../utils/database');
const { createLogger } = require('../utils/logger');

const logger = createLogger('game-handlers');

module.exports = (io, socket) => {
  // Start game (host only)
  socket.on('start-game', async (data, callback) => {
    try {
      const { lobbyId } = data;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id, status FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      const lobby = lobbyResult.rows[0];

      if (lobby.host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can start game' });
      }

      if (lobby.status !== 'waiting') {
        return callback({ success: false, error: 'Game already started' });
      }

      // Update lobby status
      await query(
        `UPDATE lobbies SET status = 'playing', started_at = NOW() WHERE id = $1`,
        [lobbyId]
      );

      // Notify all players
      io.to(`lobby:${lobbyId}`).emit('game-started', {
        lobbyId,
        timestamp: new Date().toISOString()
      });

      logger.info(`Game started in lobby ${lobbyId} by host ${socket.userId}`);

      callback({ success: true, message: 'Game started successfully' });
    } catch (error) {
      logger.error('Start game error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Make turn
  socket.on('make-turn', async (data, callback) => {
    try {
      const { lobbyId, gameId, turnData } = data;

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // Save turn (you might want to add more validation here)
      // For now, just acknowledge the turn

      // Notify other players
      socket.to(`lobby:${lobbyId}`).emit('turn-made', {
        lobbyId,
        gameId,
        userId: socket.userId,
        timestamp: new Date().toISOString()
      });

      logger.info(`Turn made in lobby ${lobbyId} by user ${socket.userId}`);

      callback({ success: true, message: 'Turn submitted successfully' });
    } catch (error) {
      logger.error('Make turn error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Submit game result
  socket.on('submit-game-result', async (data, callback) => {
    try {
      const { lobbyId, gameId, score, timeTaken } = data;

      // This would typically be handled by the REST API
      // But we acknowledge it here for real-time updates

      // Notify other players
      socket.to(`lobby:${lobbyId}`).emit('game-result-submitted', {
        userId: socket.userId,
        gameId,
        score,
        timestamp: new Date().toISOString()
      });

      logger.info(`Game result submitted in lobby ${lobbyId} by user ${socket.userId}`);

      callback({ success: true, message: 'Result submitted successfully' });
    } catch (error) {
      logger.error('Submit game result error', error);
      callback({ success: false, error: error.message });
    }
  });
};
