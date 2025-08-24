import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String provider;
  final String? fcmToken;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;
  final String? phoneNumber;
  final NotificationSettings notificationSettings;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.provider,
    this.fcmToken,
    this.createdAt,
    this.lastLoginAt,
    required this.isEmailVerified,
    this.phoneNumber,
    required this.notificationSettings,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'User',
      photoURL: json['photoURL'],
      provider: json['provider'] ?? 'email',
      fcmToken: json['fcmToken'],
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] is DateTime 
              ? json['createdAt'] 
              : DateTime.parse(json['createdAt'].toDate().toIso8601String()))
          : null,
      lastLoginAt: json['lastLoginAt'] != null 
          ? (json['lastLoginAt'] is DateTime 
              ? json['lastLoginAt'] 
              : DateTime.parse(json['lastLoginAt'].toDate().toIso8601String()))
          : null,
      isEmailVerified: json['isEmailVerified'] ?? false,
      phoneNumber: json['phoneNumber'],
      notificationSettings: json['notificationSettings'] != null
          ? NotificationSettings.fromJson(json['notificationSettings'])
          : const NotificationSettings(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'provider': provider,
      'fcmToken': fcmToken,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'notificationSettings': notificationSettings.toJson(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? provider,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
    String? phoneNumber,
    NotificationSettings? notificationSettings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      provider: provider ?? this.provider,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoURL,
    provider,
    fcmToken,
    createdAt,
    lastLoginAt,
    isEmailVerified,
    phoneNumber,
    notificationSettings,
  ];

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, provider: $provider)';
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
