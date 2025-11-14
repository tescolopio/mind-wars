const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { Pool } = require('pg');
const redis = require('redis');
const winston = require('winston');
const promClient = require('prom-client');

// Load environment variables
require('dotenv').config();

// Initialize Express app
const app = express();
const PORT = process.env.PORT || 3000;

// ====== Logging Setup ======
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

// ====== Metrics Setup ======
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const httpRequestTotal = new promClient.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

// ====== Database Setup ======
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'mindwars_beta',
  user: process.env.DB_USER || 'mindwars',
  password: process.env.DB_PASSWORD,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

pool.on('error', (err) => {
  logger.error('Unexpected database error', { error: err.message });
});

// ====== Redis Setup ======
const redisClient = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379
  },
  password: process.env.REDIS_PASSWORD
});

redisClient.on('error', (err) => {
  logger.error('Redis error', { error: err.message });
});

redisClient.connect().catch(err => {
  logger.error('Failed to connect to Redis', { error: err.message });
});

// ====== Middleware ======
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const route = req.route ? req.route.path : req.path;
    
    httpRequestDuration.labels(req.method, route, res.statusCode).observe(duration);
    httpRequestTotal.labels(req.method, route, res.statusCode).inc();
    
    logger.info('Request', {
      method: req.method,
      path: req.path,
      statusCode: res.statusCode,
      duration: `${duration}s`,
      ip: req.ip
    });
  });
  
  next();
});

// Rate limiting
const limiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: process.env.API_RATE_LIMIT || 100,
  message: 'Too many requests from this IP, please try again later.'
});

app.use('/api/', limiter);

// ====== Health Check ======
app.get('/health', async (req, res) => {
  try {
    // Check database
    await pool.query('SELECT 1');
    
    // Check Redis
    await redisClient.ping();
    
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        database: 'up',
        redis: 'up'
      }
    });
  } catch (error) {
    logger.error('Health check failed', { error: error.message });
    res.status(503).json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: error.message
    });
  }
});

// ====== Metrics Endpoint ======
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// ====== Import Routes ======
const authRoutes = require('./routes/auth');
const lobbyRoutes = require('./routes/lobbies');
const gameRoutes = require('./routes/games');
const leaderboardRoutes = require('./routes/leaderboards');
const syncRoutes = require('./routes/sync');
const analyticsRoutes = require('./routes/analytics');
const userRoutes = require('./routes/users');

// ====== Route Registration ======
app.use('/auth', authRoutes);
app.use('/lobbies', lobbyRoutes);
app.use('/games', gameRoutes);
app.use('/leaderboard', leaderboardRoutes);
app.use('/sync', syncRoutes);
app.use('/analytics', analyticsRoutes);
app.use('/users', userRoutes);

// ====== Error Handling ======
app.use((err, req, res, next) => {
  logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
    path: req.path
  });
  
  res.status(err.statusCode || 500).json({
    error: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// ====== Start Server ======
app.listen(PORT, () => {
  logger.info(`API Server running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV}`);
  logger.info(`Database: ${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}`);
  logger.info(`Redis: ${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`);
});

// Export for testing
module.exports = { app, pool, redisClient, logger };
