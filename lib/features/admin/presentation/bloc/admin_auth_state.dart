part of 'admin_auth_bloc.dart';

abstract class AdminAuthState extends Equatable {
  const AdminAuthState();
  @override List<Object?> get props => [];
}

class AdminAuthInitial       extends AdminAuthState {}
class AdminAuthLoading       extends AdminAuthState {}
class AdminUnauthenticated   extends AdminAuthState {}

class AdminAuthenticated extends AdminAuthState {
  final AdminUserEntity user;
  const AdminAuthenticated(this.user);
  @override List<Object> get props => [user];
}

class AdminAuthError extends AdminAuthState {
  final String message;
  const AdminAuthError(this.message);
  @override List<Object> get props => [message];
}
