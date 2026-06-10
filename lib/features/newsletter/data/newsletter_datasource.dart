// lib/features/newsletter/data/newsletter_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Lightweight write path for the `newsletters` collection. Newsletter signup
/// is a single fire-and-write action, so it skips the full repository layering.
abstract class NewsletterDatasource {
  /// Subscribes [email]. [source] is e.g. 'home' | 'footer' | 'popup'.
  Future<void> subscribe(String email, {String source = 'home'});
}

class NewsletterDatasourceImpl implements NewsletterDatasource {
  final FirebaseFirestore firestore;
  NewsletterDatasourceImpl({required this.firestore});

  @override
  Future<void> subscribe(String email, {String source = 'home'}) async {
    final normalized = email.trim().toLowerCase();
    // Doc id = email so re-subscribing is idempotent (no duplicate rows).
    await firestore.collection('newsletters').doc(normalized).set({
      'email': normalized,
      'subscribedAt': DateTime.now().toIso8601String(),
      'isActive': true,
      'source': source,
    }, SetOptions(merge: true));
  }
}
