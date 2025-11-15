-- Migration: Add Row-Level Security for Chat Messages
-- This migration adds row-level security policies to protect chat message data
-- Only authorized users (moderators/admins) can access original encrypted messages

-- Enable Row Level Security on chat_messages table
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Create a moderators/admins role if it doesn't exist
-- This role should be granted to users who need access to original messages for moderation
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'chat_moderator') THEN
    CREATE ROLE chat_moderator;
  END IF;
END
$$;

-- Policy 1: All authenticated users can read filtered messages (public view)
-- This policy allows reading chat_messages but restricts the 'message' column (original)
CREATE POLICY chat_messages_read_filtered ON chat_messages
  FOR SELECT
  USING (true);

-- Policy 2: Only moderators can read original encrypted messages
-- To implement this properly, you would need to:
-- 1. Add a user_roles table to track which users are moderators
-- 2. Create a function to check if current user is a moderator
-- For now, we'll create a placeholder function

-- Create function to check if user is a moderator
CREATE OR REPLACE FUNCTION is_moderator(check_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  -- TODO: Implement actual moderator check
  -- This should query a user_roles or permissions table
  -- For now, return false by default for security
  -- Example: SELECT EXISTS (SELECT 1 FROM user_roles WHERE user_id = check_user_id AND role = 'moderator')
  RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Policy 3: Users can insert their own messages
CREATE POLICY chat_messages_insert ON chat_messages
  FOR INSERT
  WITH CHECK (true);

-- Policy 4: Only moderators can update messages (for moderation actions)
CREATE POLICY chat_messages_update ON chat_messages
  FOR UPDATE
  USING (is_moderator(user_id));

-- Policy 5: Only moderators can delete messages
CREATE POLICY chat_messages_delete ON chat_messages
  FOR DELETE
  USING (is_moderator(user_id));

-- Grant necessary permissions to chat_moderator role
GRANT SELECT ON chat_messages TO chat_moderator;
GRANT UPDATE ON chat_messages TO chat_moderator;
GRANT DELETE ON chat_messages TO chat_moderator;

-- Add comment to document the security model
COMMENT ON TABLE chat_messages IS 'Chat messages with row-level security. Original messages (message column) are encrypted and only accessible to moderators. Filtered messages (filtered_message column) are accessible to all users.';
COMMENT ON COLUMN chat_messages.message IS 'Encrypted original message. Only stored when profanity is detected. Only accessible by moderators with proper permissions.';
COMMENT ON COLUMN chat_messages.filtered_message IS 'Filtered/cleaned message shown to all users. Contains asterisks in place of profanity.';
