const driverService = require('../services/driverService');
const { snakeToCamel, camelToSnake } = require('../utils/casing');
const asyncHandler = require('../utils/asyncHandler');

async function getDrivers(req, res) {
  const result = await driverService.getDrivers(snakeToCamel(req.query));
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Drivers retrieved successfully'
  });
}

async function getDriverById(req, res) {
  const result = await driverService.getDriverById(req.params.id);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Driver details retrieved successfully'
  });
}

async function createDriver(req, res) {
  const result = await driverService.createDriver(snakeToCamel(req.body));
  return res.status(201).json({
    success: true,
    data: camelToSnake(result),
    message: 'Driver registered successfully'
  });
}

async function updateDriver(req, res) {
  const result = await driverService.updateDriver(req.params.id, snakeToCamel(req.body), req.user);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Driver details updated successfully'
  });
}

async function deleteDriver(req, res) {
  const result = await driverService.deleteDriver(req.params.id);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Driver profile deleted successfully'
  });
}

async function sendExpiryReminders(req, res) {
  const days = req.body.days ? parseInt(req.body.days, 10) : 30;
  const result = await driverService.sendExpiryReminders(days);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: `Expiry reminder emails processed. Sent ${result.length} reminders.`
  });
}

module.exports = {
  getDrivers: asyncHandler(getDrivers),
  getDriverById: asyncHandler(getDriverById),
  createDriver: asyncHandler(createDriver),
  updateDriver: asyncHandler(updateDriver),
  deleteDriver: asyncHandler(deleteDriver),
  sendExpiryReminders: asyncHandler(sendExpiryReminders)
};
