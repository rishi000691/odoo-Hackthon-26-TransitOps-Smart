const tripService = require('../services/tripService');

async function getTrips(req, res) {
  const { status } = req.query;
  const result = await tripService.getTrips({ status });
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Trips retrieved successfully'
  });
}

async function getTripById(req, res) {
  const result = await tripService.getTripById(req.params.id);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Trip details retrieved successfully'
  });
}

async function createTrip(req, res) {
  const result = await tripService.createTrip(req.body);
  return res.status(201).json({
    success: true,
    data: result,
    message: 'Trip created successfully'
  });
}

async function dispatchTrip(req, res) {
  const result = await tripService.dispatchTrip(req.params.id);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Trip dispatched successfully'
  });
}

async function completeTrip(req, res) {
  const result = await tripService.completeTrip(req.params.id, req.body);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Trip completed successfully'
  });
}

async function cancelTrip(req, res) {
  const result = await tripService.cancelTrip(req.params.id);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Trip cancelled successfully'
  });
}

module.exports = {
  getTrips,
  getTripById,
  createTrip,
  dispatchTrip,
  completeTrip,
  cancelTrip
};
