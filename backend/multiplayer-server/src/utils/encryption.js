/**
 * Encryption Service
 * Provides encryption and decryption for sensitive data like original chat messages
 * Uses AES-256-GCM for authenticated encryption
 */

const crypto = require('crypto');
const { createLogger } = require('./logger');

const logger = createLogger('encryption');

// Algorithm to use for encryption
const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16; // For AES, this is always 16
const AUTH_TAG_LENGTH = 16;
const SALT_LENGTH = 64;
const KEY_LENGTH = 32;

class EncryptionService {
  constructor() {
    // Get encryption key from environment variable
    this.masterKey = process.env.ENCRYPTION_KEY;
    
    if (!this.masterKey) {
      logger.warn('ENCRYPTION_KEY environment variable not set. Encryption will be disabled.');
      this.enabled = false;
    } else if (this.masterKey.length < 32) {
      logger.warn('ENCRYPTION_KEY is too short. Should be at least 32 characters. Encryption will be disabled.');
      this.enabled = false;
    } else {
      this.enabled = true;
    }
  }

  /**
   * Derives a key from the master key and salt using PBKDF2
   * @param {string} salt - Salt for key derivation
   * @returns {Buffer} - Derived key
   */
  deriveKey(salt) {
    return crypto.pbkdf2Sync(
      this.masterKey,
      salt,
      100000, // iterations
      KEY_LENGTH,
      'sha256'
    );
  }

  /**
   * Encrypts a string value
   * @param {string} plaintext - The text to encrypt
   * @returns {string|null} - Encrypted text in format: salt:iv:authTag:ciphertext (all base64), or null if encryption disabled
   */
  encrypt(plaintext) {
    if (!this.enabled) {
      logger.debug('Encryption disabled, returning null');
      return null;
    }

    if (!plaintext || typeof plaintext !== 'string') {
      return null;
    }

    try {
      // Generate random salt and IV
      const salt = crypto.randomBytes(SALT_LENGTH);
      const iv = crypto.randomBytes(IV_LENGTH);
      
      // Derive key from master key and salt
      const key = this.deriveKey(salt);
      
      // Create cipher
      const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
      
      // Encrypt the plaintext
      let encrypted = cipher.update(plaintext, 'utf8', 'base64');
      encrypted += cipher.final('base64');
      
      // Get authentication tag
      const authTag = cipher.getAuthTag();
      
      // Return format: salt:iv:authTag:ciphertext (all base64 encoded)
      return `${salt.toString('base64')}:${iv.toString('base64')}:${authTag.toString('base64')}:${encrypted}`;
    } catch (error) {
      logger.error('Encryption error', error);
      return null;
    }
  }

  /**
   * Decrypts an encrypted string
   * @param {string} encryptedData - The encrypted data in format: salt:iv:authTag:ciphertext
   * @returns {string|null} - Decrypted text, or null if decryption fails or encryption disabled
   */
  decrypt(encryptedData) {
    if (!this.enabled) {
      logger.debug('Encryption disabled, cannot decrypt');
      return null;
    }

    if (!encryptedData || typeof encryptedData !== 'string') {
      return null;
    }

    try {
      // Split the encrypted data
      const parts = encryptedData.split(':');
      if (parts.length !== 4) {
        logger.error('Invalid encrypted data format');
        return null;
      }

      const [saltB64, ivB64, authTagB64, encrypted] = parts;
      
      // Decode from base64
      const salt = Buffer.from(saltB64, 'base64');
      const iv = Buffer.from(ivB64, 'base64');
      const authTag = Buffer.from(authTagB64, 'base64');
      
      // Derive key from master key and salt
      const key = this.deriveKey(salt);
      
      // Create decipher
      const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
      decipher.setAuthTag(authTag);
      
      // Decrypt the ciphertext
      let decrypted = decipher.update(encrypted, 'base64', 'utf8');
      decrypted += decipher.final('utf8');
      
      return decrypted;
    } catch (error) {
      logger.error('Decryption error', error);
      return null;
    }
  }

  /**
   * Check if encryption is enabled
   * @returns {boolean} - True if encryption is enabled
   */
  isEnabled() {
    return this.enabled;
  }
}

// Export a singleton instance
module.exports = new EncryptionService();
