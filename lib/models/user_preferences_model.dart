import 'package:equatable/equatable.dart';

class UserPreferencesModel extends Equatable {
  final String userId;
  final String country;
  final String countryCode;
  final String defaultCurrency;
  final String language;
  final bool locationPermission;
  final bool cameraPermission;
  final bool storagePermission;
  final bool smsPermission;
  final bool biometricPermission;
  final bool notificationPermission;
  final bool isFirstTimeSetup;
  final NotificationSettings notificationSettings;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPreferencesModel({
    required this.userId,
    required this.country,
    required this.countryCode,
    required this.defaultCurrency,
    this.language = 'en',
    this.locationPermission = false,
    this.cameraPermission = false,
    this.storagePermission = false,
    this.smsPermission = false,
    this.biometricPermission = false,
    this.notificationPermission = false,
    this.isFirstTimeSetup = true,
    this.notificationSettings = const NotificationSettings(),
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      userId: json['userId'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['countryCode'] ?? '',
      defaultCurrency: json['defaultCurrency'] ?? 'USD',
      language: json['language'] ?? 'en',
      locationPermission: json['locationPermission'] ?? false,
      cameraPermission: json['cameraPermission'] ?? false,
      storagePermission: json['storagePermission'] ?? false,
      smsPermission: json['smsPermission'] ?? false,
      biometricPermission: json['biometricPermission'] ?? false,
             notificationPermission: json['notificationPermission'] ?? false,
       isFirstTimeSetup: json['isFirstTimeSetup'] ?? true,
       notificationSettings: json['notificationSettings'] != null
           ? NotificationSettings.fromJson(json['notificationSettings'])
           : const NotificationSettings(),
       latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      city: json['city'],
      state: json['state'],
      timezone: json['timezone'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime
                ? json['createdAt']
                : DateTime.parse(json['createdAt'].toDate().toIso8601String()))
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is DateTime
                ? json['updatedAt']
                : DateTime.parse(json['updatedAt'].toDate().toIso8601String()))
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'country': country,
      'countryCode': countryCode,
      'defaultCurrency': defaultCurrency,
      'language': language,
      'locationPermission': locationPermission,
      'cameraPermission': cameraPermission,
      'storagePermission': storagePermission,
      'smsPermission': smsPermission,
      'biometricPermission': biometricPermission,
             'notificationPermission': notificationPermission,
       'isFirstTimeSetup': isFirstTimeSetup,
       'notificationSettings': notificationSettings.toJson(),
       'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserPreferencesModel copyWith({
    String? userId,
    String? country,
    String? countryCode,
    String? defaultCurrency,
    String? language,
    bool? locationPermission,
    bool? cameraPermission,
    bool? storagePermission,
    bool? smsPermission,
    bool? biometricPermission,
    bool? notificationPermission,
    bool? isFirstTimeSetup,
    NotificationSettings? notificationSettings,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferencesModel(
      userId: userId ?? this.userId,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      language: language ?? this.language,
      locationPermission: locationPermission ?? this.locationPermission,
      cameraPermission: cameraPermission ?? this.cameraPermission,
      storagePermission: storagePermission ?? this.storagePermission,
      smsPermission: smsPermission ?? this.smsPermission,
      biometricPermission: biometricPermission ?? this.biometricPermission,
      notificationPermission:notificationPermission ?? this.notificationPermission,
      isFirstTimeSetup: isFirstTimeSetup ?? this.isFirstTimeSetup,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      state: state ?? this.state,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    country,
    countryCode,
    defaultCurrency,
    language,
    locationPermission,
    cameraPermission,
    storagePermission,
    smsPermission,
    biometricPermission,
    notificationPermission,
    isFirstTimeSetup,
    notificationSettings,
    latitude,
    longitude,
    city,
    state,
    timezone,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'UserPreferencesModel(userId: $userId, country: $country, currency: $defaultCurrency, isFirstTimeSetup: $isFirstTimeSetup)';
  }
}

class NotificationSettings extends Equatable {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final bool inAppEnabled;

  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
    this.inAppEnabled = true,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      smsEnabled: json['smsEnabled'] ?? false,
      inAppEnabled: json['inAppEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'smsEnabled': smsEnabled,
      'inAppEnabled': inAppEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? inAppEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
    );
  }

  @override
  List<Object?> get props => [pushEnabled, emailEnabled, smsEnabled, inAppEnabled];

  @override
  String toString() {
    return 'NotificationSettings(pushEnabled: $pushEnabled, emailEnabled: $emailEnabled, smsEnabled: $smsEnabled, inAppEnabled: $inAppEnabled)';
  }
}

// Country data model
class Country {
  final String name;
  final String code;
  final String flag;
  final String currency;
  final String currencyCode;
  final String currencySymbol;

  const Country({
    required this.name,
    required this.code,
    required this.flag,
    required this.currency,
    required this.currencyCode,
    required this.currencySymbol,
  });

  @override
  String toString() => name;
}

// Predefined countries with currencies
class Countries {
  static const List<Country> all = [
    Country(
      name: 'United States',
      code: 'US',
      flag: '🇺🇸',
      currency: 'US Dollar',
      currencyCode: 'USD',
      currencySymbol: '\$',
    ),
    Country(
      name: 'United Kingdom',
      code: 'GB',
      flag: '🇬🇧',
      currency: 'British Pound',
      currencyCode: 'GBP',
      currencySymbol: '£',
    ),
    Country(
      name: 'European Union',
      code: 'EU',
      flag: '🇪🇺',
      currency: 'Euro',
      currencyCode: 'EUR',
      currencySymbol: '€',
    ),
    Country(
      name: 'India',
      code: 'IN',
      flag: '🇮🇳',
      currency: 'Indian Rupee',
      currencyCode: 'INR',
      currencySymbol: '₹',
    ),
    Country(
      name: 'Canada',
      code: 'CA',
      flag: '🇨🇦',
      currency: 'Canadian Dollar',
      currencyCode: 'CAD',
      currencySymbol: 'C\$',
    ),
    Country(
      name: 'Australia',
      code: 'AU',
      flag: '🇦🇺',
      currency: 'Australian Dollar',
      currencyCode: 'AUD',
      currencySymbol: 'A\$',
    ),
    Country(
      name: 'Japan',
      code: 'JP',
      flag: '🇯🇵',
      currency: 'Japanese Yen',
      currencyCode: 'JPY',
      currencySymbol: '¥',
    ),
    Country(
      name: 'China',
      code: 'CN',
      flag: '🇨🇳',
      currency: 'Chinese Yuan',
      currencyCode: 'CNY',
      currencySymbol: '¥',
    ),
    Country(
      name: 'Brazil',
      code: 'BR',
      flag: '🇧🇷',
      currency: 'Brazilian Real',
      currencyCode: 'BRL',
      currencySymbol: 'R\$',
    ),
    Country(
      name: 'Mexico',
      code: 'MX',
      flag: '🇲🇽',
      currency: 'Mexican Peso',
      currencyCode: 'MXN',
      currencySymbol: '\$',
    ),
  ];

  static Country? findByCode(String code) {
    try {
      return all.firstWhere((country) => country.code == code);
    } catch (e) {
      return null;
    }
  }

  static Country? findByCurrencyCode(String currencyCode) {
    try {
      return all.firstWhere((country) => country.currencyCode == currencyCode);
    } catch (e) {
      return null;
    }
  }
}
