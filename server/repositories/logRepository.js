const { prisma } = require('../database/db');

async function createFuelLog(data) {
  return prisma.fuelLog.create({
    data: {
      vehicleId: data.vehicleId,
      liters: data.liters,
      cost: data.cost,
      date: new Date()
    }
  });
}

async function findFuelLogsByVehicle(vehicleId) {
  return prisma.fuelLog.findMany({
    where: { vehicleId },
    orderBy: { date: 'desc' }
  });
}

async function createExpense(data) {
  return prisma.expense.create({
    data: {
      vehicleId: data.vehicleId,
      expenseType: data.expenseType,
      cost: data.cost,
      date: new Date()
    }
  });
}

async function findExpensesByVehicle(vehicleId) {
  return prisma.expense.findMany({
    where: { vehicleId },
    orderBy: { date: 'desc' }
  });
}

module.exports = {
  createFuelLog,
  findFuelLogsByVehicle,
  createExpense,
  findExpensesByVehicle
};
