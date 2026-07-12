const assert = require('assert');

const BASE_URL = 'http://localhost:3000';

async function run() {
  console.log("=== STARTING ENDPOINT VERIFICATION TESTS ===");

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
    fleetManagerToken = fmData.token;
    assert.ok(fleetManagerToken, "FleetManager login failed");
    console.log("✓ FleetManager logged in.");

    const dRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'driver@transitops.com', password: 'Password123!' })
    });
    const dData = await dRes.json();
    driverToken = dData.token;
    assert.ok(driverToken, "Driver login failed");
    console.log("✓ Driver logged in.");

    const soRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'safetyofficer@transitops.com', password: 'Password123!' })
    });
    const soData = await soRes.json();
    safetyOfficerToken = soData.token;
    assert.ok(safetyOfficerToken, "SafetyOfficer login failed");
    console.log("✓ SafetyOfficer logged in.");

    const faRes = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'financialanalyst@transitops.com', password: 'Password123!' })
    });
    const faData = await faRes.json();
    financialAnalystToken = faData.token;
    assert.ok(financialAnalystToken, "FinancialAnalyst login failed");
    console.log("✓ FinancialAnalyst logged in.");
  } catch (e) {
    console.error("Auth Test Failed:", e);
    process.exit(1);
  }

  // 2. Fetch Dashboard KPIs
  console.log("2. Fetching KPIs...");
  const kpiRes = await fetch(`${BASE_URL}/dashboard/kpis`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const kpiData = await kpiRes.json();
  console.log("KPIs Data:", kpiData);
  assert.equal(kpiRes.status, 200);
  assert.ok('fleetUtilizationPercentage' in kpiData);

  // 3. Create Vehicle & Driver (FleetManager)
  console.log("3. Creating testing Vehicle and Driver...");
  const vRes = await fetch(`${BASE_URL}/vehicles`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      registrationNumber: "TEST-001-XYZ",
      name: "Test Delivery Van",
      type: "Van",
      maxLoadCapacity: 2000.0,
      odometer: 1000.0,
      acquisitionCost: 30000.0
    })
  });
  const vehicle = await vRes.json();
  assert.equal(vRes.status, 201);
  console.log("✓ Vehicle created:", vehicle.id);

  const drRes = await fetch(`${BASE_URL}/drivers`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      name: "Driver Bob",
      licenseNumber: "LIC-TEST-88",
      licenseCategory: "Class C",
      licenseExpiryDate: "2029-05-20",
      contactNumber: "555-9988"
    })
  });
  const driver = await drRes.json();
  assert.equal(drRes.status, 201);
  console.log("✓ Driver created:", driver.id);

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
      vehicleId: vehicle.id,
      driverId: driver.id,
      cargoWeight: 2500.0, // exceeds 2000
      plannedDistance: 100.0,
      status: "Dispatched"
    })
  });
  const overweightErr = await tripOverweightRes.json();
  assert.equal(tripOverweightRes.status, 400);
  assert.equal(overweightErr.error.code, 'EXCEEDS_CAPACITY');
  console.log("✓ Correctly rejected overweight trip.");

  // 5. Dispatch trip -> verify OnTrip state
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
      vehicleId: vehicle.id,
      driverId: driver.id,
      cargoWeight: 1500.0,
      plannedDistance: 100.0,
      status: "Dispatched"
    })
  });
  const trip = await dispatchRes.json();
  assert.equal(dispatchRes.status, 201);
  assert.equal(trip.status, 'Dispatched');

  // Verify Vehicle & Driver are OnTrip
  const checkVRes = await fetch(`${BASE_URL}/vehicles/${vehicle.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const updatedVehicle = await checkVRes.json();
  assert.equal(updatedVehicle.status, 'OnTrip');

  const checkDrRes = await fetch(`${BASE_URL}/drivers/${driver.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const updatedDriver = await checkDrRes.json();
  assert.equal(updatedDriver.status, 'OnTrip');
  console.log("✓ Trip dispatched, statuses updated to OnTrip.");

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
      vehicleId: vehicle.id,
      driverId: driver.id,
      cargoWeight: 500.0,
      plannedDistance: 50.0,
      status: "Dispatched"
    })
  });
  assert.equal(secondTripRes.status, 400);
  console.log("✓ Correctly rejected assigning busy vehicle/driver.");

  // 7. Complete Trip -> check statuses restore to Available
  console.log("7. Completing trip...");
  const completeRes = await fetch(`${BASE_URL}/trips/${trip.id}/complete`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${fleetManagerToken}`
    },
    body: JSON.stringify({
      actualDistance: 105.5,
      fuelConsumed: 40.0
    })
  });
  const completedTrip = await completeRes.json();
  assert.equal(completeRes.status, 200);
  assert.equal(completedTrip.status, 'Completed');

  const finalVRes = await fetch(`${BASE_URL}/vehicles/${vehicle.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const finalVehicle = await finalVRes.json();
  assert.equal(finalVehicle.status, 'Available');
  assert.equal(finalVehicle.odometer, 1105.5); // 1000 + 105.5

  const finalDrRes = await fetch(`${BASE_URL}/drivers/${driver.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const finalDriver = await finalDrRes.json();
  assert.equal(finalDriver.status, 'Available');
  console.log("✓ Trip completed, vehicle and driver set to Available. Vehicle odometer updated.");

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
  console.log("✓ SafetyOfficer suspended driver successfully.");

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
      vehicleId: vehicle.id,
      driverId: driver.id,
      cargoWeight: 1000.0,
      plannedDistance: 100.0,
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
      vehicleId: vehicle.id,
      description: "Replace tires",
      cost: 500.0
    })
  });
  const log = await maintRes.json();
  assert.equal(maintRes.status, 201);
  assert.equal(log.status, 'Active');

  // Verify vehicle is InShop
  const maintVRes = await fetch(`${BASE_URL}/vehicles/${vehicle.id}`, {
    headers: { 'Authorization': `Bearer ${fleetManagerToken}` }
  });
  const maintVehicle = await maintVRes.json();
  assert.equal(maintVehicle.status, 'InShop');
  console.log("✓ Vehicle status is InShop while in maintenance.");

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
  const postMaintVehicle = await postMaintVRes.json();
  assert.equal(postMaintVehicle.status, 'Available');
  console.log("✓ Vehicle status is restored to Available on maintenance close.");

  // 10. Reports & CSV Format
  console.log("10. Testing reports and CSV output format...");
  const roiRes = await fetch(`${BASE_URL}/reports/vehicle-roi`, {
    headers: { 'Authorization': `Bearer ${financialAnalystToken}` }
  });
  assert.equal(roiRes.status, 200);
  const roiJson = await roiRes.json();
  console.log("ROI JSON Sample:", roiJson[0]);

  // Request CSV
  const roiCsvRes = await fetch(`${BASE_URL}/reports/vehicle-roi?format=csv`, {
    headers: { 'Authorization': `Bearer ${financialAnalystToken}` }
  });
  assert.equal(roiCsvRes.status, 200);
  const contentType = roiCsvRes.headers.get('content-type');
  assert.ok(contentType.includes('text/csv'));
  const csvText = await roiCsvRes.text();
  console.log("ROI CSV Head:");
  console.log(csvText.split('\n').slice(0, 3).join('\n'));
  console.log("✓ CSV format works correctly.");

  console.log("\n=== ALL ENDPOINT VERIFICATION TESTS PASSED SUCCESSFULLY! ===");
}

run().catch(console.error);
