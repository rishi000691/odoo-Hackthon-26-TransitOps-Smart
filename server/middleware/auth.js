const jwt = require('jsonwebtoken');
const { AuthError } = require('./errorHandler');
const userRepository = require('../repositories/userRepository');
const { authorize } = require('./rbac');

const JWT_SECRET = process.env.JWT_SECRET || 'transitops_super_secret_jwt_key_123!';

async function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new AuthError('Access token is missing or invalid.', null, 'UNAUTHORIZED'));
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    
    const userId = payload.userId || payload.id;
    const user = await userRepository.findById(userId);

    if (!user || !user.isActive) {
      return next(new AuthError('User no longer exists or is inactive.', null, 'UNAUTHORIZED'));
    }

    req.user = user;
    next();
  } catch (err) {
    return next(new AuthError('Invalid or expired access token.', null, 'UNAUTHORIZED'));
  }
}

module.exports = {
  authenticate,
  authenticateJWT: authenticate,
  authorizeRoles: authorize
};
