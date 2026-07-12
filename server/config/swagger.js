const swaggerJSDoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'TransitOps API',
      version: '1.0.0',
      description: 'TransitOps Transport Operations Platform Backend API Documentation'
    },
    servers: [
      {
        url: '/api/v1',
        description: 'V1 API Namespace'
      }
    ],
    components: {
      securitySchemes: {
        BearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Enter your Bearer token in the format: Bearer <token>'
        }
      },
      schemas: {
        SuccessResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
            data: { type: 'object' },
            message: { type: 'string', example: 'Resource retrieved successfully' },
            meta: {
              type: 'object',
              nullable: true,
              properties: {
                page: { type: 'integer', example: 1 },
                limit: { type: 'integer', example: 10 },
                totalCount: { type: 'integer', example: 42 }
              }
            }
          }
        },
        ErrorResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            error: {
              type: 'object',
              properties: {
                code: { type: 'string', example: 'VALIDATION_ERROR' },
                message: { type: 'string', example: 'Cargo weight exceeds maximum load capacity' },
                details: {
                  type: 'array',
                  nullable: true,
                  items: {
                    type: 'object',
                    properties: {
                      field: { type: 'string', example: 'cargo_weight' },
                      issue: { type: 'string', example: 'Weight is 550kg, maximum allowed is 500kg' }
                    }
                  }
                }
              }
            }
          }
        },
        User: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            email: { type: 'string', format: 'email', example: 'driver@transitops.com' },
            first_name: { type: 'string', example: 'John' },
            last_name: { type: 'string', example: 'Doe' },
            is_active: { type: 'boolean', example: true },
            roles: {
              type: 'array',
              items: { type: 'string' },
              example: ['Driver']
            },
            created_at: { type: 'string', format: 'date-time', example: '2026-07-12T10:00:00.000Z' }
          }
        },
        Vehicle: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            registration_number: { type: 'string', example: 'TX-9988-AB' },
            model: { type: 'string', example: 'Freightliner M2' },
            type: { type: 'string', example: 'Truck' },
            max_load_capacity: { type: 'number', example: 15000.0 },
            current_odometer: { type: 'number', example: 120500.2 },
            acquisition_cost: { type: 'number', example: 85000.0 },
            status: { type: 'string', enum: ['Available', 'On Trip', 'In Shop', 'Retired'], example: 'Available' },
            region: { type: 'string', nullable: true, example: 'Texas' },
            created_at: { type: 'string', format: 'date-time', example: '2026-07-12T10:00:00.000Z' }
          }
        },
        Driver: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            name: { type: 'string', example: 'John Doe' },
            license_number: { type: 'string', example: 'DL-12345678' },
            license_category: { type: 'string', enum: ['A', 'B', 'C', 'D'], example: 'A' },
            license_expiry_date: { type: 'string', format: 'date-time', example: '2028-12-31T00:00:00.000Z' },
            contact_number: { type: 'string', example: '+15550199' },
            safety_score: { type: 'number', example: 95.5 },
            status: { type: 'string', enum: ['Available', 'On Trip', 'Off Duty', 'Suspended'], example: 'Available' },
            created_at: { type: 'string', format: 'date-time', example: '2026-07-12T10:00:00.000Z' }
          }
        },
        Trip: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            source: { type: 'string', example: 'Houston, TX' },
            destination: { type: 'string', example: 'Dallas, TX' },
            vehicle_id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            driver_id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            cargo_weight: { type: 'number', example: 8000.0 },
            planned_distance: { type: 'number', example: 240.0 },
            actual_distance: { type: 'number', nullable: true, example: 242.5 },
            fuel_consumed: { type: 'number', nullable: true, example: 95.0 },
            revenue: { type: 'number', example: 1500.0 },
            status: { type: 'string', enum: ['Draft', 'Dispatched', 'Completed', 'Cancelled'], example: 'Draft' },
            created_at: { type: 'string', format: 'date-time', example: '2026-07-12T10:00:00.000Z' },
            completed_at: { type: 'string', format: 'date-time', nullable: true, example: '2026-07-12T18:00:00.000Z' }
          }
        },
        MaintenanceLog: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            vehicle_id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            description: { type: 'string', example: 'Brake repair and engine check' },
            cost: { type: 'number', example: 450.0 },
            start_date: { type: 'string', format: 'date-time', example: '2026-07-10T00:00:00.000Z' },
            end_date: { type: 'string', format: 'date-time', nullable: true, example: '2026-07-12T00:00:00.000Z' },
            status: { type: 'string', enum: ['Active', 'Closed'], example: 'Active' },
            created_at: { type: 'string', format: 'date-time', example: '2026-07-12T10:00:00.000Z' }
          }
        },
        FuelLog: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            vehicle_id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            liters: { type: 'number', example: 120.0 },
            cost: { type: 'number', example: 180.0 },
            date: { type: 'string', format: 'date-time', example: '2026-07-11T00:00:00.000Z' },
            created_at: { type: 'string', format: 'date-time', example: '2026-07-12T10:00:00.000Z' }
          }
        },
        Expense: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            vehicle_id: { type: 'string', format: 'uuid', example: '3fa85f64-5717-4562-b3fc-2c963f66afa6' },
            expense_type: { type: 'string', enum: ['Toll', 'Maintenance', 'Insurance', 'Other'], example: 'Toll' },
            cost: { type: 'number', example: 45.0 },
            date: { type: 'string', format: 'date-time', example: '2026-07-11T00:00:00.000Z' },
            created_at: { type: 'string', format: 'date-time', example: '2026-07-12T10:00:00.000Z' }
          }
        }
      }
    },
    security: [
      {
        BearerAuth: []
      }
    ]
  },
  apis: ['./server/routes/*.js']
};

const swaggerSpec = swaggerJSDoc(options);

module.exports = swaggerSpec;
