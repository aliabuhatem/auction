// lib/features/admin/presentation/bloc/admin_order_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_order_entity.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../data/datasources/admin_order_datasource.dart';

part 'admin_order_event.dart';

class AdminOrderBloc extends Bloc<AdminOrderEvent, AdminOrderState> {
  final AdminOrderDatasource _ds;

  AdminOrderBloc(this._ds) : super(AdminOrderInitial()) {
    on<LoadAdminOrders>(_onLoad);
    on<FilterAdminOrders>(_onFilter);
    on<UpdateAdminOrderStatus>(_onUpdateStatus);
    on<SelectAdminOrder>(_onSelect);
    on<SendAdminPaymentReminder>(_onSendReminder);
  }

  OrderStatus? _statusFilter;
  String? _search;
  DateTime? _from;
  DateTime? _to;

  Future<void> _onLoad(
      LoadAdminOrders event, Emitter<AdminOrderState> emit) async {
    emit(AdminOrderLoading());
    try {
      final orders = await _ds.getOrders(
        status: _statusFilter,
        search: _search,
        from: _from,
        to: _to,
      );
      final stats = await _ds.getOrderStats();
      final chart = await _ds.getRevenueChart();

      emit(AdminOrderLoaded(
        orders: orders,
        stats: stats,
        revenueChart: chart,
        statusFilter: _statusFilter,
        search: _search ?? '',
      ));
    } catch (e) {
      emit(AdminOrderError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFilter(
      FilterAdminOrders event, Emitter<AdminOrderState> emit) async {
    _statusFilter = event.status;
    _search = event.search;
    _from = event.from;
    _to = event.to;
    add(LoadAdminOrders());
  }

  Future<void> _onUpdateStatus(
      UpdateAdminOrderStatus event, Emitter<AdminOrderState> emit) async {
    final current = state;
    if (current is! AdminOrderLoaded) return;

    final order = current.orders.firstWhere(
      (o) => o.id == event.orderId,
      orElse: () => throw Exception('Order niet gevonden'),
    );
    final before = {
      'status': order.status.firestoreValue,
      'paidAt': order.paidAt?.toIso8601String(),
    };

    try {
      await _ds.updateOrderStatus(
        event.orderId,
        event.newStatus,
        event.adminId,
        event.adminName,
        before,
      );

      final paidAt =
          event.newStatus == OrderStatus.paid ? DateTime.now() : order.paidAt;

      final updated = current.orders
          .map((o) => o.id == event.orderId
              ? o.copyWith(status: event.newStatus, paidAt: paidAt)
              : o)
          .toList();

      final updatedSelected = current.selectedOrder?.id == event.orderId
          ? updated.firstWhere((o) => o.id == event.orderId)
          : current.selectedOrder;

      emit(current.copyWith(orders: updated, selectedOrder: updatedSelected));
    } catch (e) {
      emit(AdminOrderError(e.toString().replaceAll('Exception: ', '')));
      add(LoadAdminOrders());
    }
  }

  void _onSelect(SelectAdminOrder event, Emitter<AdminOrderState> emit) {
    if (state is AdminOrderLoaded) {
      emit((state as AdminOrderLoaded).copyWith(
        selectedOrder: event.order,
        clearSelected: event.order == null,
      ));
    }
  }

  Future<void> _onSendReminder(
      SendAdminPaymentReminder event, Emitter<AdminOrderState> emit) async {
    try {
      await _ds.sendPaymentReminder(event.userId, event.auctionTitle);
    } catch (e) {
      emit(AdminOrderError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
