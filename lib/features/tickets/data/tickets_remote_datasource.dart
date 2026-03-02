import 'package:cloud_firestore/cloud_firestore.dart';
import '../../tickets/domain/voucher_entity.dart';

abstract class TicketsRemoteDatasource {
  Future<List<VoucherEntity>> getMyTickets(String userId);
  Future<VoucherEntity> getTicketById(String voucherId);
  Future<bool> markAsUsed(String voucherId);
}

class TicketsRemoteDatasourceImpl implements TicketsRemoteDatasource {
  final FirebaseFirestore _firestore;
  TicketsRemoteDatasourceImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<VoucherEntity>> getMyTickets(String userId) async {
    final snap = await _firestore.collection('vouchers').where('userId', isEqualTo: userId).orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => _fromFirestore(d)).toList();
  }

  @override
  Future<VoucherEntity> getTicketById(String voucherId) async {
    final doc = await _firestore.collection('vouchers').doc(voucherId).get();
    if (!doc.exists) throw Exception('Voucher niet gevonden');
    return _fromFirestore(doc);
  }

  @override
  Future<bool> markAsUsed(String voucherId) async {
    await _firestore.collection('vouchers').doc(voucherId).update({'isUsed': true, 'usedAt': FieldValue.serverTimestamp()});
    return true;
  }

  VoucherEntity _fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return VoucherEntity(
      id: doc.id,
      code: d['code'] ?? '',
      auctionId: d['auctionId'] ?? '',
      auctionTitle: d['auctionTitle'] ?? '',
      expiresAt: (d['expiresAt'] as Timestamp).toDate(),
      isUsed: d['isUsed'] ?? false,
    );
  }
}
