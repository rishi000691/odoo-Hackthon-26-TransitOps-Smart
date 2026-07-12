const authService = require('../services/authService');

async function register(req, res) {
  const result = await authService.register(req.body);
  return res.status(201).json({
    success: true,
    data: result,
    message: 'User registered successfully'
  });
}

async function login(req, res) {
  const result = await authService.login(req.body);
  return res.status(200).json({
    success: true,
    data: result,
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
  register,
  login,
  logout
};
