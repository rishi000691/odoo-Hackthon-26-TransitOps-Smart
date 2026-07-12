class AppError extends Error {
  constructor(message, statusCode, code = 'INTERNAL_ERROR', details = null) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    Error.captureStackTrace(this, this.constructor);
  }
}

class BadRequestError extends AppError {
  constructor(message, code = 'BAD_REQUEST', details = null) {
    super(message, 400, code, details);
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized access', code = 'UNAUTHORIZED', details = null) {
    super(message, 401, code, details);
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Permission denied', code = 'FORBIDDEN', details = null) {
    super(message, 403, code, details);
  }
}

class NotFoundError extends AppError {
  constructor(message, code = 'NOT_FOUND', details = null) {
    super(message, 404, code, details);
  }
}

function errorHandler(err, req, res, next) {
  if (res.headersSent) {
    return next(err);
  }

  console.error("Error Handler Caught:", err);

  if (err.name === 'ZodError') {
    return res.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Request validation failed',
        details: err.errors.map(e => ({
          field: e.path.join('.'),
          issue: e.message
        }))
      }
    });
  }

  const statusCode = err.statusCode || 500;
  return res.status(statusCode).json({
    success: false,
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: err.message || 'An unexpected error occurred',
      details: err.details || null
    }
  });
}

module.exports = {
  AppError,
  BadRequestError,
  UnauthorizedError,
  ForbiddenError,
  NotFoundError,
  errorHandler
};
