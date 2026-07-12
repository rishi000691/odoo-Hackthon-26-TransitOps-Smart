const { prisma } = require('../database/db');

async function findMany(filters = {}) {
  const where = {};

  if (filters.type) {
    where.type = filters.type;
  }

  if (filters.status) {
    where.status = filters.status;
  }

  if (filters.region) {
    where.region = filters.region;
  }

  if (filters.availableForTrip === 'true') {
    // "Retired" or "In Shop" vehicles must never appear in dispatch/selection endpoints.
    // Also, "On Trip" vehicles are busy. So only "Available" vehicles are listed.
    where.status = 'Available';
  }

  return prisma.vehicle.findMany({ where });
}

async function findById(id) {
  return prisma.vehicle.findUnique({
    where: { id }
  });
}

async function findByRegistrationNumber(registrationNumber) {
  return prisma.vehicle.findUnique({
    where: { registrationNumber }
  });
}

async function create(data) {
  return prisma.vehicle.create({
    data: {
      registrationNumber: data.registrationNumber,
      model: data.model,
      type: data.type,
      maxLoadCapacity: data.maxLoadCapacity,
      currentOdometer: data.currentOdometer,
      acquisitionCost: data.acquisitionCost,
      status: data.status || 'Available',
      region: data.region
    }
  });
}

async function update(id, data) {
  return prisma.vehicle.update({
    where: { id },
    data
  });
}

async function softDelete(id) {
  return prisma.vehicle.update({
    where: { id },
    data: { status: 'Retired' }
  });
}

module.exports = {
  findMany,
  findById,
  findByRegistrationNumber,
  create,
  update,
  softDelete
};
