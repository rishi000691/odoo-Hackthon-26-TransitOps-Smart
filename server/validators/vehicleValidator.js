const { z } = require('zod');

const VehicleStatusEnum = z.enum(['Available', 'On Trip', 'In Shop', 'Retired']);

const vehicleCreateSchema = z.object({
  registration_number: z
    .string()
    .min(1, 'Registration number is required')
    .regex(/^[A-Za-z0-9-]+$/, 'Registration number must contain only alphanumeric characters and dashes'),
  model: z.string().min(1, 'Model is required'),
  type: z.enum(['Van', 'Truck', 'Sedan'], {
    errorMap: () => ({ message: 'Type must be one of: Van, Truck, Sedan' })
  }),
  max_load_capacity: z.number().positive('Max load capacity must be positive'),
  current_odometer: z.number().nonnegative('Odometer must be non-negative').default(0),
  acquisition_cost: z.number().positive('Acquisition cost must be positive'),
  status: VehicleStatusEnum.optional(),
  region: z.string().optional()
});

const vehicleUpdateSchema = vehicleCreateSchema.partial();

module.exports = {
  vehicleCreateSchema,
  vehicleUpdateSchema
};
