// lib/features/admin/domain/entities/admin_voucher_entity.dart
import 'package:equatable/equatable.dart';

enum VoucherStatus { valid, used, expired, revoked }

extension VoucherStatusX on VoucherStatus {
  String get label {
    switch (this) {
      case VoucherStatus.valid:   return 'Geldig';
      case VoucherStatus.used:    return 'Gebruikt';
      case VoucherStatus.expired: return 'Verlopen';
      case VoucherStatus.revoked: return 'Ingetrokken';
    }
  }

  String get firestoreValue => name;

  static VoucherStatus fromString(String? v) {
    switch (v) {
      case 'used':    return VoucherStatus.used;
      case 'expired': return VoucherStatus.expired;
      case 'revoked': return VoucherStatus.revoked;
      default:        return VoucherStatus.valid;
    }
  }
}

class AdminVoucherEntity extends Equatable {
  final String        id;
  final String        code;
  final String        auctionId;
  final String        auctionTitle;
  final String?       userId;
  final String?       userName;
  final String?       userEmail;
  final String?       orderId;
  final VoucherStatus status;
  final String        qrData;
  final DateTime      expiresAt;
  final DateTime?     usedAt;
  final DateTime      createdAt;

  const AdminVoucherEntity({
    required this.id,
    required this.code,
    required this.auctionId,
    required this.auctionTitle,
    this.userId,
    this.userName,
    this.userEmail,
    this.orderId,
    required this.status,
    required this.qrData,
    required this.expiresAt,
    this.usedAt,
    required this.createdAt,
  });

  bool get isExpired =>
      status == VoucherStatus.valid && expiresAt.isBefore(DateTime.now());

  AdminVoucherEntity copyWith({VoucherStatus? status, DateTime? usedAt}) =>
      AdminVoucherEntity(
        id:           id,
        code:         code,
        auctionId:    auctionId,
        auctionTitle: auctionTitle,
        userId:       userId,
        userName:     userName,
        userEmail:    userEmail,
        orderId:      orderId,
        qrData:       qrData,
        expiresAt:    expiresAt,
        createdAt:    createdAt,
        status: status ?? this.status,
        usedAt: usedAt ?? this.usedAt,
      );

  @override
  List<Object?> get props => [id, code, status, expiresAt];
}

class VoucherStatsEntity {
  final int validCount;
  final int usedCount;
  final int expiredCount;
  final int revokedCount;

  const VoucherStatsEntity({
    required this.validCount,
    required this.usedCount,
    required this.expiredCount,
    required this.revokedCount,
  });

  int get total => validCount + usedCount + expiredCount + revokedCount;
}
