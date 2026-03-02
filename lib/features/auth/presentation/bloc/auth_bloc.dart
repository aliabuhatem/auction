import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/usecases/usecase.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository repository;

  AuthBloc({required this.loginUseCase, required this.registerUseCase, required this.logoutUseCase, required this.repository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<GoogleLoginRequested>(_onGoogle);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onAppStarted(AppStarted e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = await repository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }
  Future<void> _onLogin(LoginRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final r = await loginUseCase(LoginParams(email: e.email, password: e.password));
    r.fold((f) => emit(AuthError(f.message)), (u) => emit(AuthAuthenticated(u)));
  }
  Future<void> _onRegister(RegisterRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final r = await registerUseCase(RegisterParams(email: e.email, password: e.password, name: e.name));
    r.fold((f) => emit(AuthError(f.message)), (u) => emit(AuthAuthenticated(u)));
  }
  Future<void> _onGoogle(GoogleLoginRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final r = await repository.loginWithGoogle();
    r.fold((f) => emit(AuthError(f.message)), (u) => emit(AuthAuthenticated(u)));
  }
  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    await logoutUseCase(NoParams());
    emit(AuthUnauthenticated());
  }
}
