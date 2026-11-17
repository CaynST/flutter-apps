import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/auth_exception.dart';
import '../models/app_user.dart';

Map<String, dynamic> newUserProfileData({
  required String email,
  required String displayName,
}) {
  return <String, dynamic>{
    'email': email,
    'displayName': displayName,
    'createdAt': FieldValue.serverTimestamp(),
    'lastLogin': FieldValue.serverTimestamp(),
  };
}

Map<String, dynamic> lastLoginUpdateData() {
  return <String, dynamic>{'lastLogin': FieldValue.serverTimestamp()};
}

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toAppUser);

  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  static AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    final String fallback = user.email?.split('@').first ?? 'Usuario';
    return AppUser(
      uid: user.uid,
      displayName: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : fallback,
      email: user.email ?? '',
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = credential.user;
      if (user == null) return;
      await user.updateDisplayName(displayName.trim());
      await user.sendEmailVerification();
      await ensureUserProfile(user, createIfMissing: true);
    } on FirebaseAuthException catch (e) {
      throw AuthException(authErrorMessage(e.code));
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = credential.user;
      if (user != null) {
        await ensureUserProfile(user, createIfMissing: true);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(authErrorMessage(e.code));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final UserCredential credential =
          await _auth.signInWithPopup(GoogleAuthProvider());
      final User? user = credential.user;
      if (user != null) {
        await ensureUserProfile(user, createIfMissing: true);
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(authErrorMessage(e.code));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(authErrorMessage(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> ensureUserProfile(
    User user, {
    bool createIfMissing = false,
  }) async {
    final DocumentReference<Map<String, dynamic>> ref =
        _db.collection('users').doc(user.uid);
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    if (!snapshot.exists) {
      if (!createIfMissing) return;
      await ref.set(
        newUserProfileData(
          email: user.email ?? '',
          displayName: user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : (user.email?.split('@').first ?? 'Usuario'),
        ),
      );
      return;
    }

    await ref.update(lastLoginUpdateData());
  }
}
