const { z } = require('zod');

// Constants
const RoleNames = z.enum(['Fleet Manager', 'Driver', 'Safety Officer', 'Financial Analyst']);
const VehicleStatusEnum = z.enum(['Available', 'On Trip', 'In Shop', 'Retired']);
const DriverStatusEnum = z.enum(['Available', 'On Trip', 'Off Duty', 'Suspended']);
const TripStatusEnum = z.enum(['Draft', 'Dispatched', 'Completed', 'Cancelled']);
const ExpenseTypeEnum = z.enum(['Toll', 'Maintenance', 'Insurance', 'Other']);

// Auth Validation
const registerSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  firstName: z.string().min(1, 'First name is required'),
  lastName: z.string().min(1, 'Last name is required'),
  roleName: RoleNames,
});

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(1, 'Password is required'),
});

// Vehicle Validation
const vehicleCreateSchema = z.object({
  registrationNumber: z.string().min(1, 'Registration number is required'),
  model: z.string().min(1, 'Model is required'),
  type: z.string().min(1, 'Type is required'),
  maxLoadCapacity: z.number().positive('Max load capacity must be positive'),
  currentOdometer: z.number().nonnegative('Odometer must be non-negative'),
  acquisitionCost: z.number().positive('Acquisition cost must be positive'),
  status: VehicleStatusEnum.optional(),
  region: z.string().optional(),
});

const vehicleUpdateSchema = vehicleCreateSchema.partial();

// Driver Validation
const driverCreateSchema = z.object({
  name: z.string().min(1, 'Driver name is required'),
  licenseNumber: z.string().min(1, 'License number is required'),
  licenseCategory: z.string().min(1, 'License category is required'),
  licenseExpiryDate: z.coerce.date({
    required_error: 'License expiry date is required',
    invalid_type_error: 'Invalid date format',
  }),
  contactNumber: z.string().min(1, 'Contact number is required'),
  safetyScore: z.number().min(0).max(100).optional(),
  status: DriverStatusEnum.optional(),
});

const driverUpdateSchema = driverCreateSchema.partial();

// Trip Validation
const tripCreateSchema = z.object({
  source: z.string().min(1, 'Source is required'),
  destination: z.string().min(1, 'Destination is required'),
  vehicleId: z.string().uuid('Vehicle ID must be a valid UUID'),
  driverId: z.string().uuid('Driver ID must be a valid UUID'),
  cargoWeight: z.number().positive('Cargo weight must be positive'),
  plannedDistance: z.number().positive('Planned distance must be positive'),
  revenue: z.number().nonnegative('Revenue must be non-negative').optional(),
  status: z.enum(['Draft', 'Dispatched']).optional(),
});

const tripCompleteSchema = z.object({
  actualDistance: z.number().positive('Actual distance must be positive'),
  fuelConsumed: z.number().positive('Fuel consumed must be positive'),
  revenue: z.number().nonnegative('Revenue must be non-negative').optional(),
});

// Maintenance Validation
const maintenanceCreateSchema = z.object({
  vehicleId: z.string().uuid('Vehicle ID must be a valid UUID'),
  description: z.string().min(1, 'Description is required'),
  cost: z.number().nonnegative('Cost must be non-negative'),
  status: z.enum(['Active', 'Closed']).optional(),
});

const maintenanceCloseSchema = z.object({
  cost: z.number().nonnegative('Updated cost must be non-negative').optional(),
});

// Fuel Log Validation
const fuelLogCreateSchema = z.object({
  vehicleId: z.string().uuid('Vehicle ID must be a valid UUID'),
  liters: z.number().positive('Liters must be positive'),
  cost: z.number().positive('Cost must be positive'),
});

// Expense Validation
const expenseCreateSchema = z.object({
  vehicleId: z.string().uuid('Vehicle ID must be a valid UUID'),
  expenseType: ExpenseTypeEnum,
  cost: z.number().positive('Cost must be positive'),
});

module.exports = {
  registerSchema,
  loginSchema,
  vehicleCreateSchema,
  vehicleUpdateSchema,
  driverCreateSchema,
  driverUpdateSchema,
  tripCreateSchema,
  tripCompleteSchema,
  maintenanceCreateSchema,
  maintenanceCloseSchema,
  fuelLogCreateSchema,
  expenseCreateSchema,
};
