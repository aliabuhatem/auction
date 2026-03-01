// Auction entity

import 'package:equatable/equatable.dart';

enum AuctionStatus { upcoming, live, ended, sold }
enum AuctionCategory { vacation, beauty, sauna, food, products, experiences, sports, wellness, dayTrips }

class AuctionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;
  final double currentBid;
  final double startingBid;
  final int bidCount;
  final DateTime endsAt;
  final AuctionStatus status;
  final AuctionCategory category;
  final String location;
  final double retailValue;   // Original market price
  final bool isWatchlisted;
  final String? winnerId;

  const AuctionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
    required this.currentBid,
    required this.startingBid,
    required this.bidCount,
    required this.endsAt,
    required this.status,
    required this.category,
    required this.location,
    required this.retailValue,
    this.isWatchlisted = false,
    this.winnerId,
  });

  // Time remaining
  Duration get timeRemaining => endsAt.difference(DateTime.now());
  bool get isLive => status == AuctionStatus.live;
  bool get isEnding => timeRemaining.inMinutes < 10;

  // Savings compared to retail
  double get savingsPercent =>
      ((retailValue - currentBid) / retailValue * 100).clamp(0, 100);

  @override
  List<Object?> get props => [id, title, currentBid, bidCount, endsAt, status];
}