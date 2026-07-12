# TransitOps API Contract Draft (V1)

This document lists every endpoint, required role, request payload, and response envelope using the standard `snake_case` keys matching the Flutter serializers.

---

## 1. Authentication (`/api/v1/auth`)

### Register User
* **Method**: `POST`
* **Path**: `/api/v1/auth/register`
* **Access**: Public
* **Request Body**:
  ```json
  {
    "email": "user@transitops.com",
    "password": "Password123!",
    "first_name": "Alice",
    "last_name": "Smith",
    "role_name": "Driver"
  }
  ```
* **Success Response (201 Created)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "user-uuid-1234",
      "email": "user@transitops.com",
      "first_name": "Alice",
      "last_name": "Smith",
      "is_active": true,
      "created_at": "2026-07-12T10:00:00.000Z"
    },
    "message": "User registered successfully"
  }
  ```

### User Login
* **Method**: `POST`
* **Path**: `/api/v1/auth/login`
* **Access**: Public
* **Request Body**:
  ```json
  {
    "email": "fleetmanager@transitops.com",
    "password": "Password123!"
  }
  ```
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "user": {
        "id": "user-uuid-1234",
        "email": "fleetmanager@transitops.com",
        "first_name": "Alice",
        "last_name": "Manager",
        "roles": ["Fleet Manager"]
      }
    },
    "message": "Login successful"
  }
  ```

### User Logout
* **Method**: `POST`
* **Path**: `/api/v1/auth/logout`
* **Access**: Authenticated
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "message": "Logout successful"
  }
  ```

---

## 2. Vehicles (`/api/v1/vehicles`)

### Get All Vehicles
* **Method**: `GET`
* **Path**: `/api/v1/vehicles`
* **Access**: Authenticated (Any role)
* **Query Parameters**: `type` (optional), `status` (optional), `region` (optional), `available_for_trip` (optional boolean string)
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "vehicle-uuid-123",
        "registration_number": "TX-9988-AB",
        "model": "Freightliner M2",
        "type": "Truck",
        "max_load_capacity": 15000.0,
        "current_odometer": 120500.2,
        "acquisition_cost": 85000.0,
        "status": "Available",
        "region": "Texas",
        "created_at": "2026-07-12T10:00:00.000Z"
      }
    ],
    "message": "Vehicles retrieved successfully"
  }
  ```

### Get Vehicle by ID
* **Method**: `GET`
* **Path**: `/api/v1/vehicles/:id`
* **Access**: Authenticated (Any role)
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "vehicle-uuid-123",
      "registration_number": "TX-9988-AB",
      "model": "Freightliner M2",
      "type": "Truck",
      "max_load_capacity": 15000.0,
      "current_odometer": 120500.2,
      "acquisition_cost": 85000.0,
      "status": "Available",
      "region": "Texas",
      "created_at": "2026-07-12T10:00:00.000Z"
    },
    "message": "Vehicle details retrieved successfully"
  }
  ```

### Register Vehicle
* **Method**: `POST`
* **Path**: `/api/v1/vehicles`
* **Access**: "Fleet Manager" only
* **Request Body**:
  ```json
  {
    "registration_number": "TX-9988-AB",
    "model": "Freightliner M2",
    "type": "Truck",
    "max_load_capacity": 15000.0,
    "current_odometer": 120500.2,
    "acquisition_cost": 85000.0,
    "region": "Texas"
  }
  ```
* **Success Response (201 Created)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "vehicle-uuid-123",
      "registration_number": "TX-9988-AB",
      "model": "Freightliner M2",
      "type": "Truck",
      "max_load_capacity": 15000.0,
      "current_odometer": 120500.2,
      "acquisition_cost": 85000.0,
      "status": "Available",
      "region": "Texas",
      "created_at": "2026-07-12T10:00:00.000Z"
    },
    "message": "Vehicle registered successfully"
  }
  ```

### Update Vehicle Registry
* **Method**: `PUT`
* **Path**: `/api/v1/vehicles/:id`
* **Access**: "Fleet Manager" only
* **Request Body**: Partial keys of POST payload plus `"status"` optional.
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "vehicle-uuid-123",
      "registration_number": "TX-9988-AB",
      "status": "In Shop"
    },
    "message": "Vehicle registry updated successfully"
  }
  ```

### Retire Vehicle (Soft Delete)
* **Method**: `DELETE`
* **Path**: `/api/v1/vehicles/:id`
* **Access**: "Fleet Manager" only
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "vehicle-uuid-123",
      "status": "Retired"
    },
    "message": "Vehicle retired successfully"
  }
  ```

---

## 3. Drivers (`/api/v1/drivers`)

### Get All Drivers
* **Method**: `GET`
* **Path**: `/api/v1/drivers`
* **Access**: Authenticated (Any role)
* **Query Parameters**: `status` (optional), `available_for_trip` (optional boolean string)
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "driver-uuid-456",
        "name": "John Doe",
        "license_number": "DL-12345678",
        "license_category": "A",
        "license_expiry_date": "2028-12-31T00:00:00.000Z",
        "contact_number": "+15550199",
        "safety_score": 95.5,
        "status": "Available"
      }
    ],
    "message": "Drivers retrieved successfully"
  }
  ```

### Register Driver
* **Method**: `POST`
* **Path**: `/api/v1/drivers`
* **Access**: "Fleet Manager" or "Safety Officer" only
* **Request Body**:
  ```json
  {
    "name": "John Doe",
    "license_number": "DL-12345678",
    "license_category": "A",
    "license_expiry_date": "2028-12-31",
    "contact_number": "+15550199",
    "safety_score": 95.5
  }
  ```
* **Success Response (201 Created)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "driver-uuid-456",
      "name": "John Doe",
      "license_number": "DL-12345678",
      "license_category": "A",
      "license_expiry_date": "2028-12-31T00:00:00.000Z",
      "contact_number": "+15550199",
      "safety_score": 95.5,
      "status": "Available",
      "created_at": "2026-07-12T10:00:00.000Z"
    },
    "message": "Driver registered successfully"
  }
  ```

### Update Driver Details
* **Method**: `PUT`
* **Path**: `/api/v1/drivers/:id`
* **Access**: "Fleet Manager" or "Safety Officer" only
* **Note**: Only "Safety Officer" role is authorized to update a driver's status to `"Suspended"`.
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "driver-uuid-456",
      "status": "Suspended"
    },
    "message": "Driver details updated successfully"
  }
  ```

---

## 4. Trips (`/api/v1/trips`)

### Create Trip (Draft)
* **Method**: `POST`
* **Path**: `/api/v1/trips`
* **Access**: "Driver" or "Fleet Manager" only
* **Request Body**:
  ```json
  {
    "source": "Houston, TX",
    "destination": "Dallas, TX",
    "vehicle_id": "vehicle-uuid-123",
    "driver_id": "driver-uuid-456",
    "cargo_weight": 8000.0,
    "planned_distance": 240.0
  }
  ```
* **Success Response (201 Created)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "trip-uuid-789",
      "source": "Houston, TX",
      "destination": "Dallas, TX",
      "status": "Draft"
    },
    "message": "Trip created successfully"
  }
  ```

### Dispatch Trip
* **Method**: `POST` or `PUT`
* **Path**: `/api/v1/trips/:id/dispatch`
* **Access**: "Driver" or "Fleet Manager" only
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "trip-uuid-789",
      "status": "Dispatched"
    },
    "message": "Trip dispatched successfully"
  }
  ```

### Complete Trip
* **Method**: `POST` or `PUT`
* **Path**: `/api/v1/trips/:id/complete`
* **Access**: "Driver" or "Fleet Manager" only
* **Request Body**:
  ```json
  {
    "actual_distance": 242.5,
    "fuel_consumed": 95.0,
    "revenue": 1500.0
  }
  ```
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "trip-uuid-789",
      "status": "Completed"
    },
    "message": "Trip completed successfully"
  }
  ```

---

## 5. Maintenance (`/api/v1/maintenance`)

### Create Maintenance Log
* **Method**: `POST`
* **Path**: `/api/v1/maintenance`
* **Access**: "Fleet Manager" only
* **Request Body**:
  ```json
  {
    "vehicle_id": "vehicle-uuid-123",
    "description": "Brake pad replacement",
    "cost": 450.0
  }
  ```
* **Success Response (201 Created)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "log-uuid-abc",
      "status": "Active"
    },
    "message": "Maintenance log created successfully"
  }
  ```

### Close Maintenance Log
* **Method**: `POST` or `PUT`
* **Path**: `/api/v1/maintenance/:id/close`
* **Access**: "Fleet Manager" only
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "log-uuid-abc",
      "status": "Closed"
    },
    "message": "Maintenance log closed successfully"
  }
  ```

---

## 6. Expenses & Refuel Logs (`/api/v1/expenses`)

### Record Fuel Log
* **Method**: `POST`
* **Path**: `/api/v1/expenses/fuel`
* **Access**: "Driver", "Fleet Manager", or "Financial Analyst" only
* **Request Body**:
  ```json
  {
    "vehicle_id": "vehicle-uuid-123",
    "liters": 120.0,
    "cost": 180.0
  }
  ```
* **Success Response (201 Created)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "fuel-uuid-xyz"
    },
    "message": "Fuel log recorded successfully"
  }
  ```

### Record Toll or Other Expense
* **Method**: `POST`
* **Path**: `/api/v1/expenses/other`
* **Access**: "Fleet Manager" or "Financial Analyst" only
* **Request Body**:
  ```json
  {
    "vehicle_id": "vehicle-uuid-123",
    "expense_type": "Toll",
    "cost": 45.0
  }
  ```
* **Success Response (201 Created)**:
  ```json
  {
    "success": true,
    "data": {
      "id": "expense-uuid-xyz"
    },
    "message": "Expense recorded successfully"
  }
  ```

---

## 7. Reports & Analytics (`/api/v1/reports`)

### Get Dashboard KPIs
* **Method**: `GET`
* **Path**: `/api/v1/reports/kpis`
* **Access**: Authenticated (Any role)
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": {
      "active_vehicles": 1,
      "available_vehicles": 4,
      "vehicles_in_maintenance": 1,
      "active_trips": 0,
      "pending_trips": 1,
      "drivers_on_duty": 5,
      "fleet_utilization_pct": 20.0
    },
    "message": "Dashboard KPIs retrieved successfully"
  }
  ```

### Get Vehicle ROI Report
* **Method**: `GET`
* **Path**: `/api/v1/reports/roi`
* **Access**: "Fleet Manager" or "Financial Analyst" only
* **Success Response (200 OK)**:
  ```json
  {
    "success": true,
    "data": [
      {
        "vehicle_id": "vehicle-uuid-123",
        "registration_number": "TX-9988-AB",
        "acquisition_cost": 85000,
        "revenue": 1500,
        "maintenance_cost": 0,
        "fuel_cost": 0,
        "roi": 1.76
      }
    ],
    "message": "Vehicle ROI report retrieved successfully"
  }
  ```

### Export CSV
* **Method**: `GET`
* **Path**: `/api/v1/reports/export/csv`
* **Access**: "Fleet Manager" or "Financial Analyst" only
* **Query Parameters**: `report` (one of `roi`, `utilization`, `efficiency`, `cost`)
* **Success Response (200 OK)**:
  * **Content-Type**: `text/csv`
  * **Content-Disposition**: `attachment; filename="transitops-report-YYYY-MM-DD.csv"`
  * Returns CSV spreadsheet format data.

---

## Standard Error Envelope (Example)

When any request validation fails (e.g. cargo weight validation, invalid format, missing field):
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "cargo_weight",
        "issue": "Cargo weight must be positive"
      }
    ]
  }
}
```
If access is denied due to roles:
```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "Access denied. Roles 'Driver' are not authorized to access this resource.",
    "details": null
  }
}
```
