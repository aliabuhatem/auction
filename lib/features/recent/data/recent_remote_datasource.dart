// lib/features/recent/data/recent_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auctions/data/models/auction_model.dart';
import '../../auctions/domain/entities/auction_entity.dart';

/// Reads/writes the `recently_viewed/{userId_auctionId}` collection.
/// Each doc denormalises a snapshot of the auction so a history row can render
/// even if the underlying auction is later removed.
abstract class RecentRemoteDatasource {
  Future<void> recordView(String userId, AuctionEntity auction);
  Future<List<AuctionModel>> getRecent(String userId);
  Future<void> clear(String userId);
}

class RecentRemoteDatasourceImpl implements RecentRemoteDatasource {
  final FirebaseFirestore firestore;
  RecentRemoteDatasourceImpl({required this.firestore});

  static const _maxRecent = 20;

  String _docId(String userId, String auctionId) => '${userId}_$auctionId';

  CollectionReference<Map<String, dynamic>> get _col =>
      firestore.collection('recently_viewed');

  @override
  Future<void> recordView(String userId, AuctionEntity auction) async {
    await _col.doc(_docId(userId, auction.id)).set({
      'userId': userId,
      'auctionId': auction.id,
      'viewedAt': DateTime.now().toIso8601String(),
      'auctionTitle': auction.title,
      'auctionImageUrl': auction.imageUrl,
      'currentBid': auction.currentBid,
    }, SetOptions(merge: true));
  }

  @override
  Future<List<AuctionModel>> getRecent(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .orderBy('viewedAt', descending: true)
        .limit(_maxRecent)
        .get();

    final auctionIds =
        snap.docs.map((d) => d.data()['auctionId'] as String).toList();
    if (auctionIds.isEmpty) return [];

    // Fetch the live auction docs so cards show up-to-date bid/countdown data.
    final futures =
        auctionIds.map((id) => firestore.collection('auctions').doc(id).get());
    final docs = await Future.wait(futures);

    // Preserve the recently-viewed order; drop auctions that no longer exist.
    final byId = {
      for (final d in docs)
        if (d.exists) d.id: AuctionModel.fromFirestore(d),
    };
    return [
      for (final id in auctionIds)
        if (byId.containsKey(id)) byId[id]!,
    ];
  }

  @override
  Future<void> clear(String userId) async {
    final snap = await _col.where('userId', isEqualTo: userId).get();
    if (snap.docs.isEmpty) return;
    final batch = firestore.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}
