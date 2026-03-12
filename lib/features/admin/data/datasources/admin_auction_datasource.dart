import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/admin_auction_entity.dart';
import '../../../../core/errors/exceptions.dart';

class AdminAuctionDatasource {
  final FirebaseFirestore _db;
  final FirebaseStorage   _storage;
  final FirebaseAuth      _auth;

  AdminAuctionDatasource({
    FirebaseFirestore? db,
    FirebaseStorage?   storage,
    FirebaseAuth?      auth,
  })  : _db      = db      ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth    = auth    ?? FirebaseAuth.instance;

  // ── Read ─────────────────────────────────────────────────────────────────

  Future<List<AdminAuctionEntity>> getAuctions({
    AuctionStatus? status,
    AuctionCategory? category,
    String? searchQuery,
    int limit = 50,
  }) async {
    Query<Map<String, dynamic>> q = _db.collection('auctions');

    if (status   != null) q = q.where('status',   isEqualTo: status.firestoreValue);
    if (category != null) q = q.where('category', isEqualTo: category.firestoreValue);

    q = q.orderBy('createdAt', descending: true).limit(limit);

    final snap = await q.get();
    var list   = snap.docs.map((d) => _map(d.id, d.data())).toList();

    // Client-side search (Firestore doesn't support full-text)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((a) =>
        a.title.toLowerCase().contains(q) ||
        a.location?.toLowerCase().contains(q) == true,
      ).toList();
    }

    return list;
  }

  Future<AdminAuctionEntity> getAuction(String id) async {
    final snap = await _db.collection('auctions').doc(id).get();
    if (!snap.exists) throw const ServerException('Veiling niet gevonden.');
    return _map(snap.id, snap.data()!);
  }

  // ── Create ───────────────────────────────────────────────────────────────

  Future<AdminAuctionEntity> createAuction({
    required String          title,
    required String          description,
    required AuctionCategory category,
    required double          retailValue,
    required double          startingBid,
    required AuctionStatus   status,
    required DateTime        startAt,
    required DateTime        endsAt,
    String?                  location,
    List<String>             imageUrls = const [],
  }) async {
    final uid = _auth.currentUser?.uid ?? '';
    final now = DateTime.now().toIso8601String();

    final data = {
      'title':        title,
      'description':  description,
      'category':     category.firestoreValue,
      'retailValue':  retailValue,
      'startingBid':  startingBid,
      'currentBid':   startingBid,
      'bidCount':     0,
      'status':       status.firestoreValue,
      'images':       imageUrls,
      'location':     location,
      'startAt':      startAt.toIso8601String(),
      'endsAt':       endsAt.toIso8601String(),
      'winnerId':     null,
      'winnerName':   null,
      'createdAt':    now,
      'createdBy':    uid,
    };

    final ref = await _db.collection('auctions').add(data);
    return _map(ref.id, data);
  }

  // ── Update ───────────────────────────────────────────────────────────────

  Future<void> updateAuction(String id, Map<String, dynamic> fields) async {
    await _db.collection('auctions').doc(id).update(fields);
  }

  Future<void> updateAuctionStatus(String id, AuctionStatus status) async {
    await _db.collection('auctions').doc(id).update({
      'status': status.firestoreValue,
    });
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteAuction(String id) async {
    // Delete images from storage first
    final snap = await _db.collection('auctions').doc(id).get();
    if (snap.exists) {
      final images = List<String>.from(snap.data()?['images'] ?? []);
      for (final url in images) {
        try {
          await _storage.refFromURL(url).delete();
        } catch (_) {}
      }
    }
    await _db.collection('auctions').doc(id).delete();
  }

  // ── Image upload ─────────────────────────────────────────────────────────

  /// Uploads image bytes (from web file picker) to Firebase Storage.
  /// Returns the download URL.
  Future<String> uploadAuctionImage({
    required String     auctionId,
    required Uint8List  bytes,
    required String     fileName,
  }) async {
    final ext  = fileName.split('.').last;
    final path = 'auctions/$auctionId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref  = _storage.ref(path);

    final meta = SettableMetadata(contentType: 'image/$ext');
    await ref.putData(bytes, meta);
    return await ref.getDownloadURL();
  }

  Future<void> deleteImage(String url) async {
    try { await _storage.refFromURL(url).delete(); } catch (_) {}
  }

  // ── Stats for a single auction ────────────────────────────────────────────

  Future<Map<String, dynamic>> getAuctionStats(String auctionId) async {
    final bidsSnap = await _db.collection('bids')
        .where('auctionId', isEqualTo: auctionId)
        .orderBy('amount', descending: true)
        .limit(20)
        .get();

    return {
      'bids':      bidsSnap.docs.map((d) => d.data()).toList(),
      'bidCount':  bidsSnap.size,
      'topBid':    bidsSnap.docs.isNotEmpty ? bidsSnap.docs.first.data()['amount'] : 0,
    };
  }

  // ── Mapper ────────────────────────────────────────────────────────────────

  AdminAuctionEntity _map(String id, Map<String, dynamic> d) {
    return AdminAuctionEntity(
      id:          id,
      title:       d['title']       ?? '',
      description: d['description'] ?? '',
      category:    AuctionCategoryX.fromString(d['category'] as String?),
      retailValue: (d['retailValue'] as num?)?.toDouble() ?? 0,
      startingBid: (d['startingBid'] as num?)?.toDouble() ?? 0,
      currentBid:  (d['currentBid']  as num?)?.toDouble() ?? 0,
      bidCount:    (d['bidCount']    as num?)?.toInt()    ?? 0,
      status:      AuctionStatusX.fromString(d['status']  as String?),
      images:      List<String>.from(d['images'] ?? []),
      location:    d['location']    as String?,
      startAt:     DateTime.tryParse(d['startAt'] ?? '') ?? DateTime.now(),
      endsAt:      DateTime.tryParse(d['endsAt']  ?? '') ?? DateTime.now(),
      winnerId:    d['winnerId']    as String?,
      winnerName:  d['winnerName']  as String?,
      createdAt:   d['createdAt']   ?? '',
      createdBy:   d['createdBy']   ?? '',
    );
  }
}
