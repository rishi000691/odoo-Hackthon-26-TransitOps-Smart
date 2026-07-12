const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const { env } = require('./config/env');
const apiV1Router = require('./routes/api.v1');
const { errorHandler, NotFoundError, AppError } = require('./middleware/errorHandler');

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

// Swagger UI doc stub route
app.get('/api/v1/docs', (req, res) => {
  res.status(200).send('TransitOps API Documentation (V1 Docs Stub)');
});

// A temporary debug endpoint to test custom AppError throws
app.get('/api/v1/test-error', (req, res, next) => {
  next(new AppError('This is a test operational error.', 418, 'TEST_TEAPOT_ERROR', { extra: 'debug information' }));
});

// Mount versioned API routes
app.use('/api/v1', apiV1Router);

// Fallback: Mount versioned API router at root namespace as well for local test-endpoint script compatibility
app.use('/', apiV1Router);

// Catch-all route for undefined routes - forwards a NotFoundError to the error handler
app.use((req, res, next) => {
  next(new NotFoundError(`Resource not found: ${req.method} ${req.originalUrl}`));
});

// Global Error Handler Middleware - registered last
app.use(errorHandler);

module.exports = app;
