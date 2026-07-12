const driverService = require('../services/driverService');

async function getDrivers(req, res) {
  const { status, availableForTrip } = req.query;
  const result = await driverService.getDrivers({ status, availableForTrip });
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Drivers retrieved successfully'
  });
}

async function getDriverById(req, res) {
  const result = await driverService.getDriverById(req.params.id);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Driver details retrieved successfully'
  });
}

async function createDriver(req, res) {
  const result = await driverService.createDriver(req.body);
  return res.status(201).json({
    success: true,
    data: result,
    message: 'Driver registered successfully'
  });
}

async function updateDriver(req, res) {
  const result = await driverService.updateDriver(req.params.id, req.body, req.user);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Driver details updated successfully'
  });
}

async function deleteDriver(req, res) {
  const result = await driverService.deleteDriver(req.params.id);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Driver profile deleted successfully'
  });
}

module.exports = {
  getDrivers,
  getDriverById,
  createDriver,
  updateDriver,
  deleteDriver
};
