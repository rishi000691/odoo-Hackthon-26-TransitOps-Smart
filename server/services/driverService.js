const driverRepository = require('../repositories/driverRepository');
const { BadRequestError, NotFoundError } = require('../middleware/errorHandler');

async function getDrivers(filters = {}) {
  return driverRepository.findMany(filters);
}

async function getDriverById(id) {
  const driver = await driverRepository.findById(id);
  if (!driver) {
    throw new NotFoundError(`Driver with ID ${id} not found`);
  }
  return driver;
}

async function createDriver(data) {
  const existing = await driverRepository.findByLicenseNumber(data.licenseNumber);
  if (existing) {
    throw new BadRequestError(`Driver license number '${data.licenseNumber}' is already in use`, 'DUPLICATE_LICENSE');
  }
  return driverRepository.create(data);
}

async function updateDriver(id, data, performingUser) {
  await getDriverById(id);

  // Business Rule: only Safety Officer can suspend a driver
  if (data.status === 'Suspended') {
    const userRoleNames = performingUser.roles ? performingUser.roles.map(ur => ur.role.name) : [];
    if (!userRoleNames.includes('Safety Officer')) {
      throw new BadRequestError('Only a Safety Officer can suspend a driver', 'SAFETY_OFFICER_ONLY');
    }
  }

  if (data.licenseNumber) {
    const existing = await driverRepository.findByLicenseNumber(data.licenseNumber);
    if (existing && existing.id !== id) {
      throw new BadRequestError(`Driver license number '${data.licenseNumber}' is already in use`, 'DUPLICATE_LICENSE');
    }
  }

  return driverRepository.update(id, data);
}

async function deleteDriver(id) {
  await getDriverById(id);
  try {
    return await driverRepository.destroy(id);
  } catch (error) {
    throw new BadRequestError('Cannot delete driver because they have associated trips. Update their status to Suspended or Off Duty instead.', 'DEPENDENT_TRIPS');
  }
}

module.exports = {
  getDrivers,
  getDriverById,
  createDriver,
  updateDriver,
  deleteDriver
};
