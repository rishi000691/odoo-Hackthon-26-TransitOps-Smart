const path = require('path');
const fs = require('fs');

const serverEnvPath = path.join(__dirname, '../.env');
const rootEnvPath = path.join(__dirname, '../../.env');

if (fs.existsSync(serverEnvPath)) {
  require('dotenv').config({ path: serverEnvPath });
} else {
  require('dotenv').config({ path: rootEnvPath });
}

const requiredEnvVars = ['JWT_SECRET', 'JWT_EXPIRES_IN', 'DATABASE_URL'];

for (const key of requiredEnvVars) {
  if (!process.env[key]) {
    throw new Error(`BOOTSTRAP ERROR: Environment variable "${key}" is missing but required.`);
  }
}

const env = {
  PORT: process.env.PORT ? parseInt(process.env.PORT, 10) : 5000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  JWT_SECRET: process.env.JWT_SECRET,
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN,
  DATABASE_URL: process.env.DATABASE_URL,
  CORS_ORIGIN: process.env.CORS_ORIGIN || '*'
};

module.exports = { env };
