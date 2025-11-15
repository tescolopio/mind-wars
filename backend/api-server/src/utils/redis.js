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

// Cache helpers
const setCache = async (key, value, expirySeconds = 3600) => {
  const redisClient = await getRedisClient();
  await redisClient.setEx(key, expirySeconds, JSON.stringify(value));
};

const getCache = async (key) => {
  const redisClient = await getRedisClient();
  const data = await redisClient.get(key);
  return data ? JSON.parse(data) : null;
};

const deleteCache = async (key) => {
  const redisClient = await getRedisClient();
  await redisClient.del(key);
};

// FIX: Use SCAN instead of KEYS for non-blocking iteration (Comment #1)
const deleteCachePattern = async (pattern) => {
  const redisClient = await getRedisClient();
  const keys = [];
  let cursor = '0';

  // Use SCAN instead of KEYS to avoid blocking Redis
  do {
    const result = await redisClient.scan(cursor, {
      MATCH: pattern,
      COUNT: 100
    });
    cursor = result.cursor;
    keys.push(...result.keys);
  } while (cursor !== '0');

  if (keys.length > 0) {
    await redisClient.del(keys);
  }
};

module.exports = {
  connectRedis,
  getRedisClient,
  setCache,
  getCache,
  deleteCache,
  deleteCachePattern
};
