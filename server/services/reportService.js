const { prisma } = require('../database/db');

async function getFleetUtilization() {
  const vehicles = await prisma.vehicle.findMany({
    where: { NOT: { status: 'Retired' } }
  });

  const total = vehicles.length;
  const active = vehicles.filter(v => v.status === 'On Trip').length;
  const available = vehicles.filter(v => v.status === 'Available').length;
  const inShop = vehicles.filter(v => v.status === 'In Shop').length;

  const utilizationPercentage = total > 0 ? (active / total) * 100 : 0;

  const vehicleList = vehicles.map(v => ({
    id: v.id,
    registrationNumber: v.registrationNumber,
    model: v.model,
    type: v.type,
    status: v.status
  }));

  return {
    summary: {
      totalVehicles: total,
      activeVehicles: active,
      availableVehicles: available,
      inShopVehicles: inShop,
      utilizationPercentage: parseFloat(utilizationPercentage.toFixed(2))
    },
    vehicles: vehicleList
  };
}

async function getFuelEfficiency() {
  const vehicles = await prisma.vehicle.findMany({
    include: {
      trips: {
        where: { status: 'Completed' }
      }
    }
  });

  return vehicles.map(v => {
    let totalDistance = 0;
    let totalFuel = 0;

    v.trips.forEach(t => {
      if (t.actualDistance) totalDistance += Number(t.actualDistance);
      if (t.fuelConsumed) totalFuel += Number(t.fuelConsumed);
    });

    const efficiency = totalFuel > 0 ? totalDistance / totalFuel : 0;

    return {
      vehicleId: v.id,
      registrationNumber: v.registrationNumber,
      model: v.model,
      type: v.type,
      totalDistance: parseFloat(totalDistance.toFixed(2)),
      totalFuelConsumedLiters: parseFloat(totalFuel.toFixed(2)),
      fuelEfficiencyKmPerLiter: parseFloat(efficiency.toFixed(2))
    };
  });
}

async function getOperationalCost() {
  const vehicles = await prisma.vehicle.findMany({
    include: {
      maintenanceLogs: true,
      fuelLogs: true,
      expenses: true
    }
  });

  return vehicles.map(v => {
    const maintenanceCost = v.maintenanceLogs.reduce((sum, log) => sum + Number(log.cost), 0);
    const fuelCost = v.fuelLogs.reduce((sum, log) => sum + Number(log.cost), 0);
    const expenseCost = v.expenses.reduce((sum, exp) => sum + Number(exp.cost), 0);

    const operationalCost = fuelCost + maintenanceCost;
    const totalCost = operationalCost + expenseCost;

    return {
      vehicleId: v.id,
      registrationNumber: v.registrationNumber,
      model: v.model,
      maintenanceCost: parseFloat(maintenanceCost.toFixed(2)),
      fuelCost: parseFloat(fuelCost.toFixed(2)),
      otherExpensesCost: parseFloat(expenseCost.toFixed(2)),
      operationalCost: parseFloat(operationalCost.toFixed(2)),
      totalCost: parseFloat(totalCost.toFixed(2))
    };
  });
}

async function getVehicleROI() {
  const vehicles = await prisma.vehicle.findMany({
    include: {
      trips: {
        where: { status: 'Completed' }
      },
      maintenanceLogs: true,
      fuelLogs: true
    }
  });

  return vehicles.map(v => {
    const revenue = v.trips.reduce((sum, t) => sum + Number(t.revenue), 0);
    const maintenanceCost = v.maintenanceLogs.reduce((sum, log) => sum + Number(log.cost), 0);
    const fuelCost = v.fuelLogs.reduce((sum, log) => sum + Number(log.cost), 0);
    
    const netProfit = revenue - (maintenanceCost + fuelCost);
    const acquisition = Number(v.acquisitionCost);
    const roiRatio = acquisition > 0 ? netProfit / acquisition : 0;

    return {
      vehicleId: v.id,
      registrationNumber: v.registrationNumber,
      model: v.model,
      acquisitionCost: acquisition,
      totalRevenue: parseFloat(revenue.toFixed(2)),
      totalMaintenanceCost: parseFloat(maintenanceCost.toFixed(2)),
      totalFuelCost: parseFloat(fuelCost.toFixed(2)),
      netProfit: parseFloat(netProfit.toFixed(2)),
      roiDecimal: parseFloat(roiRatio.toFixed(4)),
      roiPercentage: parseFloat((roiRatio * 100).toFixed(2))
    };
  });
}

async function getDashboardKPIs() {
  const [
    vehiclesCount,
    activeVehiclesCount,
    availableVehiclesCount,
    inShopVehiclesCount,
    activeTripsCount,
    pendingTripsCount,
    driversOnDutyCount
  ] = await Promise.all([
    prisma.vehicle.count({ where: { NOT: { status: 'Retired' } } }),
    prisma.vehicle.count({ where: { status: 'On Trip' } }),
    prisma.vehicle.count({ where: { status: 'Available' } }),
    prisma.vehicle.count({ where: { status: 'In Shop' } }),
    prisma.trip.count({ where: { status: 'Dispatched' } }),
    prisma.trip.count({ where: { status: 'Draft' } }),
    prisma.driver.count({ where: { status: { in: ['Available', 'On Trip'] } } })
  ]);

  const utilizationPercentage = vehiclesCount > 0 ? (activeVehiclesCount / vehiclesCount) * 100 : 0;

  return {
    activeVehicles: activeVehiclesCount,
    availableVehicles: availableVehiclesCount,
    vehiclesInMaintenance: inShopVehiclesCount,
    activeTrips: activeTripsCount,
    pendingTrips: pendingTripsCount,
    driversOnDuty: driversOnDutyCount,
    fleetUtilizationPercentage: parseFloat(utilizationPercentage.toFixed(2))
  };
}

function convertToCSV(data, headers, fields) {
  const headerRow = headers.join(',');
  const rows = data.map(item => {
    return fields.map(field => {
      const parts = field.split('.');
      let val = item;
      for (const part of parts) {
        if (val) val = val[part];
        else val = '';
      }
      if (val === undefined || val === null) return '';
      const strVal = String(val).replace(/"/g, '""');
      return strVal.includes(',') || strVal.includes('"') || strVal.includes('\n') ? `"${strVal}"` : strVal;
    }).join(',');
  });

  return [headerRow, ...rows].join('\n');
}

module.exports = {
  getFleetUtilization,
  getFuelEfficiency,
  getOperationalCost,
  getVehicleROI,
  getDashboardKPIs,
  convertToCSV
};
