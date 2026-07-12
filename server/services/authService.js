const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/userRepository');
const { prisma } = require('../database/db');
const { BadRequestError, UnauthorizedError } = require('../middleware/errorHandler');

const JWT_SECRET = process.env.JWT_SECRET || 'transitops_super_secret_jwt_key_123!';

async function register({ email, password, firstName, lastName, roleName }) {
  const existingUser = await userRepository.findByEmail(email);

  if (existingUser) {
    throw new BadRequestError('Email address is already in use', 'EMAIL_ALREADY_IN_USE');
  }

  const role = await prisma.role.findUnique({
    where: { name: roleName }
  });

  if (!role) {
    throw new BadRequestError(`Role '${roleName}' does not exist`, 'ROLE_NOT_FOUND');
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const user = await userRepository.create({
    email,
    passwordHash,
    firstName,
    lastName
  }, role.id);

  const { passwordHash: _, ...userWithoutPassword } = user;
  return userWithoutPassword;
}

async function login({ email, password }) {
  const user = await userRepository.findByEmail(email);

  if (!user || !user.isActive) {
    throw new UnauthorizedError('Invalid email or password', 'INVALID_CREDENTIALS');
  }

  const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

  if (!isPasswordValid) {
    throw new UnauthorizedError('Invalid email or password', 'INVALID_CREDENTIALS');
  }

  const roleNames = user.roles.map(ur => ur.role.name);

  const token = jwt.sign(
    { userId: user.id, email: user.email, roles: roleNames },
    JWT_SECRET,
    { expiresIn: '24h' }
  );

  return {
    token,
    user: {
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      roles: roleNames
    }
  };
}

module.exports = {
  register,
  login
};
