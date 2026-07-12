const authService = require('../services/authService');
const { snakeToCamel, camelToSnake } = require('../utils/casing');
const asyncHandler = require('../utils/asyncHandler');

async function register(req, res) {
  const result = await authService.register(snakeToCamel(req.body));
  return res.status(201).json({
    success: true,
    data: camelToSnake(result),
    message: 'User registered successfully'
  });
}

async function login(req, res) {
  const result = await authService.login(snakeToCamel(req.body));
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Login successful'
  });
}

async function logout(req, res) {
  return res.status(200).json({
    success: true,
    message: 'Logout successful'
  });
}

module.exports = {
  register: asyncHandler(register),
  login: asyncHandler(login),
  logout: asyncHandler(logout)
};
