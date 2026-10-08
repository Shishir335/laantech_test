# Flutter POS Background Upload/Download Module
**Position:** Android POS Developer — LAAN TECH USA Limited Technical Assessment  
**Author:** Mahbub Ullah  
**Technology Stack:** Flutter, Clean Architecture, Riverpod, GetIt, Dio, Retrofit

---

## 1. Architecture & Key Design Decisions

The application is engineered strictly following **Clean Architecture** principles to separate concerns, enforce single responsibility, and guarantee testability and maintainability.

```
lib/
├── core/
│   ├── constants/       # API endpoints, timeouts, storage keys
│   ├── di/              # GetIt service locator setup (injection_container.dart)
│   ├── network/         # Dio client, AuthInterceptor, AppException, ApiResult
│   ├── services/        # NotificationService, StorageService, ConnectivityProvider
│   ├── theme/           # POS Dark Theme, AppColors, Design System tokens
│   └── utils/           # Formatters (bytes, speed, ETA), File generator utils
├── features/
│   ├── auth/
│   │   ├── data/        # AuthResponseModel, AuthApiService (Retrofit), AuthRepositoryImpl
│   │   ├── domain/      # AuthUser, AuthSession entities, AuthRepository interface
│   │   └── presentation/# AuthState, AuthNotifier (Riverpod), AuthDialog widget
│   └── transfer/
│       ├── data/        # FileItemModel, UploadResponseModel, TransferApiService, TransferRepositoryImpl
│       ├── domain/      # TransferTask, FileItem entities, TransferRepository, UseCases
│       └── presentation/
│           ├── providers/ # TransferState, TransferNotifier, FileCatalogNotifier, TransferExecutor
│           ├── screens/   # UploadScreen, DownloadScreen, TransferDashboardScreen, MainPosLayoutScreen
│           └── widgets/   # Modular Stateless Components (Cards, Bars, Badges, Banner)
└── main.dart            # Entrypoint with ProviderScope & GetIt initialization
```

### Key Design Decisions:
1. **Riverpod for Reactive Global State Management**:
   - Manages global transfer state (`TransferState`), file catalog list (`FileCatalogState`), and authentication session (`AuthState`).
   - Ensures any transfer initiated from any screen updates the global queue, dashboard counters, and persistent docked banner simultaneously without tight coupling.
2. **GetIt for Dependency Injection (Service Locator)**:
   - Decouples interface contracts from concrete implementations (`TransferRepository` -> `TransferRepositoryImpl`).
   - Cleanly registers singletons for `Dio`, `NotificationService`, `StorageService`, and Use Cases.
3. **Dio + Retrofit for Network Layer**:
   - `Retrofit` defines declarative REST contracts (`@POST`, `@GET`, `@DELETE`).
   - `Dio` provides granular control over timeouts, cancellation (`CancelToken`), upload streaming progress (`onSendProgress`), and byte-level HTTP range requests (`Range: bytes=offset-`).
4. **Resumable Downloads via HTTP 206 Range Headers**:
   - When a download is paused or interrupted, the downloaded byte count is preserved. Resuming sends `Range: bytes={transferredBytes}-` and appends incoming chunks via `FileMode.append`.
5. **Named Routing (`routes: AppRoutes.routes`)**:
   - Centralized routing table in `AppRoutes` (`/`, `/upload`, `/download`, `/dashboard`) mapping directly to widget screens.
   - Integrated with `rootNavigatorKey` for notification intent routing.
6. **Strict POS Modular Standards**:
   - Every file strictly stays under 300 lines of code.
   - Reusable components are implemented as `StatelessWidget` / `ConsumerWidget`.
   - Method and widget names do not use leading underscores (`_`), adhering strictly to human code conventions.
7. **Responsive POS Layout**:
   - Dynamically adapts between handheld Android POS terminals (portrait, bottom navigation bar) and countertop POS tablets (landscape, NavigationRail, multi-column metrics grid).

---

## 2. Background Execution Strategy & Android Platform Limits

### Strategy:
1. **In-App Backgrounding & Dio Stream Engine**:
   - File transfers are orchestrated through asynchronous streams decoupled from the widget lifecycle. When the user navigates between screens or tabs, transfers proceed uninterrupted.
2. **System Tray Integration (`flutter_local_notifications`)**:
   - Active transfers display ongoing, non-intrusive progress notifications.
   - Upon completion or failure, a persistent system tray notification is triggered with payload information allowing users to jump back into the POS transfer screen.
3. **Sensible Device Storage**:
   - Files are stored in the device's accessible storage (`getExternalStorageDirectory` on Android or `getApplicationDocumentsDirectory`), allowing direct preview via `OpenFilex`.

### Android Platform Limitations & Real-World POS Mitigation:
1. **Android Doze Mode & App Standby**:
   - When an Android device is unplugged and stationary with the screen off, Doze restricts CPU and network access.
   - *Mitigation for POS*: Commercial POS hardware typically operates in kiosk mode with continuous power, where `WAKE_LOCK` or setting `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` ensures transfers never halt.
2. **Android 14+ Foreground Service Restrictions**:
   - Android 14 (API 34) requires declaring explicit foreground service types. For large uploads/downloads, `android:foregroundServiceType="dataSync"` must be declared in `AndroidManifest.xml`.
3. **Cleartext Traffic Restriction**:
   - Since the mock endpoint (`http://15.232.228.139`) uses HTTP rather than HTTPS, Android 9+ blocks requests by default. We explicitly configured `android:usesCleartextTraffic="true"` in `AndroidManifest.xml`.
4. **Android Low-Memory Killer (LMK)**:
   - If the OS terminates the app process in low-memory situations, in-flight streams are cut. Our architecture persists transfer task metadata so tasks can resume from their exact byte offset upon app relaunch.

---

## 3. Resilience & Polish (Key Differentiators)

1. **Poor Network & Offline Awareness**:
   - Integrated `connectivity_plus` to monitor connection state. The POS app displays a live `ONLINE` / `OFFLINE` status pill in the header.
2. **Pause & Resume Controls**:
   - Both upload and download cards feature instant Pause / Resume / Cancel / Retry actions.
   - Downloads resume seamlessly from the saved byte offset using HTTP partial content.
3. **One-Click 50MB Sample Generator**:
   - To make evaluation effortless without manually copying a 50MB file to an emulator, the **Upload Screen** includes a **"Generate 50MB CSV"** button that produces a compliant product catalog CSV in seconds.
4. **Persistent Global Transfer Dock**:
   - A floating persistent widget appears at the bottom of the screen during active transfers, showing aggregate transfer speed and active count. Tapping it opens a quick-management drawer accessible from anywhere in the app.

---

## 4. Known Limitations & Future Improvements

1. **Upload Resumability on Server**:
   - While the download endpoint supports standard HTTP Range requests (`HTTP 206 Partial Content`), the mock upload endpoint (`POST /api/upload`) expects standard multipart/form-data. To support byte-resumable uploads in production, integrating protocols like **Tus.io** or chunked upload APIs would allow resume after mid-upload disconnection.
2. **Android WorkManager / Native Foreground Service**:
   - For long-running background tasks exceeding 10–15 minutes when the app is completely terminated by the user, integrating Android WorkManager (`workmanager` package) ensures OS-guaranteed scheduled retries.
3. **File Integrity Verification**:
   - Calculating MD5 / SHA-256 hash checks before and after transfer to verify bit-level integrity against network corruption.

---

## 5. Build & Setup Instructions

### Prerequisites:
- Flutter SDK 3.13+ / 3.48+
- Dart SDK 3.x
- Android SDK (API 34 / Java 17)

### Installation & Run:
```bash
# 1. Clone repository
git clone https://github.com/Shishir335/laantech_test.git
cd laantech_test

# 2. Install dependencies
flutter pub get

# 3. Verify analyzer
flutter analyze

# 4. Run the app on Android emulator or connected POS device
flutter run

# 5. Build release APK
flutter build apk --release
```
The output APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.
