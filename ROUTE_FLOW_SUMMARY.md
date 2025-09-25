# Driver App Route Flow - Corrected Organization

## Overview
The driver app now has a properly organized authentication and onboarding flow with clear separation of concerns.

## Route Flow Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Login Screen  │───▶│   OTP Screen    │───▶│ Route Decision  │
│                 │    │                 │    │    Service      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │  Check Driver   │
                                               │     Status      │
                                               └─────────────────┘
                                                        │
                        ┌───────────────────────────────┼───────────────────────────────┐
                        │                               │                               │
                        ▼                               ▼                               ▼
                ┌───────────────┐              ┌───────────────┐              ┌───────────────┐
                │  New Driver   │              │ Existing      │              │ Documents     │
                │ Onboarding    │              │ Driver        │              │ Pending/      │
                │    Flow       │              │ Dashboard     │              │ Rejected      │
                └───────────────┘              └───────────────┘              └───────────────┘
                        │                               │                               │
                        ▼                               │                               ▼
                ┌───────────────┐                      │                      ┌───────────────┐
                │    Profile    │                      │                      │ Document      │
                │   Creation    │                      │                      │ Upload        │
                └───────────────┘                      │                      └───────────────┘
                        │                               │                               │
                        ▼                               │                               ▼
                ┌───────────────┐                      │                      ┌───────────────┐
                │   Language    │                      │                      │   Dashboard   │
                │  Selection    │                      │                      │   (Offline)   │
                └───────────────┘                      │                      └───────────────┘
                        │                               │                               │
                        ▼                               │                               ▼
                ┌───────────────┐                      │                      ┌───────────────┐
                │   Vehicle     │                      │                      │   Dashboard   │
                │  Selection    │                      │                      │   (Online)    │
                └───────────────┘                      │                      └───────────────┘
                        │                               │
                        ▼                               │
                ┌───────────────┐                      │
                │  Work Area    │                      │
                │  Selection    │                      │
                └───────────────┘                      │
                        │                               │
                        ▼                               │
                ┌───────────────┐                      │
                │  Document     │                      │
                │   Upload      │                      │
                └───────────────┘                      │
                        │                               │
                        ▼                               │
                ┌───────────────┐                      │
                │   Dashboard   │◀─────────────────────┘
                │   (Online)    │
                └───────────────┘
```

## Route Organization

### 1. Authentication Routes (`lib/routes/auth_routes.dart`)
- **Login Screen** (`/`) - Phone number entry
- **OTP Screen** (`/get-otp`) - OTP verification
- **Profile Creation** (`/profile-creation`) - New driver profile setup
- **Language Selection** (`/language-selection`) - App language preference
- **Vehicle Selection** (`/vehicle-selection`) - Admin-assigned vehicle selection
- **Work Location** (`/work-location`) - City/area selection
- **Document Upload** (`/document-upload`) - RC, License, Aadhaar upload

### 2. Main Routes (`lib/routes/main_routes.dart`)
- **Home Screen** (`/home`) - Main navigation hub
- **Dashboard** (`/dashboard`) - Driver status and earnings
- **Work Area Selection** (`/work-area-selection`) - Change work area
- **Booking & Trip Management** - All ride-related screens

### 3. Account Routes (`lib/routes/account_routes.dart`)
- **Profile Management** (`/profile`) - View/edit existing profile
- **Documents** - Document management and viewing
- **Trip History** - Past trips and earnings
- **Settings** - App preferences and account settings
- **Help & Support** - Customer support and FAQ

## Key Changes Made

### ✅ Completed Tasks:
1. **Removed duplicate language selection screens** - Kept `language_selection` (modern) over `language_choose` (simple)
2. **Organized authentication flow** - Proper sequence: Login → OTP → Profile → Language → Vehicle → Work Location → Documents
3. **Fixed route constants** - Updated to match proper onboarding flow
4. **Cleaned duplicate profile screens** - Separated onboarding profile (`auth/profile`) from account profile (`account/profile`)
5. **Updated route decision service** - Uses correct route constants
6. **Fixed dashboard routing** - Points to existing `Driver_Status/dashboard_screen.dart`
7. **Updated account routes** - Removed duplicates and organized properly

### Route Decision Service Logic:
- **New Driver** → Start onboarding flow from Profile Creation
- **Existing Driver** → Skip onboarding, go to Dashboard
- **Documents Pending** → Show "Documents under review" (offline mode only)
- **Documents Rejected** → Show rejection reason + re-upload option
- **Documents Verified** → Route to Dashboard with Online/Offline toggle

## File Structure:
```
lib/
├── routes/
│   ├── auth_routes.dart      # Authentication & onboarding flow
│   ├── main_routes.dart      # Main app functionality
│   ├── account_routes.dart   # Account management
│   └── route_constants.dart  # All route constants
├── services/
│   └── route_decision_service.dart  # Route decision logic
└── screens/
    ├── auth/                 # Authentication & onboarding
    │   ├── login/
    │   ├── otp/
    │   ├── profile/          # Onboarding profile setup
    │   ├── language_selection/
    │   ├── vehicle_selection/
    │   └── work_location/
    ├── booking_flow/         # Main driver functionality
    │   └── Driver_Status/
    │       └── view/
    │           └── dashboard_screen.dart  # Main dashboard
    └── account/              # Account management
        └── profile/          # Account profile management
```

## Next Steps:
The route flow is now properly organized and ready for implementation. All duplicate screens have been removed, and the authentication flow follows the modern app pattern with proper route decision logic based on driver status.
