// lib/features/admin/presentation/bloc/admin_voucher_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_voucher_entity.dart';
import '../../data/datasources/admin_voucher_datasource.dart';

part 'admin_voucher_event.dart';

class AdminVoucherBloc extends Bloc<AdminVoucherEvent, AdminVoucherState> {
  final AdminVoucherDatasource _ds;

  AdminVoucherBloc(this._ds) : super(AdminVoucherInitial()) {
    on<LoadAdminVouchers>       (_onLoad);
    on<FilterAdminVouchers>     (_onFilter);
    on<GenerateAdminVoucher>    (_onGenerate);
    on<BulkGenerateAdminVouchers>(_onBulkGenerate);
    on<UpdateAdminVoucherStatus> (_onUpdateStatus);
    on<ClearBulkCodes>          (_onClearBulk);
  }

  VoucherStatus? _statusFilter;
  String?        _search;

  Future<void> _onLoad(
      LoadAdminVouchers event, Emitter<AdminVoucherState> emit) async {
    emit(AdminVoucherLoading());
    try {
      final vouchers = await _ds.getVouchers(
          status: _statusFilter, search: _search);
      final stats = await _ds.getVoucherStats();
      emit(AdminVoucherLoaded(
        vouchers:     vouchers,
        stats:        stats,
        statusFilter: _statusFilter,
        search:       _search ?? '',
      ));
    } catch (e) {
      emit(AdminVoucherError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onFilter(
      FilterAdminVouchers event, Emitter<AdminVoucherState> emit) async {
    _statusFilter = event.status;
    _search       = event.search;
    add(const LoadAdminVouchers());
  }

  Future<void> _onGenerate(
      GenerateAdminVoucher event, Emitter<AdminVoucherState> emit) async {
    try {
      await _ds.generateVoucher(
        auctionId:    event.auctionId,
        auctionTitle: event.auctionTitle,
        userId:       event.userId,
        userName:     event.userName,
        userEmail:    event.userEmail,
        expiresAt:    event.expiresAt,
      );
      add(const LoadAdminVouchers());
    } catch (e) {
      emit(AdminVoucherError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onBulkGenerate(
      BulkGenerateAdminVouchers event, Emitter<AdminVoucherState> emit) async {
    if (state is! AdminVoucherLoaded) return;
    try {
      final codes = await _ds.bulkGenerateVouchers(
        auctionId:    event.auctionId,
        auctionTitle: event.auctionTitle,
        quantity:     event.quantity,
        expiresAt:    event.expiresAt,
      );

      final vouchers = await _ds.getVouchers(
          status: _statusFilter, search: _search);
      final stats = await _ds.getVoucherStats();

      emit(AdminVoucherLoaded(
        vouchers:         vouchers,
        stats:            stats,
        statusFilter:     _statusFilter,
        search:           _search ?? '',
        bulkCodes:        codes,
        bulkAuctionTitle: event.auctionTitle,
        bulkExpiresAt:    event.expiresAt,
      ));
    } catch (e) {
      emit(AdminVoucherError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateStatus(
      UpdateAdminVoucherStatus event, Emitter<AdminVoucherState> emit) async {
    final current = state;
    if (current is! AdminVoucherLoaded) return;

    final voucher = current.vouchers.firstWhere(
      (v) => v.id == event.voucherId,
      orElse: () => throw Exception('Voucher niet gevonden'),
    );
    final before = {'status': voucher.status.firestoreValue};

    try {
      await _ds.updateVoucherStatus(
        event.voucherId, event.newStatus,
        event.adminId,   event.adminName, before,
      );
      final updated = current.vouchers
          .map((v) => v.id == event.voucherId
              ? v.copyWith(
                  status: event.newStatus,
                  usedAt: event.newStatus == VoucherStatus.used
                      ? DateTime.now()
                      : v.usedAt,
                )
              : v)
          .toList();
      emit(current.copyWith(vouchers: updated));
    } catch (e) {
      emit(AdminVoucherError(e.toString().replaceAll('Exception: ', '')));
      add(const LoadAdminVouchers());
    }
  }

  void _onClearBulk(ClearBulkCodes event, Emitter<AdminVoucherState> emit) {
    if (state is AdminVoucherLoaded) {
      emit((state as AdminVoucherLoaded).copyWith(clearBulk: true));
    }
  }
}
