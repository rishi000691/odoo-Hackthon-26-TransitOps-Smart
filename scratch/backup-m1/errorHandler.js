const { sendError } = require('../utils/response');

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

class AuthError extends AppError {
  constructor(message, details = null, code = 'AUTHENTICATION_ERROR') {
    super(message, 401, code, details);
  }
}

class ForbiddenError extends AppError {
  constructor(message, details = null, code = 'FORBIDDEN_ERROR') {
    super(message, 403, code, details);
  }
}

class NotFoundError extends AppError {
  constructor(message, details = null, code = 'NOT_FOUND_ERROR') {
    super(message, 404, code, details);
  }
}

class ConflictError extends AppError {
  constructor(message, details = null, code = 'CONFLICT_ERROR') {
    super(message, 409, code, details);
  }
}

const errorHandler = (err, req, res, next) => {
  // Always log the full stack trace on the server for diagnostics
  console.error('--- ERROR LOG ---');
  console.error(err);
  console.error('-----------------');

  // If the error is custom AppError
  if (err instanceof AppError) {
    return sendError(res, {
      code: err.code,
      message: err.message,
      details: err.details
    }, err.statusCode);
  }

  // Handle generic JSON parse error
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return sendError(res, {
      code: 'BAD_REQUEST',
      message: 'Invalid JSON payload structure.',
      details: null
    }, 400);
  }

  // Generic/Unexpected errors
  return sendError(res, {
    code: 'INTERNAL_ERROR',
    message: err.message || 'An unexpected internal server error occurred.',
    details: null
  }, 500);
};

module.exports = {
  AppError,
  ValidationError,
  AuthError,
  ForbiddenError,
  NotFoundError,
  ConflictError,
  errorHandler
};
