import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/util_log.dart';

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

final signInWithGoogleProvider = Provider((ref) {
  return () async {
    final firebaseAuth = ref.read(firebaseAuthProvider);
    final googleSignIn = ref.read(googleSignInProvider);

    // GoogleSignIn をして得られた情報を Firebase と関連づけることをやっています。
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await firebaseAuth.signInWithCredential(credential);
    utilLog(ref.read(userProvider).value?.displayName);
  };
});

final signOutProvider = Provider((ref) {
  return () async {
    await ref.read(googleSignInProvider).signOut();
    await ref.read(firebaseAuthProvider).signOut();
  };
});
