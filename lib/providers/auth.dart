import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider((ref) {
  return FirebaseAuth.instance;
});

final googleSignInProvider = Provider((ref) {
  return GoogleSignIn(scopes: ['profile', 'email']);
});

final userProvider = StreamProvider((ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return firebaseAuth.userChanges();
});

final uidProvider = Provider((ref) {
  return ref.watch(userProvider).whenData((value) => value?.uid);
});

final isSingedInProvider = Provider((ref) {
  return ref.watch(uidProvider).whenData((value) => value != null);
});

final authProvider = Provider((ref) => Auth(ref.read));

class Auth {
  Auth(this._read);

  final Reader _read;
  late final _firebaseAuth = _read(firebaseAuthProvider);
  late final _googleSignIn = _read(googleSignInProvider);

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
