const { v4: uuidv4 } = require('uuid');
const { query } = require('../utils/database');
const { createLogger } = require('../utils/logger');

const logger = createLogger('voting-handlers');

module.exports = (io, socket) => {
  // Start voting (host only)
  socket.on('start-voting', async (data, callback) => {
    try {
      const { lobbyId } = data;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id, voting_points_per_player FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      const lobby = lobbyResult.rows[0];

      if (lobby.host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can start voting' });
      }

      const votingId = uuidv4();

      // Create voting session
      await query(
        `INSERT INTO voting_sessions (id, lobby_id, status, points_per_player, started_at)
         VALUES ($1, $2, 'active', $3, NOW())`,
        [votingId, lobbyId, lobby.voting_points_per_player]
      );

      // Notify all players
      io.to(`lobby:${lobbyId}`).emit('voting-started', {
        votingId,
        pointsPerPlayer: lobby.voting_points_per_player,
        timestamp: new Date().toISOString()
      });

      logger.info(`Voting started in lobby ${lobbyId} by host ${socket.userId}`);

      callback({
        success: true,
        votingId,
        pointsPerPlayer: lobby.voting_points_per_player
      });
    } catch (error) {
      logger.error('Start voting error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Vote for game
  socket.on('vote-game', async (data, callback) => {
    try {
      const { lobbyId, votingId, gameId, points } = data;

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // Verify voting session is active
      const votingResult = await query(
        `SELECT status, points_per_player FROM voting_sessions WHERE id = $1 AND lobby_id = $2`,
        [votingId, lobbyId]
      );

      if (votingResult.rows.length === 0) {
        return callback({ success: false, error: 'Voting session not found' });
      }

      if (votingResult.rows[0].status !== 'active') {
        return callback({ success: false, error: 'Voting session is not active' });
      }

      // Check if user has already voted for this game
      const existingVote = await query(
        `SELECT points FROM votes WHERE voting_id = $1 AND user_id = $2 AND game_id = $3`,
        [votingId, socket.userId, gameId]
      );

      if (existingVote.rows.length > 0) {
        // Update existing vote
        await query(
          `UPDATE votes SET points = $1 WHERE voting_id = $2 AND user_id = $3 AND game_id = $4`,
          [points, votingId, socket.userId, gameId]
        );
      } else {
        // Insert new vote
        await query(
          `INSERT INTO votes (voting_id, user_id, game_id, points, created_at)
           VALUES ($1, $2, $3, $4, NOW())`,
          [votingId, socket.userId, gameId, points]
        );
      }

      // Get total votes for this game
      const totalResult = await query(
        `SELECT SUM(points) as total FROM votes WHERE voting_id = $1 AND game_id = $2`,
        [votingId, gameId]
      );

      const totalVotes = parseInt(totalResult.rows[0].total) || 0;

      // Notify all players
      socket.to(`lobby:${lobbyId}`).emit('vote-cast', {
        userId: socket.userId,
        gameId,
        points,
        totalVotes,
        timestamp: new Date().toISOString()
      });

      logger.info(`Vote cast in lobby ${lobbyId} by user ${socket.userId}: ${points} points for ${gameId}`);

      callback({ success: true, totalVotes });
    } catch (error) {
      logger.error('Vote game error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Remove vote
  socket.on('remove-vote', async (data, callback) => {
    try {
      const { lobbyId, votingId, gameId } = data;

      // Delete vote
      await query(
        `DELETE FROM votes WHERE voting_id = $1 AND user_id = $2 AND game_id = $3`,
        [votingId, socket.userId, gameId]
      );

      // Get updated total
      const totalResult = await query(
        `SELECT SUM(points) as total FROM votes WHERE voting_id = $1 AND game_id = $2`,
        [votingId, gameId]
      );

      const totalVotes = parseInt(totalResult.rows[0].total) || 0;

      // Notify all players
      socket.to(`lobby:${lobbyId}`).emit('vote-removed', {
        userId: socket.userId,
        gameId,
        totalVotes,
        timestamp: new Date().toISOString()
      });

      logger.info(`Vote removed in lobby ${lobbyId} by user ${socket.userId} for ${gameId}`);

      callback({ success: true, totalVotes });
    } catch (error) {
      logger.error('Remove vote error', error);
      callback({ success: false, error: error.message });
    }
  });

  // End voting (host only)
  socket.on('end-voting', async (data, callback) => {
    try {
      const { lobbyId, votingId } = data;

      // Verify requester is host
      const lobbyResult = await query(
        `SELECT host_id FROM lobbies WHERE id = $1`,
        [lobbyId]
      );

      if (lobbyResult.rows.length === 0) {
        return callback({ success: false, error: 'Lobby not found' });
      }

      if (lobbyResult.rows[0].host_id !== socket.userId) {
        return callback({ success: false, error: 'Only host can end voting' });
      }

      // Update voting session
      await query(
        `UPDATE voting_sessions SET status = 'completed', ended_at = NOW() WHERE id = $1`,
        [votingId]
      );

      // Get voting results
      const results = await query(
        `SELECT game_id, SUM(points) as total_votes
         FROM votes WHERE voting_id = $1
         GROUP BY game_id
         ORDER BY total_votes DESC`,
        [votingId]
      );

      const votingResults = results.rows.map(r => ({
        gameId: r.game_id,
        totalVotes: parseInt(r.total_votes)
      }));

      // Notify all players
      io.to(`lobby:${lobbyId}`).emit('voting-ended', {
        votingId,
        results: votingResults,
        timestamp: new Date().toISOString()
      });

      logger.info(`Voting ended in lobby ${lobbyId} by host ${socket.userId}`);

      callback({ success: true, results: votingResults });
    } catch (error) {
      logger.error('End voting error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Vote to skip (any player)
  socket.on('vote-skip', async (data, callback) => {
    try {
      const { lobbyId } = data;

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // For simplicity, just notify other players
      // In production, you'd track votes and automatically skip when majority reached

      socket.to(`lobby:${lobbyId}`).emit('skip-vote-cast', {
        userId: socket.userId,
        timestamp: new Date().toISOString()
      });

      logger.info(`Skip vote cast in lobby ${lobbyId} by user ${socket.userId}`);

      callback({ success: true });
    } catch (error) {
      logger.error('Vote skip error', error);
      callback({ success: false, error: error.message });
    }
  });
};
