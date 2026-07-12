const { prisma } = require('../database/db');

async function findMany(filters = {}) {
  const where = {};

  if (filters.status) {
    where.status = filters.status;
  }

  if (filters.availableForTrip === 'true') {
    where.status = 'Available';
    where.licenseExpiryDate = {
      gt: new Date()
    };
  }

  return prisma.driver.findMany({ where });
}

async function findById(id) {
  return prisma.driver.findUnique({
    where: { id }
  });
}

async function findByLicenseNumber(licenseNumber) {
  return prisma.driver.findUnique({
    where: { licenseNumber }
  });
}

async function create(data) {
  return prisma.driver.create({
    data: {
      name: data.name,
      licenseNumber: data.licenseNumber,
      licenseCategory: data.licenseCategory,
      licenseExpiryDate: data.licenseExpiryDate,
      contactNumber: data.contactNumber,
      safetyScore: data.safetyScore || 100.0,
      status: data.status || 'Available'
    }
  });
}

async function update(id, data) {
  return prisma.driver.update({
    where: { id },
    data
  });
}

async function destroy(id) {
  return prisma.driver.delete({
    where: { id }
  });
}

module.exports = {
  findMany,
  findById,
  findByLicenseNumber,
  create,
  update,
  destroy
};
