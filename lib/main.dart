import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'pages/chat_page.dart';
import 'pages/sing_in_page.dart';
import 'providers/auth.dart';
import 'providers/firestore_provider.dart';

Future<void> main() async {
  // main 関数でも async が使えます
  WidgetsFlutterBinding.ensureInitialized(); // runApp 前に何かを実行したいときはこれが必要です。
  await Firebase.initializeApp(
    // これが Firebase の初期化処理です。
    options: DefaultFirebaseOptions.android,
  );
  runApp(
    /// Riverpodをつかうために必要
    ProviderScope(
      overrides: [
        /// これだけでFirebaseFirestoreのモックを注入できる。
        firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        firebaseAuthProvider.overrideWithValue(
          MockFirebaseAuth(
            signedIn: true,
            mockUser: MockUser(
              isAnonymous: false,
              uid: 'someuid',
              email: 'bob@somedomain.com',
              displayName: '若狹 健太',
              photoURL:
                  'https://pbs.twimg.com/profile_images/1510946043718160386/mPJ6v_Xf_400x400.jpg',
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(),
      home: ref.watch(userProvider).maybeWhen(data: (data) {
        if (data == null) {
          return const SignInPage();
        }
        return const ChatPage();
      }, orElse: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }
}
