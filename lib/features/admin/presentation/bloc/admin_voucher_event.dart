// lib/features/admin/presentation/bloc/admin_voucher_event.dart
part of 'admin_voucher_bloc.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AdminVoucherEvent extends Equatable {
  const AdminVoucherEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdminVouchers extends AdminVoucherEvent {
  const LoadAdminVouchers();
}

class FilterAdminVouchers extends AdminVoucherEvent {
  final VoucherStatus? status;
  final String?        search;
  const FilterAdminVouchers({this.status, this.search});
  @override
  List<Object?> get props => [status, search];
}

class GenerateAdminVoucher extends AdminVoucherEvent {
  final String   auctionId;
  final String   auctionTitle;
  final String?  userId;
  final String?  userName;
  final String?  userEmail;
  final DateTime expiresAt;
  const GenerateAdminVoucher({
    required this.auctionId,
    required this.auctionTitle,
    this.userId,
    this.userName,
    this.userEmail,
    required this.expiresAt,
  });
  @override
  List<Object?> get props => [auctionId, userId, expiresAt];
}

class BulkGenerateAdminVouchers extends AdminVoucherEvent {
  final String   auctionId;
  final String   auctionTitle;
  final int      quantity;
  final DateTime expiresAt;
  const BulkGenerateAdminVouchers({
    required this.auctionId,
    required this.auctionTitle,
    required this.quantity,
    required this.expiresAt,
  });
  @override
  List<Object?> get props => [auctionId, quantity, expiresAt];
}

class UpdateAdminVoucherStatus extends AdminVoucherEvent {
  final String        voucherId;
  final VoucherStatus newStatus;
  final String        adminId;
  final String        adminName;
  const UpdateAdminVoucherStatus({
    required this.voucherId,
    required this.newStatus,
    required this.adminId,
    required this.adminName,
  });
  @override
  List<Object?> get props => [voucherId, newStatus];
}

class ClearBulkCodes extends AdminVoucherEvent {
  const ClearBulkCodes();
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AdminVoucherState extends Equatable {
  const AdminVoucherState();
  @override
  List<Object?> get props => [];
}

class AdminVoucherInitial extends AdminVoucherState {}

class AdminVoucherLoading extends AdminVoucherState {}

class AdminVoucherLoaded extends AdminVoucherState {
  final List<AdminVoucherEntity> vouchers;
  final VoucherStatsEntity       stats;
  final VoucherStatus?           statusFilter;
  final String                   search;
  final List<String>?            bulkCodes;
  final String?                  bulkAuctionTitle;
  final DateTime?                bulkExpiresAt;

  const AdminVoucherLoaded({
    required this.vouchers,
    required this.stats,
    this.statusFilter,
    this.search = '',
    this.bulkCodes,
    this.bulkAuctionTitle,
    this.bulkExpiresAt,
  });

  AdminVoucherLoaded copyWith({
    List<AdminVoucherEntity>? vouchers,
    VoucherStatsEntity?       stats,
    VoucherStatus?            statusFilter,
    String?                   search,
    List<String>?             bulkCodes,
    String?                   bulkAuctionTitle,
    DateTime?                 bulkExpiresAt,
    bool                      clearBulk = false,
  }) =>
      AdminVoucherLoaded(
        vouchers:         vouchers         ?? this.vouchers,
        stats:            stats            ?? this.stats,
        statusFilter:     statusFilter     ?? this.statusFilter,
        search:           search           ?? this.search,
        bulkCodes:        clearBulk ? null : (bulkCodes ?? this.bulkCodes),
        bulkAuctionTitle: clearBulk ? null : (bulkAuctionTitle ?? this.bulkAuctionTitle),
        bulkExpiresAt:    clearBulk ? null : (bulkExpiresAt ?? this.bulkExpiresAt),
      );

  @override
  List<Object?> get props =>
      [vouchers, stats, statusFilter, search, bulkCodes];
}

class AdminVoucherError extends AdminVoucherState {
  final String message;
  const AdminVoucherError(this.message);
  @override
  List<Object?> get props => [message];
}
