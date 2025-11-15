require('dotenv').config({ path: '../.env' });
const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const { createLogger } = require('./utils/logger');
const { initDatabase } = require('./utils/database');
const { connectRedis } = require('./utils/redis');

// Import event handlers
const lobbyHandlers = require('./handlers/lobbyHandlers');
const gameHandlers = require('./handlers/gameHandlers');
const chatHandlers = require('./handlers/chatHandlers');
const votingHandlers = require('./handlers/votingHandlers');

const logger = createLogger('multiplayer-server');
const PORT = process.env.MULTIPLAYER_PORT || 3001;

// Initialize Socket.io server
const io = new Server(PORT, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || '*',
    methods: ['GET', 'POST'],
    credentials: true
  },
  pingTimeout: 60000,
  pingInterval: 25000
});

logger.info(`Multiplayer server starting on port ${PORT}`);

// Middleware: Authenticate socket connections
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;

    if (!token) {
      return next(new Error('Authentication token required'));
    }

    // Verify JWT token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Attach user info to socket
    socket.userId = decoded.userId;
    socket.userEmail = decoded.email;

    logger.info(`User authenticated: ${socket.userEmail} (${socket.userId})`);
    next();
  } catch (error) {
    logger.error('Socket authentication failed', error);
    next(new Error('Authentication failed'));
  }
});

// Connection handler
io.on('connection', async (socket) => {
  logger.info(`Client connected: ${socket.id} (User: ${socket.userId})`);

  // Track user connection
  socket.join(`user:${socket.userId}`);

  // Emit connection success
  socket.emit('connected', {
    socketId: socket.id,
    userId: socket.userId,
    timestamp: new Date().toISOString()
  });

  // Register event handlers
  lobbyHandlers(io, socket);
  gameHandlers(io, socket);
  chatHandlers(io, socket);
  votingHandlers(io, socket);

  // Handle disconnection
  socket.on('disconnect', async (reason) => {
    logger.info(`Client disconnected: ${socket.id} (Reason: ${reason})`);

    // Update player status in lobbies
    try {
      // You would typically update the player's status in the database here
      // and notify other players in the same lobby
      socket.rooms.forEach(room => {
        if (room.startsWith('lobby:')) {
          socket.to(room).emit('player-disconnected', {
            userId: socket.userId,
            timestamp: new Date().toISOString()
          });
        }
      });
    } catch (error) {
      logger.error('Error handling disconnect', error);
    }
  });

  // Handle errors
  socket.on('error', (error) => {
    logger.error(`Socket error for ${socket.id}:`, error);
  });
});

// Initialize connections
(async () => {
  try {
    await initDatabase();
    await connectRedis();
    logger.info('Multiplayer server ready');
  } catch (error) {
    logger.error('Failed to initialize server', error);
    process.exit(1);
  }
})();

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully...');
  io.close(() => {
    logger.info('Socket.io server closed');
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down gracefully...');
  io.close(() => {
    logger.info('Socket.io server closed');
    process.exit(0);
  });
});

module.exports = io;
