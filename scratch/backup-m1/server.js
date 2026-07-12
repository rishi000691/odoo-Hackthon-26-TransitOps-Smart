// Load env variables as early as possible
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const app = require('./app');
const { env } = require('./config/env');

const PORT = env.PORT || 5000;

const server = app.listen(PORT, () => {
  console.log(`===============================================`);
  console.log(` TransitOps Backend Server Running Successfully `);
  console.log(` Port:        ${PORT}`);
  console.log(` Environment: ${env.NODE_ENV}`);
  console.log(`===============================================`);
});

// Handle unhandled promise rejections outside of Express
process.on('unhandledRejection', (err) => {
  console.error('UNHANDLED REJECTION! Shutting down server...');
  console.error(err);
  server.close(() => {
    process.exit(1);
  });
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('UNCAUGHT EXCEPTION! Shutting down server...');
  console.error(err);
  process.exit(1);
});
