const express = require('express');
const { query } = require('../utils/database');
const { authenticate, optionalAuth } = require('../middleware/auth');
const { standardLimiter } = require('../middleware/rateLimit');
const { getCache, setCache } = require('../utils/redis');

const router = express.Router();

router.use(optionalAuth);
router.use(standardLimiter);

// GET /api/leaderboard/weekly - Get weekly leaderboard
router.get('/weekly', async (req, res, next) => {
  try {
    const { limit = 100 } = req.query;
    const cacheKey = `leaderboard:weekly:${limit}`;

    // Try to get from cache
    let leaderboard = await getCache(cacheKey);

    if (!leaderboard) {
      // Calculate weekly leaderboard (Monday to Sunday)
      const result = await query(
        `SELECT
           u.id, u.display_name, u.avatar_url, u.level,
           SUM(gr.score) as weekly_score,
           COUNT(gr.id) as games_played,
           ROW_NUMBER() OVER (ORDER BY SUM(gr.score) DESC) as rank
         FROM users u
         JOIN game_results gr ON u.id = gr.user_id
         WHERE gr.created_at >= date_trunc('week', CURRENT_DATE)
         GROUP BY u.id, u.display_name, u.avatar_url, u.level
         ORDER BY weekly_score DESC
         LIMIT $1`,
        [limit]
      );

      leaderboard = result.rows.map(row => ({
        rank: parseInt(row.rank),
        userId: row.id,
        displayName: row.display_name,
        avatarUrl: row.avatar_url,
        level: row.level,
        score: parseInt(row.weekly_score),
        gamesPlayed: parseInt(row.games_played)
      }));

      // Cache for 5 minutes
      await setCache(cacheKey, leaderboard, 300);
    }

    // Find current user's rank if authenticated
    let currentUserRank = null;
    if (req.user) {
      const userRankResult = await query(
        `WITH ranked_users AS (
           SELECT u.id, SUM(gr.score) as weekly_score,
                  ROW_NUMBER() OVER (ORDER BY SUM(gr.score) DESC) as rank
           FROM users u
           JOIN game_results gr ON u.id = gr.user_id
           WHERE gr.created_at >= date_trunc('week', CURRENT_DATE)
           GROUP BY u.id
         )
         SELECT rank, weekly_score FROM ranked_users WHERE id = $1`,
        [req.user.id]
      );

      if (userRankResult.rows.length > 0) {
        currentUserRank = {
          rank: parseInt(userRankResult.rows[0].rank),
          score: parseInt(userRankResult.rows[0].weekly_score)
        };
      }
    }

    res.json({
      success: true,
      data: {
        leaderboard,
        currentUserRank,
        period: 'weekly',
        updatedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/leaderboard/all-time - Get all-time leaderboard
router.get('/all-time', async (req, res, next) => {
  try {
    const { limit = 100 } = req.query;
    const cacheKey = `leaderboard:all-time:${limit}`;

    // Try to get from cache
    let leaderboard = await getCache(cacheKey);

    if (!leaderboard) {
      const result = await query(
        `SELECT
           u.id, u.display_name, u.avatar_url, u.level, u.total_score,
           u.games_played, u.games_won,
           ROW_NUMBER() OVER (ORDER BY u.total_score DESC) as rank
         FROM users u
         WHERE u.total_score > 0
         ORDER BY u.total_score DESC
         LIMIT $1`,
        [limit]
      );

      leaderboard = result.rows.map(row => ({
        rank: parseInt(row.rank),
        userId: row.id,
        displayName: row.display_name,
        avatarUrl: row.avatar_url,
        level: row.level,
        score: parseInt(row.total_score),
        gamesPlayed: parseInt(row.games_played),
        gamesWon: parseInt(row.games_won)
      }));

      // Cache for 10 minutes
      await setCache(cacheKey, leaderboard, 600);
    }

    // Find current user's rank if authenticated
    let currentUserRank = null;
    if (req.user) {
      const userRankResult = await query(
        `WITH ranked_users AS (
           SELECT id, total_score,
                  ROW_NUMBER() OVER (ORDER BY total_score DESC) as rank
           FROM users WHERE total_score > 0
         )
         SELECT rank, total_score FROM ranked_users WHERE id = $1`,
        [req.user.id]
      );

      if (userRankResult.rows.length > 0) {
        currentUserRank = {
          rank: parseInt(userRankResult.rows[0].rank),
          score: parseInt(userRankResult.rows[0].total_score)
        };
      }
    }

    res.json({
      success: true,
      data: {
        leaderboard,
        currentUserRank,
        period: 'all-time',
        updatedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
