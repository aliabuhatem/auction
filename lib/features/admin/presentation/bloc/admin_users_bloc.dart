import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user_entity.dart';
import '../../data/datasources/admin_users_datasource.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();
  @override List<Object?> get props => [];
}

class LoadAdminUsers extends AdminUsersEvent { const LoadAdminUsers(); }

class FilterAdminUsers extends AdminUsersEvent {
  final String? search;
  final bool?   isActive;
  const FilterAdminUsers({this.search, this.isActive});
  @override List<Object?> get props => [search, isActive];
}

class SelectAdminAppUser extends AdminUsersEvent {
  final AppUserEntity? user;
  const SelectAdminAppUser(this.user);
  @override List<Object?> get props => [user];
}

class ToggleAppUserActive extends AdminUsersEvent {
  final String userId;
  final bool   isActive;
  const ToggleAppUserActive(this.userId, this.isActive);
  @override List<Object?> get props => [userId, isActive];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();
  @override List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}
class AdminUsersLoading extends AdminUsersState {}

class AdminUsersError extends AdminUsersState {
  final String message;
  const AdminUsersError(this.message);
  @override List<Object?> get props => [message];
}

class AdminUsersLoaded extends AdminUsersState {
  final List<AppUserEntity> users;
  final UserStatsEntity     stats;
  final String              search;
  final bool?               isActiveFilter;
  final AppUserEntity?      selectedUser;

  const AdminUsersLoaded({
    required this.users,
    required this.stats,
    this.search        = '',
    this.isActiveFilter,
    this.selectedUser,
  });

  AdminUsersLoaded copyWith({
    List<AppUserEntity>? users,
    UserStatsEntity?     stats,
    String?              search,
    bool?                isActiveFilter,
    AppUserEntity?       selectedUser,
    bool                 clearSelected = false,
  }) => AdminUsersLoaded(
    users:          users          ?? this.users,
    stats:          stats          ?? this.stats,
    search:         search         ?? this.search,
    isActiveFilter: isActiveFilter ?? this.isActiveFilter,
    selectedUser:   clearSelected  ? null : (selectedUser ?? this.selectedUser),
  );

  @override List<Object?> get props =>
      [users, stats, search, isActiveFilter, selectedUser];
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final AdminUsersDatasource _ds;
  String? _search;
  bool?   _isActive;

  AdminUsersBloc(this._ds) : super(AdminUsersInitial()) {
    on<LoadAdminUsers>      (_onLoad);
    on<FilterAdminUsers>    (_onFilter);
    on<SelectAdminAppUser>  (_onSelect);
    on<ToggleAppUserActive> (_onToggle);
  }

  Future<void> _onLoad(
      LoadAdminUsers e, Emitter<AdminUsersState> emit) async {
    emit(AdminUsersLoading());
    try {
      final results = await Future.wait([
        _ds.getUsers(search: _search, isActive: _isActive),
        _ds.getUserStats(),
      ]);
      emit(AdminUsersLoaded(
        users:          results[0] as List<AppUserEntity>,
        stats:          results[1] as UserStatsEntity,
        search:         _search    ?? '',
        isActiveFilter: _isActive,
      ));
    } catch (e) {
      emit(AdminUsersError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onFilter(FilterAdminUsers e, Emitter<AdminUsersState> emit) {
    _search   = e.search?.isEmpty == true ? null : e.search;
    _isActive = e.isActive;
    add(const LoadAdminUsers());
  }

  void _onSelect(SelectAdminAppUser e, Emitter<AdminUsersState> emit) {
    if (state is AdminUsersLoaded) {
      emit((state as AdminUsersLoaded).copyWith(
        selectedUser:  e.user,
        clearSelected: e.user == null,
      ));
    }
  }

  Future<void> _onToggle(
      ToggleAppUserActive e, Emitter<AdminUsersState> emit) async {
    if (state is! AdminUsersLoaded) return;
    final s = state as AdminUsersLoaded;
    try {
      await _ds.toggleUserActive(e.userId, e.isActive);
      final updated = s.users
          .map((u) => u.id == e.userId ? u.copyWith(isActive: e.isActive) : u)
          .toList();
      emit(s.copyWith(users: updated));
    } catch (ex) {
      emit(AdminUsersError(ex.toString().replaceAll('Exception: ', '')));
    }
  }
}
