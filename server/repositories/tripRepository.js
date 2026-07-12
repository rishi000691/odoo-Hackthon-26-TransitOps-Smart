const { prisma } = require('../database/db');

async function findMany(filters = {}) {
  const where = {};

  if (filters.status) {
    where.status = filters.status;
  }

  return prisma.trip.findMany({
    where,
    include: {
      vehicle: true,
      driver: true
    }
  });
}

async function findById(id) {
  return prisma.trip.findUnique({
    where: { id },
    include: {
      vehicle: true,
      driver: true
    }
  });
}

async function create(data) {
  const revenue = data.revenue !== undefined ? data.revenue : data.plannedDistance * data.cargoWeight * 0.0005;

  return prisma.trip.create({
    data: {
      source: data.source,
      destination: data.destination,
      vehicleId: data.vehicleId,
      driverId: data.driverId,
      cargoWeight: data.cargoWeight,
      plannedDistance: data.plannedDistance,
      revenue,
      status: data.status || 'Draft'
    }
  });
}

async function createAndDispatch(data) {
  const revenue = data.revenue !== undefined ? data.revenue : data.plannedDistance * data.cargoWeight * 0.0005;

  return prisma.$transaction(async (tx) => {
    const trip = await tx.trip.create({
      data: {
        source: data.source,
        destination: data.destination,
        vehicleId: data.vehicleId,
        driverId: data.driverId,
        cargoWeight: data.cargoWeight,
        plannedDistance: data.plannedDistance,
        revenue,
        status: 'Dispatched'
      }
    });

    await tx.vehicle.update({
      where: { id: data.vehicleId },
      data: { status: 'On Trip' }
    });

    await tx.driver.update({
      where: { id: data.driverId },
      data: { status: 'On Trip' }
    });

    return trip;
  });
}

async function dispatch(trip) {
  return prisma.$transaction(async (tx) => {
    const updatedTrip = await tx.trip.update({
      where: { id: trip.id },
      data: { status: 'Dispatched' }
    });

    await tx.vehicle.update({
      where: { id: trip.vehicleId },
      data: { status: 'On Trip' }
    });

    await tx.driver.update({
      where: { id: trip.driverId },
      data: { status: 'On Trip' }
    });

    return updatedTrip;
  });
}

async function complete(trip, actualDistance, fuelConsumed, revenue) {
  return prisma.$transaction(async (tx) => {
    const updatedTrip = await tx.trip.update({
      where: { id: trip.id },
      data: {
        status: 'Completed',
        actualDistance,
        fuelConsumed,
        revenue: revenue !== undefined ? revenue : trip.revenue,
        completedAt: new Date()
      }
    });

    await tx.vehicle.update({
      where: { id: trip.vehicleId },
      data: {
        status: 'Available',
        currentOdometer: {
          increment: actualDistance
        }
      }
    });

    await tx.driver.update({
      where: { id: trip.driverId },
      data: { status: 'Available' }
    });

    return updatedTrip;
  });
}

async function cancel(trip) {
  const wasDispatched = trip.status === 'Dispatched';

  return prisma.$transaction(async (tx) => {
    const updatedTrip = await tx.trip.update({
      where: { id: trip.id },
      data: { status: 'Cancelled' }
    });

    if (wasDispatched) {
      await tx.vehicle.update({
        where: { id: trip.vehicleId },
        data: { status: 'Available' }
      });

      await tx.driver.update({
        where: { id: trip.driverId },
        data: { status: 'Available' }
      });
    }

    return updatedTrip;
  });
}

module.exports = {
  findMany,
  findById,
  create,
  createAndDispatch,
  dispatch,
  complete,
  cancel
};
