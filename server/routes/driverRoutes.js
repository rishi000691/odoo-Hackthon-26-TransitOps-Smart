const express = require('express');
const driverController = require('../controllers/driverController');
const { authenticateJWT, authorizeRoles } = require('../middleware/auth');
const validate = require('../middleware/validate');
const { driverCreateSchema, driverUpdateSchema } = require('../validators');

const router = express.Router();

router.use(authenticateJWT);

router.get('/', driverController.getDrivers);
router.get('/:id', driverController.getDriverById);

// Fleet Manager and Safety Officer can manage drivers
router.post('/', authorizeRoles('Fleet Manager', 'Safety Officer'), validate(driverCreateSchema), driverController.createDriver);
router.put('/:id', authorizeRoles('Fleet Manager', 'Safety Officer'), validate(driverUpdateSchema), driverController.updateDriver);
router.delete('/:id', authorizeRoles('Fleet Manager', 'Safety Officer'), driverController.deleteDriver);

module.exports = router;
