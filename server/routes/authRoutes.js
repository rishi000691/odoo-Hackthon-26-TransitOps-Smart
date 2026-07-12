const express = require('express');
const authController = require('../controllers/authController');
const { authenticateJWT } = require('../middleware/auth');
const validate = require('../middleware/validate');
const { registerSchema, loginSchema } = require('../validators');

const router = express.Router();

router.post('/register', validate(registerSchema), authController.register);
router.post('/login', validate(loginSchema), authController.login);
router.post('/logout', authenticateJWT, authController.logout);

module.exports = router;
