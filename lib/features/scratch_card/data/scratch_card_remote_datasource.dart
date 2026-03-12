import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ScratchCardRemoteDatasource {
  Future<Map<String, dynamic>> getScratchCardData(String userId);
  Future<String> revealPrize(String userId);
  Future<void> recordScratch(String userId, String prize);
}

class ScratchCardRemoteDatasourceImpl implements ScratchCardRemoteDatasource {
  final FirebaseFirestore _firestore;
  ScratchCardRemoteDatasourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>> getScratchCardData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data() ?? {};
    final lastScratch = data['lastScratchCardDate'] as Timestamp?;
    final lastDate = lastScratch?.toDate();
    final today = DateTime.now();
    final canScratch = lastDate == null || (today.year != lastDate.year || today.month != lastDate.month || today.day != lastDate.day);
    return {
      'canScratch': canScratch,
      'streakDays': data['streakDays'] ?? 0,
      'scratchCardsUsed': data['scratchCardsUsed'] ?? 0,
    };
  }

  @override
  Future<String> revealPrize(String userId) async {
    // Generate a random prize server-side in production
    final prizes = ['€5 tegoed', '€10 tegoed', 'Gratis veiling', '€2 tegoed', 'Extra kraskaart', '€25 tegoed'];
    prizes.shuffle();
    return prizes.first;
  }

  @override
  Future<void> recordScratch(String userId, String prize) async {
    final ref = _firestore.collection('users').doc(userId);
    final doc = await ref.get();
    final data = doc.data() ?? {};
    final lastDate = (data['lastScratchCardDate'] as Timestamp?)?.toDate();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final streak = (lastDate != null &&
        lastDate.year == yesterday.year && lastDate.month == yesterday.month && lastDate.day == yesterday.day)
        ? (data['streakDays'] ?? 0) + 1
        : 1;
    await ref.update({
      'lastScratchCardDate': FieldValue.serverTimestamp(),
      'streakDays': streak,
      'scratchCardsUsed': FieldValue.increment(1),
      'prizes': FieldValue.arrayUnion([{'prize': prize, 'date': DateTime.now().toIso8601String()}]),
    });
  }
}
