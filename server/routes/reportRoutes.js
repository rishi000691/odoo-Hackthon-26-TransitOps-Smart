const express = require('express');
const reportController = require('../controllers/reportController');
const { authenticateJWT, authorizeRoles } = require('../middleware/auth');

const router = express.Router();

router.use(authenticateJWT);

// Dashboard KPIs visible to all authenticated roles
router.get('/kpis', reportController.getDashboardKPIs);

// Reports restricted to Fleet Manager and Financial Analyst
router.get('/roi', authorizeRoles('Fleet Manager', 'Financial Analyst'), reportController.getVehicleROI);
router.get('/fleet-utilization', authorizeRoles('Fleet Manager', 'Financial Analyst'), reportController.getFleetUtilization);
router.get('/fuel-efficiency', authorizeRoles('Fleet Manager', 'Financial Analyst'), reportController.getFuelEfficiency);
router.get('/operational-cost', authorizeRoles('Fleet Manager', 'Financial Analyst'), reportController.getOperationalCost);

// CSV export
router.get('/export/csv', authorizeRoles('Fleet Manager', 'Financial Analyst'), reportController.exportCSV);

module.exports = router;
