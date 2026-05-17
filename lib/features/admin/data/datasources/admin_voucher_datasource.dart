// lib/features/admin/data/datasources/admin_voucher_datasource.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/admin_voucher_entity.dart';

class AdminVoucherDatasource {
  final FirebaseFirestore _db;
  final FirebaseAuth      _auth;

  AdminVoucherDatasource({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db   = db   ?? FirebaseFirestore.instance,
        _auth  = auth ?? FirebaseAuth.instance;

  // ── Read ─────────────────────────────────────────────────────────────────────

  Future<List<AdminVoucherEntity>> getVouchers({
    VoucherStatus? status,
    String?        search,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db
          .collection('vouchers')
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.firestoreValue);
      }

      final snap     = await query.limit(200).get();
      var   vouchers = snap.docs.map(_mapVoucher).toList();

      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        vouchers = vouchers
            .where((v) =>
                v.code.toLowerCase().contains(q) ||
                v.auctionTitle.toLowerCase().contains(q) ||
                (v.userName?.toLowerCase().contains(q) ?? false) ||
                (v.userEmail?.toLowerCase().contains(q) ?? false))
            .toList();
      }

      return vouchers;
    } catch (e) {
      throw Exception('Fout bij ophalen vouchers: $e');
    }
  }

  Future<VoucherStatsEntity> getVoucherStats() async {
    try {
      final validCount = (await _db
              .collection('vouchers')
              .where('status', isEqualTo: 'valid')
              .count()
              .get())
          .count ?? 0;
      final usedCount = (await _db
              .collection('vouchers')
              .where('status', isEqualTo: 'used')
              .count()
              .get())
          .count ?? 0;
      final expiredCount = (await _db
              .collection('vouchers')
              .where('status', isEqualTo: 'expired')
              .count()
              .get())
          .count ?? 0;
      final revokedCount = (await _db
              .collection('vouchers')
              .where('status', isEqualTo: 'revoked')
              .count()
              .get())
          .count ?? 0;

      return VoucherStatsEntity(
        validCount:   validCount,
        usedCount:    usedCount,
        expiredCount: expiredCount,
        revokedCount: revokedCount,
      );
    } catch (e) {
      throw Exception('Fout bij ophalen statistieken: $e');
    }
  }

  // Client-side status filter avoids compound index requirement.
  Future<List<({String id, String title})>> getLiveAuctions() async {
    try {
      final snap = await _db
          .collection('auctions')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      return snap.docs
          .where((d) => ['live', 'scheduled', 'ended']
              .contains(d.data()['status']))
          .map((d) => (
                id:    d.id,
                title: (d.data()['title'] as String?) ?? '',
              ))
          .toList();
    } catch (e) {
      throw Exception('Fout bij ophalen veilingen: $e');
    }
  }

  Future<List<({String uid, String name, String email})>> searchUsers(
      String query) async {
    try {
      if (query.length < 2) return [];
      final q    = query.trim();
      final snap = await _db
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: q)
          .where('displayName', isLessThanOrEqualTo: '$q')
          .limit(10)
          .get();
      return snap.docs
          .map((d) => (
                uid:   d.id,
                name:  (d.data()['displayName'] as String?) ?? '',
                email: (d.data()['email']       as String?) ?? '',
              ))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Write ────────────────────────────────────────────────────────────────────

  Future<void> generateVoucher({
    required String   auctionId,
    required String   auctionTitle,
    String?           userId,
    String?           userName,
    String?           userEmail,
    String?           orderId,
    required DateTime expiresAt,
  }) async {
    try {
      final code = _generateCode();
      final now  = DateTime.now().toIso8601String();
      final batch = _db.batch();
      final vRef  = _db.collection('vouchers').doc();

      batch.set(vRef, {
        'code':         code,
        'auctionId':    auctionId,
        'auctionTitle': auctionTitle,
        'userId':       userId,
        'userName':     userName,
        'userEmail':    userEmail,
        'orderId':      orderId,
        'status':       'valid',
        'qrData':       code,
        'expiresAt':    expiresAt.toIso8601String(),
        'usedAt':       null,
        'createdAt':    now,
      });
      batch.set(_db.collection('audit_log').doc(), {
        'adminId':     _auth.currentUser?.uid ?? '',
        'adminName':   _auth.currentUser?.displayName ?? '',
        'action':      'create_voucher',
        'targetId':    vRef.id,
        'targetType':  'voucher',
        'before':      null,
        'after':       {'code': code, 'auctionId': auctionId},
        'performedAt': now,
      });
      await batch.commit();
    } catch (e) {
      throw Exception('Voucher aanmaken mislukt: $e');
    }
  }

  // Returns generated codes so the UI can build a CSV for download.
  Future<List<String>> bulkGenerateVouchers({
    required String   auctionId,
    required String   auctionTitle,
    required int      quantity,
    required DateTime expiresAt,
  }) async {
    try {
      final now   = DateTime.now().toIso8601String();
      final codes = <String>[];
      final batch = _db.batch(); // max 500 ops — quantity capped at 100 in UI

      for (int i = 0; i < quantity; i++) {
        final code = _generateCode();
        codes.add(code);
        batch.set(_db.collection('vouchers').doc(), {
          'code':         code,
          'auctionId':    auctionId,
          'auctionTitle': auctionTitle,
          'userId':       null,
          'userName':     null,
          'userEmail':    null,
          'orderId':      null,
          'status':       'valid',
          'qrData':       code,
          'expiresAt':    expiresAt.toIso8601String(),
          'usedAt':       null,
          'createdAt':    now,
        });
      }

      batch.set(_db.collection('audit_log').doc(), {
        'adminId':     _auth.currentUser?.uid ?? '',
        'adminName':   _auth.currentUser?.displayName ?? '',
        'action':      'bulk_create_vouchers',
        'targetId':    auctionId,
        'targetType':  'voucher',
        'before':      null,
        'after':       {'quantity': quantity, 'auctionId': auctionId},
        'performedAt': now,
      });

      await batch.commit();
      return codes;
    } catch (e) {
      throw Exception('Bulk aanmaken mislukt: $e');
    }
  }

  Future<void> updateVoucherStatus(
    String               id,
    VoucherStatus        newStatus,
    String               adminId,
    String               adminName,
    Map<String, dynamic> before,
  ) async {
    try {
      final now    = DateTime.now().toIso8601String();
      final update = <String, dynamic>{
        'status': newStatus.firestoreValue,
        if (newStatus == VoucherStatus.used) 'usedAt': now,
      };

      final batch = _db.batch();
      batch.update(_db.collection('vouchers').doc(id), update);
      batch.set(_db.collection('audit_log').doc(), {
        'adminId':     adminId,
        'adminName':   adminName,
        'action':      'update_voucher_status',
        'targetId':    id,
        'targetType':  'voucher',
        'before':      before,
        'after':       update,
        'performedAt': now,
      });
      await batch.commit();
    } catch (e) {
      throw Exception('Statuswijziging mislukt: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // excludes I, O, 0, 1
    final rand  = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  AdminVoucherEntity _mapVoucher(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    return AdminVoucherEntity(
      id:           doc.id,
      code:         d['code']         ?? '',
      auctionId:    d['auctionId']    ?? '',
      auctionTitle: d['auctionTitle'] ?? '',
      userId:       d['userId']       as String?,
      userName:     d['userName']     as String?,
      userEmail:    d['userEmail']    as String?,
      orderId:      d['orderId']      as String?,
      status:       VoucherStatusX.fromString(d['status'] as String?),
      qrData:       d['qrData'] ?? d['code'] ?? '',
      expiresAt:    _ts(d['expiresAt']),
      usedAt:       _tsOpt(d['usedAt']),
      createdAt:    _ts(d['createdAt']),
    );
  }

  // Handles both Firestore Timestamp objects and ISO-8601 strings.
  static DateTime _ts(dynamic v, [DateTime? fallback]) {
    if (v is Timestamp) return v.toDate();
    if (v is String)    return DateTime.tryParse(v) ?? (fallback ?? DateTime.now());
    return fallback ?? DateTime.now();
  }

  static DateTime? _tsOpt(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String)    return DateTime.tryParse(v);
    return null;
  }
}
