# Flutter Frontend Architecture Specification

This document details the frontend standard for the **TransitOps** mobile/web application. The project is implemented in Flutter, strictly following the **Feature-Based BLoC (Business Logic Component) Architecture**.

---

## 1. Directory Structure

The frontend project is structured in a feature-first pattern to decouple components and ensure modularity:

```text
lib/
│
├── core/
│   ├── config/          # App flavor settings, system variables
│   ├── constants/       # Global assets, spacing, strings, keys
│   ├── routes/          # AppRouter using go_router
│   ├── services/        # Non-feature global services (e.g. Device info)
│   ├── network/         # Http clients, API interceptors, SSL Pinning (Dio client)
│   ├── storage/         # Secure storage (FlutterSecureStorage) and Key-Value caches (Hive/SharedPrefs)
│   ├── theme/           # Premium Light and Dark theme configurations
│   ├── widgets/         # Shared global UI elements (Custom buttons, indicators, layouts)
│   ├── utils/           # Formatting, date functions, UI helpers
│   ├── extensions/      # Dart and Flutter extensions (Context, String, Num extensions)
│   └── exceptions/      # Core exception mapping and failure definitions
│
├── features/
│   ├── authentication/  # Login, logout, user session tracking
│   ├── dashboard/       # KPI cards, quick actions, analytics widgets
│   ├── vehicles/        # Vehicle registry, CRUD operations
│   ├── drivers/         # Driver profiles, license tracking, safety ratings
│   ├── trips/           # Trip dispatching, lifecycle management
│   ├── maintenance/     # Active maintenance logs, scheduler
│   ├── expenses/        # Fuel logs, toll expenses, maintenance costs
│   └── reports/         # Operational metrics, ROI charts, exports
│
└── main.dart            # MultiBlocProvider initialization and app entry
```

---

## 2. Feature-First Folder Layout

Every folder in the `features/` directory must follow this sub-folder structure:

```text
feature_name/
│
├── blocs/
│   ├── feature_bloc.dart
│   ├── feature_event.dart
│   └── feature_state.dart
│
├── models/             # Data models with serialization logic (freezed or json_serializable)
│
├── repositories/       # Single point of contact for data retrieval, abstracts network/local stores
│
├── services/           # Service-level API requests specific to this feature
│
├── screens/            # Screens/Pages representing full viewport layouts
│
├── widgets/            # Local UI components specific to this feature only
│
└── utils/              # Specialized helper classes or validators for this feature
```

---

## 3. Data Flow & State Management

TransitOps utilizes the **BLoC Pattern** to enforce unidirectional data flow. 

```mermaid
graph LR
    Screen[UI Screen / Widget] -- "Dispatches Event" --> Bloc[BLoC Layer]
    Bloc -- "Invokes Method" --> Repository[Repository Layer]
    Repository -- "Calls API Client" --> Service[Feature Service Layer]
    Service -- "Http Response" --> Repository
    Repository -- "Serializes JSON to Model" --> Bloc
    Bloc -- "Emits State" --> Screen
```

- **Events (Inputs)**: User actions (e.g., `AddVehicleSubmitEvent`) or lifecycle triggers.
- **States (Outputs)**: UI states (e.g., `VehicleLoading`, `VehicleLoaded`, `VehicleError`).
- **BLoC Logic**: Maps incoming Events to outgoing States. Employs Repositories to load and commit data.

---

## 4. Feature Specifications

### 4.1 Authentication
- **Purpose**: Authenticates user credentials and maintains the JWT session.
- **Responsibilities**: Access token refresh, logout invalidation, role-based screen routing.
- **State Management**: `AuthBloc` (emits `Unauthenticated`, `Authenticating`, `Authenticated`, `AuthError`).
- **Data Flow**: `LoginScreen` &rarr; `AuthBloc` &rarr; `AuthRepository` &rarr; `AuthService` &rarr; API POST `/auth/login`.
- **Validation**: Enforces email format and password minimum lengths before dispatching API calls.
- **Error Handling**: Catches 401 Unauthorized errors and maps them to an user-friendly `Invalid credentials` message.
- **Navigation**: Routes authenticated users to the `/dashboard` page and redirects unauthenticated users to `/login`.

### 4.2 Dashboard
- **Purpose**: High-level operational summary for immediate overview.
- **Responsibilities**: Renders KPI cards (Active Vehicles, Available Vehicles, Drivers On Duty) and filter controllers.
- **State Management**: `DashboardBloc` (emits `DashboardLoading`, `DashboardLoaded`, `DashboardError`).
- **Data Flow**: `DashboardScreen` &rarr; `DashboardBloc` &rarr; `DashboardRepository` &rarr; API GET `/reports/kpis`.
- **Shared Widgets**: `KpiCard` (reusable numeric badge), `QuickFilterRow`.

### 4.3 Vehicle Registry
- **Purpose**: Manages the fleet database entries.
- **Responsibilities**: Vehicle CRUD operations and status validation.
- **State Management**: `VehicleBloc` (triggers list updates, add, update, delete).
- **Data Flow**: Employs `VehicleRepository` which fetches from `/vehicles`.
- **Validation**:
  - Registration number must match standard syntax.
  - Maximum load capacity must be greater than zero.
- **Error Handling**: Catches unique constraint errors (e.g., duplicate registration numbers) from the server and displays inline warnings.

### 4.4 Driver Management
- **Purpose**: Manages driver registration, statuses, and compliance.
- **Responsibilities**: Driver profile updates, license tracking.
- **State Management**: `DriverBloc`.
- **Data Flow**: Fetches from `/drivers`.
- **Validation**: Checks license expiry date. If expired, highlights driver profile and displays warnings.
- **Shared Widgets**: `DriverStatusChip` (color codes: Green = Available, Red = Suspended/Off Duty, Blue = On Trip).

### 4.5 Trip Management
- **Purpose**: Orchestrates cargo dispatch logs.
- **Responsibilities**: Validates driver/vehicle availability, verifies load constraints, manages trip lifecycle.
- **State Management**: `TripBloc`.
- **Data Flow**: Forms dispatch requests pointing to `/trips` API.
- **Validation (Frontend Guards)**:
  - Blocks dispatch if cargo weight > vehicle's maximum capacity.
  - Blocks dispatch if selected driver has an expired license or is already `On Trip`.
  - Blocks dispatch if selected vehicle is `In Shop` or already `On Trip`.
- **Navigation**: Clicking an active trip opens a dynamic progress tracker page.

### 4.6 Maintenance
- **Purpose**: Logs and manages vehicle service periods.
- **Responsibilities**: Sends vehicles to the maintenance pool, tracks active issues.
- **State Management**: `MaintenanceBloc`.
- **Data Flow**: Calls `/maintenance` endpoints.
- **Automatic Transitions**: Creating an active maintenance record updates the target vehicle to `In Shop` status across all other components.

### 4.7 Fuel & Expenses
- **Purpose**: Financial registry for operational spend.
- **Responsibilities**: Fuel log entries and non-fuel expense recording.
- **State Management**: `ExpenseBloc`.
- **Data Flow**: Commits entries to `/expenses/fuel` and `/expenses/other`.

### 4.8 Reports & Analytics
- **Purpose**: Computes business ROI and efficiency.
- **Responsibilities**: Visualizes fuel efficiency graphs and fleet utilization trends.
- **Dependencies**: `fl_chart` library for data plotting.
- **CSV Export**: Employs file-saving platform services to save downloaded reports to mobile storage.

---

## 5. Core Infrastructure Rules

### Theme Management
- The UI follows a modern dark/light system with custom HSL palette mapping.
- Standard Font: `Outfit` (loaded via `google_fonts` package).
- Renders rounded, glassmorphism cards with fine-grain border strokes to feel premium.

### Network Client
- Powered by `Dio`.
- Includes interceptors to automatically attach Bearer JWT tokens to requests, and intercept 401 statuses to trigger token refreshing or session logouts.

### Secure Storage
- Stores access/refresh tokens securely using `flutter_secure_storage`.
- Never saves sensitive customer data in plain text in Shared Preferences.
