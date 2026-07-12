const vehicleService = require('../services/vehicleService');
const { snakeToCamel, camelToSnake } = require('../utils/casing');
const asyncHandler = require('../utils/asyncHandler');

async function getVehicles(req, res) {
  const result = await vehicleService.getVehicles(snakeToCamel(req.query));
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Vehicles retrieved successfully'
  });
}

async function getVehicleById(req, res) {
  const result = await vehicleService.getVehicleById(req.params.id);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Vehicle details retrieved successfully'
  });
}

async function createVehicle(req, res) {
  const result = await vehicleService.createVehicle(snakeToCamel(req.body));
  return res.status(201).json({
    success: true,
    data: camelToSnake(result),
    message: 'Vehicle registered successfully'
  });
}

async function updateVehicle(req, res) {
  const result = await vehicleService.updateVehicle(req.params.id, snakeToCamel(req.body));
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Vehicle registry updated successfully'
  });
}

async function retireVehicle(req, res) {
  const result = await vehicleService.deleteVehicle(req.params.id);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Vehicle retired successfully'
  });
}

module.exports = {
  getVehicles: asyncHandler(getVehicles),
  getVehicleById: asyncHandler(getVehicleById),
  createVehicle: asyncHandler(createVehicle),
  updateVehicle: asyncHandler(updateVehicle),
  retireVehicle: asyncHandler(retireVehicle)
};
