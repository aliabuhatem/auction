import 'package:equatable/equatable.dart';

enum AuctionStatus { upcoming, live, ended, sold }
enum AuctionCategory { vacation, beauty, sauna, food, products, experiences, sports, wellness, dayTrips }

extension AuctionCategoryX on AuctionCategory {
  String get label {
    switch (this) {
      case AuctionCategory.vacation:    return 'Vakantie';
      case AuctionCategory.beauty:      return 'Beauty';
      case AuctionCategory.sauna:       return 'Sauna';
      case AuctionCategory.food:        return 'Eten';
      case AuctionCategory.products:    return 'Producten';
      case AuctionCategory.experiences: return 'Beleving';
      case AuctionCategory.sports:      return 'Sport';
      case AuctionCategory.wellness:    return 'Wellness';
      case AuctionCategory.dayTrips:    return 'Dagtrips';
    }
  }

  String get firestoreValue {
    switch (this) {
      case AuctionCategory.vacation:    return 'vacation';
      case AuctionCategory.beauty:      return 'beauty';
      case AuctionCategory.sauna:       return 'sauna';
      case AuctionCategory.food:        return 'food';
      case AuctionCategory.products:    return 'products';
      case AuctionCategory.experiences: return 'experiences';
      case AuctionCategory.sports:      return 'sports';
      case AuctionCategory.wellness:    return 'wellness';
      case AuctionCategory.dayTrips:    return 'daytrips';
    }
  }
}

extension AuctionStatusX on AuctionStatus {
  String get firestoreValue {
    switch (this) {
      case AuctionStatus.upcoming: return 'scheduled';
      case AuctionStatus.live:     return 'live';
      case AuctionStatus.ended:    return 'ended';
      case AuctionStatus.sold:     return 'sold';
    }
  }
}

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
  final double retailValue;
  final bool isWatchlisted;
  final String? winnerId;
  // ── Advanced bidding ──────────────────────────────────────────────────────
  final double minBidIncrement;
  final double? buyNowPrice;
  final int watchers;
  final int extensionSeconds;
  final String? lastBidderId;
  // ── Discovery & metadata ──────────────────────────────────────────────────
  final DateTime? createdAt;   // null = unknown (isNew returns false)
  final int viewCount;
  // ── Shipping ─────────────────────────────────────────────────────────────
  final double? shippingCost;
  final String? shippingMethod;
  final int? shippingDays;

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
    this.minBidIncrement = 1.0,
    this.buyNowPrice,
    this.watchers = 0,
    this.extensionSeconds = 30,
    this.lastBidderId,
    this.createdAt,
    this.viewCount = 0,
    this.shippingCost,
    this.shippingMethod,
    this.shippingDays,
  });

  Duration get timeRemaining  => endsAt.difference(DateTime.now());
  bool get isLive             => status == AuctionStatus.live;
  bool get isEnding           => timeRemaining.inMinutes < 10 && timeRemaining.inSeconds > 0;
  bool get isEndingSoon       => timeRemaining.inSeconds > 0 && timeRemaining.inSeconds <= 60;
  bool get isNew              => createdAt != null &&
      createdAt!.isAfter(DateTime.now().subtract(const Duration(hours: 24)));
  double get nextMinBid       => currentBid + minBidIncrement;
  double get savingsPercent   =>
      ((retailValue - currentBid) / retailValue * 100).clamp(0, 100);

  @override
  List<Object?> get props => [id, title, currentBid, bidCount, endsAt, status, watchers];
}
