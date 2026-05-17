// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../notifications/notification_service.dart';
import '../../../../injection_container.dart' as di;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase    loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase   logoutUseCase;
  final AuthRepository  repository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.repository,
  }) : super(AuthInitial()) {
    on<AppStarted>      (_onAppStarted);
    on<LoginRequested>  (_onLogin);
    on<RegisterRequested>(_onRegister);
    on<GoogleLoginRequested>(_onGoogle);
    on<LogoutRequested> (_onLogout);
  }

  Future<void> _onAppStarted(AppStarted e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = await repository.getCurrentUser();
    if (user != null) {
      await _saveToken();
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final r = await loginUseCase(
        LoginParams(email: e.email, password: e.password));
    await r.fold(
      (f) async => emit(AuthError(f.message)),
      (u) async {
        await _saveToken();
        emit(AuthAuthenticated(u));
      },
    );
  }

  Future<void> _onRegister(
      RegisterRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final r = await registerUseCase(
        RegisterParams(email: e.email, password: e.password, name: e.name));
    await r.fold(
      (f) async => emit(AuthError(f.message)),
      (u) async {
        await _saveToken();
        emit(AuthAuthenticated(u));
      },
    );
  }

  Future<void> _onGoogle(
      GoogleLoginRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final r = await repository.loginWithGoogle();
    await r.fold(
      (f) async => emit(AuthError(f.message)),
      (u) async {
        await _saveToken();
        emit(AuthAuthenticated(u));
      },
    );
  }

  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    await _notifService?.onUserSignedOut();
    await logoutUseCase(NoParams());
    // Clear any backend JWT tokens stored in secure storage.
    try { await di.sl<ApiClient>().clearTokens(); } catch (_) {}
    emit(AuthUnauthenticated());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  NotificationService? get _notifService {
    try { return di.sl<NotificationService>(); } catch (_) { return null; }
  }

  Future<void> _saveToken() async {
    await _notifService?.onUserSignedIn();
  }
}
