const { z } = require('zod');

const DriverStatusEnum = z.enum(['Available', 'On Trip', 'Off Duty', 'Suspended']);
const LicenseCategoryEnum = z.enum(['A', 'B', 'C', 'D']);

const driverCreateSchema = z.object({
  name: z.string().min(1, 'Driver name is required'),
  license_number: z.string().min(1, 'License number is required'),
  license_category: LicenseCategoryEnum,
  license_expiry_date: z.preprocess((val) => {
    if (typeof val === 'string') {
      const parsedDate = new Date(val);
      return isNaN(parsedDate.getTime()) ? val : parsedDate;
    }
    return val;
  }, z.date({
    required_error: 'License expiry date is required',
    invalid_type_error: 'License expiry date must be a valid date'
  })),
  contact_number: z.string().min(1, 'Contact number is required'),
  safety_score: z.number().min(0).max(100).optional(),
  status: DriverStatusEnum.optional()
});

const driverUpdateSchema = driverCreateSchema.partial();

module.exports = {
  driverCreateSchema,
  driverUpdateSchema
};
