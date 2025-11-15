require('dotenv').config({ path: '../.env' });
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: process.env.POSTGRES_PORT || 5432,
  database: process.env.POSTGRES_DB || 'mindwars',
  user: process.env.POSTGRES_USER || 'mindwars',
  password: process.env.POSTGRES_PASSWORD,
});

async function runMigration() {
  const client = await pool.connect();

  try {
    console.log('Running database migration...');

    // Read and execute schema.sql
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');

    console.log('Creating database schema...');
    await client.query(schema);

    console.log('✓ Schema created successfully');

    // Optionally run seed data (only in development)
    if (process.env.NODE_ENV !== 'production') {
      console.log('Seeding database with test data...');
      const seedPath = path.join(__dirname, 'seed.sql');
      const seed = fs.readFileSync(seedPath, 'utf8');
      await client.query(seed);
      console.log('✓ Seed data inserted successfully');
    }

    console.log('Migration completed successfully!');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

runMigration();
