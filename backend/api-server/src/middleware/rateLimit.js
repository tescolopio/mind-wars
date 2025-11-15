const rateLimit = require('express-rate-limit');

const createRateLimiter = (windowMs, max) => {
  return rateLimit({
    windowMs: windowMs || parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 900000, // 15 minutes
    max: max || parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
    message: {
      success: false,
      error: {
        message: 'Too many requests, please try again later',
        statusCode: 429
      }
    },
    standardHeaders: true,
    legacyHeaders: false
  });
};

// Strict rate limiter for auth endpoints
const authLimiter = createRateLimiter(900000, 5); // 5 requests per 15 minutes

// Standard rate limiter
const standardLimiter = createRateLimiter(900000, 100); // 100 requests per 15 minutes

module.exports = { createRateLimiter, authLimiter, standardLimiter };
