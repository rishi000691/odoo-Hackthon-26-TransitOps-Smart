const express = require('express');
const logController = require('../controllers/logController');
const { authenticateJWT, authorizeRoles } = require('../middleware/auth');
const validate = require('../middleware/validate');
const { fuelLogCreateSchema, expenseCreateSchema } = require('../validators');

const router = express.Router();

router.use(authenticateJWT);

// Fuel logging endpoints
router.post('/fuel', authorizeRoles('Driver', 'Fleet Manager', 'Financial Analyst'), validate(fuelLogCreateSchema), logController.createFuelLog);
router.get('/fuel/vehicle/:vehicleId', authorizeRoles('Driver', 'Fleet Manager', 'Financial Analyst'), logController.getFuelLogsByVehicle);

// Other expense logging endpoints
router.post('/other', authorizeRoles('Fleet Manager', 'Financial Analyst'), validate(expenseCreateSchema), logController.createExpense);
router.get('/other/vehicle/:vehicleId', authorizeRoles('Driver', 'Fleet Manager', 'Financial Analyst'), logController.getExpensesByVehicle);

module.exports = router;
