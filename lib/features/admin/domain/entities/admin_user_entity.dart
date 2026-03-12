import 'package:equatable/equatable.dart';

enum AdminRole { superAdmin, branchManager, viewer }

extension AdminRoleX on AdminRole {
  String get label {
    switch (this) {
      case AdminRole.superAdmin:    return 'Super Admin';
      case AdminRole.branchManager: return 'Branch Manager';
      case AdminRole.viewer:        return 'Viewer';
    }
  }

  String get firestoreValue {
    switch (this) {
      case AdminRole.superAdmin:    return 'super_admin';
      case AdminRole.branchManager: return 'branch_manager';
      case AdminRole.viewer:        return 'viewer';
    }
  }

  static AdminRole fromString(String? v) {
    switch (v) {
      case 'super_admin':    return AdminRole.superAdmin;
      case 'branch_manager': return AdminRole.branchManager;
      default:               return AdminRole.viewer;
    }
  }
}

class AdminUserEntity extends Equatable {
  final String    id;
  final String    email;
  final String    displayName;
  final AdminRole role;
  final String?   branch;
  final bool      isActive;

  const AdminUserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.branch,
    this.isActive = true,
  });

  bool get canManageUsers      => role == AdminRole.superAdmin;
  bool get canManageSettings   => role == AdminRole.superAdmin;
  bool get canCreateAuctions   => role != AdminRole.viewer;
  bool get canDeleteAuctions   => role == AdminRole.superAdmin;
  bool get canSendNotifications => role != AdminRole.viewer;

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  AdminUserEntity copyWith({
    String? displayName, AdminRole? role, String? branch, bool? isActive,
  }) =>
      AdminUserEntity(
        id: id, email: email,
        displayName: displayName ?? this.displayName,
        role:        role        ?? this.role,
        branch:      branch      ?? this.branch,
        isActive:    isActive    ?? this.isActive,
      );

  @override
  List<Object?> get props => [id, email, role, branch, isActive];
}
