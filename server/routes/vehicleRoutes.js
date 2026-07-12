const express = require('express');
const vehicleController = require('../controllers/vehicleController');
const { authenticateJWT, authorizeRoles } = require('../middleware/auth');
const validate = require('../middleware/validate');
const { vehicleCreateSchema, vehicleUpdateSchema } = require('../validators');

const router = express.Router();

router.use(authenticateJWT);

router.get('/', vehicleController.getVehicles);
router.get('/:id', vehicleController.getVehicleById);

// Fleet Manager-only operations for vehicles
router.post('/', authorizeRoles('Fleet Manager'), validate(vehicleCreateSchema), vehicleController.createVehicle);
router.put('/:id', authorizeRoles('Fleet Manager'), validate(vehicleUpdateSchema), vehicleController.updateVehicle);
router.delete('/:id', authorizeRoles('Fleet Manager'), vehicleController.retireVehicle);

module.exports = router;
