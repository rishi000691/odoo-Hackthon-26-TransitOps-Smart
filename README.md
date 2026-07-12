# TransitOps

TransitOps is a professional fleet operations and trip management platform designed to optimize transit logistics and resource allocation. It provides a mobile and web application that coordinates with a secure backend API to monitor vehicles, manage drivers, assign trips, and track expenses. The system enables logistics managers to improve fleet utilization, ensure driver compliance, monitor operational costs, and assess fleet ROI in real-time.

## Features

- **Authentication & Security**: Secure email-based login with role-based routing (e.g., Driver, Fleet Manager, Safety Officer, Financial Analyst) and JWT session token management.
- **Operational Dashboard**: High-level real-time KPI overview showing metrics like active/available vehicles, drivers on duty, active trips, and fleet utilization with quick-filter controls.
- **Vehicle Registry**: Comprehensive CRUD management for fleet vehicles, including model categorization, maximum load capacities, odometer readings, and current statuses.
- **Driver Profiles & Compliance**: Driver registry tracking license categories, expiry dates, safety scores, and real-time statuses (Available, On Trip, Off Duty, Suspended).
- **Trip Dispatching & Lifecycle**: Advanced trip management verifying vehicle/driver availability and cargo weight capacity constraints in real-time before dispatch.
- **Maintenance Logs**: Active tracking of vehicle service periods with automatic vehicle availability status updates (e.g. updating vehicle availability status to "In Shop").
- **Financial Expense Registry**: Detailed recording of fuel consumption, toll fees, maintenance costs, and other administrative expenses per vehicle.
- **Reports & Analytics**: Custom ROI assessments, fuel efficiency tracking, and CSV reports generation for exporting fleet logistics data.

## Technology Stack

| Category | Technologies |
|---|---|
| **Frontend** | Flutter, Bloc (State Management), go_router (Navigation), Dio (Network Client), google_fonts, fl_chart (Data Visualization), flutter_secure_storage |
| **Backend** | Node.js, Express.js, Prisma (ORM), Swagger (API Docs), nodemon |
| **Database** | PostgreSQL |
| **Languages** | Dart, JavaScript (ES6+), SQL |
| **Frameworks/Libraries** | Flutter SDK, Express |
| **Tools** | Node Package Manager (npm), Prisma CLI, Flutter CLI, Git |

## Project Structure

```text
.
├── frontend/
│   └── transitops/
│       ├── lib/
│       │   ├── core/               # App configuration, routes, themes, network, secure storage, shared widgets
│       │   └── features/           # Feature-specific modules
│       │       ├── authentication/ # User login, registration, and logout
│       │       ├── dashboard/      # KPI cards and analytics overview
│       │       ├── drivers/        # Driver profile management and license tracking
│       │       ├── expenses/       # Fuel logs and toll expense tracking
│       │       ├── maintenance/    # Active service schedules and logs
│       │       ├── reports/        # Utilization metrics and export utilities
│       │       ├── trips/          # Trip dispatching and lifecycle tracker
│       │       └── vehicles/       # Vehicle registration and status registry
│       └── pubspec.yaml            # Frontend configuration and dependencies
├── server/
│   ├── config/                     # Environment configuration and validation
│   ├── database/                   # Prisma schema, database client setup, and seed scripts
│   ├── controllers/                # Request/response controller methods
│   ├── routes/                     # REST API endpoint route definitions
│   ├── services/                   # Core business logic and database actions
│   ├── app.js                      # Express application setup and middleware
│   └── server.js                   # API server startup and shutdown scripts
├── package.json                    # Backend project configuration and dependencies
└── API_CONTRACT_DRAFT.md           # API specification draft
```

## Installation

### Prerequisites
- **Flutter SDK** (v3.12.2 or higher)
- **Node.js** (v18 or higher)
- **PostgreSQL** instance

### 1. Clone the Repository
```bash
git clone <repository-url>
cd odoo-Hackthon-26-TransitOps-Smart
```

### 2. Install Dependencies
**Backend Setup:**
Install the backend node packages from the root directory:
```bash
npm install
```

**Frontend Setup:**
Navigate to the transitops folder and fetch the Dart dependencies:
```bash
cd frontend/transitops
flutter pub get
```

### 3. Configure Environment Variables
Create a `.env` file in the root directory. Configure the following variables matching your database setup:
```env
PORT=3000
NODE_ENV=development
JWT_SECRET=supersecretjwtkey123!
JWT_EXPIRES_IN=1d
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/transitops
CORS_ORIGIN=*
```

To initialize the database schema, run the Prisma migration command from the root directory:
```bash
npx prisma db push
```

To seed the database with initial users, roles, and mock fleet details, run:
```bash
npx prisma db seed
```

### 4. Run the Project Locally

**Start the Backend API Server:**
Run from the root directory:
```bash
npm run dev
```
The Express server will start up. You can view the API Swagger docs by navigating to `http://localhost:3000/`.

**Start the Flutter App:**
From the `frontend/transitops` directory, launch the app:
```bash
flutter run
```

## Usage

1. **Authentication**: Sign in using pre-configured user credentials (e.g., `fleetmanager@transitops.com`). The interface routes you to the appropriate view depending on your account role permissions.
2. **Dashboard Overview**: Monitor active trips, available vehicles, and driver statistics. Use the top filters to view subsets of the fleet.
3. **Register Resources**: Navigate to the Vehicles or Drivers tab to add new resources, record odometer entries, or update status indicators.
4. **Dispatch a Trip**: Go to the Trips tab to create a new trip draft. Select an available vehicle and an active driver. The app validates weight capacities and availability status dynamically before allowing dispatch.
5. **Log Expenses**: Track expenses and fuel consumption entries under the Expenses registry to update fleet charts and analyze utilization efficiency.

## Future Improvements

- **GPS Integration**: Adding dynamic map views with GPS tracking to monitor trip vehicles in real-time.
- **Offline Data Sync**: Enabling drivers to record fuel and trip logs offline with automatic sync once a internet connection is established.
- **Odometer Milestones**: Custom email or push notifications for upcoming maintenance schedules based on live vehicle mileage milestones.
- **Predictive Analytics**: Using historical maintenance log history to predict and schedule vehicle inspections.
