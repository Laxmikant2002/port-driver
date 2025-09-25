# Driver App Route Flow Documentation

## Overview
This document describes the complete driver lifecycle flow with conditional routing after OTP verification in the modern driver app.

## Route Flow Architecture

### Step 1: Authentication Flow
```
LoginScreen → Phone Input → OTP Verification
```

**Files:**
- `lib/screens/auth/login/view/login_screen.dart` - Phone number input
- `lib/screens/auth/otp/view/otp_screen.dart` - OTP verification
- `lib/routes/auth_routes.dart` - Authentication routes

### Step 2: Route Decision After OTP Success
After successful OTP verification, the app determines the next route based on driver status:

**Service:** `lib/services/route_decision_service.dart`
**Logic:** `packages/profile_repo/lib/src/profile_repo.dart` - `checkDriverStatus()`

## Driver Status-Based Routing

### Case A: New Driver → Onboarding Flow
**Status:** `DriverStatus.newUser` or `DriverStatus.profileIncomplete`

**Route:** `/profile-creation`
**Flow:**
```
OTP Success → Profile Creation → Language Selection → Vehicle Selection → Work Location → Dashboard
```

**Files:**
- `lib/screens/auth/profile/view/profile_screen.dart` - Profile creation form
- `lib/screens/auth/language_choose/view/language_screen.dart` - Language selection
- `lib/screens/auth/vehicle_selection/view/vehicle_screen.dart` - Vehicle selection
- `lib/screens/auth/work_location/view/work_screen.dart` - Work location setup

### Case B: Existing Driver → Skip Onboarding
**Status:** `DriverStatus.verified`

**Route:** `/dashboard`
**Flow:**
```
OTP Success → Dashboard (Direct)
```

### Case C: Documents Pending
**Status:** `DriverStatus.documentsPending`

**Route:** `/document-intro`
**Flow:**
```
OTP Success → Document Introduction → Document Upload → Dashboard
```

### Case D: Documents Rejected
**Status:** `DriverStatus.documentsRejected`

**Route:** `/document-upload`
**Flow:**
```
OTP Success → Document Upload (Resubmission) → Dashboard
```

### Case E: Account Issues
**Status:** `DriverStatus.suspended` or `DriverStatus.inactive`

**Routes:** `/account-suspended` or `/account-inactive`
**Flow:**
```
OTP Success → Account Status Screen (No further navigation)
```

## Route Constants

All routes are defined in `lib/routes/route_constants.dart`:

```dart
// Authentication routes
static const String login = '/';
static const String otp = '/get-otp';

// Profile creation routes
static const String profileCreation = '/profile-creation';
static const String languageSelection = '/language-selection';
static const String vehicleSelection = '/vehicle-selection';
static const String workLocation = '/work-location';

// Document routes
static const String documentIntro = '/document-intro';
static const String documentUpload = '/document-upload';

// Main app routes
static const String dashboard = '/dashboard';

// Account status routes
static const String accountSuspended = '/account-suspended';
static const String accountInactive = '/account-inactive';
```

## Route Registration

Routes are registered in three main files:

1. **Authentication Routes:** `lib/routes/auth_routes.dart`
2. **Main App Routes:** `lib/routes/main_routes.dart`
3. **Account Routes:** `lib/routes/account_routes.dart`

All routes are combined in `lib/routes/app_routes.dart`.

## Key Components

### RouteDecisionService
**File:** `lib/services/route_decision_service.dart`

**Purpose:** Determines the next route after OTP verification based on driver status.

**Method:** `determineRouteAfterOtp()`
- Takes `AuthUser` and `ProfileRepo` as parameters
- Calls `profileRepo.checkDriverStatus()` to get driver status
- Returns `RouteDecision` with route, arguments, and reason

### RouteDecision Model
```dart
class RouteDecision {
  final String route;
  final dynamic arguments;
  final String reason;
  final DriverProfile? profile;
}
```

### Driver Status Enum
**File:** `packages/profile_repo/lib/src/profile_repo.dart`

```dart
enum DriverStatus {
  newUser,           // Completely new user - needs profile creation
  profileIncomplete, // Profile exists but incomplete - needs profile completion
  documentsPending,  // Profile complete but documents not uploaded/verified
  documentsRejected, // Documents uploaded but rejected - needs resubmission
  verified,          // Fully verified and ready to work
  suspended,         // Account suspended
  inactive,          // Account inactive
}
```

## OTP Bloc Integration

**File:** `lib/screens/auth/otp/bloc/otp_bloc.dart`

The OTP bloc handles the route decision after successful verification:

```dart
// After successful OTP verification, determine the next route
final routeDecision = await RouteDecisionService.determineRouteAfterOtp(
  user: response.user!,
  profileRepo: profileRepo,
);

emit(state.copyWith(
  status: FormzSubmissionStatus.success,
  user: response.user,
  routeDecision: routeDecision,
));
```

**File:** `lib/screens/auth/otp/view/otp_screen.dart`

The OTP screen listens for successful verification and navigates accordingly:

```dart
BlocListener<OtpBloc, OtpState>(
  listener: (context, state) {
    if (state.isSuccess && state.user != null && state.routeDecision != null) {
      final routeDecision = state.routeDecision!;
      
      Navigator.pushReplacementNamed(
        context, 
        routeDecision.route, 
        arguments: routeDecision.arguments,
      );
    }
  },
  // ...
)
```

## Flow Examples

### New Driver Flow
1. User enters phone number → `LoginScreen`
2. User enters OTP → `OtpScreen`
3. Backend returns `DriverStatus.newUser`
4. Navigate to → `/profile-creation`
5. Complete profile → Navigate to `/language-selection`
6. Select language → Navigate to `/vehicle-selection`
7. Select vehicle → Navigate to `/work-location`
8. Set work location → Navigate to `/dashboard`

### Existing Driver Flow
1. User enters phone number → `LoginScreen`
2. User enters OTP → `OtpScreen`
3. Backend returns `DriverStatus.verified`
4. Navigate directly to → `/dashboard`

### Document Pending Flow
1. User enters phone number → `LoginScreen`
2. User enters OTP → `OtpScreen`
3. Backend returns `DriverStatus.documentsPending`
4. Navigate to → `/document-intro`
5. Upload documents → Navigate to `/dashboard`

## Error Handling

- **Network Errors:** Default to `/profile-creation` route
- **Invalid Driver Status:** Default to `/profile-creation` route
- **Missing Arguments:** Routes handle missing arguments gracefully

## Testing the Flow

To test the complete flow:

1. **New Driver:** Use a phone number not in the system
2. **Existing Driver:** Use a phone number with verified status
3. **Document Pending:** Use a phone number with pending documents
4. **Account Suspended:** Use a phone number with suspended account

## Future Enhancements

1. **Analytics:** Track route decision outcomes
2. **Caching:** Cache driver status to reduce API calls
3. **Offline Support:** Handle offline scenarios gracefully
4. **Deep Linking:** Support deep links to specific routes
5. **Route Guards:** Add authentication guards for protected routes
