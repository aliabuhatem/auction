// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> registerWithEmail(String email, String password, String name);
  Future<UserModel> loginWithGoogle();
  Future<void>      logout();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth      _auth;
  final GoogleSignIn      _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRemoteDatasourceImpl({
    FirebaseAuth?      auth,
    GoogleSignIn?      googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth         = auth         ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore    = firestore    ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return UserModel.fromFirebaseUser(cred.user!);
  }

  @override
  Future<UserModel> registerWithEmail(
      String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    final user = cred.user!;
    await user.updateDisplayName(name);
    await user.reload();

    // Create the Firestore user document with all initial fields.
    // This doc is the source of truth for profile, wallet, referral, stats.
    await _createFirestoreUserDoc(
      uid:   user.uid,
      email: email,
      name:  name,
    );

    return UserModel.fromFirebaseUser(_auth.currentUser!);
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google inloggen geannuleerd');

    final googleAuth = await googleUser.authentication;
    final cred       = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken:     googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(cred);
    final user   = result.user!;

    // Create Firestore doc only if it doesn't exist yet (first Google login).
    final docRef = _firestore.collection('users').doc(user.uid);
    final snap   = await docRef.get();
    if (!snap.exists) {
      await _createFirestoreUserDoc(
        uid:   user.uid,
        email: user.email ?? '',
        name:  user.displayName ?? googleUser.displayName ?? '',
        avatarUrl: user.photoURL,
      );
    }

    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      _auth.authStateChanges().map(
          (u) => u != null ? UserModel.fromFirebaseUser(u) : null);

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _createFirestoreUserDoc({
    required String uid,
    required String email,
    required String name,
    String?         avatarUrl,
    String?         referralCode,
  }) async {
    final code = referralCode ?? _generateReferralCode(uid);

    await _firestore.collection('users').doc(uid).set({
      'uid':              uid,
      'email':            email,
      'displayName':      name,
      'avatarUrl':        avatarUrl,
      'phoneNumber':      null,
      'role':             'user',
      'bidCredits':       0.0,
      'referralCode':     code,
      'onboardingDone':   false,
      'bidsCount':        0,
      'wonCount':         0,
      'totalSpent':       0.0,
      'isActive':         true,
      'isBanned':         false,
      'fcmToken':         null,
      'notificationPrefs': {
        'bids':   true,
        'won':    true,
        'alarms': true,
        'offers': false,
      },
      'createdAt':        FieldValue.serverTimestamp(),
      'updatedAt':        FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _generateReferralCode(String uid) {
    final base = uid.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return base.length >= 8 ? base.substring(0, 8) : base.padRight(8, '0');
  }
}
