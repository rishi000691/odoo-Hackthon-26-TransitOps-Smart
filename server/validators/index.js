const { z } = require('zod');
const { vehicleCreateSchema, vehicleUpdateSchema } = require('./vehicleValidator');
const { driverCreateSchema, driverUpdateSchema } = require('./driverValidator');
const { tripCreateSchema, tripCompleteSchema } = require('./tripValidator');
const { maintenanceCreateSchema, maintenanceCloseSchema } = require('./maintenanceValidator');
const { fuelLogCreateSchema, expenseCreateSchema } = require('./expenseValidator');

const RoleNames = z.enum(['Fleet Manager', 'Driver', 'Safety Officer', 'Financial Analyst']);

const registerSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  first_name: z.string().min(1, 'First name is required'),
  last_name: z.string().min(1, 'Last name is required'),
  role_name: RoleNames
});

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(1, 'Password is required')
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
  expenseCreateSchema
};
