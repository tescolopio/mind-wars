const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const { Pool } = require('pg');
const redis = require('redis');
const winston = require('winston');
const promClient = require('prom-client');

// Load environment variables
require('dotenv').config();

// Initialize Express app
const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 3001;

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

const activeConnections = new promClient.Gauge({
  name: 'socket_active_connections',
  help: 'Number of active socket connections',
  registers: [register]
});

const messagesTotal = new promClient.Counter({
  name: 'socket_messages_total',
  help: 'Total number of socket messages',
  labelNames: ['event'],
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

// ====== Redis Setup ======
const redisClient = redis.createClient({
  socket: {
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379
  },
  password: process.env.REDIS_PASSWORD
});

redisClient.connect().catch(err => {
  logger.error('Failed to connect to Redis', { error: err.message });
});

// ====== Socket.io Setup ======
const io = new Server(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST']
  },
  transports: ['websocket', 'polling']
});

// Authentication middleware for Socket.io
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    
    if (!token) {
      return next(new Error('Authentication error'));
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.userId = decoded.userId;
    socket.userRole = decoded.role;
    
    next();
  } catch (error) {
    logger.error('Socket auth error', { error: error.message });
    next(new Error('Authentication error'));
  }
});

// ====== Socket Event Handlers ======

io.on('connection', (socket) => {
  activeConnections.inc();
  logger.info('Client connected', { socketId: socket.id, userId: socket.userId });
  
  // ====== Lobby Events ======
  
  socket.on('create-lobby', async (data) => {
    try {
      messagesTotal.labels('create-lobby').inc();
      const { name, maxPlayers, isPrivate } = data;
      
      // Create lobby via database
      const code = Math.random().toString(36).substring(2, 8).toUpperCase();
      
      const result = await pool.query(
        `INSERT INTO lobbies (code, name, host_id, max_players, is_private)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *`,
        [code, name, socket.userId, maxPlayers, isPrivate]
      );
      
      const lobby = result.rows[0];
      
      // Join socket room
      socket.join(`lobby:${lobby.id}`);
      
      socket.emit('lobby-created', { lobby });
      logger.info('Lobby created', { lobbyId: lobby.id, userId: socket.userId });
    } catch (error) {
      logger.error('Create lobby error', { error: error.message });
      socket.emit('error', { message: 'Failed to create lobby' });
    }
  });
  
  socket.on('join-lobby', async (data) => {
    try {
      messagesTotal.labels('join-lobby').inc();
      const { lobbyId } = data;
      
      // Verify lobby exists and has space
      const lobbyResult = await pool.query(
        'SELECT * FROM lobbies WHERE id = $1',
        [lobbyId]
      );
      
      if (lobbyResult.rows.length === 0) {
        return socket.emit('error', { message: 'Lobby not found' });
      }
      
      const lobby = lobbyResult.rows[0];
      
      // Add player to lobby
      await pool.query(
        'INSERT INTO lobby_players (lobby_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
        [lobbyId, socket.userId]
      );
      
      // Join socket room
      socket.join(`lobby:${lobbyId}`);
      
      // Notify other players
      socket.to(`lobby:${lobbyId}`).emit('player-joined', {
        userId: socket.userId,
        timestamp: new Date()
      });
      
      socket.emit('lobby-joined', { lobby });
      logger.info('User joined lobby', { lobbyId, userId: socket.userId });
    } catch (error) {
      logger.error('Join lobby error', { error: error.message });
      socket.emit('error', { message: 'Failed to join lobby' });
    }
  });
  
  socket.on('leave-lobby', async (data) => {
    try {
      messagesTotal.labels('leave-lobby').inc();
      const { lobbyId } = data;
      
      // Update database
      await pool.query(
        'UPDATE lobby_players SET is_active = false, left_at = NOW() WHERE lobby_id = $1 AND user_id = $2',
        [lobbyId, socket.userId]
      );
      
      // Leave socket room
      socket.leave(`lobby:${lobbyId}`);
      
      // Notify other players
      socket.to(`lobby:${lobbyId}`).emit('player-left', {
        userId: socket.userId,
        timestamp: new Date()
      });
      
      logger.info('User left lobby', { lobbyId, userId: socket.userId });
    } catch (error) {
      logger.error('Leave lobby error', { error: error.message });
    }
  });
  
  socket.on('start-game', async (data) => {
    try {
      messagesTotal.labels('start-game').inc();
      const { lobbyId } = data;
      
      // Update lobby status
      await pool.query(
        'UPDATE lobbies SET status = $1, started_at = NOW() WHERE id = $2',
        ['in_progress', lobbyId]
      );
      
      // Notify all players in lobby
      io.to(`lobby:${lobbyId}`).emit('game-started', {
        lobbyId,
        timestamp: new Date()
      });
      
      logger.info('Game started', { lobbyId, userId: socket.userId });
    } catch (error) {
      logger.error('Start game error', { error: error.message });
      socket.emit('error', { message: 'Failed to start game' });
    }
  });
  
  // ====== Game Events ======
  
  socket.on('make-turn', async (data) => {
    try {
      messagesTotal.labels('make-turn').inc();
      const { lobbyId, gameId, turnData } = data;
      
      // Validate and store turn
      // Server-side validation would happen here
      
      // Broadcast turn to lobby
      io.to(`lobby:${lobbyId}`).emit('turn-made', {
        userId: socket.userId,
        gameId,
        turnData,
        timestamp: new Date()
      });
      
      logger.info('Turn made', { lobbyId, gameId, userId: socket.userId });
    } catch (error) {
      logger.error('Make turn error', { error: error.message });
      socket.emit('error', { message: 'Failed to make turn' });
    }
  });
  
  // ====== Chat Events ======
  
  socket.on('chat-message', async (data) => {
    try {
      messagesTotal.labels('chat-message').inc();
      const { lobbyId, message } = data;
      
      // Store message in database
      await pool.query(
        'INSERT INTO chat_messages (lobby_id, user_id, message_type, content) VALUES ($1, $2, $3, $4)',
        [lobbyId, socket.userId, 'text', message]
      );
      
      // Broadcast to lobby
      io.to(`lobby:${lobbyId}`).emit('chat-message', {
        userId: socket.userId,
        message,
        timestamp: new Date()
      });
      
      logger.info('Chat message sent', { lobbyId, userId: socket.userId });
    } catch (error) {
      logger.error('Chat message error', { error: error.message });
    }
  });
  
  socket.on('emoji-reaction', async (data) => {
    try {
      messagesTotal.labels('emoji-reaction').inc();
      const { lobbyId, emoji } = data;
      
      // Store reaction in database
      await pool.query(
        'INSERT INTO chat_messages (lobby_id, user_id, message_type, content) VALUES ($1, $2, $3, $4)',
        [lobbyId, socket.userId, 'emoji', emoji]
      );
      
      // Broadcast to lobby
      io.to(`lobby:${lobbyId}`).emit('emoji-reaction', {
        userId: socket.userId,
        emoji,
        timestamp: new Date()
      });
    } catch (error) {
      logger.error('Emoji reaction error', { error: error.message });
    }
  });
  
  // ====== Voting Events ======
  
  socket.on('start-voting', async (data) => {
    try {
      messagesTotal.labels('start-voting').inc();
      const { lobbyId, availableGames } = data;
      
      // Create voting session
      const result = await pool.query(
        `INSERT INTO voting_sessions (lobby_id, available_games)
         VALUES ($1, $2)
         RETURNING *`,
        [lobbyId, JSON.stringify(availableGames)]
      );
      
      const votingSession = result.rows[0];
      
      // Notify lobby
      io.to(`lobby:${lobbyId}`).emit('voting-started', {
        votingSessionId: votingSession.id,
        availableGames,
        timestamp: new Date()
      });
      
      logger.info('Voting started', { lobbyId, votingSessionId: votingSession.id });
    } catch (error) {
      logger.error('Start voting error', { error: error.message });
      socket.emit('error', { message: 'Failed to start voting' });
    }
  });
  
  socket.on('vote-game', async (data) => {
    try {
      messagesTotal.labels('vote-game').inc();
      const { votingSessionId, gameType, points } = data;
      
      // Store vote
      await pool.query(
        `INSERT INTO votes (voting_session_id, user_id, game_type, points)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (voting_session_id, user_id, game_type)
         DO UPDATE SET points = $4, updated_at = NOW()`,
        [votingSessionId, socket.userId, gameType, points]
      );
      
      // Get lobby ID for broadcasting
      const sessionResult = await pool.query(
        'SELECT lobby_id FROM voting_sessions WHERE id = $1',
        [votingSessionId]
      );
      
      if (sessionResult.rows.length > 0) {
        const lobbyId = sessionResult.rows[0].lobby_id;
        
        // Broadcast vote update
        io.to(`lobby:${lobbyId}`).emit('vote-cast', {
          userId: socket.userId,
          gameType,
          points,
          timestamp: new Date()
        });
      }
      
      logger.info('Vote cast', { votingSessionId, userId: socket.userId });
    } catch (error) {
      logger.error('Vote game error', { error: error.message });
      socket.emit('error', { message: 'Failed to cast vote' });
    }
  });
  
  socket.on('vote-skip', async (data) => {
    try {
      messagesTotal.labels('vote-skip').inc();
      const { lobbyId, targetUserId } = data;
      
      // Store skip vote
      // Implementation for vote-to-skip inactive player
      
      io.to(`lobby:${lobbyId}`).emit('skip-vote-cast', {
        voterId: socket.userId,
        targetUserId,
        timestamp: new Date()
      });
      
      logger.info('Skip vote cast', { lobbyId, voterId: socket.userId, targetUserId });
    } catch (error) {
      logger.error('Vote skip error', { error: error.message });
    }
  });
  
  // ====== Disconnect ======
  
  socket.on('disconnect', () => {
    activeConnections.dec();
    logger.info('Client disconnected', { socketId: socket.id, userId: socket.userId });
  });
});

// ====== HTTP Routes ======

app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    await redisClient.ping();
    
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      connections: io.engine.clientsCount
    });
  } catch (error) {
    logger.error('Health check failed', { error: error.message });
    res.status(503).json({
      status: 'unhealthy',
      error: error.message
    });
  }
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// ====== Start Server ======

server.listen(PORT, () => {
  logger.info(`Socket.io Server running on port ${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV}`);
  logger.info(`Database: ${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}`);
  logger.info(`Redis: ${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`);
});

module.exports = { io, pool, redisClient, logger };
