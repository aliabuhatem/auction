import 'package:equatable/equatable.dart';

class BidEntity extends Equatable {
  final String id;
  final String auctionId;
  final String userId;
  final String? userName;
  final double amount;
  final DateTime placedAt;

  const BidEntity({
    required this.id,
    required this.auctionId,
    required this.userId,
    this.userName,
    required this.amount,
    required this.placedAt,
  });

  String get maskedUserName {
    if (userName == null || userName!.isEmpty) return 'Anoniem';
    final parts = userName!.split(' ');
    return parts.map((p) => p.isNotEmpty ? '${p[0]}***' : '').join(' ');
  }

  @override
  List<Object?> get props => [id, auctionId, userId, amount, placedAt];
}
