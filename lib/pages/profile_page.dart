import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'sing_in_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 何度も FirebaseAuth.instance.currentUser! と書くのは大変です。
    // そこで適当な変数名をつけた変数に一時的に値を格納して記述量を短くする場合あります。
    final user = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('マイページ')),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // ユーザーアイコン画像
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL!),
              radius: 40,
            ),
            // ユーザー名
            Text(
              user.displayName!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),

            // 部分的に左寄せにしたい場合の書き方
            Align(
              alignment: Alignment.centerLeft,
              // ユーザー ID
              child: Text('ユーザーID：${user.uid}'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              // 登録日
              child: Text('登録日：${user.metadata.creationTime!}'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                // Google からサインアウト
                await GoogleSignIn().signOut();
                // Firebase からサインアウト
                await FirebaseAuth.instance.signOut();
                // SignInPage に遷移
                // このページには戻れないようにします。
                await navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) {
                    return const SignInPage();
                  }),
                  (route) => false,
                );
              },
              child: const Text('サインアウト'),
            ),
          ],
        ),
      ),
    );
  }
}
