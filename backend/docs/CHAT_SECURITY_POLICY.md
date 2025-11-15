# Chat Message Data Security and Retention Policy

## Overview

This document outlines the security measures, data retention policy, and compliance guidelines for the chat message system in Mind Wars.

## Security Measures

### 1. Encryption of Original Messages

**Implementation:**
- Original chat messages containing profanity are encrypted using AES-256-GCM before storage
- Only encrypted versions are stored in the database when profanity is detected
- Clean messages (without profanity) are stored without encryption
- Encryption key must be set via the `ENCRYPTION_KEY` environment variable (minimum 32 characters)

**Technical Details:**
- Algorithm: AES-256-GCM (Authenticated Encryption)
- Key Derivation: PBKDF2 with SHA-256 (100,000 iterations)
- Each message uses a unique salt and initialization vector (IV)
- Authentication tags ensure data integrity and prevent tampering

**Access Control:**
- Encrypted messages can only be decrypted by authorized moderators/administrators
- Decryption requires both the encryption key and proper authorization

### 2. Row-Level Security (RLS)

**Database Policies:**
- PostgreSQL Row-Level Security is enabled on the `chat_messages` table
- Separate policies control access to original vs. filtered messages
- Moderator role (`chat_moderator`) has elevated access permissions

**Access Levels:**
- **All Users:** Can read filtered messages (public view)
- **Message Authors:** Can insert their own messages
- **Moderators Only:** Can access encrypted original messages, update, and delete messages

**Implementation:**
```sql
-- Enable RLS
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Policies enforce access controls at the database level
CREATE POLICY chat_messages_read_filtered ON chat_messages FOR SELECT USING (true);
```

### 3. Separation of Concerns

**Data Storage Strategy:**
- `filtered_message` column: Contains cleaned text (profanity replaced with asterisks), visible to all
- `message` column: Contains encrypted original only when profanity detected, restricted access
- `flagged_for_review` boolean: Indicates messages requiring moderator review
- `flagged_reason` text: Documents why a message was flagged

## Data Retention Policy

### Retention Periods

1. **Active Chat Messages:**
   - Retained for the duration of the lobby/game session
   - Plus 30 days after lobby completion for moderation review

2. **Flagged Messages:**
   - Retained for 90 days after flagging for moderation and compliance purposes
   - Original encrypted messages retained during this period

3. **Clean Messages:**
   - Retained for 30 days after lobby completion
   - No original message stored (only filtered version, which is identical)

### Automated Cleanup

Implement automated cleanup jobs:

```sql
-- Example cleanup query (to be run by scheduled job)
DELETE FROM chat_messages 
WHERE flagged_for_review = false 
  AND timestamp < NOW() - INTERVAL '30 days';

DELETE FROM chat_messages 
WHERE flagged_for_review = true 
  AND timestamp < NOW() - INTERVAL '90 days';
```

### Data Minimization

- Only store original messages when profanity is detected
- Clean messages do not require duplication of data
- Reduces storage requirements and privacy exposure

## Compliance Guidelines

### GDPR Compliance (European Union)

**Right to Access:**
- Users can request access to their chat messages
- Provide filtered message history to users
- Original encrypted messages only disclosed if legally required

**Right to Erasure (Right to be Forgotten):**
- Users can request deletion of their messages
- Implement user data deletion endpoint
- Exception: Flagged messages may be retained for compliance/safety for the full 90-day period

**Data Processing Basis:**
- Legitimate interest: Maintaining safe online environment
- Contract performance: Providing chat functionality as part of service

**Data Protection Officer (DPO):**
- Designate DPO if processing large volumes of user data
- DPO contact information should be publicly available

### COPPA Compliance (USA - Children's Privacy)

**Age Verification:**
- Verify users are 13+ years old before allowing chat
- Parental consent required for users under 13

**Data Collection:**
- Minimize data collection from children
- No personal information in chat logs beyond user ID

### Content Moderation Requirements

**Illegal Content:**
- Moderators must review flagged messages within 24 hours
- Report illegal content (threats, child exploitation) to authorities
- Maintain audit logs of moderation actions

**Harassment and Abuse:**
- Implement user reporting system
- Document moderation decisions
- Provide appeal process for moderation actions

### Transparency

**Privacy Policy:**
- Clearly disclose that chat messages are logged
- Explain encryption and retention policies
- Inform users about moderator access to flagged content

**Terms of Service:**
- Prohibit harassment, threats, and illegal content
- Specify consequences for policy violations
- Reserve right to review and moderate content

## Access Logs and Auditing

### Audit Trail

Implement logging for:
- All access to encrypted original messages
- Moderation actions (updates, deletions)
- Decryption operations
- Changes to moderator role assignments

### Log Retention

- Audit logs retained for 1 year minimum
- Longer retention may be required by jurisdiction
- Logs must be tamper-proof and include timestamps

### Monitoring

- Regular review of access patterns
- Alerts for suspicious access to encrypted data
- Quarterly security audits

## Environment Configuration

### Required Environment Variables

```bash
# Encryption key for chat messages (32+ characters required)
ENCRYPTION_KEY=your-secure-key-here-minimum-32-characters-long

# Database connection (ensure encrypted in transit)
DATABASE_URL=postgresql://user:password@host:5432/dbname?sslmode=require
```

### Security Best Practices

1. **Key Management:**
   - Store `ENCRYPTION_KEY` in secure vault (e.g., AWS Secrets Manager, Azure Key Vault)
   - Rotate encryption keys annually
   - Implement key versioning for decryption of older messages

2. **Database Security:**
   - Use SSL/TLS for all database connections
   - Restrict database access to application servers only
   - Regular security patches and updates

3. **Application Security:**
   - Input validation on all chat messages
   - Rate limiting to prevent spam
   - HTTPS only for all API communications

## Incident Response

### Data Breach Procedure

1. **Detection:** Identify and contain the breach
2. **Assessment:** Determine scope and affected data
3. **Notification:** Notify affected users within 72 hours (GDPR requirement)
4. **Remediation:** Fix vulnerability and enhance security
5. **Documentation:** Document incident and response actions

### Unauthorized Access

- Immediately revoke moderator access if compromised
- Audit all access logs during suspected breach period
- Reset encryption keys if necessary (requires re-encryption of existing data)
- Notify users if their data may have been accessed

## Regular Reviews

- **Quarterly:** Review data retention compliance
- **Semi-Annually:** Security audit of encryption implementation
- **Annually:** Update privacy policy and terms of service
- **As Needed:** Update in response to new regulations or security threats

## Contact Information

For questions about this policy:
- Technical Issues: Contact development team
- Privacy Concerns: Contact Data Protection Officer
- Security Issues: Contact security team immediately

---

**Document Version:** 1.0
**Last Updated:** November 2025
**Next Review:** February 2026
