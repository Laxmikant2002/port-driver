# UI Components Package

This package contains reusable UI components for the driver app, including bottom sheets and other UI widgets.

## Components

### Bottom Sheets
- `DriverStatusBottomSheet` - Shows driver status and required actions
- `RideDetailsBottomSheet` - Displays ride details and actions
- `RideRequestBottomSheet` - Shows incoming ride requests

## Usage

```dart
import 'package:ui_components/ui_components.dart';

// Use any of the exported components
DriverStatusBottomSheet(...)
RideDetailsBottomSheet(...)
RideRequestBottomSheet(...)
```

## Dependencies

This package depends on:
- `driver` - Main app package for colors and other shared resources
- `flutter` - Flutter SDK
- `equatable` - For value equality