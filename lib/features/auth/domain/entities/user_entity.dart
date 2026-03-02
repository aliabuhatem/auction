import 'package:equatable/equatable.dart';

/// Core user domain entity.
/// This is the single source of truth for user data across the whole app.
/// All layers (data, presentation) map to/from this.
class UserEntity extends Equatable {
  final String  id;
  final String  email;
  final String  displayName;
  final String? avatarUrl;
  final String? phoneNumber;
  final bool    isEmailVerified;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.createdAt,
  });

  // ── Derived helpers ──────────────────────────────────────────────────────

  /// First letter of displayName, uppercased — used for avatar fallback.
  String get initials {
    if (displayName.isEmpty) return '?';
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName[0].toUpperCase();
  }

  /// First name only (everything before the first space).
  String get firstName {
    final trimmed = displayName.trim();
    final spaceIdx = trimmed.indexOf(' ');
    return spaceIdx == -1 ? trimmed : trimmed.substring(0, spaceIdx);
  }

  /// True when the entity has all mandatory fields populated.
  bool get isComplete => id.isNotEmpty && email.isNotEmpty && displayName.isNotEmpty;

  // ── CopyWith ─────────────────────────────────────────────────────────────

  UserEntity copyWith({
    String?   id,
    String?   email,
    String?   displayName,
    String?   avatarUrl,
    String?   phoneNumber,
    bool?     isEmailVerified,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id:              id              ?? this.id,
      email:           email           ?? this.email,
      displayName:     displayName     ?? this.displayName,
      avatarUrl:       avatarUrl       ?? this.avatarUrl,
      phoneNumber:     phoneNumber     ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt:       createdAt       ?? this.createdAt,
    );
  }

  // ── Equatable ────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        phoneNumber,
        isEmailVerified,
        createdAt,
      ];

  @override
  String toString() =>
      'UserEntity(id: $id, email: $email, displayName: $displayName)';
}
