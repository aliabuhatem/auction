import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../data/datasources/admin_remote_datasource.dart';

part 'admin_auth_event.dart';
part 'admin_auth_state.dart';

class AdminAuthBloc extends Bloc<AdminAuthEvent, AdminAuthState> {
  final AdminRemoteDatasource _datasource;
  StreamSubscription<AdminUserEntity?>? _authSub;

  AdminAuthBloc(this._datasource) : super(AdminAuthInitial()) {
    on<AdminAuthStarted>  (_onStarted);
    on<AdminLoginRequested>(_onLogin);
    on<AdminLogoutRequested>(_onLogout);
    on<_AdminUserChanged>  (_onUserChanged);
  }

  Future<void> _onStarted(AdminAuthStarted event, Emitter<AdminAuthState> emit) async {
    emit(AdminAuthLoading());
    _authSub?.cancel();
    _authSub = _datasource.watchCurrentAdmin().listen(
      (user) => add(_AdminUserChanged(user)),
    );
  }

  Future<void> _onLogin(AdminLoginRequested event, Emitter<AdminAuthState> emit) async {
    emit(AdminAuthLoading());
    try {
      final user = await _datasource.loginAdmin(event.email, event.password);
      emit(AdminAuthenticated(user));
    } catch (e) {
      emit(AdminAuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogout(AdminLogoutRequested event, Emitter<AdminAuthState> emit) async {
    await _datasource.logoutAdmin();
    emit(AdminUnauthenticated());
  }

  void _onUserChanged(_AdminUserChanged event, Emitter<AdminAuthState> emit) {
    if (event.user != null) {
      emit(AdminAuthenticated(event.user!));
    } else {
      emit(AdminUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
