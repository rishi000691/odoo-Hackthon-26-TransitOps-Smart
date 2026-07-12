class AppError extends Error {
  constructor(message, statusCode, code = 'INTERNAL_ERROR', details = null) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message, details = null, code = 'VALIDATION_ERROR') {
    super(message, 400, code, details);
  }
}

class BadRequestError extends ValidationError {
  constructor(message, code = 'BAD_REQUEST', details = null) {
    super(message, details, code);
  }
}

class AuthError extends AppError {
  constructor(message = 'Unauthorized access', details = null, code = 'UNAUTHORIZED') {
    super(message, 401, code, details);
  }
}

class UnauthorizedError extends AuthError {
  constructor(message = 'Unauthorized access', code = 'UNAUTHORIZED', details = null) {
    super(message, details, code);
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Permission denied', details = null, code = 'FORBIDDEN') {
    super(message, 403, code, details);
  }
}

class NotFoundError extends AppError {
  constructor(message, details = null, code = 'NOT_FOUND') {
    super(message, 404, code, details);
  }
}

class ConflictError extends AppError {
  constructor(message, details = null, code = 'CONFLICT') {
    super(message, 409, code, details);
  }
}

function errorHandler(err, req, res, next) {
  if (res.headersSent) {
    return next(err);
  }

  console.error("Error Handler Caught:", err);

  // Handle input validation errors from Zod
  if (err.name === 'ZodError' || err.code === 'ZOD_ERROR') {
    const issues = err.issues || err.errors || [];
    const errorDetails = issues.map(e => ({
      field: e.path.join('.'),
      issue: e.message
    }));

    const cleanMessage = issues.length > 0
      ? 'Validation failed: ' + issues.map(e => `${e.path.join('.') || 'body'}: ${e.message}`).join('; ')
      : 'Request validation failed';

    return res.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: cleanMessage,
        details: errorDetails.length > 0 ? errorDetails : null
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
  ValidationError,
  BadRequestError,
  AuthError,
  UnauthorizedError,
  ForbiddenError,
  NotFoundError,
  ConflictError,
  errorHandler
};
