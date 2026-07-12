const { z } = require('zod');

const maintenanceCreateSchema = z.object({
  vehicle_id: z.string().uuid('Vehicle ID must be a valid UUID'),
  description: z.string().min(1, 'Description is required'),
  cost: z.number().nonnegative('Cost must be non-negative'),
  status: z.enum(['Active', 'Closed']).optional()
});

const maintenanceCloseSchema = z.object({
  cost: z.number().nonnegative('Cost must be non-negative').optional()
});

module.exports = {
  maintenanceCreateSchema,
  maintenanceCloseSchema
};
