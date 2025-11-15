const { query } = require('../utils/database');
const { createLogger } = require('../utils/logger');

const logger = createLogger('chat-handlers');

// Simple profanity filter (you should use a better one in production)
const profanityFilter = (message) => {
  const badWords = ['badword1', 'badword2']; // Add your list
  let filtered = message;
  badWords.forEach(word => {
    const regex = new RegExp(word, 'gi');
    filtered = filtered.replace(regex, '***');
  });
  return filtered;
};

module.exports = (io, socket) => {
  // Send chat message
  socket.on('chat-message', async (data, callback) => {
    try {
      const { lobbyId, message } = data;

      if (!message || message.trim().length === 0) {
        return callback({ success: false, error: 'Message cannot be empty' });
      }

      if (message.length > 500) {
        return callback({ success: false, error: 'Message too long (max 500 characters)' });
      }

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // Get user info
      const userResult = await query(
        `SELECT display_name, avatar_url FROM users WHERE id = $1`,
        [socket.userId]
      );

      const user = userResult.rows[0];

      // Apply profanity filter
      const filteredMessage = profanityFilter(message);

      // Broadcast message to lobby
      io.to(`lobby:${lobbyId}`).emit('chat-message', {
        id: Date.now().toString(),
        userId: socket.userId,
        displayName: user.display_name,
        avatarUrl: user.avatar_url,
        message: filteredMessage,
        timestamp: new Date().toISOString()
      });

      logger.info(`Chat message in lobby ${lobbyId} from user ${socket.userId}`);

      callback({ success: true });
    } catch (error) {
      logger.error('Chat message error', error);
      callback({ success: false, error: error.message });
    }
  });

  // Send emoji reaction
  socket.on('emoji-reaction', async (data, callback) => {
    try {
      const { lobbyId, emoji } = data;

      const allowedEmojis = ['👍', '❤️', '😂', '🎉', '🔥', '👏', '😮', '🤔'];

      if (!allowedEmojis.includes(emoji)) {
        return callback({ success: false, error: 'Invalid emoji' });
      }

      // Verify player is in lobby
      const playerResult = await query(
        `SELECT id FROM lobby_players WHERE lobby_id = $1 AND user_id = $2`,
        [lobbyId, socket.userId]
      );

      if (playerResult.rows.length === 0) {
        return callback({ success: false, error: 'Player not in lobby' });
      }

      // Get user info
      const userResult = await query(
        `SELECT display_name FROM users WHERE id = $1`,
        [socket.userId]
      );

      const user = userResult.rows[0];

      // Broadcast reaction to lobby
      io.to(`lobby:${lobbyId}`).emit('emoji-reaction', {
        userId: socket.userId,
        displayName: user.display_name,
        emoji,
        timestamp: new Date().toISOString()
      });

      logger.info(`Emoji reaction ${emoji} in lobby ${lobbyId} from user ${socket.userId}`);

      callback({ success: true });
    } catch (error) {
      logger.error('Emoji reaction error', error);
      callback({ success: false, error: error.message });
    }
  });
};
