const jwt = require('jsonwebtoken');
const { UnauthorizedError, ForbiddenError } = require('./errorHandler');
const userRepository = require('../repositories/userRepository');

const JWT_SECRET = process.env.JWT_SECRET || 'transitops_super_secret_jwt_key_123!';

async function authenticateJWT(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new UnauthorizedError('Access token is missing or invalid'));
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    
    const user = await userRepository.findById(payload.userId);

    if (!user || !user.isActive) {
      return next(new UnauthorizedError('User no longer exists or is inactive'));
    }

    req.user = user;
    next();
  } catch (err) {
    return next(new UnauthorizedError('Invalid or expired access token'));
  }
}

function authorizeRoles(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return next(new UnauthorizedError('Authentication required'));
    }

    const userRoleNames = req.user.roles ? req.user.roles.map(ur => ur.role.name) : [];
    
    const hasRole = allowedRoles.some(role => userRoleNames.includes(role));
    if (!hasRole) {
      return next(new ForbiddenError(`Access denied. Roles '${userRoleNames.join(', ')}' are not authorized.`));
    }

    next();
  };
}

module.exports = {
  authenticateJWT,
  authorizeRoles
};
