/**
 * Example: Integration of Profanity Filter Configuration with Lobby Creation
 * 
 * This file demonstrates how to integrate the configurable profanity filter
 * into the lobby creation and management workflow.
 */

const profanityFilterService = require('../utils/profanityFilter');
const { STRICTNESS_LEVELS } = profanityFilterService;

/**
 * Example: Enhanced lobby creation with profanity filter configuration
 */
function exampleCreateLobbyWithFilter(io, socket) {
  socket.on('create-lobby', async (data, callback) => {
    try {
      const {
        name,
        maxPlayers = 10,
        isPrivate = true,
        totalRounds = 3,
        votingPointsPerPlayer = 10,
        chatStrictness = 'moderate'  // NEW: Optional chat strictness setting
      } = data;

      // ... existing lobby creation code ...
      const lobbyId = 'lobby-123'; // from database

      // Configure profanity filter for this lobby
      const strictnessMap = {
        'strict': STRICTNESS_LEVELS.STRICT,
        'moderate': STRICTNESS_LEVELS.MODERATE,
        'relaxed': STRICTNESS_LEVELS.RELAXED
      };

      profanityFilterService.setConfiguration(lobbyId, {
        strictness: strictnessMap[chatStrictness] || STRICTNESS_LEVELS.MODERATE
      });

      logger.info(`Lobby ${lobbyId} created with ${chatStrictness} chat filtering`);

      callback({
        success: true,
        lobby: { id: lobbyId, /* ... */ }
      });
    } catch (error) {
      logger.error('Create lobby error', error);
      callback({ success: false, error: error.message });
    }
  });
}

/**
 * Example: Cleanup profanity filter configuration when lobby closes
 */
function exampleCloseLobbyWithFilterCleanup(io, socket) {
  socket.on('close-lobby', async (data, callback) => {
    try {
      const { lobbyId } = data;

      // ... existing lobby closure code ...

      // Clean up profanity filter configuration
      profanityFilterService.removeConfiguration(lobbyId);

      logger.info(`Lobby ${lobbyId} closed and filter configuration removed`);

      callback({ success: true });
    } catch (error) {
      logger.error('Close lobby error', error);
      callback({ success: false, error: error.message });
    }
  });
}

/**
 * Example: Update lobby chat strictness dynamically
 */
function exampleUpdateLobbyStrictness(io, socket) {
  socket.on('update-lobby-chat-strictness', async (data, callback) => {
    try {
      const { lobbyId, strictness } = data;

      // Verify user is host...
      // ... host verification code ...

      const strictnessMap = {
        'strict': STRICTNESS_LEVELS.STRICT,
        'moderate': STRICTNESS_LEVELS.MODERATE,
        'relaxed': STRICTNESS_LEVELS.RELAXED
      };

      // Update filter configuration
      profanityFilterService.setConfiguration(lobbyId, {
        strictness: strictnessMap[strictness]
      });

      // Notify all players in lobby
      io.to(`lobby:${lobbyId}`).emit('chat-strictness-updated', {
        strictness
      });

      logger.info(`Lobby ${lobbyId} chat strictness updated to ${strictness}`);

      callback({ success: true });
    } catch (error) {
      logger.error('Update strictness error', error);
      callback({ success: false, error: error.message });
    }
  });
}

/**
 * Example: Add custom blocked word for a specific lobby
 */
function exampleAddCustomBlockedWord(io, socket) {
  socket.on('add-blocked-word', async (data, callback) => {
    try {
      const { lobbyId, word } = data;

      // Verify user is host...
      // ... host verification code ...

      // Add word to lobby's filter
      profanityFilterService.addWordsToContext(lobbyId, word.toLowerCase());

      logger.info(`Word "${word}" added to lobby ${lobbyId} filter`);

      callback({ success: true });
    } catch (error) {
      logger.error('Add blocked word error', error);
      callback({ success: false, error: error.message });
    }
  });
}

/**
 * Example: Remove word from lobby filter (for false positives)
 */
function exampleRemoveBlockedWord(io, socket) {
  socket.on('remove-blocked-word', async (data, callback) => {
    try {
      const { lobbyId, word } = data;

      // Verify user is host...
      // ... host verification code ...

      // Remove word from lobby's filter
      profanityFilterService.removeWordsFromContext(lobbyId, word.toLowerCase());

      logger.info(`Word "${word}" removed from lobby ${lobbyId} filter`);

      callback({ success: true });
    } catch (error) {
      logger.error('Remove blocked word error', error);
      callback({ success: false, error: error.message });
    }
  });
}

/**
 * Example: Frontend Usage
 * 
 * // When creating a lobby
 * socket.emit('create-lobby', {
 *   name: 'Family Game Night',
 *   maxPlayers: 6,
 *   isPrivate: true,
 *   chatStrictness: 'strict'  // or 'moderate', 'relaxed'
 * }, (response) => {
 *   if (response.success) {
 *     console.log('Lobby created with strict chat filtering');
 *   }
 * });
 * 
 * // Update chat strictness during game
 * socket.emit('update-lobby-chat-strictness', {
 *   lobbyId: 'lobby-123',
 *   strictness: 'moderate'
 * }, (response) => {
 *   if (response.success) {
 *     console.log('Chat strictness updated');
 *   }
 * });
 * 
 * // Add custom blocked word
 * socket.emit('add-blocked-word', {
 *   lobbyId: 'lobby-123',
 *   word: 'spoiler'
 * }, (response) => {
 *   if (response.success) {
 *     console.log('Word added to filter');
 *   }
 * });
 */

module.exports = {
  exampleCreateLobbyWithFilter,
  exampleCloseLobbyWithFilterCleanup,
  exampleUpdateLobbyStrictness,
  exampleAddCustomBlockedWord,
  exampleRemoveBlockedWord
};
