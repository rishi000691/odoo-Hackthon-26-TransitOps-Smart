const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
require('dotenv').config();

async function main() {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  const adapter = new PrismaPg(pool);
  const prisma = new PrismaClient({ adapter });

  console.log("Seeding database...");

  // Clear existing data (in order of dependencies)
  await prisma.expense.deleteMany();
  await prisma.fuelLog.deleteMany();
  await prisma.maintenanceLog.deleteMany();
  await prisma.trip.deleteMany();
  await prisma.userRole.deleteMany();
  await prisma.user.deleteMany();
  await prisma.role.deleteMany();
  await prisma.vehicle.deleteMany();
  await prisma.driver.deleteMany();

  // 1. Seed Roles
  const roles = {};
  const roleNames = ['Fleet Manager', 'Driver', 'Safety Officer', 'Financial Analyst'];
  for (const name of roleNames) {
    const role = await prisma.role.create({
      data: { name }
    });
    roles[name] = role;
  }
  console.log("Seeded roles.");

  // 2. Seed Users & UserRoles
  const passwordHash = await bcrypt.hash("Password123!", 10);

  const usersToCreate = [
    { email: 'fleetmanager@transitops.com', firstName: 'Alice', lastName: 'Manager', roleName: 'Fleet Manager' },
    { email: 'driver@transitops.com', firstName: 'Bob', lastName: 'Driver', roleName: 'Driver' },
    { email: 'safetyofficer@transitops.com', firstName: 'Charlie', lastName: 'Officer', roleName: 'Safety Officer' },
    { email: 'financialanalyst@transitops.com', firstName: 'Diana', lastName: 'Analyst', roleName: 'Financial Analyst' },
  ];

  for (const item of usersToCreate) {
    const user = await prisma.user.create({
      data: {
        email: item.email,
        passwordHash,
        firstName: item.firstName,
        lastName: item.lastName,
        isActive: true,
      }
    });

    await prisma.userRole.create({
      data: {
        userId: user.id,
        roleId: roles[item.roleName].id
      }
    });
  }
  console.log("Seeded users with assigned roles.");

  // 3. Seed Vehicles
  const vehicle1 = await prisma.vehicle.create({
    data: {
      registrationNumber: "TX-9988-AB",
      model: "Freightliner M2",
      type: "Truck",
      maxLoadCapacity: 15000.0,
      currentOdometer: 120500.2,
      acquisitionCost: 85000.0,
      status: "Available",
      region: "Texas"
    }
  });

  const vehicle2 = await prisma.vehicle.create({
    data: {
      registrationNumber: "NY-4422-CD",
      model: "Ford Transit 350",
      type: "Van",
      maxLoadCapacity: 3500.0,
      currentOdometer: 45200.5,
      acquisitionCost: 45000.0,
      status: "In Shop",
      region: "New York"
    }
  });
  console.log("Seeded vehicles.");

  // 4. Seed Drivers
  const driverActive = await prisma.driver.create({
    data: {
      name: "John Doe",
      licenseNumber: "DL-12345678",
      licenseCategory: "A",
      licenseExpiryDate: new Date("2028-12-31"),
      contactNumber: "+15550199",
      safetyScore: 95.5,
      status: "Available"
    }
  });

  const driverSuspended = await prisma.driver.create({
    data: {
      name: "Jane Smith",
      licenseNumber: "DL-87654321",
      licenseCategory: "B",
      licenseExpiryDate: new Date("2025-01-01"),
      contactNumber: "+15550288",
      safetyScore: 60.0,
      status: "Suspended"
    }
  });
  console.log("Seeded drivers.");

  // 5. Seed Logs
  await prisma.maintenanceLog.create({
    data: {
      vehicleId: vehicle2.id,
      description: "Brake repair and engine check",
      cost: 450.0,
      startDate: new Date("2026-07-10"),
      status: "Active"
    }
  });

  await prisma.fuelLog.create({
    data: {
      vehicleId: vehicle1.id,
      liters: 120.0,
      cost: 180.0,
      date: new Date("2026-07-11")
    }
  });

  await prisma.expense.create({
    data: {
      vehicleId: vehicle1.id,
      expenseType: "Toll",
      cost: 45.0,
      date: new Date("2026-07-11")
    }
  });

  // Completed trip
  await prisma.trip.create({
    data: {
      source: "Houston, TX",
      destination: "Dallas, TX",
      vehicleId: vehicle1.id,
      driverId: driverActive.id,
      cargoWeight: 8000.0,
      plannedDistance: 240.0,
      actualDistance: 242.5,
      fuelConsumed: 95.0,
      revenue: 1500.0,
      status: "Completed",
      createdAt: new Date("2026-07-09"),
      completedAt: new Date("2026-07-09T18:00:00Z")
    }
  });

  console.log("Seeded trip, maintenance, fuel, and expense logs.");
  console.log("Database seeding completed successfully!");

  await pool.end();
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
