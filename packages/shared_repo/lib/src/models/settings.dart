import 'package:equatable/equatable.dart';

/// Settings model for driver app settings
class Settings extends Equatable {
  const Settings({
    required this.id,
    required this.driverId,
    required this.language,
    required this.notifications,
    required this.privacy,
    required this.appearance,
    this.version,
    this.lastUpdated,
  });

  final String id;
  final String driverId;
  final LanguageSettings language;
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final AppearanceSettings appearance;
  final String? version;
  final DateTime? lastUpdated;

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      language: LanguageSettings.fromJson(json['language'] as Map<String, dynamic>),
      notifications: NotificationSettings.fromJson(json['notifications'] as Map<String, dynamic>),
      privacy: PrivacySettings.fromJson(json['privacy'] as Map<String, dynamic>),
      appearance: AppearanceSettings.fromJson(json['appearance'] as Map<String, dynamic>),
      version: json['version'] as String?,
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'language': language.toJson(),
      'notifications': notifications.toJson(),
      'privacy': privacy.toJson(),
      'appearance': appearance.toJson(),
      'version': version,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  Settings copyWith({
    String? id,
    String? driverId,
    LanguageSettings? language,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    AppearanceSettings? appearance,
    String? version,
    DateTime? lastUpdated,
  }) {
    return Settings(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      appearance: appearance ?? this.appearance,
      version: version ?? this.version,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        driverId,
        language,
        notifications,
        privacy,
        appearance,
        version,
        lastUpdated,
      ];
}

/// Language settings
class LanguageSettings extends Equatable {
  const LanguageSettings({
    required this.currentLanguage,
    this.availableLanguages = const ['English', 'Hindi', 'Tamil', 'Telugu'],
  });

  final String currentLanguage;
  final List<String> availableLanguages;

  factory LanguageSettings.fromJson(Map<String, dynamic> json) {
    return LanguageSettings(
      currentLanguage: json['currentLanguage'] as String,
      availableLanguages: (json['availableLanguages'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentLanguage': currentLanguage,
      'availableLanguages': availableLanguages,
    };
  }

  LanguageSettings copyWith({
    String? currentLanguage,
    List<String>? availableLanguages,
  }) {
    return LanguageSettings(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      availableLanguages: availableLanguages ?? this.availableLanguages,
    );
  }

  @override
  List<Object?> get props => [currentLanguage, availableLanguages];
}

/// Notification settings
class NotificationSettings extends Equatable {
  const NotificationSettings({
    this.rideNotifications = true,
    this.paymentNotifications = true,
    this.systemNotifications = true,
    this.promotionNotifications = false,
    this.emergencyNotifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  final bool rideNotifications;
  final bool paymentNotifications;
  final bool systemNotifications;
  final bool promotionNotifications;
  final bool emergencyNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      rideNotifications: json['rideNotifications'] as bool? ?? true,
      paymentNotifications: json['paymentNotifications'] as bool? ?? true,
      systemNotifications: json['systemNotifications'] as bool? ?? true,
      promotionNotifications: json['promotionNotifications'] as bool? ?? false,
      emergencyNotifications: json['emergencyNotifications'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideNotifications': rideNotifications,
      'paymentNotifications': paymentNotifications,
      'systemNotifications': systemNotifications,
      'promotionNotifications': promotionNotifications,
      'emergencyNotifications': emergencyNotifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? rideNotifications,
    bool? paymentNotifications,
    bool? systemNotifications,
    bool? promotionNotifications,
    bool? emergencyNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      rideNotifications: rideNotifications ?? this.rideNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      promotionNotifications: promotionNotifications ?? this.promotionNotifications,
      emergencyNotifications: emergencyNotifications ?? this.emergencyNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object?> get props => [
        rideNotifications,
        paymentNotifications,
        systemNotifications,
        promotionNotifications,
        emergencyNotifications,
        soundEnabled,
        vibrationEnabled,
      ];
}

/// Privacy settings
class PrivacySettings extends Equatable {
  const PrivacySettings({
    this.shareLocation = true,
    this.allowDataCollection = false,
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.marketingEmails = false,
  });

  final bool shareLocation;
  final bool allowDataCollection;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool marketingEmails;

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      shareLocation: json['shareLocation'] as bool? ?? true,
      allowDataCollection: json['allowDataCollection'] as bool? ?? false,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
      crashReportingEnabled: json['crashReportingEnabled'] as bool? ?? true,
      marketingEmails: json['marketingEmails'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shareLocation': shareLocation,
      'allowDataCollection': allowDataCollection,
      'analyticsEnabled': analyticsEnabled,
      'crashReportingEnabled': crashReportingEnabled,
      'marketingEmails': marketingEmails,
    };
  }

  PrivacySettings copyWith({
    bool? shareLocation,
    bool? allowDataCollection,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? marketingEmails,
  }) {
    return PrivacySettings(
      shareLocation: shareLocation ?? this.shareLocation,
      allowDataCollection: allowDataCollection ?? this.allowDataCollection,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      marketingEmails: marketingEmails ?? this.marketingEmails,
    );
  }

  @override
  List<Object?> get props => [
        shareLocation,
        allowDataCollection,
        analyticsEnabled,
        crashReportingEnabled,
        marketingEmails,
      ];
}

/// Appearance settings
class AppearanceSettings extends Equatable {
  const AppearanceSettings({
    this.theme = 'light',
    this.fontSize = 'medium',
    this.colorScheme = 'default',
  });

  final String theme;
  final String fontSize;
  final String colorScheme;

  factory AppearanceSettings.fromJson(Map<String, dynamic> json) {
    return AppearanceSettings(
      theme: json['theme'] as String? ?? 'light',
      fontSize: json['fontSize'] as String? ?? 'medium',
      colorScheme: json['colorScheme'] as String? ?? 'default',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'fontSize': fontSize,
      'colorScheme': colorScheme,
    };
  }

  AppearanceSettings copyWith({
    String? theme,
    String? fontSize,
    String? colorScheme,
  }) {
    return AppearanceSettings(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }

  @override
  List<Object?> get props => [theme, fontSize, colorScheme];
}
