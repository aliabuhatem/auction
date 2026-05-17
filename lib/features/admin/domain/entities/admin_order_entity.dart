// lib/features/admin/domain/entities/admin_order_entity.dart
import 'package:equatable/equatable.dart';

enum OrderStatus { pending, paid, failed, cancelled, refunded }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:   return 'In afwachting';
      case OrderStatus.paid:      return 'Betaald';
      case OrderStatus.failed:    return 'Mislukt';
      case OrderStatus.cancelled: return 'Geannuleerd';
      case OrderStatus.refunded:  return 'Terugbetaald';
    }
  }

  String get firestoreValue => name;

  static OrderStatus fromString(String? v) {
    switch (v) {
      case 'paid':      return OrderStatus.paid;
      case 'failed':    return OrderStatus.failed;
      case 'cancelled': return OrderStatus.cancelled;
      case 'refunded':  return OrderStatus.refunded;
      default:          return OrderStatus.pending;
    }
  }
}

class AdminOrderEntity extends Equatable {
  final String      id;
  final String      auctionId;
  final String      auctionTitle;
  final String      userId;
  final String      userName;
  final String      userEmail;
  final double      amount;
  final OrderStatus status;
  final String      molliePaymentId;
  final String      mollieCheckoutUrl;
  final String?     paymentMethod;
  final DateTime    createdAt;
  final DateTime?   paidAt;
  final DateTime    expiresAt;

  const AdminOrderEntity({
    required this.id,
    required this.auctionId,
    required this.auctionTitle,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.amount,
    required this.status,
    required this.molliePaymentId,
    required this.mollieCheckoutUrl,
    this.paymentMethod,
    required this.createdAt,
    this.paidAt,
    required this.expiresAt,
  });

  bool get isAlmostExpired =>
      status == OrderStatus.pending &&
      DateTime.now().difference(createdAt).inHours >= 20;

  Duration get timeToExpiry => expiresAt.difference(DateTime.now());

  String get shortId =>
      id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

  AdminOrderEntity copyWith({OrderStatus? status, DateTime? paidAt}) =>
      AdminOrderEntity(
        id:                id,
        auctionId:         auctionId,
        auctionTitle:      auctionTitle,
        userId:            userId,
        userName:          userName,
        userEmail:         userEmail,
        amount:            amount,
        molliePaymentId:   molliePaymentId,
        mollieCheckoutUrl: mollieCheckoutUrl,
        paymentMethod:     paymentMethod,
        createdAt:         createdAt,
        expiresAt:         expiresAt,
        status: status ?? this.status,
        paidAt: paidAt  ?? this.paidAt,
      );

  @override
  List<Object?> get props => [id, status, amount, createdAt];
}

class OrderStatsEntity {
  final double totalRevenue;
  final int    pendingCount;
  final int    failedCount;
  final double refundedTotal;
  final int    expiringCount;

  const OrderStatsEntity({
    required this.totalRevenue,
    required this.pendingCount,
    required this.failedCount,
    required this.refundedTotal,
    required this.expiringCount,
  });
}
