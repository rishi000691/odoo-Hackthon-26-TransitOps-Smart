require('express-async-errors');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { env } = require('./config/env');

const authRoutes = require('./routes/authRoutes');
const vehicleRoutes = require('./routes/vehicleRoutes');
const driverRoutes = require('./routes/driverRoutes');
const tripRoutes = require('./routes/tripRoutes');
const maintenanceRoutes = require('./routes/maintenanceRoutes');
const logRoutes = require('./routes/logRoutes');
const reportRoutes = require('./routes/reportRoutes');

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

// Routes mounted under /api/v1 as defined by the specification
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/vehicles', vehicleRoutes);
app.use('/api/v1/drivers', driverRoutes);
app.use('/api/v1/trips', tripRoutes);
app.use('/api/v1/maintenance', maintenanceRoutes);
app.use('/api/v1/expenses', logRoutes);
app.use('/api/v1/reports', reportRoutes);

// Catch-all 404 handler
app.use((req, res, next) => {
  next(new NotFoundError(`Route ${req.method} ${req.originalUrl} not found`, 'ROUTE_NOT_FOUND'));
});

// Centralized error handling middleware
app.use(errorHandler);

module.exports = app;
