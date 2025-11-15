# Chat Message Encryption Setup

## Overview

The chat system uses AES-256-GCM encryption to protect original messages that contain profanity. This document provides setup instructions for the encryption system.

## Prerequisites

- Node.js environment with `crypto` module (built-in)
- PostgreSQL database
- Environment configuration capability

## Configuration

### 1. Generate Encryption Key

Generate a secure encryption key using one of these methods:

**Option A: Using Node.js**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

**Option B: Using OpenSSL**
```bash
openssl rand -hex 32
```

**Option C: Using /dev/urandom (Linux/Mac)**
```bash
head -c 32 /dev/urandom | base64
```

### 2. Set Environment Variable

Add the generated key to your environment configuration:

**For Development (.env file):**
```bash
ENCRYPTION_KEY=your-generated-key-here-minimum-32-characters
```

**For Production (secure secret management):**
- AWS: Use AWS Secrets Manager or Parameter Store
- Azure: Use Azure Key Vault
- GCP: Use Secret Manager
- Kubernetes: Use Secrets with encryption at rest

### 3. Security Requirements

**Encryption Key:**
- Minimum length: 32 characters
- Recommended: 64 hexadecimal characters (32 bytes)
- Must be kept secret and never committed to version control
- Should be rotated annually

**Storage:**
- Never store in code or configuration files that are committed
- Use secure secret management services in production
- Restrict access to authorized personnel only
- Maintain backup of key in secure offline location

## How It Works

### Encryption Process

1. User sends a chat message
2. Message is checked for profanity
3. If profanity detected:
   - Generate unique salt and IV (Initialization Vector)
   - Derive encryption key using PBKDF2
   - Encrypt original message with AES-256-GCM
   - Store encrypted message with salt, IV, and auth tag
4. If no profanity:
   - Store message as-is (no encryption needed)
5. Always broadcast only the filtered message to users

### Data Flow

```
User Input → Profanity Check → Encryption (if needed) → Database Storage
                                    ↓
                            Filtered Message → Broadcast to Users
```

### Storage Format

Encrypted messages are stored in the format:
```
salt:iv:authTag:ciphertext
```

All components are base64-encoded for safe text storage.

## Usage in Code

### Encrypting a Message

```javascript
const encryptionService = require('./utils/encryption');

// Encrypt a message
const encryptedMessage = encryptionService.encrypt('original message text');
// Returns: "base64salt:base64iv:base64tag:base64ciphertext" or null if disabled
```

### Decrypting a Message

```javascript
const encryptionService = require('./utils/encryption');

// Decrypt a message (moderators only)
const originalMessage = encryptionService.decrypt(encryptedMessage);
// Returns: "original message text" or null if error/disabled
```

### Checking If Encryption Is Enabled

```javascript
const encryptionService = require('./utils/encryption');

if (encryptionService.isEnabled()) {
  console.log('Encryption is enabled and working');
} else {
  console.warn('Encryption is disabled - ENCRYPTION_KEY not set or invalid');
}
```

## Database Migration

Run the row-level security migration to add access controls:

```bash
psql -d your_database -f backend/database/migrations/001_add_chat_rls.sql
```

This migration:
- Enables row-level security on chat_messages table
- Creates moderator role with elevated permissions
- Adds policies to control data access
- Documents the security model

## Testing

### Test Encryption Service

Create a test file to verify encryption is working:

```javascript
const encryptionService = require('./src/utils/encryption');

// Test encryption
const original = 'Test message with sensitive content';
console.log('Original:', original);

const encrypted = encryptionService.encrypt(original);
console.log('Encrypted:', encrypted);

const decrypted = encryptionService.decrypt(encrypted);
console.log('Decrypted:', decrypted);

console.log('Match:', original === decrypted ? '✓' : '✗');
```

Run the test:
```bash
node test-encryption.js
```

Expected output:
```
Original: Test message with sensitive content
Encrypted: [long base64 string with colons]
Decrypted: Test message with sensitive content
Match: ✓
```

## Troubleshooting

### Issue: "Encryption disabled" warning

**Cause:** `ENCRYPTION_KEY` environment variable not set or too short

**Solution:** 
1. Generate a secure key (see Configuration section)
2. Add to environment variables
3. Restart the application

### Issue: Decryption fails

**Cause:** 
- Incorrect encryption key
- Corrupted encrypted data
- Format mismatch

**Solution:**
1. Verify `ENCRYPTION_KEY` matches the key used for encryption
2. Check encrypted data format (should have 4 colon-separated parts)
3. Check application logs for detailed error messages

### Issue: Performance concerns

**Encryption Impact:**
- Encryption adds ~1-2ms per message
- Key derivation (PBKDF2) is intentionally slow for security
- Impact is minimal for typical chat usage

**Optimization:**
- Only encrypted when profanity is detected (most messages unaffected)
- Consider caching derived keys if performance critical

## Security Best Practices

1. **Key Rotation:**
   - Rotate encryption key annually
   - Plan for decrypting old messages with old keys
   - Implement key versioning system

2. **Access Control:**
   - Limit access to encryption key
   - Monitor access to encrypted messages
   - Use separate keys per environment (dev/staging/prod)

3. **Backup:**
   - Securely backup encryption keys
   - Store backups offline in secure location
   - Test backup recovery process

4. **Monitoring:**
   - Log encryption/decryption operations (but not the data)
   - Alert on unusual access patterns
   - Regular security audits

## Additional Resources

- [CHAT_SECURITY_POLICY.md](./CHAT_SECURITY_POLICY.md) - Complete security and compliance documentation
- [AES-GCM Documentation](https://csrc.nist.gov/publications/detail/sp/800-38d/final)
- [PBKDF2 Specification](https://tools.ietf.org/html/rfc2898)

## Support

For questions or issues:
- Security concerns: Contact security team immediately
- Implementation questions: Contact development team
- Key management: Contact DevOps/infrastructure team
