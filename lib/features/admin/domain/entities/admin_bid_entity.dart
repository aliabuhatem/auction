import 'package:equatable/equatable.dart';

class AdminBidEntity extends Equatable {
  final String   id;
  final String   userId;
  final String   userName;
  final String   auctionId;
  final String   auctionTitle;
  final double   amount;
  final DateTime createdAt;

  const AdminBidEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.auctionId,
    required this.auctionTitle,
    required this.amount,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, userId, userName, auctionId, auctionTitle, amount, createdAt];
}

class BidStatsEntity extends Equatable {
  final int    totalBids;
  final int    todayBids;
  final double highestBid;
  final int    activeAuctions;

  const BidStatsEntity({
    required this.totalBids,
    required this.todayBids,
    required this.highestBid,
    required this.activeAuctions,
  });

  @override
  List<Object?> get props =>
      [totalBids, todayBids, highestBid, activeAuctions];
}
