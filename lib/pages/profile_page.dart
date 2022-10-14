import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../providers/auth.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider).value!;
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
                await ref.read(firebaseAuthProvider).signOut();

                navigator.pop();
              },
              child: const Text('サインアウト'),
            ),
          ],
        ),
      ),
    );
  }
}
