const redis = require('redis');
const { createLogger } = require('./logger');
const logger = createLogger('redis');

let client = null;

const connectRedis = async () => {
  if (client) return client;

  client = redis.createClient({
    socket: {
      host: process.env.REDIS_HOST || 'localhost',
      port: process.env.REDIS_PORT || 6379
    },
    password: process.env.REDIS_PASSWORD || undefined
  });

  client.on('error', (err) => {
    logger.error('Redis client error', err);
  });

  client.on('connect', () => {
    logger.info('Redis client connected');
  });

  await client.connect();
  return client;
};

const getRedisClient = async () => {
  if (!client) {
    await connectRedis();
  }
  return client;
};

module.exports = { connectRedis, getRedisClient };
