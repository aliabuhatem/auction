// lib/features/admin/presentation/bloc/admin_order_event.dart
part of 'admin_order_bloc.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AdminOrderEvent extends Equatable {
  const AdminOrderEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdminOrders extends AdminOrderEvent {}

class FilterAdminOrders extends AdminOrderEvent {
  final OrderStatus? status;
  final String? search;
  final DateTime? from;
  final DateTime? to;
  const FilterAdminOrders({this.status, this.search, this.from, this.to});
  @override
  List<Object?> get props => [status, search, from, to];
}

class UpdateAdminOrderStatus extends AdminOrderEvent {
  final String orderId;
  final OrderStatus newStatus;
  final String adminId;
  final String adminName;
  const UpdateAdminOrderStatus({
    required this.orderId,
    required this.newStatus,
    required this.adminId,
    required this.adminName,
  });
  @override
  List<Object> get props => [orderId, newStatus, adminId, adminName];
}

class SelectAdminOrder extends AdminOrderEvent {
  final AdminOrderEntity? order;
  const SelectAdminOrder(this.order);
  @override
  List<Object?> get props => [order];
}

class SendAdminPaymentReminder extends AdminOrderEvent {
  final String userId;
  final String auctionTitle;
  const SendAdminPaymentReminder({
    required this.userId,
    required this.auctionTitle,
  });
  @override
  List<Object> get props => [userId, auctionTitle];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AdminOrderState extends Equatable {
  const AdminOrderState();
  @override
  List<Object?> get props => [];
}

class AdminOrderInitial extends AdminOrderState {}

class AdminOrderLoading extends AdminOrderState {}

class AdminOrderLoaded extends AdminOrderState {
  final List<AdminOrderEntity> orders;
  final OrderStatsEntity stats;
  final List<ChartPoint> revenueChart;
  final OrderStatus? statusFilter;
  final String search;
  final AdminOrderEntity? selectedOrder;

  const AdminOrderLoaded({
    required this.orders,
    required this.stats,
    required this.revenueChart,
    this.statusFilter,
    this.search = '',
    this.selectedOrder,
  });

  AdminOrderLoaded copyWith({
    List<AdminOrderEntity>? orders,
    OrderStatsEntity? stats,
    List<ChartPoint>? revenueChart,
    OrderStatus? statusFilter,
    String? search,
    AdminOrderEntity? selectedOrder,
    bool clearSelected = false,
  }) =>
      AdminOrderLoaded(
        orders: orders ?? this.orders,
        stats: stats ?? this.stats,
        revenueChart: revenueChart ?? this.revenueChart,
        statusFilter: statusFilter ?? this.statusFilter,
        search: search ?? this.search,
        selectedOrder:
            clearSelected ? null : (selectedOrder ?? this.selectedOrder),
      );

  @override
  List<Object?> get props =>
      [orders, stats, statusFilter, search, selectedOrder];
}

class AdminOrderError extends AdminOrderState {
  final String message;
  const AdminOrderError(this.message);
  @override
  List<Object> get props => [message];
}
