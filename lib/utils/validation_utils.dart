import 'package:flutter/services.dart';

class ValidationUtils {
  /// Aadhaar number validation (12 digits)
  static bool isValidAadhaar(String aadhaar) {
    final regex = RegExp(r'^\d{12}$');
    return regex.hasMatch(aadhaar);
  }

  /// PAN number validation (10 characters: 5 letters + 4 digits + 1 letter)
  static bool isValidPAN(String pan) {
    final regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    return regex.hasMatch(pan.toUpperCase());
  }

  /// Vehicle number validation (Indian format: XX##XX####)
  static bool isValidVehicleNumber(String vehicleNumber) {
    final regex = RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{4}$');
    return regex.hasMatch(vehicleNumber.toUpperCase());
  }

  /// License number validation (basic format)
  static bool isValidLicenseNumber(String license) {
    return license.length >= 8 && license.length <= 16;
  }

  /// Date format validation (DD/MM/YYYY)
  static bool isValidDateFormat(String date) {
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(date)) return false;
    
    try {
      final parts = date.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final dateTime = DateTime(year, month, day);
      return dateTime.day == day && dateTime.month == month && dateTime.year == year;
    } catch (e) {
      return false;
    }
  }

  /// Check if date is in the future
  static bool isFutureDate(String date) {
    try {
      final parts = date.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final inputDate = DateTime(year, month, day);
      return inputDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Check if date is expired (for insurance, license)
  static bool isExpired(String date) {
    try {
      final parts = date.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final inputDate = DateTime(year, month, day);
      return inputDate.isBefore(DateTime.now());
    } catch (e) {
      return false;
    }
  }

  /// Age validation (18+ years)
  static bool isAdult(String dob) {
    try {
      final parts = dob.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      final birthDate = DateTime(year, month, day);
      final age = DateTime.now().difference(birthDate).inDays / 365.25;
      return age >= 18;
    } catch (e) {
      return false;
    }
  }

  /// Input formatters
  static List<TextInputFormatter> getAadhaarFormatter() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(12),
    ];
  }

  static List<TextInputFormatter> getPANFormatter() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
      LengthLimitingTextInputFormatter(10),
      UpperCaseTextInputFormatter(),
    ];
  }

  static List<TextInputFormatter> getVehicleNumberFormatter() {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
      LengthLimitingTextInputFormatter(10),
      UpperCaseTextInputFormatter(),
    ];
  }

  static List<TextInputFormatter> getDateFormatter() {
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(10),
      DateInputFormatter(),
    ];
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.length <= 2) {
      return newValue;
    } else if (text.length == 3 && !text.contains('/')) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(offset: 4),
      );
    } else if (text.length == 6 && text.split('/').length == 2) {
      return TextEditingValue(
        text: '${text.substring(0, 5)}/${text.substring(5)}',
        selection: TextSelection.collapsed(offset: 7),
      );
    }
    
    return newValue;
  }
}

class UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
