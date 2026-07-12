const express = require('express');
const router = express.Router();

const authRoutes = require('./authRoutes');
const vehicleRoutes = require('./vehicleRoutes');
const driverRoutes = require('./driverRoutes');
const tripRoutes = require('./tripRoutes');
const maintenanceRoutes = require('./maintenanceRoutes');
const logRoutes = require('./logRoutes');
const reportRoutes = require('./reportRoutes');

// Mount child routes
router.use('/auth', authRoutes);
router.use('/vehicles', vehicleRoutes);
router.use('/drivers', driverRoutes);
router.use('/trips', tripRoutes);
router.use('/maintenance', maintenanceRoutes);
router.use('/expenses', logRoutes);
router.use('/reports', reportRoutes);

module.exports = router;
