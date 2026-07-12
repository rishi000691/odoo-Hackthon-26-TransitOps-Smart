const tripService = require('../services/tripService');
const { snakeToCamel, camelToSnake } = require('../utils/casing');
const asyncHandler = require('../utils/asyncHandler');

async function getTrips(req, res) {
  const result = await tripService.getTrips(snakeToCamel(req.query));
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Trips retrieved successfully'
  });
}

async function getTripById(req, res) {
  const result = await tripService.getTripById(req.params.id);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Trip details retrieved successfully'
  });
}

async function createTrip(req, res) {
  const result = await tripService.createTrip(snakeToCamel(req.body));
  return res.status(201).json({
    success: true,
    data: camelToSnake(result),
    message: 'Trip created successfully'
  });
}

async function dispatchTrip(req, res) {
  const result = await tripService.dispatchTrip(req.params.id);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Trip dispatched successfully'
  });
}

async function completeTrip(req, res) {
  const result = await tripService.completeTrip(req.params.id, snakeToCamel(req.body));
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Trip completed successfully'
  });
}

async function cancelTrip(req, res) {
  const result = await tripService.cancelTrip(req.params.id);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Trip cancelled successfully'
  });
}

module.exports = {
  getTrips: asyncHandler(getTrips),
  getTripById: asyncHandler(getTripById),
  createTrip: asyncHandler(createTrip),
  dispatchTrip: asyncHandler(dispatchTrip),
  completeTrip: asyncHandler(completeTrip),
  cancelTrip: asyncHandler(cancelTrip)
};
