# Driver App

This repository contains the Flutter driver app for the Port project — a mobile application used by drivers to receive and manage bookings. This README is written to hand the project over to a new developer. It documents project structure, important files, how to run and build the app, testing, localization, assets, and a handover checklist.

Important: this README is generated from the repository snapshot on branch `booking-flow`. Verify branch-specific behavior, feature flags, or missing secrets when taking over.

## Table of contents

- Project summary
- Quick start (setup & run)
- Project layout (top-level folders)
- Key files and entry points
- `lib/` package structure and responsibilities
- Packages in `packages/` folder
- Localization and assets
- Build & release notes
- Testing
- Troubleshooting & common issues
- Handover checklist
- Contacts & references

## Project summary

- Flutter mobile application for drivers.
- Contains platform folders for Android, iOS, Windows, macOS, and web.
- Uses feature-targeted packages under `packages/` (e.g., `api_client`, `auth_repo`, `vehicle_repo`).

## Quick start (setup & run)

1. Prerequisites
   - Flutter (version compatible with repo; check `pubspec.yaml` SDK constraints).
   - Android SDK + Android Studio for Android builds.
   - Xcode for iOS builds (macOS only).
   - For Windows/macOS builds, see Flutter desktop docs.

2. Get dependencies

```powershell
cd "c:\Users\laxmi\OneDrive\Documents\web app\port-driver"
flutter pub get
```

3. Run on device or emulator

- Android emulator or connected device:

```powershell
flutter run -d <device-id>
```

- Web (Chrome):

```powershell
flutter run -d chrome
```

- iOS (macOS host):

```powershell
flutter run -d ios
```

4. Build release APK (Android)

```powershell
flutter build apk --release
```

Replace commands with the appropriate platform target as needed.

## Project layout (top-level)

- `android/` — Android project. Keystore and `google-services.json` may be present under `app/`.
- `ios/` — iOS project.
- `macos/` — macOS host.
- `windows/` — Windows host and CMake config.
- `lib/` — Main Flutter codebase (see below).
- `packages/` — Local multi-package folders (often Dart packages providing repos, clients, and features).
- `assets/` — Static assets like images and icons.
- `test/` — Unit and widget tests.
- `build/` — Build outputs (ignored in VCS normally).
- `pubspec.yaml` — Flutter/Dart package manifest and dependencies.

## Key files and entry points

- `pubspec.yaml` — check Flutter SDK constraints, package dependencies, assets and fonts.
- `lib/bootstrap.dart` — likely prepares the app (dependency injection, environment); used by the `main_*.dart` entry files.
- `lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart` — environment-specific application entrypoints.
- `lib/app/app.dart` — main `MaterialApp` / `CupertinoApp` widget.
- `lib/locator.dart` — dependency injection registrations (get_it or similar).
- `lib/constants/` — configuration constants (API endpoints, keys, etc.).
- `packages/*` — local packages for data layers; see below for listing.

## lib/ package structure (detailed)

The `lib/` folder contains the app's primary structure. Key subfolders and their roles:

- `lib/app/` — app wiring and top-level widgets (e.g., `app.dart`, BLoC providers).
- `lib/app/bloc/` — BLoC classes and state management.
- `lib/app/view/` — probably contains the top-level views and navigation scaffolding.
- `lib/constants/` — constants such as `google_map_key.dart` and `url.dart`.
- `lib/core/` — core utilities and shared logic:
  - `error/` — error models and handlers.
  - `extensions/` — extension methods.
  - `form/` — form utilities and validators.
  - `widgets/` — low-level reusable widgets (buttons, inputs, dialogs).
- `lib/models/` — data models used across the app (e.g., `booking.dart`, `document_upload.dart`).
- `lib/routes/` — navigation route declarations and helpers.
- `lib/screens/` — feature screens and UI pages.
- `lib/services/` — platform or app services (e.g., location, notifications).
- `lib/ui/` — UI theming, styles, and components.
- `lib/utils/` — utility functions and helpers.
- `lib/widgets/` — composite widgets used across screens.

Note: Not all files are exhaustively listed here; refer to the folder for the full contents.

## Local packages (`packages/` folder)

This repo includes several local packages that encapsulate data access and domain logic:

- `api_client/` — handles HTTP API calls.
- `auth_repo/` — authentication repository (login, token handling).
- `documents_repo/` — file/document upload logic.
- `driver_status/` — driver status handling.
- `finance_repo/` — financial data and operations.
- `history_repo/` — trip history repository.
- `localstorage/` — local storage helpers, wrappers around SharedPreferences or hive.
- `notifications_repo/` — push/notification logic.
- `profile_repo/` — user profile repository.
- `rewards_repo/` — rewards and incentives logic.
- `shared_repo/` — shared repository code and models.
- `trip_repo/` — trip and booking operations.
- `vehicle_repo/` — vehicle related actions and data.

Each package has its own `pubspec.yaml` and can be developed/tested independently.

## Localization (l10n)

- `l10n/` and `lib/l10n/arb/` contain localization resources (ARB files) and generated localization code.
- Check `l10n.yaml` or `pubspec.yaml` for Flutter's localization generation settings.
- To regenerate localizations (if needed):

```powershell
flutter gen-l10n
```

or rely on the build step which may run code generation tools.

## Assets

- `assets/images/` — app images.
- `assets/vehicle_icons/` — vehicle-specific icons.
- Fonts and additional native assets may be under `unit_test_assets/` or platform `assets` folders.
- Ensure `pubspec.yaml` lists these assets under the assets section.

## Build & Release notes

- Android signing keys are present in `android/app/keystore.jks` and referenced in `android/key.properties`.
- `android/app/google-services.json` present for Firebase configuration (verify environment - production vs staging).
- For Play Store or App Store releases, ensure the correct `google-services.json`/`GoogleService-Info.plist` and keystore are used for the target environment.
- CI/CD: not present in the repo snapshot. If you use a CI, add scripts to run `flutter pub get`, `flutter test`, and `flutter build` for targets.

## Testing

- Unit and widget tests live in `test/`.
- Run tests:

```powershell
flutter test
```

- If packages under `packages/` have tests, run them individually or use:

```powershell
flutter test packages/<package_name>
```

## Troubleshooting & common issues

- Missing SDK or mismatched Flutter version: check `pubspec.yaml` SDK constraints and install the appropriate Flutter channel (stable, beta, or master).
- Platform-specific build failures: inspect `android/` or `ios/` native logs and update Gradle, Android SDK, or CocoaPods as needed.
- Firebase or API credentials: confirm `google-services.json` and environment constants under `lib/constants/`.
- Generated files: if localization or code generation is failing, try `flutter pub run build_runner build --delete-conflicting-outputs` where applicable.

## Handover checklist

- [ ] Confirm Flutter SDK version and channel.
- [ ] Verify secrets/keys: `android/key.properties`, keystore, `google-services.json`, `GoogleService-Info.plist`.
- [ ] Document any feature flags, environment toggles, or external services (APIs, Firebase projects).
- [ ] Point to backend API docs and the person owning the API.
- [ ] Review open issues and PRs on branch `booking-flow`.
- [ ] Walkthrough major flows (login, booking acceptance, navigation) with the new developer.
- [ ] Ensure CI/CD credentials and repo settings are documented elsewhere (company wiki).

## Contacts & references

- Project owner: check repository settings or ask your team.
- For localization and translations: refer to `l10n/` and `lib/l10n/`.

---

If you'd like, I can also:
- Generate a more detailed map of `lib/` files with short descriptions for each file.
- Create a developer onboarding checklist file with environment variable templates and a sample `.env` (do not include secrets).
- Add a CONTRIBUTING.md with branch/PR conventions and basic linting rules.

Tell me which of the above you'd like me to add next.
