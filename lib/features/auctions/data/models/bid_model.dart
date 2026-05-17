import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/bid_entity.dart';

class BidModel extends BidEntity {
  const BidModel({
    required super.id,
    required super.auctionId,
    required super.userId,
    super.userName,
    required super.amount,
    required super.placedAt,
  });

  factory BidModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BidModel(
      id: doc.id,
      auctionId: d['auctionId'] as String? ?? '',
      userId: d['userId'] as String? ?? '',
      userName: d['userName'] as String?,
      amount: ((d['amount'] as num?) ?? 0).toDouble(),
      placedAt: (d['placedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory BidModel.fromJson(Map<String, dynamic> d, {String id = ''}) {
    return BidModel(
      id: id,
      auctionId: d['auctionId'] as String? ?? '',
      userId: d['userId'] as String? ?? '',
      userName: d['userName'] as String?,
      amount: ((d['amount'] as num?) ?? 0).toDouble(),
      placedAt: d['placedAt'] is Timestamp
          ? (d['placedAt'] as Timestamp).toDate()
          : d['placedAt'] is String
              ? DateTime.tryParse(d['placedAt'] as String) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'auctionId': auctionId,
    'userId': userId,
    'userName': userName,
    'amount': amount,
    'placedAt': FieldValue.serverTimestamp(),
  };
}
