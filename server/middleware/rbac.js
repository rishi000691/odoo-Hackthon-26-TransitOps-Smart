const { ForbiddenError, AuthError } = require('./errorHandler');

function authorize(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return next(new AuthError('Authentication required.', null, 'UNAUTHORIZED'));
    }

    const userRoleNames = req.user.roles ? req.user.roles.map(ur => ur.role.name) : [];
    
    const hasRole = allowedRoles.some(role => userRoleNames.includes(role));
    if (!hasRole) {
      return next(new ForbiddenError(
        `Access denied. Roles '${userRoleNames.join(', ')}' are not authorized to access this resource.`,
        null,
        'FORBIDDEN'
      ));
    }

    next();
  };
}

module.exports = {
  authorize,
  authorizeRoles: authorize // Alias for compatibility with Rishi's routes
};
