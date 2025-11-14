const jwt = require('jsonwebtoken');
const { logger } = require('../server');

const JWT_SECRET = process.env.JWT_SECRET;

/**
 * Authentication middleware
 * Verifies JWT token and attaches user to request
 */
const requireAuth = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }
    
    const token = authHeader.substring(7);
    
    const decoded = jwt.verify(token, JWT_SECRET);
    
    if (decoded.type !== 'access') {
      return res.status(401).json({ error: 'Invalid token type' });
    }
    
    req.user = decoded;
    next();
  } catch (error) {
    logger.error('Auth middleware error', { error: error.message });
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    
    return res.status(401).json({ error: 'Invalid token' });
  }
};

/**
 * Role-based authorization middleware
 * @param {string[]} roles - Array of allowed roles
 */
const requireRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Not authenticated' });
    }
    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    
    next();
  };
};

module.exports = requireAuth;
module.exports.requireRole = requireRole;
