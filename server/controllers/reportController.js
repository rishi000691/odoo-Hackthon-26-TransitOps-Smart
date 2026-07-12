const reportService = require('../services/reportService');
const { snakeToCamel, camelToSnake } = require('../utils/casing');
const asyncHandler = require('../utils/asyncHandler');

async function getDashboardKPIs(req, res) {
  const filters = snakeToCamel(req.query);
  const result = await reportService.getDashboardKPIs(filters);
  
  const formattedData = {
    active_vehicles: result.activeVehicles,
    available_vehicles: result.availableVehicles,
    vehicles_in_maintenance: result.vehiclesInMaintenance,
    active_trips: result.activeTrips,
    pending_trips: result.pendingTrips,
    drivers_on_duty: result.driversOnDuty,
    fleet_utilization_pct: result.fleetUtilizationPercentage,

    activeVehicles: result.activeVehicles,
    availableVehicles: result.availableVehicles,
    vehiclesInMaintenance: result.vehiclesInMaintenance,
    activeTrips: result.activeTrips,
    pendingTrips: result.pendingTrips,
    driversOnDuty: result.driversOnDuty,
    fleetUtilizationPercentage: result.fleetUtilizationPercentage
  };

  return res.status(200).json({
    success: true,
    data: formattedData,
    message: 'Dashboard KPIs retrieved successfully'
  });
}

async function getVehicleROI(req, res) {
  const result = await reportService.getVehicleROI();
  
  if (req.query.format === 'csv') {
    req.query.report = 'roi';
    return exportCSV(req, res);
  }

  const mapped = result.map(item => {
    const snakeItem = camelToSnake(item);
    return {
      ...snakeItem,
      roi: snakeItem.roi_percentage,
      revenue: snakeItem.total_revenue,
      maintenance_cost: snakeItem.total_maintenance_cost,
      fuel_cost: snakeItem.total_fuel_cost
    };
  });

  return res.status(200).json({
    success: true,
    data: mapped,
    message: 'Vehicle ROI report retrieved successfully'
  });
}

async function getFleetUtilization(req, res) {
  const result = await reportService.getFleetUtilization();

  if (req.query.format === 'csv') {
    req.query.report = 'utilization';
    return exportCSV(req, res);
  }

  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Fleet utilization report retrieved successfully'
  });
}

async function getFuelEfficiency(req, res) {
  const result = await reportService.getFuelEfficiency();

  if (req.query.format === 'csv') {
    req.query.report = 'efficiency';
    return exportCSV(req, res);
  }

  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Fuel efficiency report retrieved successfully'
  });
}

async function getOperationalCost(req, res) {
  const result = await reportService.getOperationalCost();

  if (req.query.format === 'csv') {
    req.query.report = 'cost';
    return exportCSV(req, res);
  }

  return res.status(200).json({
    success: true,
    data: camelToSnake(result),
    message: 'Operational cost report retrieved successfully'
  });
}

async function exportCSV(req, res) {
  const { report } = req.query;
  const dateStr = new Date().toISOString().split('T')[0];

  let data;
  let headers;
  let fields;
  let filename = `transitops-report-${dateStr}.csv`;

  if (report === 'roi') {
    data = await reportService.getVehicleROI();
    headers = ['Vehicle ID', 'Registration Number', 'Model', 'Acquisition Cost', 'Total Revenue', 'Total Maintenance Cost', 'Total Fuel Cost', 'Net Profit', 'ROI (%)'];
    fields = ['vehicleId', 'registrationNumber', 'model', 'acquisitionCost', 'totalRevenue', 'totalMaintenanceCost', 'totalFuelCost', 'netProfit', 'roiPercentage'];
  } else if (report === 'utilization') {
    const resData = await reportService.getFleetUtilization();
    data = resData.vehicles;
    headers = ['Vehicle ID', 'Registration Number', 'Model', 'Type', 'Status'];
    fields = ['id', 'registrationNumber', 'model', 'type', 'status'];
  } else if (report === 'efficiency') {
    data = await reportService.getFuelEfficiency();
    headers = ['Vehicle ID', 'Registration Number', 'Model', 'Type', 'Total Distance (km)', 'Total Fuel Consumed (L)', 'Efficiency (Km/L)'];
    fields = ['vehicleId', 'registrationNumber', 'model', 'type', 'totalDistance', 'totalFuelConsumedLiters', 'fuelEfficiencyKmPerLiter'];
  } else if (report === 'cost') {
    data = await reportService.getOperationalCost();
    headers = ['Vehicle ID', 'Registration Number', 'Model', 'Maintenance Cost', 'Fuel Cost', 'Other Expenses', 'Operational Cost', 'Total Cost'];
    fields = ['vehicleId', 'registrationNumber', 'model', 'maintenanceCost', 'fuelCost', 'otherExpensesCost', 'operationalCost', 'totalCost'];
  } else {
    data = await reportService.getVehicleROI();
    headers = ['Vehicle ID', 'Registration Number', 'Model', 'Acquisition Cost', 'Total Revenue', 'Total Maintenance Cost', 'Total Fuel Cost', 'Net Profit', 'ROI (%)'];
    fields = ['vehicleId', 'registrationNumber', 'model', 'acquisitionCost', 'totalRevenue', 'totalMaintenanceCost', 'totalFuelCost', 'netProfit', 'roiPercentage'];
  }

  const csv = reportService.convertToCSV(data, headers, fields);
  
  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
  return res.status(200).send(csv);
}

module.exports = {
  getDashboardKPIs: asyncHandler(getDashboardKPIs),
  getVehicleROI: asyncHandler(getVehicleROI),
  getFleetUtilization: asyncHandler(getFleetUtilization),
  getFuelEfficiency: asyncHandler(getFuelEfficiency),
  getOperationalCost: asyncHandler(getOperationalCost),
  exportCSV: asyncHandler(exportCSV)
};
