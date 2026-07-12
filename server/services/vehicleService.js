const vehicleRepository = require('../repositories/vehicleRepository');
const { BadRequestError, NotFoundError } = require('../middleware/errorHandler');

async function getVehicles(filters = {}) {
  return vehicleRepository.findMany(filters);
}

async function getVehicleById(id) {
  const vehicle = await vehicleRepository.findById(id);
  if (!vehicle) {
    throw new NotFoundError(`Vehicle with ID ${id} not found`);
  }
  return vehicle;
}

async function createVehicle(data) {
  const existing = await vehicleRepository.findByRegistrationNumber(data.registrationNumber);
  if (existing) {
    throw new BadRequestError(`Vehicle registration number '${data.registrationNumber}' is already in use`, 'DUPLICATE_REGISTRATION');
  }
  return vehicleRepository.create(data);
}

async function updateVehicle(id, data) {
  await getVehicleById(id);

  if (data.registrationNumber) {
    const existing = await vehicleRepository.findByRegistrationNumber(data.registrationNumber);
    if (existing && existing.id !== id) {
      throw new BadRequestError(`Vehicle registration number '${data.registrationNumber}' is already in use`, 'DUPLICATE_REGISTRATION');
    }
  }

  return vehicleRepository.update(id, data);
}

async function deleteVehicle(id) {
  await getVehicleById(id);
  return vehicleRepository.softDelete(id);
}

module.exports = {
  getVehicles,
  getVehicleById,
  createVehicle,
  updateVehicle,
  deleteVehicle
};
