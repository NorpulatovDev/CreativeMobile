# Creative O'quv Markazi - Application Architecture

## Overview

Creative O'quv Markazi is a Flutter-based learning center management application. It manages students, teachers, groups, payments, attendance, inquiries, and generates reports. The app follows a **clean architecture** pattern with **offline-first** data handling.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | Flutter |
| State Management | flutter_bloc (BLoC pattern) |
| Navigation | go_router |
| Networking | Dio (REST API) |
| Local Storage | Hive CE (offline cache), SharedPreferences, FlutterSecureStorage |
| Dependency Injection | GetIt (manual registration) |
| Serialization | json_serializable / json_annotation |
| Offline Support | connectivity_plus, custom sync engine |

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── api/
│   │   └── api_client.dart            # Dio HTTP client with auth interceptor
│   ├── di/
│   │   └── injection.dart             # GetIt dependency registration
│   ├── error/
│   │   └── failures.dart              # Typed failure classes
│   ├── network/
│   │   └── connectivity_service.dart  # Online/offline detection
│   ├── offline/
│   │   ├── hive_helpers.dart          # Safe Hive serialization helpers
│   │   ├── id_mapping.dart            # Temp ID → server ID mapping
│   │   ├── sync_engine.dart           # Background sync processor
│   │   ├── sync_queue.dart            # Pending mutations queue
│   │   ├── sync_status_cubit.dart     # Sync state for UI
│   │   └── temp_id_generator.dart     # Negative temp ID generator
│   ├── router/
│   │   ├── app_router.dart            # GoRouter config + shell scaffold
│   │   └── routes.dart                # Route path constants
│   ├── storage/
│   │   └── token_storage.dart         # JWT token persistence
│   ├── theme/
│   │   └── app_theme.dart             # Material theme + color constants
│   └── widgets/
│       ├── app_widgets.dart           # Shared reusable widgets
│       └── sync_status_banner.dart    # Offline/syncing status bar
└── features/
    ├── auth/                          # Login, JWT auth
    ├── students/                      # Student CRUD
    ├── teachers/                      # Teacher CRUD
    ├── groups/                        # Group CRUD
    ├── payments/                      # Payment CRUD
    ├── attendance/                    # Attendance tracking
    ├── enrollments/                   # Student-group relationships
    ├── inquiries/                     # Prospective student inquiries
    ├── reports/                       # Daily/monthly/yearly reports
    └── sms_link/                      # SMS notification linking
```

Each feature follows this internal structure:

```
feature/
├── data/
│   ├── datasources/
│   │   ├── *_remote_datasource.dart   # API calls
│   │   ├── *_local_datasource.dart    # Hive cache
│   │   └── *_sync_handler.dart        # Sync operation executor
│   ├── models/
│   │   ├── *_model.dart               # Data model + request class
│   │   └── *_model.g.dart             # Generated serialization
│   └── repositories/
│       └── *_repository.dart          # Abstract interface + offline-aware impl
└── presentation/
    ├── bloc/
    │   └── *_bloc.dart                # BLoC (events, states, logic)
    └── pages/
        └── *_page.dart                # UI screens
```

## Application Flow

### Startup Sequence

```
main()
  → WidgetsFlutterBinding.ensureInitialized()
  → Hive.initFlutter()                    # Initialize local database
  → configureDependencies()               # Register all services in GetIt
      → SharedPreferences, TokenStorage, ApiClient
      → ConnectivityService.initialize()  # Check initial network state
      → SyncQueue, IdMappingService       # Open Hive boxes
      → TempIdGenerator
      → 8x LocalDataSource.initialize()   # Open feature Hive boxes
      → Remote datasources, Repositories, BLoCs
      → SyncEngine.start()               # Begin listening for connectivity
      → SyncStatusCubit
      → AppRouter
  → ApiClient.setLogoutCallback()         # Wire token expiry to AuthBloc
  → runApp(MyApp)
```

### Authentication

1. App starts → `AuthBloc` fires `AuthCheckStatus`
2. `AuthRepository.getCurrentUser()` checks for stored JWT token
3. If token exists → `AuthAuthenticated` state → redirect to `/home`
4. If no token → `AuthUnauthenticated` state → redirect to `/login`
5. On login → POST `/auth/login` → store JWT → `AuthAuthenticated`
6. On 401/403 API response → `AuthInterceptor` clears token → triggers logout
7. Auth has **no offline support** (login inherently requires connectivity)

### Navigation

GoRouter with a `ShellRoute` for the main scaffold:

| Route | Page | Description |
|-------|------|-------------|
| `/` | SplashPage | Auth check loading screen |
| `/login` | LoginPage | Username/password form |
| `/home` | HomePage | Dashboard |
| `/teachers` | TeachersPage | Teacher list + CRUD |
| `/teachers/:id` | TeacherDetailPage | Teacher detail view |
| `/groups` | GroupsPage | Group list + CRUD |
| `/groups/:id` | GroupDetailPage | Group detail with students/payments |
| `/students` | StudentsPage | Student list + CRUD |
| `/students/:id` | StudentDetailPage | Student detail view |
| `/inquiries` | InquiriesPage | Inquiry management |
| `/payments` | PaymentsPage | Payment recording |
| `/attendance` | AttendancePage | Attendance tracking |
| `/reports` | ReportsPage | Daily/monthly/yearly reports |

The router uses `GoRouterRefreshStream` to listen to `AuthBloc` state changes and automatically redirects between auth and main routes.

## Data Layer Architecture

### Data Flow (Online)

```
UI → BLoC → Repository → RemoteDataSource → API Server
                ↓
         LocalDataSource (cache result)
```

### Data Flow (Offline Read)

```
UI → BLoC → Repository → LocalDataSource → Hive Cache
```

### Data Flow (Offline Write)

```
UI → BLoC → Repository → LocalDataSource (optimistic update)
                ↓
           SyncQueue (enqueue mutation)
                ↓
         [Later, when online]
                ↓
           SyncEngine → SyncHandler → RemoteDataSource → API Server
                                          ↓
                                   LocalDataSource (replace with server data)
```

### Repository Pattern

Every repository method follows this logic:

**Read operations:**
1. If online → fetch from API, cache locally, return fresh data
2. If API fails or offline → return from local cache
3. If cache empty → return `CacheFailure`

**Write operations (create/update/delete):**
1. If online → send to API, update local cache, return
2. If API fails or offline → apply optimistically to local cache + enqueue `SyncOperation`
3. For offline creates → assign negative temp ID (e.g., -1, -2)

### Error Handling

Repositories return Dart 3 record tuples: `(SuccessType?, Failure?)`

```dart
final (students, failure) = await studentRepository.getAll();
if (failure != null) { /* handle error */ }
```

Failure types:
- `ServerFailure` — API returned an error
- `NetworkFailure` — connection error
- `AuthFailure` — authentication error
- `ValidationFailure` — input validation error (with field-level errors)
- `CacheFailure` — no cached data available offline
- `UnknownFailure` — unexpected error

Reports use a different pattern: `(ReportType?, String?)` with string error messages.

## Offline-First System

### Components

**ConnectivityService** — Wraps `connectivity_plus`. Provides:
- `isOnline` — current connectivity state
- `onConnectivityChanged` — stream of connectivity changes

**SyncQueue** — Hive box storing pending mutations as `SyncOperation` entries:
- `entityType` — "student", "teacher", "group", etc.
- `operationType` — "create", "update", "delete"
- `entityId` — the entity's ID (temp negative ID for creates)
- `payload` — the request body as JSON map
- `createdAt` — timestamp for FIFO ordering
- `retryCount` — number of failed attempts

**TempIdGenerator** — Generates negative integer IDs (-1, -2, -3...) for entities created offline. Negative IDs are trivially distinguishable from real server IDs (positive integers).

**IdMappingService** — Hive box mapping `"entityType_tempId"` → real server ID. When a create operation syncs successfully, the mapping is stored so that dependent entities (e.g., a group referencing a temp teacher ID) can resolve the real ID at sync time.

**SyncEngine** — Core sync processor:
1. Listens to `ConnectivityService` — triggers processing when device comes online
2. Processes queue in FIFO order (oldest first)
3. For each operation, calls the registered `SyncOperationHandler`
4. On successful create → stores temp→real ID mapping via `IdMappingService`
5. On failure → increments retry count. After 3 retries, skips the operation
6. Exposes `Stream<SyncStatus>` (idle/syncing/error) and `pendingCount`

**SyncOperationHandler** — One per entity type. Each handler:
- Resolves temp IDs in foreign keys using `IdMappingService` at sync time
- Calls the appropriate remote datasource method
- Updates local cache with server response

### Hive Serialization

Models are stored in Hive using `toJson()` / `fromJson()`. Two helpers ensure correctness:

- **`toHiveMap()`** — `jsonDecode(jsonEncode(model.toJson()))` converts all nested objects (like `List<GroupInfo>`) into plain primitives that Hive can store
- **`fromHiveMap()`** — Deep recursive cast from Hive's `Map<dynamic, dynamic>` back to `Map<String, dynamic>` that `fromJson()` requires

### Sync Status UI

`SyncStatusCubit` combines connectivity + sync engine status into a single state. `SyncStatusBanner` displays at the top of the app:

| State | Banner |
|-------|--------|
| Online, synced | Hidden |
| Offline | Red: "Oflayn rejim" |
| Offline + pending | Red: "Oflayn rejim · X ta o'zgarish kutilmoqda" |
| Online, syncing | Orange: "Sinxronlanmoqda..." |
| Online, pending | Gray: "X ta o'zgarish kutilmoqda" |

### What Supports Offline

| Feature | Offline Read | Offline Write |
|---------|:---:|:---:|
| Students | Yes | Yes (create/update/delete) |
| Teachers | Yes | Yes (create/update/delete) |
| Groups | Yes | Yes (create/update/delete) |
| Payments | Yes | Yes (create/update/delete) |
| Attendance | Yes | Yes (create/update) |
| Enrollments | Yes | Yes (add/remove) |
| Inquiries | Yes | Yes (create/update/delete) |
| Reports | Yes (cached) | No (server-computed) |
| Auth | No | No (requires connectivity) |
| SMS Link | No | No (requires connectivity) |

## API Integration

**Base URL:** `https://creativelearningcenter-production.up.railway.app/`

All API calls use JWT Bearer token authentication (except `/auth/*` endpoints).

### Endpoints

| Feature | Method | Endpoint |
|---------|--------|----------|
| **Auth** | POST | `/auth/login` |
| **Students** | GET | `/api/students` |
| | GET | `/api/students/group/{groupId}?year=&month=` |
| | GET | `/api/students/{id}` |
| | POST | `/api/students` |
| | PUT | `/api/students/{id}` |
| | DELETE | `/api/students/{id}` |
| **Teachers** | GET | `/api/teachers` |
| | GET | `/api/teachers/{id}` |
| | POST | `/api/teachers` |
| | PUT | `/api/teachers/{id}` |
| | DELETE | `/api/teachers/{id}` |
| **Groups** | GET | `/api/groups` |
| | GET | `/api/groups/sorted-by-teacher` |
| | GET | `/api/groups/teacher/{teacherId}` |
| | GET | `/api/groups/{id}` |
| | POST | `/api/groups` |
| | PUT | `/api/groups/{id}` |
| | DELETE | `/api/groups/{id}` |
| **Payments** | GET | `/api/payments` |
| | GET | `/api/payments/student/{studentId}` |
| | GET | `/api/payments/group/{groupId}` |
| | GET | `/api/payments/group/{groupId}/month/{year}/{month}` |
| | GET | `/api/payments/{id}` |
| | POST | `/api/payments` |
| | PUT | `/api/payments/{id}` |
| | DELETE | `/api/payments/{id}` |
| **Attendance** | POST | `/api/attendances` (create for group) |
| | GET | `/api/attendances/{id}` |
| | GET | `/api/attendances/group/{groupId}/date/{date}` |
| | GET | `/api/attendances/month/{year}/{month}` |
| | GET | `/api/attendances/group/{groupId}/month/{year}/{month}` |
| | GET | `/api/attendances/student/{id}/month/{year}/{month}` |
| | GET | `/api/attendances/student/{sid}/group/{gid}/month/{y}/{m}` |
| | PATCH | `/api/attendances/{id}` |
| **Enrollments** | POST | `/api/enrollments` |
| | DELETE | `/api/enrollments/student/{studentId}/group/{groupId}` |
| | GET | `/api/enrollments/student/{studentId}` |
| | GET | `/api/enrollments/student/{studentId}/active` |
| | GET | `/api/enrollments/group/{groupId}` |
| **Inquiries** | GET | `/api/inquiries` |
| | GET | `/api/inquiries/status/{status}` |
| | GET | `/api/inquiries/{id}` |
| | POST | `/api/inquiries` |
| | PUT | `/api/inquiries/{id}` |
| | DELETE | `/api/inquiries/{id}` |
| **Reports** | GET | `/api/reports/daily/{year}/{month}/{day}` |
| | GET | `/api/reports/monthly/{year}/{month}` |
| | GET | `/api/reports/yearly/{year}` |
| **SMS Link** | POST | `/sms/link/by-phone` |
| | POST | `/sms/link/by-code` |
| | GET | `/sms/link/{studentId}` |

## State Management

Each feature uses the BLoC pattern:

```
UI dispatches Event → BLoC processes → BLoC emits State → UI rebuilds
```

BLoCs interact only with repository interfaces. They are completely decoupled from data sources, caching, and offline logic. The offline-first behavior is entirely transparent to the BLoC layer.

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Architecture | Clean Architecture | Separation of concerns, testability |
| State management | BLoC | Predictable state, event-driven |
| Offline storage | Hive CE | Fast, no native dependencies, supports web |
| Storage format | `Map<String, dynamic>` via `toJson()` | Reuses existing serialization, no TypeAdapters |
| Temp IDs | Negative integers | Trivially distinguished from real server IDs |
| Sync ordering | FIFO by `createdAt` | Parent entities sync before dependents |
| Conflict resolution | Last-write-wins | Single-admin app, no concurrent editors |
| ID resolution | At sync time | Temp IDs resolve after parent entities sync |
| Retry policy | 3 retries then skip | Prevents one bad op from blocking the queue |
| Token storage | FlutterSecureStorage (mobile), SharedPreferences (web) | Platform-appropriate security |
| Error handling | Typed Failure classes with record tuples | Type-safe, no exceptions crossing layer boundaries |
