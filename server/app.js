require('express-async-errors');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { env } = require('./config/env');

const apiV1Router = require('./routes/api.v1');

const { errorHandler, NotFoundError } = require('./middleware/errorHandler');

const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require('./config/swagger');

// Initialize the Express application
const app = express();

// Disable 'x-powered-by' header for security
app.disable('x-powered-by');

// Add Morgan developer logging
if (env.NODE_ENV !== 'test') {
  app.use(morgan('dev'));
}

// Set up CORS configurations
const corsOptions = {
  origin: env.NODE_ENV === 'development' || env.CORS_ORIGIN === '*' ? '*' : env.CORS_ORIGIN,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
};
app.use(cors(corsOptions));

// Parsing body middlewares
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Swagger UI doc route
app.use('/api/v1/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Mount the api.v1 router hierarchy
app.use('/api/v1', apiV1Router);
app.use('/', apiV1Router);

// Catch-all 404 handler
app.use((req, res, next) => {
  next(new NotFoundError(`Route ${req.method} ${req.originalUrl} not found`, 'ROUTE_NOT_FOUND'));
});

// Centralized error handling middleware
app.use(errorHandler);

module.exports = app;
