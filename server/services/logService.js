const logRepository = require('../repositories/logRepository');
const vehicleRepository = require('../repositories/vehicleRepository');
const { NotFoundError } = require('../middleware/errorHandler');

async function createFuelLog(data) {
  const vehicle = await vehicleRepository.findById(data.vehicleId);
  if (!vehicle) {
    throw new NotFoundError(`Vehicle with ID ${data.vehicleId} not found`);
  }
  return logRepository.createFuelLog(data);
}

async function getFuelLogsByVehicle(vehicleId) {
  const vehicle = await vehicleRepository.findById(vehicleId);
  if (!vehicle) {
    throw new NotFoundError(`Vehicle with ID ${vehicleId} not found`);
  }
  return logRepository.findFuelLogsByVehicle(vehicleId);
}

async function createExpense(data) {
  const vehicle = await vehicleRepository.findById(data.vehicleId);
  if (!vehicle) {
    throw new NotFoundError(`Vehicle with ID ${data.vehicleId} not found`);
  }
  return logRepository.createExpense(data);
}

async function getExpensesByVehicle(vehicleId) {
  const vehicle = await vehicleRepository.findById(vehicleId);
  if (!vehicle) {
    throw new NotFoundError(`Vehicle with ID ${vehicleId} not found`);
  }
  return logRepository.findExpensesByVehicle(vehicleId);
}

module.exports = {
  createFuelLog,
  getFuelLogsByVehicle,
  createExpense,
  getExpensesByVehicle
};
