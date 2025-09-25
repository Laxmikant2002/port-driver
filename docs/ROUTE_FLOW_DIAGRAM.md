# Driver App Route Flow Diagram

## Complete Flow Visualization

```
┌─────────────────┐
│   LoginScreen   │ ← Entry Point
│  (Phone Input)  │
└─────────┬───────┘
          │ Phone Number
          ▼
┌─────────────────┐
│    OtpScreen    │ ← OTP Verification
│   (4-digit OTP) │
└─────────┬───────┘
          │ OTP Success
          ▼
┌─────────────────┐
│ RouteDecisionService │ ← Driver Status Check
│ (checkDriverStatus) │
└─────────┬───────┘
          │ Status Response
          ▼
    ┌─────────────┐
    │ Driver Status? │
    └─────┬───────┘
          │
    ┌─────┴───────┬──────────┬──────────┬──────────┐
    │             │          │          │          │
    ▼             ▼          ▼          ▼          ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ newUser │ │verified │ │documents│ │documents│ │suspended│
│         │ │         │ │ Pending │ │Rejected │ │inactive │
└────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
     │           │            │            │            │
     ▼           ▼            ▼            ▼            ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│Profile  │ │Dashboard│ │Document │ │Document │ │Account  │
│Creation │ │ (Direct)│ │  Intro  │ │ Upload  │ │ Status  │
└────┬────┘ └─────────┘ └────┬────┘ └────┬────┘ └─────────┘
     │                        │            │
     ▼                        ▼            ▼
┌─────────┐              ┌─────────┐ ┌─────────┐
│Language │              │Document │ │Dashboard│
│Selection│              │ Upload  │ │         │
└────┬────┘              └────┬────┘ └─────────┘
     │                        │
     ▼                        ▼
┌─────────┐              ┌─────────┐
│Vehicle  │              │Dashboard│
│Selection│              │         │
└────┬────┘              └─────────┘
     │
     ▼
┌─────────┐
│Work     │
│Location │
└────┬────┘
     │
     ▼
┌─────────┐
│Dashboard│ ← Final Destination
│ (Ready) │
└─────────┘
```

## Route Decision Matrix

| Driver Status | Route | Next Steps |
|---------------|-------|------------|
| `newUser` | `/profile-creation` | Profile → Language → Vehicle → Work Location → Dashboard |
| `profileIncomplete` | `/profile-creation` | Complete Profile → Language → Vehicle → Work Location → Dashboard |
| `documentsPending` | `/document-intro` | Document Intro → Document Upload → Dashboard |
| `documentsRejected` | `/document-upload` | Document Upload (Resubmission) → Dashboard |
| `verified` | `/dashboard` | Direct to Dashboard |
| `suspended` | `/account-suspended` | Show Suspension Message |
| `inactive` | `/account-inactive` | Show Inactive Message |

## Key Decision Points

### 1. OTP Success
```
OTP Verification Success
         │
         ▼
Check Driver Status via ProfileRepo
         │
         ▼
RouteDecisionService.determineRouteAfterOtp()
```

### 2. Driver Status Check
```
API Call: GET /driver/status/{phoneNumber}
         │
         ▼
Response: DriverStatusResponse
{
  "success": true,
  "status": "new_user|verified|documents_pending|...",
  "profile": {...},
  "missingRequirements": [...]
}
```

### 3. Route Navigation
```
RouteDecision {
  route: "/profile-creation|/dashboard|/document-intro|...",
  arguments: phoneNumber|profile|missingRequirements,
  reason: "Human readable explanation"
}
         │
         ▼
Navigator.pushReplacementNamed(context, route, arguments)
```

## Error Handling Flow

```
Network Error / API Failure
         │
         ▼
Default Route: /profile-creation
         │
         ▼
Show Error Message + Allow Retry
```

## Modern App Style Features

### 1. Conditional Routing
- Backend-driven route decisions
- No hardcoded navigation paths
- Dynamic arguments based on driver state

### 2. State Management
- BLoC pattern for state management
- Formz for form validation
- Equatable for state comparison

### 3. Error Handling
- Graceful fallbacks
- User-friendly error messages
- Retry mechanisms

### 4. Type Safety
- Strong typing with enums
- Null safety throughout
- Compile-time route validation
