import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/admin_product_entity.dart';
import '../../domain/entities/admin_category_entity.dart';
import '../../domain/entities/admin_auction_entity.dart';
import '../../../../core/errors/exceptions.dart';

class AdminProductDatasource {
  final FirebaseFirestore _db;
  final FirebaseStorage   _storage;
  final FirebaseAuth      _auth;

  AdminProductDatasource({
    FirebaseFirestore? db,
    FirebaseStorage?   storage,
    FirebaseAuth?      auth,
  })  : _db      = db      ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth    = auth    ?? FirebaseAuth.instance;

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<AdminProductEntity>> getProducts({
    AuctionCategory? category,
    bool?            isActive,
    String?          search,
    int              limit = 100,
  }) async {
    Query<Map<String, dynamic>> q = _db.collection('products');

    if (category != null) q = q.where('category', isEqualTo: category.firestoreValue);
    if (isActive != null) q = q.where('isActive', isEqualTo: isActive);

    q = q.orderBy('createdAt', descending: true).limit(limit);

    final snap = await q.get();
    var list   = snap.docs.map((d) => _mapProduct(d.id, d.data())).toList();

    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      list = list
          .where((p) =>
      p.title.toLowerCase().contains(s) ||
          p.description.toLowerCase().contains(s) ||
          (p.location?.toLowerCase().contains(s) ?? false))
          .toList();
    }
    return list;
  }

  Future<AdminProductEntity> getProduct(String id) async {
    final snap = await _db.collection('products').doc(id).get();
    if (!snap.exists) throw const ServerException('Product niet gevonden.');
    return _mapProduct(snap.id, snap.data()!);
  }

  Future<AdminProductEntity> createProduct({
    required String          title,
    required String          description,
    required AuctionCategory category,
    required double          retailValue,
    required bool            isActive,
    String?                  location,
    List<String>             imageUrls = const [],
  }) async {
    final uid = _auth.currentUser?.uid ?? '';
    final now = DateTime.now().toIso8601String();

    final data = {
      'title':          title,
      'description':    description,
      'category':       category.firestoreValue,
      'retailValue':    retailValue,
      'isActive':       isActive,
      'images':         imageUrls,
      'location':       location,
      'usedInAuctions': 0,
      'createdAt':      now,
      'createdBy':      uid,
    };

    final ref = await _db.collection('products').add(data);
    return _mapProduct(ref.id, data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> fields) async {
    await _db.collection('products').doc(id).update(fields);
  }

  Future<void> toggleProductActive(String id, bool isActive) async {
    await _db.collection('products').doc(id).update({'isActive': isActive});
  }

  Future<void> deleteProduct(String id) async {
    // Remove storage images first
    final snap = await _db.collection('products').doc(id).get();
    if (snap.exists) {
      final images = List<String>.from(snap.data()?['images'] ?? []);
      for (final url in images) {
        try { await _storage.refFromURL(url).delete(); } catch (_) {}
      }
    }
    await _db.collection('products').doc(id).delete();
  }

  Future<String> uploadProductImage({
    required String    productId,
    required Uint8List bytes,
    required String    fileName,
  }) async {
    final ext  = fileName.split('.').last;
    final path = 'products/$productId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref  = _storage.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/$ext'));
    return ref.getDownloadURL();
  }

  Future<void> deleteImage(String url) async {
    try { await _storage.refFromURL(url).delete(); } catch (_) {}
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Future<List<AdminCategoryEntity>> getCategories() async {
    // Categories live in Firestore but we also seed from the enum
    final snap = await _db.collection('categories')
        .orderBy('sortOrder')
        .get();

    if (snap.docs.isEmpty) {
      // Auto-seed on first run
      await _seedCategories();
      return getCategories();
    }

    // Enrich with live counts
    final results = await Future.wait(
      snap.docs.map((d) async {
        final slug    = d.data()['slug'] as String? ?? d.id;
        final prodCnt = await _db.collection('products')
            .where('category', isEqualTo: slug).count().get();
        final aucCnt  = await _db.collection('auctions')
            .where('category', isEqualTo: slug)
            .where('status',   isEqualTo: 'live').count().get();

        return _mapCategory(d.id, d.data(),
          productCount: prodCnt.count ?? 0,
          auctionCount: aucCnt.count  ?? 0,
        );
      }),
    );
    return results;
  }

  Future<void> updateCategory(String id, Map<String, dynamic> fields) async {
    await _db.collection('categories').doc(id).update(fields);
  }

  Future<void> toggleCategoryActive(String id, bool isActive) async {
    await _db.collection('categories').doc(id).update({'isActive': isActive});
  }

  Future<String> uploadCategoryBanner({
    required String    categoryId,
    required Uint8List bytes,
    required String    fileName,
  }) async {
    final ext  = fileName.split('.').last;
    final path = 'categories/$categoryId/banner.$ext';
    final ref  = _storage.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/$ext'));
    return ref.getDownloadURL();
  }

  // ── Seed ─────────────────────────────────────────────────────────────────

  Future<void> _seedCategories() async {
    final batch = _db.batch();
    final defaults = [
      {'slug': 'vacation',    'name': 'Vakantie',      'emoji': '✈️', 'sortOrder': 0},
      {'slug': 'beauty',      'name': 'Beauty',        'emoji': '💅', 'sortOrder': 1},
      {'slug': 'sauna',       'name': 'Sauna & Spa',   'emoji': '🧖', 'sortOrder': 2},
      {'slug': 'food',        'name': 'Eten & Drinken','emoji': '🍽️', 'sortOrder': 3},
      {'slug': 'experiences', 'name': 'Ervaringen',    'emoji': '🎭', 'sortOrder': 4},
      {'slug': 'products',    'name': 'Producten',     'emoji': '📦', 'sortOrder': 5},
      {'slug': 'sports',      'name': 'Sport',         'emoji': '⚽', 'sortOrder': 6},
      {'slug': 'wellness',    'name': 'Wellness',      'emoji': '🌿', 'sortOrder': 7},
      {'slug': 'daytrips',    'name': 'Dagtrips',      'emoji': '🗺️', 'sortOrder': 8},
    ];
    for (final d in defaults) {
      final ref = _db.collection('categories').doc(d['slug'] as String);
      batch.set(ref, {...d, 'isActive': true, 'bannerUrl': null});
    }
    await batch.commit();
  }

  // ── Mappers ───────────────────────────────────────────────────────────────

  AdminProductEntity _mapProduct(String id, Map<String, dynamic> d) {
    return AdminProductEntity(
      id:             id,
      title:          d['title']          ?? '',
      description:    d['description']    ?? '',
      category:       AuctionCategoryX.fromString(d['category'] as String?),
      retailValue:    (d['retailValue']   as num?)?.toDouble() ?? 0,
      images:         List<String>.from(d['images'] ?? []),
      location:       d['location']       as String?,
      isActive:       d['isActive']       ?? true,
      usedInAuctions: (d['usedInAuctions'] as num?)?.toInt() ?? 0,
      createdAt:      d['createdAt']      ?? '',
      createdBy:      d['createdBy']      ?? '',
    );
  }

  AdminCategoryEntity _mapCategory(
      String id,
      Map<String, dynamic> d, {
        required int productCount,
        required int auctionCount,
      }) {
    return AdminCategoryEntity(
      id:           id,
      name:         d['name']      ?? '',
      emoji:        d['emoji']     ?? '📦',
      slug:         d['slug']      ?? id,
      isActive:     d['isActive']  ?? true,
      bannerUrl:    d['bannerUrl'] as String?,
      sortOrder:    (d['sortOrder'] as num?)?.toInt() ?? 99,
      productCount: productCount,
      auctionCount: auctionCount,
    );
  }
}