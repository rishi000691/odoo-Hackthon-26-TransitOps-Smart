require('dotenv').config();
const assert = require('assert');

const BASE_URL = 'http://localhost:5005/api/v1';

async function run() {
  console.log("=== STARTING ENDPOINT VERIFICATION TESTS FOR NEW SPEC ===");

  // Cleanup potential leftover test records
  const { prisma, pool } = require('./database/db');
  try {
    await prisma.trip.deleteMany({
      where: {
        OR: [
          { vehicle: { registrationNumber: "TEST-002-XYZ" } },
          { driver: { licenseNumber: "LIC-TEST-99" } }
        ]
      }
    });
    await prisma.maintenanceLog.deleteMany({
      where: { vehicle: { registrationNumber: "TEST-002-XYZ" } }
    });
    await prisma.fuelLog.deleteMany({
      where: { vehicle: { registrationNumber: "TEST-002-XYZ" } }
    });
    await prisma.expense.deleteMany({
      where: { vehicle: { registrationNumber: "TEST-002-XYZ" } }
    });
    await prisma.vehicle.deleteMany({
      where: { registrationNumber: "TEST-002-XYZ" }
    });
    await prisma.driver.deleteMany({
      where: { licenseNumber: "LIC-TEST-99" }
    });
    console.log("✓ Leftover test vehicle/driver cleaned up.");
  } catch (err) {
    console.error("Cleanup warning:", err.message);
  }

  let fleetManagerToken;
  let driverToken;
  let safetyOfficerToken;
  let financialAnalystToken;

  // 1. Auth Logins
  console.log("1. Testing Logins...");
  try {
    const fmRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'fleetmanager@transitops.com', password: 'Password123!' })
    });
    const fmData = await fmRes.json();
    assert.equal(fmRes.status, 200);
    assert.ok(fmData.success);
    fleetManagerToken = fmData.data.token;
    assert.ok(fleetManagerToken, "FleetManager login failed");
    console.log("✓ FleetManager logged in successfully.");

    const dRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'driver@transitops.com', password: 'Password123!' })
    });
    const dData = await dRes.json();
    driverToken = dData.data.token;
    assert.ok(driverToken, "Driver login failed");
    console.log("✓ Driver logged in successfully.");

    const soRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'safetyofficer@transitops.com', password: 'Password123!' })
    });
    const soData = await soRes.json();
    safetyOfficerToken = soData.data.token;
    assert.ok(safetyOfficerToken, "SafetyOfficer login failed");
    console.log("✓ SafetyOfficer logged in successfully.");

    const faRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'financialanalyst@transitops.com', password: 'Password123!' })
    });
    const faData = await faRes.json();
    financialAnalystToken = faData.data.token;
    assert.ok(financialAnalystToken, "FinancialAnalyst login failed");
    console.log("✓ FinancialAnalyst logged in successfully.");
  } catch (e) {
    console.error("Auth Test Failed:", e);
    process.exit(1);
  }

  // 2. Fetch Dashboard KPIs
  console.log("2. Fetching KPIs...");
  const kpiRes = await fetch(`${BASE_URL}/reports/kpis`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const kpiData = await kpiRes.json();
  assert.equal(kpiRes.status, 200);
  assert.ok(kpiData.success);
  assert.ok('fleet_utilization_pct' in kpiData.data);
  console.log("✓ KPIs retrieved successfully:", kpiData.data);

  // 3. Create Vehicle & Driver (FleetManager)
  console.log("3. Creating testing Vehicle and Driver...");
  const vRes = await fetch(`${BASE_URL}/vehicles`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      registration_number: "TEST-002-XYZ",
      model: "Transit Custom",
      type: "Van",
      max_load_capacity: 2000.0,
      current_odometer: 1000.0,
      acquisition_cost: 30000.0,
      region: "Texas"
    })
  });
  const vBody = await vRes.json();
  console.log("vBody:", vBody);
  assert.equal(vRes.status, 201);
  const vehicle = vBody.data;
  console.log("✓ Vehicle created successfully:", vehicle.id);

  const drRes = await fetch(`${BASE_URL}/drivers`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      name: "Driver Bob",
      license_number: "LIC-TEST-99",
      license_category: "C",
      license_expiry_date: "2029-05-20",
      contact_number: "555-9988"
    })
  });
  const drBody = await drRes.json();
  assert.equal(drRes.status, 201);
  const driver = drBody.data;
  console.log("✓ Driver created successfully:", driver.id);

  // 4. Test cargoWeight rule (exceeds capacity)
  console.log("4. Testing cargoWeight validation...");
  const tripOverweightRes = await fetch(`${BASE_URL}/trips`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      source: "A",
      destination: "B",
      vehicle_id: vehicle.id,
      driver_id: driver.id,
      cargo_weight: 2500.0, // exceeds 2000
      planned_distance: 100.0,
      status: "Dispatched"
    })
  });
  const overweightErr = await tripOverweightRes.json();
  assert.equal(tripOverweightRes.status, 400);
  assert.equal(overweightErr.error.code, 'EXCEEDS_CAPACITY');
  console.log("✓ Correctly rejected overweight trip.");

  // 5. Dispatch trip -> verify On Trip state
  console.log("5. Dispatching valid trip...");
  const dispatchRes = await fetch(`${BASE_URL}/trips`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      source: "A",
      destination: "B",
      vehicle_id: vehicle.id,
      driver_id: driver.id,
      cargo_weight: 1500.0,
      planned_distance: 100.0,
      status: "Dispatched"
    })
  });
  const dispatchBody = await dispatchRes.json();
  assert.equal(dispatchRes.status, 201);
  const trip = dispatchBody.data;
  assert.equal(trip.status, 'Dispatched');

  // Verify Vehicle & Driver are "On Trip"
  const checkVRes = await fetch(`${BASE_URL}/vehicles/${vehicle.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const checkVBody = await checkVRes.json();
  assert.equal(checkVBody.data.status, 'On Trip');

  const checkDrRes = await fetch(`${BASE_URL}/drivers/${driver.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const checkDrBody = await checkDrRes.json();
  assert.equal(checkDrBody.data.status, 'On Trip');
  console.log("✓ Trip dispatched, statuses updated to 'On Trip'.");

  // 6. Test vehicle/driver busy rule
  console.log("6. Testing busy driver / vehicle rules...");
  const secondTripRes = await fetch(`${BASE_URL}/trips`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      source: "X",
      destination: "Y",
      vehicle_id: vehicle.id,
      driver_id: driver.id,
      cargo_weight: 500.0,
      planned_distance: 50.0,
      status: "Dispatched"
    })
  });
  assert.equal(secondTripRes.status, 400);
  console.log("✓ Correctly rejected assigning busy vehicle/driver.");

  // 7. Complete Trip -> check statuses restore to Available
  console.log("7. Completing trip...");
  const completeRes = await fetch(`${BASE_URL}/trips/${trip.id}/complete`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      actual_distance: 105.5,
      fuel_consumed: 40.0
    })
  });
  const completeBody = await completeRes.json();
  assert.equal(completeRes.status, 200);
  assert.equal(completeBody.data.status, 'Completed');

  const finalVRes = await fetch(`${BASE_URL}/vehicles/${vehicle.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const finalVBody = await finalVRes.json();
  assert.equal(finalVBody.data.status, 'Available');
  assert.equal(Number(finalVBody.data.current_odometer), 1105.5); // 1000 + 105.5

  const finalDrRes = await fetch(`${BASE_URL}/drivers/${driver.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const finalDrBody = await finalDrRes.json();
  assert.equal(finalDrBody.data.status, 'Available');
  console.log("✓ Trip completed, vehicle and driver set to 'Available'. Vehicle odometer updated.");

  // 8. Suspend driver role restrictions
  console.log("8. Testing role restrictions on suspension...");
  // FleetManager tries to suspend
  const suspendFMRes = await fetch(`${BASE_URL}/drivers/${driver.id}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({ status: 'Suspended' })
  });
  assert.equal(suspendFMRes.status, 400);
  const suspendFMErr = await suspendFMRes.json();
  assert.equal(suspendFMErr.error.code, 'SAFETY_OFFICER_ONLY');
  console.log("✓ FleetManager was blocked from suspending driver.");

  // SafetyOfficer suspends
  const suspendSORes = await fetch(`${BASE_URL}/drivers/${driver.id}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${safetyOfficerToken}`
    },
    body: JSON.stringify({ status: 'Suspended' })
  });
  assert.equal(suspendSORes.status, 200);
  console.log("✓ Safety Officer suspended driver successfully.");

  // Try dispatching with suspended driver -> should fail
  const tripSuspendedRes = await fetch(`${BASE_URL}/trips`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      source: "A",
      destination: "B",
      vehicle_id: vehicle.id,
      driver_id: driver.id,
      cargo_weight: 1000.0,
      planned_distance: 100.0,
      status: "Dispatched"
    })
  });
  assert.equal(tripSuspendedRes.status, 400);
  console.log("✓ Correctly blocked dispatching a suspended driver.");

  // Unsuspend driver so they are usable again
  await fetch(`${BASE_URL}/drivers/${driver.id}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${safetyOfficerToken}`
    },
    body: JSON.stringify({ status: 'Available' })
  });

  // 9. Maintenance Log workflow
  console.log("9. Testing maintenance log workflow...");
  const maintRes = await fetch(`${BASE_URL}/maintenance`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      vehicle_id: vehicle.id,
      description: "Replace tyres",
      cost: 500.0
    })
  });
  const maintBody = await maintRes.json();
  assert.equal(maintRes.status, 201);
  const log = maintBody.data;
  assert.equal(log.status, 'Active');

  // Verify vehicle is In Shop
  const maintVRes = await fetch(`${BASE_URL}/vehicles/${vehicle.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const maintVBody = await maintVRes.json();
  assert.equal(maintVBody.data.status, 'In Shop');
  console.log("✓ Vehicle status is In Shop while in maintenance.");

  // Close log
  const closeMaintRes = await fetch(`${BASE_URL}/maintenance/${log.id}/close`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    }
  });
  assert.equal(closeMaintRes.status, 200);

  // Verify vehicle is Available
  const postMaintVRes = await fetch(`${BASE_URL}/vehicles/${vehicle.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const postMaintVBody = await postMaintVRes.json();
  assert.equal(postMaintVBody.data.status, 'Available');
  console.log("✓ Vehicle status is restored to Available on maintenance close.");

  // 10. Logging Expenses
  console.log("10. Testing Expenses Logging...");
  const fuelLogRes = await fetch(`${BASE_URL}/expenses/fuel`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${driverToken}`
    },
    body: JSON.stringify({
      vehicle_id: vehicle.id,
      liters: 50.0,
      cost: 75.0
    })
  });
  assert.equal(fuelLogRes.status, 201);
  console.log("✓ Refueling logged successfully.");

  const tollLogRes = await fetch(`${BASE_URL}/expenses/other`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${financialAnalystToken}`
    },
    body: JSON.stringify({
      vehicle_id: vehicle.id,
      expense_type: "Toll",
      cost: 20.0
    })
  });
  assert.equal(tollLogRes.status, 201);
  console.log("✓ Toll expense logged successfully.");

  // 11. Reports & CSV Format
  console.log("11. Testing reports and CSV output format...");
  const roiRes = await fetch(`${BASE_URL}/reports/roi`, {
    headers: { 'Authorization': `Bearer ${financialAnalystToken}` }
  });
  assert.equal(roiRes.status, 200);
  const roiJson = await roiRes.json();
  console.log("ROI JSON Sample:", roiJson.data[0]);

  // Request CSV via reports/export/csv
  const roiCsvRes = await fetch(`${BASE_URL}/reports/export/csv?report=roi`, {
    headers: { 'Authorization': `Bearer ${financialAnalystToken}` }
  });
  assert.equal(roiCsvRes.status, 200);
  const contentType = roiCsvRes.headers.get('content-type');
  assert.ok(contentType.includes('text/csv'));
  const csvText = await roiCsvRes.text();
  console.log("ROI CSV Head:");
  console.log(csvText.split('\n').slice(0, 3).join('\n'));
  console.log("✓ CSV export works correctly.");

  console.log("\n=== ALL ENDPOINT VERIFICATION TESTS PASSED SUCCESSFULLY! ===");
  await pool.end();
}

run().catch(console.error);
