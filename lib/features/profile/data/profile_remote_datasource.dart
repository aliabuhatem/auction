import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ProfileRemoteDatasource {
  Future<Map<String, dynamic>> getProfile(String userId);
  Future<void> updateProfile(String userId, {String? displayName, String? avatarUrl});
  Future<void> deleteAccount();
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  ProfileRemoteDatasourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Map<String, dynamic>> getProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data() ?? {};
  }

  @override
  Future<void> updateProfile(String userId, {String? displayName, String? avatarUrl}) async {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['displayName'] = displayName;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    if (displayName != null) await _auth.currentUser?.updateDisplayName(displayName);
  }

  @override
  Future<void> deleteAccount() => _auth.currentUser?.delete() ?? Future.value();
}
