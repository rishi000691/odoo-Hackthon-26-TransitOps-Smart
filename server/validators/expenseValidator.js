const { z } = require('zod');

const ExpenseTypeEnum = z.enum(['Toll', 'Maintenance', 'Insurance', 'Other'], {
  errorMap: () => ({ message: 'Expense type must be one of: Toll, Maintenance, Insurance, Other' })
});

const fuelLogCreateSchema = z.object({
  vehicle_id: z.string().uuid('Vehicle ID must be a valid UUID'),
  liters: z.number().positive('Liters must be positive'),
  cost: z.number().positive('Cost must be positive')
});

const expenseCreateSchema = z.object({
  vehicle_id: z.string().uuid('Vehicle ID must be a valid UUID'),
  expense_type: ExpenseTypeEnum,
  cost: z.number().positive('Cost must be positive')
});

module.exports = {
  fuelLogCreateSchema,
  expenseCreateSchema
};
