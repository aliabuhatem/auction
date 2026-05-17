import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
    super.phoneNumber,
    super.isEmailVerified,
    super.createdAt,
  });

  factory UserModel.fromFirebaseUser(User user) => UserModel(
    id: user.uid,
    email: user.email ?? '',
    displayName: user.displayName ?? user.email?.split('@').first ?? 'Gebruiker',
    avatarUrl: user.photoURL,
    phoneNumber: user.phoneNumber,
    isEmailVerified: user.emailVerified,
    createdAt: user.metadata.creationTime,
  );

  factory UserModel.fromJson(Map<String, dynamic> d) => UserModel(
    id: d['id'] as String? ?? '',
    email: d['email'] as String? ?? '',
    displayName: d['displayName'] as String? ?? '',
    avatarUrl: d['avatarUrl'] as String?,
    phoneNumber: d['phoneNumber'] as String?,
    isEmailVerified: d['isEmailVerified'] as bool? ?? false,
    createdAt: d['createdAt'] is String
        ? DateTime.tryParse(d['createdAt'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'phoneNumber': phoneNumber,
    'isEmailVerified': isEmailVerified,
    'createdAt': createdAt?.toIso8601String(),
  };
}
