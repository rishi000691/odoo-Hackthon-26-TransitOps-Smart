require('dotenv').config();
const app = require('./app');
const { pool } = require('./database/db');

const PORT = process.env.PORT || 5000;

const server = app.listen(PORT, () => {
  console.log(`TransitOps API Server is running on port ${PORT}`);
});

// Graceful shutdown
const shutdown = async () => {
  console.log('Shutting down TransitOps server gracefully...');
  server.close(async () => {
    console.log('Express server closed.');
    try {
      await pool.end();
      console.log('Database connection pool ended.');
      process.exit(0);
    } catch (err) {
      console.error('Error closing database connection pool:', err);
      process.exit(1);
    }
  });
};

process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);
