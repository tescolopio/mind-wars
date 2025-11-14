const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const router = express.Router();

const { pool, redisClient, logger } = require('../server');

// JWT configuration
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_ACCESS_EXPIRY = process.env.JWT_ACCESS_EXPIRY || '15m';
const JWT_REFRESH_EXPIRY = process.env.JWT_REFRESH_EXPIRY || '7d';

// ====== Helper Functions ======

const generateAccessToken = (userId, role) => {
  return jwt.sign({ userId, role, type: 'access' }, JWT_SECRET, {
    expiresIn: JWT_ACCESS_EXPIRY
  });
};

const generateRefreshToken = (userId) => {
  return jwt.sign({ userId, type: 'refresh' }, JWT_SECRET, {
    expiresIn: JWT_REFRESH_EXPIRY
  });
};

const hashPassword = async (password) => {
  return await bcrypt.hash(password, 12);
};

const comparePassword = async (password, hash) => {
  return await bcrypt.compare(password, hash);
};

// ====== Validation Middleware ======

const validateRegistration = [
  body('username').isLength({ min: 3, max: 50 }).trim().escape(),
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/),
  body('invitationCode').optional().isLength({ min: 1 })
];

const validateLogin = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty()
];

// ====== Routes ======

/**
 * POST /auth/register
 * Register a new user
 */
router.post('/register', validateRegistration, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { username, email, password, invitationCode, displayName } = req.body;

    // Check if invitation code is valid (if provided)
    if (invitationCode) {
      const codeResult = await pool.query(
        'SELECT * FROM invitation_codes WHERE code = $1 AND (expires_at IS NULL OR expires_at > NOW())',
        [invitationCode]
      );

      if (codeResult.rows.length === 0) {
        return res.status(400).json({ error: 'Invalid or expired invitation code' });
      }

      const code = codeResult.rows[0];
      if (code.current_uses >= code.max_uses) {
        return res.status(400).json({ error: 'Invitation code has reached its usage limit' });
      }
    }

    // Check if user already exists
    const existingUser = await pool.query(
      'SELECT * FROM users WHERE email = $1 OR username = $2',
      [email, username]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const passwordHash = await hashPassword(password);

    // Create user
    const result = await pool.query(
      `INSERT INTO users (username, email, password_hash, display_name, invitation_code)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, username, email, display_name, role, created_at`,
      [username, email, passwordHash, displayName || username, invitationCode]
    );

    const user = result.rows[0];

    // Update invitation code usage
    if (invitationCode) {
      await pool.query(
        'UPDATE invitation_codes SET current_uses = current_uses + 1 WHERE code = $1',
        [invitationCode]
      );
    }

    // Generate tokens
    const accessToken = generateAccessToken(user.id, user.role);
    const refreshToken = generateRefreshToken(user.id);

    // Store refresh token in database
    await pool.query(
      `INSERT INTO sessions (user_id, refresh_token, expires_at)
       VALUES ($1, $2, NOW() + INTERVAL '7 days')`,
      [user.id, refreshToken]
    );

    logger.info('User registered', { userId: user.id, email: user.email });

    res.status(201).json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        displayName: user.display_name,
        role: user.role
      },
      accessToken,
      refreshToken
    });
  } catch (error) {
    logger.error('Registration error', { error: error.message });
    res.status(500).json({ error: 'Registration failed' });
  }
});

/**
 * POST /auth/login
 * Login user
 */
router.post('/login', validateLogin, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body;

    // Check rate limiting
    const loginAttempts = await redisClient.get(`login_attempts:${email}`);
    if (loginAttempts && parseInt(loginAttempts) >= 5) {
      return res.status(429).json({ error: 'Too many login attempts. Please try again later.' });
    }

    // Find user
    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1 AND is_active = true',
      [email]
    );

    if (result.rows.length === 0) {
      await redisClient.setEx(`login_attempts:${email}`, 900, (parseInt(loginAttempts) || 0) + 1);
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];

    // Verify password
    const isValidPassword = await comparePassword(password, user.password_hash);
    if (!isValidPassword) {
      await redisClient.setEx(`login_attempts:${email}`, 900, (parseInt(loginAttempts) || 0) + 1);
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Reset login attempts
    await redisClient.del(`login_attempts:${email}`);

    // Generate tokens
    const accessToken = generateAccessToken(user.id, user.role);
    const refreshToken = generateRefreshToken(user.id);

    // Store refresh token
    await pool.query(
      `INSERT INTO sessions (user_id, refresh_token, expires_at)
       VALUES ($1, $2, NOW() + INTERVAL '7 days')`,
      [user.id, refreshToken]
    );

    logger.info('User logged in', { userId: user.id, email: user.email });

    res.json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        displayName: user.display_name,
        avatarId: user.avatar_id,
        role: user.role
      },
      accessToken,
      refreshToken
    });
  } catch (error) {
    logger.error('Login error', { error: error.message });
    res.status(500).json({ error: 'Login failed' });
  }
});

/**
 * POST /auth/refresh
 * Refresh access token
 */
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token required' });
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, JWT_SECRET);
    
    if (decoded.type !== 'refresh') {
      return res.status(401).json({ error: 'Invalid token type' });
    }

    // Check if token exists in database
    const sessionResult = await pool.query(
      'SELECT * FROM sessions WHERE user_id = $1 AND refresh_token = $2 AND expires_at > NOW()',
      [decoded.userId, refreshToken]
    );

    if (sessionResult.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid or expired refresh token' });
    }

    // Get user
    const userResult = await pool.query(
      'SELECT id, role FROM users WHERE id = $1 AND is_active = true',
      [decoded.userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(401).json({ error: 'User not found' });
    }

    const user = userResult.rows[0];

    // Generate new access token
    const newAccessToken = generateAccessToken(user.id, user.role);

    res.json({ accessToken: newAccessToken });
  } catch (error) {
    logger.error('Token refresh error', { error: error.message });
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});

/**
 * POST /auth/logout
 * Logout user
 */
router.post('/logout', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (refreshToken) {
      // Delete session from database
      await pool.query('DELETE FROM sessions WHERE refresh_token = $1', [refreshToken]);
    }

    logger.info('User logged out');
    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    logger.error('Logout error', { error: error.message });
    res.status(500).json({ error: 'Logout failed' });
  }
});

module.exports = router;
