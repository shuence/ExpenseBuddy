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
          ? _parseDateTime(json['createdAt'])
          : null,
      lastLoginAt: json['lastLoginAt'] != null 
          ? _parseDateTime(json['lastLoginAt'])
          : null,
      isEmailVerified: json['isEmailVerified'] ?? false,
      phoneNumber: json['phoneNumber'],
      
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
    );
  }

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue is DateTime) {
      return dateValue;
    } else if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        // If parsing fails, return null
        return null;
      }
    } else if (dateValue is int) {
      // Handle timestamp in milliseconds
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else {
      // Fallback to null
      return null;
    }
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
  ];

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, provider: $provider)';
  }
}
