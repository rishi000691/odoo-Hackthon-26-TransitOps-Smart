const maintenanceService = require('../services/maintenanceService');

async function createMaintenanceLog(req, res) {
  const result = await maintenanceService.createMaintenanceLog(req.body);
  return res.status(201).json({
    success: true,
    data: result,
    message: 'Maintenance log created successfully'
  });
}

async function closeMaintenanceLog(req, res) {
  const result = await maintenanceService.closeMaintenanceLog(req.params.id, req.body);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Maintenance log closed successfully'
  });
}

module.exports = {
  createMaintenanceLog,
  closeMaintenanceLog
};
