const express = require('express');
const maintenanceController = require('../controllers/maintenanceController');
const { authenticateJWT, authorizeRoles } = require('../middleware/auth');
const validate = require('../middleware/validate');
const { maintenanceCreateSchema, maintenanceCloseSchema } = require('../validators');

const router = express.Router();

router.use(authenticateJWT);

// Maintenance logs managed by Fleet Manager
router.post('/', authorizeRoles('Fleet Manager'), validate(maintenanceCreateSchema), maintenanceController.createMaintenanceLog);

// Supports both POST and PUT for closing maintenance logs to satisfy both PDF specifications and test suites
router.put('/:id/close', authorizeRoles('Fleet Manager'), validate(maintenanceCloseSchema), maintenanceController.closeMaintenanceLog);
router.post('/:id/close', authorizeRoles('Fleet Manager'), validate(maintenanceCloseSchema), maintenanceController.closeMaintenanceLog);

module.exports = router;
