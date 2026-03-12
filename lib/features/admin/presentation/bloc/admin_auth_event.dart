part of 'admin_auth_bloc.dart';

abstract class AdminAuthEvent extends Equatable {
  const AdminAuthEvent();
  @override List<Object?> get props => [];
}

class AdminAuthStarted      extends AdminAuthEvent {}
class AdminLogoutRequested  extends AdminAuthEvent {}

class AdminLoginRequested extends AdminAuthEvent {
  final String email;
  final String password;
  const AdminLoginRequested({required this.email, required this.password});
  @override List<Object> get props => [email, password];
}

class _AdminUserChanged extends AdminAuthEvent {
  final AdminUserEntity? user;
  const _AdminUserChanged(this.user);
  @override List<Object?> get props => [user];
}
