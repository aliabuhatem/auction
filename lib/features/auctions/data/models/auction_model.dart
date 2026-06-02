import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/auction_entity.dart';

class AuctionModel extends AuctionEntity {
  const AuctionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.imageUrls,
    required super.currentBid,
    required super.startingBid,
    required super.bidCount,
    required super.endsAt,
    required super.status,
    required super.category,
    required super.location,
    required super.retailValue,
    super.isWatchlisted,
    super.winnerId,
  });

  factory AuctionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final urls = (d['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    return AuctionModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      imageUrl: d['imageUrl'] ?? (urls.isNotEmpty ? urls.first : ''),
      imageUrls: urls,
      currentBid: (d['currentBid'] as num?)?.toDouble() ?? 1.0,
      startingBid: (d['startingBid'] as num?)?.toDouble() ?? 1.0,
      bidCount: (d['bidCount'] as int?) ?? 0,
      endsAt: (d['endsAt'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 1)),
      status: _parseStatus(d['status']),
      category: _parseCategory(d['category']),
      location: d['location'] ?? '',
      retailValue: (d['retailValue'] as num?)?.toDouble() ?? 0.0,
      isWatchlisted: d['isWatchlisted'] ?? false,
      winnerId: d['winnerId'],
    );
  }

  static AuctionStatus _parseStatus(String? s) {
    switch (s) {
      case 'upcoming':
      case 'scheduled': return AuctionStatus.upcoming;
      case 'ended':     return AuctionStatus.ended;
      case 'sold':      return AuctionStatus.sold;
      default:          return AuctionStatus.live;
    }
  }

  static AuctionCategory _parseCategory(String? c) {
    switch (c) {
      case 'vacation':    return AuctionCategory.vacation;
      case 'beauty':      return AuctionCategory.beauty;
      case 'sauna':       return AuctionCategory.sauna;
      case 'food':        return AuctionCategory.food;
      case 'experiences': return AuctionCategory.experiences;
      case 'products':    return AuctionCategory.products;
      case 'sports':      return AuctionCategory.sports;
      case 'wellness':    return AuctionCategory.wellness;
      case 'dayTrips':    // mobile casing
      case 'daytrips':    // admin casing
        return AuctionCategory.dayTrips;
      default:            return AuctionCategory.vacation;
    }
  }

  factory AuctionModel.fromJson(Map<String, dynamic> d) {
    final urls = (d['imageUrls'] as List<dynamic>?)?.cast<String>() ?? [];
    return AuctionModel(
      id: d['id'] as String? ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      imageUrl: d['imageUrl'] ?? (urls.isNotEmpty ? urls.first : ''),
      imageUrls: urls,
      currentBid: (d['currentBid'] as num?)?.toDouble() ?? 1.0,
      startingBid: (d['startingBid'] as num?)?.toDouble() ?? 1.0,
      bidCount: (d['bidCount'] as int?) ?? 0,
      endsAt: DateTime.fromMillisecondsSinceEpoch(d['endsAt'] as int),
      status: _parseStatus(d['status']),
      category: _parseCategory(d['category']),
      location: d['location'] ?? '',
      retailValue: (d['retailValue'] as num?)?.toDouble() ?? 0.0,
      isWatchlisted: d['isWatchlisted'] ?? false,
      winnerId: d['winnerId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'imageUrls': imageUrls,
    'currentBid': currentBid,
    'startingBid': startingBid,
    'bidCount': bidCount,
    'endsAt': endsAt.millisecondsSinceEpoch,
    'status': status.name,
    'category': category.name,
    'location': location,
    'retailValue': retailValue,
    'isWatchlisted': isWatchlisted,
    'winnerId': winnerId,
  };
}
