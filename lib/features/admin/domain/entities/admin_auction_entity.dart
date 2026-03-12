import 'package:equatable/equatable.dart';

enum AuctionStatus { draft, scheduled, live, ended, cancelled }
enum AuctionCategory {
  vacation, beauty, sauna, food, experiences, products, sports, wellness, daytrips,
}

extension AuctionStatusX on AuctionStatus {
  String get label {
    switch (this) {
      case AuctionStatus.draft:      return 'Concept';
      case AuctionStatus.scheduled:  return 'Gepland';
      case AuctionStatus.live:       return 'Live';
      case AuctionStatus.ended:      return 'Afgelopen';
      case AuctionStatus.cancelled:  return 'Geannuleerd';
    }
  }
  String get firestoreValue => name;

  static AuctionStatus fromString(String? v) {
    switch (v) {
      case 'draft':     return AuctionStatus.draft;
      case 'scheduled': return AuctionStatus.scheduled;
      case 'live':      return AuctionStatus.live;
      case 'ended':     return AuctionStatus.ended;
      case 'cancelled': return AuctionStatus.cancelled;
      default:          return AuctionStatus.draft;
    }
  }
}

extension AuctionCategoryX on AuctionCategory {
  String get label {
    switch (this) {
      case AuctionCategory.vacation:    return 'Vakantie';
      case AuctionCategory.beauty:      return 'Beauty';
      case AuctionCategory.sauna:       return 'Sauna & Spa';
      case AuctionCategory.food:        return 'Eten & Drinken';
      case AuctionCategory.experiences: return 'Ervaringen';
      case AuctionCategory.products:    return 'Producten';
      case AuctionCategory.sports:      return 'Sport';
      case AuctionCategory.wellness:    return 'Wellness';
      case AuctionCategory.daytrips:    return 'Dagtrips';
    }
  }
  String get emoji {
    switch (this) {
      case AuctionCategory.vacation:    return '✈️';
      case AuctionCategory.beauty:      return '💅';
      case AuctionCategory.sauna:       return '🧖';
      case AuctionCategory.food:        return '🍽️';
      case AuctionCategory.experiences: return '🎭';
      case AuctionCategory.products:    return '📦';
      case AuctionCategory.sports:      return '⚽';
      case AuctionCategory.wellness:    return '🌿';
      case AuctionCategory.daytrips:    return '🗺️';
    }
  }
  String get firestoreValue => name;

  static AuctionCategory fromString(String? v) {
    for (final c in AuctionCategory.values) {
      if (c.name == v) return c;
    }
    return AuctionCategory.products;
  }
}

class AdminAuctionEntity extends Equatable {
  final String          id;
  final String          title;
  final String          description;
  final AuctionCategory category;
  final double          retailValue;
  final double          startingBid;
  final double          currentBid;
  final int             bidCount;
  final AuctionStatus   status;
  final List<String>    images;
  final String?         location;
  final DateTime        startAt;
  final DateTime        endsAt;
  final String?         winnerId;
  final String?         winnerName;
  final String          createdAt;
  final String          createdBy;

  const AdminAuctionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.retailValue,
    required this.startingBid,
    required this.currentBid,
    required this.bidCount,
    required this.status,
    required this.images,
    this.location,
    required this.startAt,
    required this.endsAt,
    this.winnerId,
    this.winnerName,
    required this.createdAt,
    required this.createdBy,
  });

  double get savingsPercent =>
      retailValue > 0 ? ((retailValue - currentBid) / retailValue * 100) : 0;

  String get thumbnailUrl => images.isNotEmpty ? images.first : '';

  AdminAuctionEntity copyWith({
    String? title, String? description, AuctionCategory? category,
    double? retailValue, double? startingBid, AuctionStatus? status,
    List<String>? images, String? location, DateTime? startAt, DateTime? endsAt,
  }) =>
      AdminAuctionEntity(
        id: id, currentBid: currentBid, bidCount: bidCount,
        winnerId: winnerId, winnerName: winnerName,
        createdAt: createdAt, createdBy: createdBy,
        title:        title        ?? this.title,
        description:  description  ?? this.description,
        category:     category     ?? this.category,
        retailValue:  retailValue  ?? this.retailValue,
        startingBid:  startingBid  ?? this.startingBid,
        status:       status       ?? this.status,
        images:       images       ?? this.images,
        location:     location     ?? this.location,
        startAt:      startAt      ?? this.startAt,
        endsAt:       endsAt       ?? this.endsAt,
      );

  @override
  List<Object?> get props => [id, title, status, currentBid, bidCount];
}
