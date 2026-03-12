import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../data/datasources/admin_remote_datasource.dart';
part 'admin_dashboard_event.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminRemoteDatasource _datasource;

  AdminDashboardBloc(this._datasource) : super(AdminDashboardInitial()) {
    on<LoadDashboardStats>(_onLoad);
  }

  Future<void> _onLoad(LoadDashboardStats event, Emitter<AdminDashboardState> emit) async {
    emit(AdminDashboardLoading());
    try {
      final stats = await _datasource.getDashboardStats();
      emit(AdminDashboardLoaded(stats));
    } catch (e) {
      emit(AdminDashboardError(e.toString()));
    }
  }
}
