require('dotenv').config();

module.exports = {
  schema: 'server/database/schema.prisma',
  migrations: {
    seed: 'node server/database/seed.js',
  },
  datasource: {
    url: process.env.DATABASE_URL,
  },
};
