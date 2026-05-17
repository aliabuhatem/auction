import 'package:equatable/equatable.dart';

class AppUserEntity extends Equatable {
  final String   id;
  final String   displayName;
  final String   email;
  final String?  photoUrl;
  final String?  phoneNumber;
  final bool     isActive;
  final DateTime createdAt;

  const AppUserEntity({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.phoneNumber,
    required this.isActive,
    required this.createdAt,
  });

  AppUserEntity copyWith({
    String?   displayName,
    String?   email,
    String?   photoUrl,
    String?   phoneNumber,
    bool?     isActive,
    DateTime? createdAt,
  }) => AppUserEntity(
    id:          id,
    displayName: displayName  ?? this.displayName,
    email:       email        ?? this.email,
    photoUrl:    photoUrl     ?? this.photoUrl,
    phoneNumber: phoneNumber  ?? this.phoneNumber,
    isActive:    isActive     ?? this.isActive,
    createdAt:   createdAt    ?? this.createdAt,
  );

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  List<Object?> get props =>
      [id, displayName, email, photoUrl, phoneNumber, isActive, createdAt];
}

class UserStatsEntity extends Equatable {
  final int totalUsers;
  final int newToday;
  final int newThisWeek;

  const UserStatsEntity({
    required this.totalUsers,
    required this.newToday,
    required this.newThisWeek,
  });

  @override
  List<Object?> get props => [totalUsers, newToday, newThisWeek];
}
