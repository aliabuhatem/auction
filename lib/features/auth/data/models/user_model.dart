import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.avatarUrl,
  });

  factory UserModel.fromFirebaseUser(User user) => UserModel(
    id: user.uid,
    email: user.email ?? '',
    displayName: user.displayName ?? user.email?.split('@').first ?? 'Gebruiker',
    avatarUrl: user.photoURL,
  );

  factory UserModel.fromJson(Map<String, dynamic> d) => UserModel(
    id: d['id'] ?? '',
    email: d['email'] ?? '',
    displayName: d['displayName'] ?? '',
    avatarUrl: d['avatarUrl'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'avatarUrl': avatarUrl,
  };
}
