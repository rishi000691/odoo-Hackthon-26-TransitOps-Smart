const tripRepository = require('../repositories/tripRepository');
const vehicleRepository = require('../repositories/vehicleRepository');
const driverRepository = require('../repositories/driverRepository');
const { BadRequestError, NotFoundError } = require('../middleware/errorHandler');

async function getTrips(filters = {}) {
  return tripRepository.findMany(filters);
}

async function getTripById(id) {
  const trip = await tripRepository.findById(id);
  if (!trip) {
    throw new NotFoundError(`Trip with ID ${id} not found`);
  }
  return trip;
}

async function createTrip(data) {
  const vehicle = await vehicleRepository.findById(data.vehicleId);
  if (!vehicle) {
    throw new NotFoundError(`Vehicle with ID ${data.vehicleId} not found`);
  }

  const driver = await driverRepository.findById(data.driverId);
  if (!driver) {
    throw new NotFoundError(`Driver with ID ${data.driverId} not found`);
  }

  // Business Rule 5: cargoWeight must not exceed maxLoadCapacity
  // Since capacity can be Decimal, convert to number for comparison
  const maxCapacity = Number(vehicle.maxLoadCapacity);
  if (data.cargoWeight > maxCapacity) {
    throw new BadRequestError(
      `Trip cargo weight (${data.cargoWeight} kg) exceeds vehicle's maximum load capacity (${maxCapacity} kg)`,
      'EXCEEDS_CAPACITY'
    );
  }

  const status = data.status || 'Draft';

  if (status === 'Dispatched') {
    // Dispatch validations
    if (vehicle.status !== 'Available') {
      throw new BadRequestError(`Vehicle status is '${vehicle.status}'. Only 'Available' vehicles can be dispatched.`, 'VEHICLE_UNAVAILABLE');
    }

    if (driver.status !== 'Available') {
      throw new BadRequestError(`Driver status is '${driver.status}'. Only 'Available' drivers can be dispatched.`, 'DRIVER_UNAVAILABLE');
    }

    if (new Date(driver.licenseExpiryDate) < new Date()) {
      throw new BadRequestError(`Driver license has expired on ${driver.licenseExpiryDate.toISOString().split('T')[0]}`, 'DRIVER_LICENSE_EXPIRED');
    }

    return tripRepository.createAndDispatch(data);
  }

  return tripRepository.create(data);
}

async function dispatchTrip(id) {
  const trip = await getTripById(id);

  if (trip.status !== 'Draft') {
    throw new BadRequestError(`Only 'Draft' trips can be dispatched. Current status is '${trip.status}'.`, 'INVALID_TRIP_STATUS');
  }

  const vehicle = trip.vehicle;
  const driver = trip.driver;

  const maxCapacity = Number(vehicle.maxLoadCapacity);
  if (Number(trip.cargoWeight) > maxCapacity) {
    throw new BadRequestError(
      `Trip cargo weight (${trip.cargoWeight} kg) exceeds vehicle's maximum load capacity (${maxCapacity} kg)`,
      'EXCEEDS_CAPACITY'
    );
  }

  if (vehicle.status !== 'Available') {
    throw new BadRequestError(`Vehicle status is '${vehicle.status}'. Only 'Available' vehicles can be dispatched.`, 'VEHICLE_UNAVAILABLE');
  }

  if (driver.status !== 'Available') {
    throw new BadRequestError(`Driver status is '${driver.status}'. Only 'Available' drivers can be dispatched.`, 'DRIVER_UNAVAILABLE');
  }

  if (new Date(driver.licenseExpiryDate) < new Date()) {
    throw new BadRequestError(`Driver license has expired on ${driver.licenseExpiryDate.toISOString().split('T')[0]}`, 'DRIVER_LICENSE_EXPIRED');
  }

  return tripRepository.dispatch(trip);
}

async function completeTrip(id, { actualDistance, fuelConsumed, revenue }) {
  const trip = await getTripById(id);

  if (trip.status !== 'Dispatched') {
    throw new BadRequestError(`Only 'Dispatched' trips can be completed. Current status is '${trip.status}'.`, 'INVALID_TRIP_STATUS');
  }

  return tripRepository.complete(trip, actualDistance, fuelConsumed, revenue);
}

async function cancelTrip(id) {
  const trip = await getTripById(id);

  if (trip.status === 'Completed' || trip.status === 'Cancelled') {
    throw new BadRequestError(`Completed or already Cancelled trips cannot be cancelled. Current status is '${trip.status}'.`, 'INVALID_TRIP_STATUS');
  }

  return tripRepository.cancel(trip);
}

module.exports = {
  getTrips,
  getTripById,
  createTrip,
  dispatchTrip,
  completeTrip,
  cancelTrip
};
