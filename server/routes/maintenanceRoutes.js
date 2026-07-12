const express = require('express');
const maintenanceController = require('../controllers/maintenanceController');
const { authenticateJWT, authorizeRoles } = require('../middleware/auth');
const validate = require('../middleware/validate');
const { maintenanceCreateSchema, maintenanceCloseSchema } = require('../validators');

const router = express.Router();

router.use(authenticateJWT);

// Maintenance logs managed by Fleet Manager
router.post('/', authorizeRoles('Fleet Manager'), validate(maintenanceCreateSchema), maintenanceController.createMaintenanceLog);
router.put('/:id/close', authorizeRoles('Fleet Manager'), validate(maintenanceCloseSchema), maintenanceController.closeMaintenanceLog);

module.exports = router;
