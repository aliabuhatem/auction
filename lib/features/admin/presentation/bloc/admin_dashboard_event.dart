part of 'admin_dashboard_bloc.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();
  @override List<Object?> get props => [];
}
class LoadDashboardStats extends AdminDashboardEvent {}

// ── States ────────────────────────────────────────────────────────────────────
abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();
  @override List<Object?> get props => [];
}
class AdminDashboardInitial extends AdminDashboardState {}
class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final DashboardStatsEntity stats;
  const AdminDashboardLoaded(this.stats);
  @override List<Object> get props => [stats];
}

class AdminDashboardError extends AdminDashboardState {
  final String message;
  const AdminDashboardError(this.message);
  @override List<Object> get props => [message];
}
