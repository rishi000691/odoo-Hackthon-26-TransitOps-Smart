const reportService = require('../services/reportService');

async function getDashboardKPIs(req, res) {
  const result = await reportService.getDashboardKPIs();
  return res.status(200).json({
    success: true,
    data: result,
    message: 'Dashboard KPIs retrieved successfully'
  });
}

async function getVehicleROI(req, res) {
  const result = await reportService.getVehicleROI();
  
  if (req.query.format === 'csv') {
    const headers = ['Vehicle ID', 'Registration Number', 'Model', 'Acquisition Cost', 'Total Revenue', 'Total Maintenance Cost', 'Total Fuel Cost', 'Net Profit', 'ROI (%)'];
    const fields = ['vehicleId', 'registrationNumber', 'model', 'acquisitionCost', 'totalRevenue', 'totalMaintenanceCost', 'totalFuelCost', 'netProfit', 'roiPercentage'];
    const csv = reportService.convertToCSV(result, headers, fields);

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=vehicle_roi.csv');
    return res.status(200).send(csv);
  }

  return res.status(200).json({
    success: true,
    data: result,
    message: 'Vehicle ROI report retrieved successfully'
  });
}

async function getFleetUtilization(req, res) {
  const result = await reportService.getFleetUtilization();

  if (req.query.format === 'csv') {
    const headers = ['Vehicle ID', 'Registration Number', 'Model', 'Type', 'Status'];
    const fields = ['id', 'registrationNumber', 'model', 'type', 'status'];
    const csv = reportService.convertToCSV(result.vehicles, headers, fields);

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=fleet_utilization.csv');
    return res.status(200).send(csv);
  }

  return res.status(200).json({
    success: true,
    data: result,
    message: 'Fleet utilization report retrieved successfully'
  });
}

async function getFuelEfficiency(req, res) {
  const result = await reportService.getFuelEfficiency();

  if (req.query.format === 'csv') {
    const headers = ['Vehicle ID', 'Registration Number', 'Model', 'Type', 'Total Distance (km)', 'Total Fuel Consumed (L)', 'Efficiency (Km/L)'];
    const fields = ['vehicleId', 'registrationNumber', 'model', 'type', 'totalDistance', 'totalFuelConsumedLiters', 'fuelEfficiencyKmPerLiter'];
    const csv = reportService.convertToCSV(result, headers, fields);

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=fuel_efficiency.csv');
    return res.status(200).send(csv);
  }

  return res.status(200).json({
    success: true,
    data: result,
    message: 'Fuel efficiency report retrieved successfully'
  });
}

async function getOperationalCost(req, res) {
  const result = await reportService.getOperationalCost();

  if (req.query.format === 'csv') {
    const headers = ['Vehicle ID', 'Registration Number', 'Model', 'Maintenance Cost', 'Fuel Cost', 'Other Expenses', 'Operational Cost', 'Total Cost'];
    const fields = ['vehicleId', 'registrationNumber', 'model', 'maintenanceCost', 'fuelCost', 'otherExpensesCost', 'operationalCost', 'totalCost'];
    const csv = reportService.convertToCSV(result, headers, fields);

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=operational_cost.csv');
    return res.status(200).send(csv);
  }

  return res.status(200).json({
    success: true,
    data: result,
    message: 'Operational cost report retrieved successfully'
  });
}

async function exportCSV(req, res) {
  const { report } = req.query;

  let data;
  let headers;
  let fields;
  let filename = 'report.csv';

  if (report === 'roi') {
    data = await reportService.getVehicleROI();
    headers = ['Vehicle ID', 'Registration Number', 'Model', 'Acquisition Cost', 'Total Revenue', 'Total Maintenance Cost', 'Total Fuel Cost', 'Net Profit', 'ROI (%)'];
    fields = ['vehicleId', 'registrationNumber', 'model', 'acquisitionCost', 'totalRevenue', 'totalMaintenanceCost', 'totalFuelCost', 'netProfit', 'roiPercentage'];
    filename = 'vehicle_roi.csv';
  } else if (report === 'utilization') {
    const resData = await reportService.getFleetUtilization();
    data = resData.vehicles;
    headers = ['Vehicle ID', 'Registration Number', 'Model', 'Type', 'Status'];
    fields = ['id', 'registrationNumber', 'model', 'type', 'status'];
    filename = 'fleet_utilization.csv';
  } else if (report === 'efficiency') {
    data = await reportService.getFuelEfficiency();
    headers = ['Vehicle ID', 'Registration Number', 'Model', 'Type', 'Total Distance (km)', 'Total Fuel Consumed (L)', 'Efficiency (Km/L)'];
    fields = ['vehicleId', 'registrationNumber', 'model', 'type', 'totalDistance', 'totalFuelConsumedLiters', 'fuelEfficiencyKmPerLiter'];
    filename = 'fuel_efficiency.csv';
  } else if (report === 'cost') {
    data = await reportService.getOperationalCost();
    headers = ['Vehicle ID', 'Registration Number', 'Model', 'Maintenance Cost', 'Fuel Cost', 'Other Expenses', 'Operational Cost', 'Total Cost'];
    fields = ['vehicleId', 'registrationNumber', 'model', 'maintenanceCost', 'fuelCost', 'otherExpensesCost', 'operationalCost', 'totalCost'];
    filename = 'operational_cost.csv';
  } else {
    data = await reportService.getVehicleROI();
    headers = ['Vehicle ID', 'Registration Number', 'Model', 'Acquisition Cost', 'Total Revenue', 'Total Maintenance Cost', 'Total Fuel Cost', 'Net Profit', 'ROI (%)'];
    fields = ['vehicleId', 'registrationNumber', 'model', 'acquisitionCost', 'totalRevenue', 'totalMaintenanceCost', 'totalFuelCost', 'netProfit', 'roiPercentage'];
    filename = 'vehicle_roi.csv';
  }

  const csv = reportService.convertToCSV(data, headers, fields);
  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
  return res.status(200).send(csv);
}

module.exports = {
  getDashboardKPIs,
  getVehicleROI,
  getFleetUtilization,
  getFuelEfficiency,
  getOperationalCost,
  exportCSV
};
