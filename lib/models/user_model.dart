import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final String provider;
  final String? fcmToken;
  final bool isEmailVerified;
  final String? phoneNumber;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.provider,
    this.fcmToken,
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
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
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
    isEmailVerified,
    phoneNumber,
  ];

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, provider: $provider)';
  }
}
