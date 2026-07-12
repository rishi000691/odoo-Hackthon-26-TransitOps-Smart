const logService = require('../services/logService');

async function createFuelLog(req, res) {
  const result = await logService.createFuelLog(req.body);
  return res.status(201).json({
    success: true,
    data: result,
    message: 'Fuel log recorded successfully'
  });
}

async function getFuelLogsByVehicle(req, res) {
  const result = await logService.getFuelLogsByVehicle(req.params.vehicleId);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Fuel logs retrieved successfully'
  });
}

async function createExpense(req, res) {
  const result = await logService.createExpense(req.body);
  return res.status(201).json({
    success: true,
    data: result,
    message: 'Expense recorded successfully'
  });
}

async function getExpensesByVehicle(req, res) {
  const result = await logService.getExpensesByVehicle(req.params.vehicleId);
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Expenses retrieved successfully'
  });
}

module.exports = {
  createFuelLog,
  getFuelLogsByVehicle,
  createExpense,
  getExpensesByVehicle
};
