const { z } = require('zod');

const tripCreateSchema = z.object({
  source: z.string().min(1, 'Source is required'),
  destination: z.string().min(1, 'Destination is required'),
  vehicle_id: z.string().uuid('Vehicle ID must be a valid UUID'),
  driver_id: z.string().uuid('Driver ID must be a valid UUID'),
  cargo_weight: z.number().positive('Cargo weight must be positive'),
  planned_distance: z.number().positive('Planned distance must be positive'),
  status: z.enum(['Draft', 'Dispatched']).optional()
});

const tripCompleteSchema = z.object({
  actual_distance: z.number().positive('Actual distance must be positive'),
  fuel_consumed: z.number().positive('Fuel consumed must be positive'),
  revenue: z.number().nonnegative('Revenue must be non-negative').optional()
});

module.exports = {
  tripCreateSchema,
  tripCompleteSchema
};
