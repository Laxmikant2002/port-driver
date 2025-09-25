import 'package:formz/formz.dart';

/// Extensions for Formz status to improve readability
extension FormzStatusExtension on FormzSubmissionStatus {
  /// Returns true if the form is in initial state
  bool get isInitial => this == FormzSubmissionStatus.initial;
  
  /// Returns true if the form is currently being submitted
  bool get isInProgress => this == FormzSubmissionStatus.inProgress;
  
  /// Returns true if the submission was successful
  bool get isSuccess => this == FormzSubmissionStatus.success;
  
  /// Returns true if the submission failed
  bool get isFailure => this == FormzSubmissionStatus.failure;
  
  /// Returns true if the form can be submitted (not in progress)
  bool get canSubmit => this != FormzSubmissionStatus.inProgress;
}

/// Extensions for form validation
extension FormValidation on List<FormzInput<dynamic, dynamic>> {
  /// Returns true if all inputs are valid
  bool get areAllValid => every((input) => input.isValid);
  
  /// Returns the first error message found
  String? get firstError {
    try {
      final invalidInput = firstWhere((input) => !input.isValid);
      // Try to get displayError if available, otherwise use error.toString()
      if (invalidInput.displayError != null) {
        return invalidInput.displayError.toString();
      }
      return invalidInput.error?.toString();
    } catch (e) {
      return null;
    }
  }
  
  /// Returns all error messages
  List<String> get allErrors {
    return where((input) => !input.isValid)
        .map((input) {
          if (input.displayError != null) {
            return input.displayError.toString();
          }
          return input.error?.toString() ?? 'Invalid input';
        })
        .toList();
  }
  
  /// Returns true if any input has been modified
  bool get anyDirty => any((input) => !input.isPure);
  
  /// Returns true if all inputs are pure (unmodified)
  bool get allPure => every((input) => input.isPure);
}

/// Extensions for String validation
extension StringValidation on String {
  /// Returns true if string is not empty after trimming
  bool get isNotEmptyTrimmed => trim().isNotEmpty;
  
  /// Returns true if string contains only letters and spaces
  bool get isValidName => RegExp(r'^[a-zA-Z\s]+$').hasMatch(this);
  
  /// Returns true if string is a valid email
  bool get isValidEmail => RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  ).hasMatch(this);
  
  /// Returns true if string is a valid phone number
  bool get isValidPhone {
    final clean = replaceAll(RegExp(r'[^\d]'), '');
    return RegExp(r'^[6-9]\d{9}$').hasMatch(clean);
  }
  
  /// Returns true if string contains only digits
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);
  
  /// Returns true if string is a valid OTP (4-6 digits)
  bool get isValidOtp => RegExp(r'^\d{4,6}$').hasMatch(this);
  
  /// Returns clean phone number (digits only)
  String get cleanPhone => replaceAll(RegExp(r'[^\d]'), '');
  
  /// Returns formatted phone number (XXXXX XXXXX)
  String get formattedPhone {
    final clean = cleanPhone;
    if (clean.length == 10) {
      return '${clean.substring(0, 5)} ${clean.substring(5)}';
    }
    return this;
  }
  
  /// Capitalizes first letter of each word
  String get titleCase => split(' ')
      .map((word) => word.isNotEmpty 
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : word)
      .join(' ');
  
  /// Returns true if password is strong
  bool get isValidPassword {
    return length >= 8 &&
           RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(this);
  }
  
  /// Masks the string (useful for phone numbers, emails)
  String mask({int visibleStart = 2, int visibleEnd = 2, String maskChar = '*'}) {
    if (length <= visibleStart + visibleEnd) return this;
    
    final start = substring(0, visibleStart);
    final end = substring(length - visibleEnd);
    final maskLength = length - visibleStart - visibleEnd;
    
    return start + (maskChar * maskLength) + end;
  }
}

/// Extensions for nullable String
extension NullableStringValidation on String? {
  /// Returns true if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// Returns true if string is not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  
  /// Returns true if string is null, empty, or only whitespace
  bool get isNullOrWhitespace => this == null || this!.trim().isEmpty;
  
  /// Returns string or empty if null
  String get orEmpty => this ?? '';
  
  /// Returns string or default value if null or empty
  String orDefault(String defaultValue) => isNullOrEmpty ? defaultValue : this!;
}

/// Extensions for List operations
extension ListExtensions<T> on List<T> {
  /// Returns true if list is null or empty
  bool get isNullOrEmpty => isEmpty;
  
  /// Returns true if list is not null and not empty
  bool get isNotNullOrEmpty => isNotEmpty;
  
  /// Safely gets element at index, returns null if index is out of bounds
  T? safeElementAt(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }
  
  /// Adds element if it's not null
  void addIfNotNull(T? element) {
    if (element != null) {
      add(element);
    }
  }
  
  /// Removes duplicates while preserving order
  List<T> get distinct {
    final seen = <T>{};
    return where((element) => seen.add(element)).toList();
  }
}

/// Extensions for DateTime
extension DateTimeExtensions on DateTime {
  /// Returns true if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Returns true if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// Returns true if date is in the past
  bool get isPast => isBefore(DateTime.now());
  
  /// Returns true if date is in the future
  bool get isFuture => isAfter(DateTime.now());
  
  /// Returns formatted date string (DD/MM/YYYY)
  String get formatDate => '${day.toString().padLeft(2, '0')}/'
      '${month.toString().padLeft(2, '0')}/$year';
  
  /// Returns formatted time string (HH:MM)
  String get formatTime => '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
  
  /// Returns age in years
  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }
}

/// Extensions for BuildContext (if needed)
/* 
extension BuildContextExtensions on BuildContext {
  /// Gets theme data
  ThemeData get theme => Theme.of(this);
  
  /// Gets color scheme
  ColorScheme get colorScheme => theme.colorScheme;
  
  /// Gets text theme
  TextTheme get textTheme => theme.textTheme;
  
  /// Gets media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// Gets screen size
  Size get screenSize => mediaQuery.size;
  
  /// Gets screen width
  double get screenWidth => screenSize.width;
  
  /// Gets screen height
  double get screenHeight => screenSize.height;
  
  /// Shows snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
*/