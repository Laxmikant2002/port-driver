import 'base_paths.dart';

class SharedPaths extends BasePaths {
  // Common Enums and Constants
  static final String getTripStates = "${BasePaths.baseUrl}/shared/trip-states";
  static final String getPaymentMethods = "${BasePaths.baseUrl}/shared/payment-methods";
  static final String getVehicleTypes = "${BasePaths.baseUrl}/shared/vehicle-types";
  static final String getDocumentTypes = "${BasePaths.baseUrl}/shared/document-types";
  static final String getNotificationTypes = "${BasePaths.baseUrl}/shared/notification-types";
  
  // Location Services
  static final String getCities = "${BasePaths.baseUrl}/shared/cities";
  static final String getServiceAreas = "${BasePaths.baseUrl}/shared/service-areas";
  static final String getZones = "${BasePaths.baseUrl}/shared/zones";
  static final String validateCoordinates = "${BasePaths.baseUrl}/shared/validate-coordinates";
  
  // Common Models
  static final String getCountries = "${BasePaths.baseUrl}/shared/countries";
  static final String getLanguages = "${BasePaths.baseUrl}/shared/languages";
  static final String getCurrencies = "${BasePaths.baseUrl}/shared/currencies";
  static final String getTimeZones = "${BasePaths.baseUrl}/shared/timezones";
  
  // App Configuration
  static final String getAppConfig = "${BasePaths.baseUrl}/shared/app-config";
  static final String getAppVersion = "${BasePaths.baseUrl}/shared/app-version";
  static final String getFeatureFlags = "${BasePaths.baseUrl}/shared/feature-flags";
  
  // Common Utilities
  static final String uploadFile = "${BasePaths.baseUrl}/shared/upload";
  static final String deleteFile = "${BasePaths.baseUrl}/shared/delete-file";
  static final String getFileUrl = "${BasePaths.baseUrl}/shared/file-url";
  
  // Validation Services
  static final String validatePhone = "${BasePaths.baseUrl}/shared/validate-phone";
  static final String validateEmail = "${BasePaths.baseUrl}/shared/validate-email";
  static final String validateDocument = "${BasePaths.baseUrl}/shared/validate-document";
  
  // Common Data
  static final String getCommonData = "${BasePaths.baseUrl}/shared/common-data";
  static final String getSystemInfo = "${BasePaths.baseUrl}/shared/system-info";
}
