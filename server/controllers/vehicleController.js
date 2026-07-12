const vehicleService = require('../services/vehicleService');

async function getVehicles(req, res) {
  const { type, status, region, availableForTrip } = req.query;
  const result = await vehicleService.getVehicles({ type, status, region, availableForTrip });
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Vehicles retrieved successfully'
  });
}

async function getVehicleById(req, res) {
  const result = await vehicleService.getVehicleById(req.params.id);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Vehicle details retrieved successfully'
  });
}

async function createVehicle(req, res) {
  const result = await vehicleService.createVehicle(req.body);
  return res.status(201).json({
    success: true,
    data: result,
    message: 'Vehicle registered successfully'
  });
}

async function updateVehicle(req, res) {
  const result = await vehicleService.updateVehicle(req.params.id, req.body);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Vehicle registry updated successfully'
  });
}

async function retireVehicle(req, res) {
  const result = await vehicleService.deleteVehicle(req.params.id);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Vehicle retired successfully'
  });
}

module.exports = {
  getVehicles,
  getVehicleById,
  createVehicle,
  updateVehicle,
  retireVehicle
};
