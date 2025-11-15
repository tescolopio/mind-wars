-- Seed data for development

-- Insert default badges
INSERT INTO badges (name, description, category, icon, criteria) VALUES
    ('First Victory', 'Win your first game', 'first_victory', '🏆', '{"games_won": 1}'),
    ('3 Day Streak', 'Play for 3 consecutive days', 'streak', '🔥', '{"streak": 3}'),
    ('7 Day Streak', 'Play for 7 consecutive days', 'streak', '🔥🔥', '{"streak": 7}'),
    ('30 Day Streak', 'Play for 30 consecutive days', 'streak', '🔥🔥🔥', '{"streak": 30}'),
    ('Memory Master', 'Win 10 Memory games', 'category_mastery', '🧠', '{"category": "Memory", "wins": 10}'),
    ('Logic Legend', 'Win 10 Logic games', 'category_mastery', '🧩', '{"category": "Logic", "wins": 10}'),
    ('Attention Ace', 'Win 10 Attention games', 'category_mastery', '👁️', '{"category": "Attention", "wins": 10}'),
    ('Spatial Star', 'Win 10 Spatial games', 'category_mastery', '🗺️', '{"category": "Spatial", "wins": 10}'),
    ('Language Lord', 'Win 10 Language games', 'category_mastery', '📚', '{"category": "Language", "wins": 10}'),
    ('Social Butterfly', 'Play 10 games with friends', 'social', '🦋', '{"multiplayer_games": 10}'),
    ('10 Games Played', 'Play 10 games', 'games_played', '🎮', '{"games_played": 10}'),
    ('50 Games Played', 'Play 50 games', 'games_played', '🎮🎮', '{"games_played": 50}'),
    ('100 Games Played', 'Play 100 games', 'games_played', '🎮🎮🎮', '{"games_played": 100}'),
    ('Perfect Score', 'Get a perfect score in any game', 'achievement', '💯', '{"perfect_games": 1}'),
    ('Speed Demon', 'Complete a game in under 30 seconds', 'achievement', '⚡', '{"speed_record": 30000}')
ON CONFLICT DO NOTHING;

-- Create test users (for development only - passwords are all 'password123')
-- Password hash for 'password123' with bcrypt rounds=12
INSERT INTO users (email, password_hash, display_name, avatar_url, level, total_score) VALUES
    ('alice@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqYK8p3.qS', 'Alice', NULL, 5, 2500),
    ('bob@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqYK8p3.qS', 'Bob', NULL, 3, 1200),
    ('charlie@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqYK8p3.qS', 'Charlie', NULL, 7, 4800),
    ('diana@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYqYK8p3.qS', 'Diana', NULL, 2, 800)
ON CONFLICT DO NOTHING;

-- Note: In production, remove these test users or use a different seeding strategy
