const Roles = {
  FLEET_MANAGER: 'Fleet Manager',
  DRIVER: 'Driver',
  SAFETY_OFFICER: 'Safety Officer',
  FINANCIAL_ANALYST: 'Financial Analyst'
};

const VehicleStatus = {
  AVAILABLE: 'Available',
  ON_TRIP: 'On Trip',
  IN_SHOP: 'In Shop',
  RETIRED: 'Retired'
};

const DriverStatus = {
  AVAILABLE: 'Available',
  ON_TRIP: 'On Trip',
  OFF_DUTY: 'Off Duty',
  SUSPENDED: 'Suspended'
};

const TripStatus = {
  DRAFT: 'Draft',
  DISPATCHED: 'Dispatched',
  COMPLETED: 'Completed',
  CANCELLED: 'Cancelled'
};

const MaintenanceStatus = {
  ACTIVE: 'Active',
  CLOSED: 'Closed'
};

const ExpenseType = {
  TOLL: 'Toll',
  MAINTENANCE: 'Maintenance',
  INSURANCE: 'Insurance',
  OTHER: 'Other'
};

module.exports = {
  Roles,
  VehicleStatus,
  DriverStatus,
  TripStatus,
  MaintenanceStatus,
  ExpenseType
};
