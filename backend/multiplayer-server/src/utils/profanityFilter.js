/**
 * Profanity Filter Service
 * Uses bad-words library for content moderation in chat messages
 */

const Filter = require('bad-words');

class ProfanityFilterService {
  constructor() {
    this.filter = new Filter();

    // Add custom words if needed
    // this.filter.addWords('customword1', 'customword2');

    // Remove words that might be OK in certain contexts (Scunthorpe problem)
    // this.filter.removeWords('word1', 'word2');
  }

  /**
   * Filter a message and return filtered version with metadata
   * @param {string} message - The message to filter
   * @returns {object} - Object with filtered message and metadata
   */
  filterMessage(message) {
    if (!message || typeof message !== 'string') {
      return {
        filtered: '',
        hasProfanity: false,
        originalLength: 0,
      };
    }

    const hasProfanity = this.filter.isProfane(message);

    return {
      filtered: hasProfanity ? this.filter.clean(message) : message,
      hasProfanity,
      originalLength: message.length,
    };
  }

  /**
   * Check if a message contains profanity without filtering
   * @param {string} message - The message to check
   * @returns {boolean} - True if message contains profanity
   */
  isProfane(message) {
    if (!message || typeof message !== 'string') {
      return false;
    }
    return this.filter.isProfane(message);
  }

  /**
   * Clean a message (replace profanity with asterisks)
   * @param {string} message - The message to clean
   * @returns {string} - Cleaned message
   */
  clean(message) {
    if (!message || typeof message !== 'string') {
      return '';
    }
    return this.filter.clean(message);
  }

  /**
   * Add custom words to the filter
   * @param {...string} words - Words to add to the filter
   */
  addWords(...words) {
    this.filter.addWords(...words);
  }

  /**
   * Remove words from the filter (for false positives)
   * @param {...string} words - Words to remove from the filter
   */
  removeWords(...words) {
    this.filter.removeWords(...words);
  }
}

// Export a singleton instance
module.exports = new ProfanityFilterService();
