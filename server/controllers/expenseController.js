const logService = require('../services/logService');
const { snakeToCamel, camelToSnake } = require('../utils/casing');

async function logFuel(req, res) {
  // Translate snake_case body to camelCase for the service layer
  const result = await logService.createFuelLog(snakeToCamel(req.body));
  
  // Translate response to snake_case for the Flutter client
  return res.status(201).json({
    success: true,
    data: camelToSnake(result),
    message: 'Fuel log recorded successfully'
  });
}

async function getFuelLogsByVehicle(req, res) {
  const result = await logService.getFuelLogsByVehicle(req.params.vehicleId);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Fuel logs retrieved successfully'
  });
}

async function logExpense(req, res) {
  // Translate snake_case body to camelCase for the service layer
  const result = await logService.createExpense(snakeToCamel(req.body));
  
  // Translate response to snake_case for the Flutter client
  return res.status(201).json({
    success: true,
    data: camelToSnake(result),
    message: 'Expense recorded successfully'
  });
}

async function getExpensesByVehicle(req, res) {
  const result = await logService.getExpensesByVehicle(req.params.vehicleId);
  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Expenses retrieved successfully'
  });
}

module.exports = {
  logFuel,
  createFuelLog: logFuel, // Alias for compatibility with Rishi's routing
  getFuelLogsByVehicle,
  logExpense,
  createExpense: logExpense, // Alias for compatibility with Rishi's routing
  getExpensesByVehicle
};
