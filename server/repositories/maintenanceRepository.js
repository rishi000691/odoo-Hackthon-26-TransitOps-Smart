const { prisma } = require('../database/db');

async function findById(id) {
  return prisma.maintenanceLog.findUnique({
    where: { id },
    include: { vehicle: true }
  });
}

async function create(data) {
  const status = data.status || 'Active';

  return prisma.$transaction(async (tx) => {
    const log = await tx.maintenanceLog.create({
      data: {
        vehicleId: data.vehicleId,
        description: data.description,
        cost: data.cost,
        startDate: new Date(),
        status
      }
    });

    if (status === 'Active') {
      await tx.vehicle.update({
        where: { id: data.vehicleId },
        data: { status: 'In Shop' }
      });
    }

    return log;
  });
}

async function close(log, cost) {
  const finalCost = cost !== undefined ? cost : log.cost;

  return prisma.$transaction(async (tx) => {
    const updatedLog = await tx.maintenanceLog.update({
      where: { id: log.id },
      data: {
        status: 'Closed',
        cost: finalCost,
        endDate: new Date()
      }
    });

    if (log.vehicle.status !== 'Retired') {
      await tx.vehicle.update({
        where: { id: log.vehicleId },
        data: { status: 'Available' }
      });
    }

    return updatedLog;
  });
}

async function findMany(filters = {}) {
  const where = {};
  if (filters.status) {
    where.status = filters.status;
  }
  if (filters.vehicleId) {
    where.vehicleId = filters.vehicleId;
  }
  return prisma.maintenanceLog.findMany({
    where,
    orderBy: { startDate: 'desc' },
    include: { vehicle: true }
  });
}

module.exports = {
  findById,
  findMany,
  create,
  close
};
