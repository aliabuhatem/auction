import 'package:equatable/equatable.dart';
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object?> get props => [];
}
class AppStarted extends AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email, password;
  const LoginRequested({required this.email, required this.password});
  @override List<Object> get props => [email, password];
}
class RegisterRequested extends AuthEvent {
  final String email, password, name;
  final String? referralCode;
  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    this.referralCode,
  });
  @override List<Object?> get props => [email, password, name, referralCode];
}
class GoogleLoginRequested extends AuthEvent {}
class LogoutRequested extends AuthEvent {}
