const maintenanceService = require('../services/maintenanceService');
const { snakeToCamel, camelToSnake } = require('../utils/casing');
const asyncHandler = require('../utils/asyncHandler');

async function createMaintenanceLog(req, res) {
  const result = await maintenanceService.createMaintenanceLog(snakeToCamel(req.body));
  return res.status(201).json({
    success: true,
    data: camelToSnake(result),
    message: 'Maintenance log created successfully'
  });
}

async function closeMaintenanceLog(req, res) {
  const result = await maintenanceService.closeMaintenanceLog(req.params.id, snakeToCamel(req.body));
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Maintenance log closed successfully'
  });
}

module.exports = {
  createMaintenanceLog: asyncHandler(createMaintenanceLog),
  closeMaintenanceLog: asyncHandler(closeMaintenanceLog)
};
