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

async function sendExpiryReminders(days = 30) {
  const expiringDrivers = await driverRepository.findExpiringDrivers(days);
  const remindersSent = [];

  for (const driver of expiringDrivers) {
    const formattedExpiryDate = driver.licenseExpiryDate.toISOString().split('T')[0];
    
    // Simulate sending email
    console.log(`\n======================================================`);
    console.log(`[EMAIL SENT] TO: ${driver.name.toLowerCase().replace(/\s+/g, '')}@transitops-fleet.com`);
    console.log(`SUBJECT: URGENT: Driver License Renewal Reminder`);
    console.log(`BODY:`);
    console.log(`Dear ${driver.name},`);
    console.log(`This is an automated reminder that your driver license (${driver.licenseNumber}) is set to expire on ${formattedExpiryDate}.`);
    console.log(`Please renew your license before this date to maintain active status.`);
    console.log(`Best regards,`);
    console.log(`TransitOps Safety & Compliance Team`);
    console.log(`======================================================\n`);

    remindersSent.push({
      driverId: driver.id,
      driverName: driver.name,
      licenseNumber: driver.licenseNumber,
      expiryDate: formattedExpiryDate,
      email: `${driver.name.toLowerCase().replace(/\s+/g, '')}@transitops-fleet.com`
    });
  }

  return remindersSent;
}

module.exports = {
  getDrivers,
  getDriverById,
  createDriver,
  updateDriver,
  deleteDriver,
  sendExpiryReminders
};
