// lib/features/banners/data/banner_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A promo banner shown on the home page (home Section 1).
class BannerEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String? title;
  final String linkType; // 'auction' | 'category' | 'external' | 'none'
  final String? linkId;
  final String? linkUrl;

  const BannerEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.linkType = 'none',
    this.linkId,
    this.linkUrl,
  });

  factory BannerEntity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return BannerEntity(
      id: doc.id,
      imageUrl: (d['imageUrl'] as String?) ?? '',
      title: d['title'] as String?,
      linkType: (d['linkType'] as String?) ?? 'none',
      linkId: d['linkId'] as String?,
      linkUrl: d['linkUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, imageUrl, title, linkType, linkId, linkUrl];
}

abstract class BannerDatasource {
  /// Streams active banners ordered by sortOrder. Time-window fields
  /// (startsAt/endsAt) are filtered client-side to avoid extra indexes.
  Stream<List<BannerEntity>> watchActiveBanners();
}

class BannerDatasourceImpl implements BannerDatasource {
  final FirebaseFirestore firestore;
  BannerDatasourceImpl({required this.firestore});

  @override
  Stream<List<BannerEntity>> watchActiveBanners() {
    return firestore
        .collection('banners')
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) {
      final now = DateTime.now();
      return snap.docs
          .where((doc) {
            final d = doc.data();
            final startsAt = DateTime.tryParse((d['startsAt'] as String?) ?? '');
            final endsAt = DateTime.tryParse((d['endsAt'] as String?) ?? '');
            if (startsAt != null && now.isBefore(startsAt)) return false;
            if (endsAt != null && now.isAfter(endsAt)) return false;
            return true;
          })
          .map(BannerEntity.fromFirestore)
          .where((b) => b.imageUrl.isNotEmpty)
          .toList();
    });
  }
}
