import 'package:chat/main.dart';
import 'package:chat/providers/auth.dart';
import 'package:chat/providers/firestore_provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets(
    'テストと投稿するとそれが画面上に正しく表示されるか',
    (tester) async {
      /// NetworkImageのためのモック
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              /// これだけでFirebaseFirestoreのモックを注入できる。
              firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
              firebaseAuthProvider.overrideWithValue(
                MockFirebaseAuth(
                  /// 初期からログイン状態とする
                  signedIn: true,
                  mockUser: MockUser(
                    isAnonymous: false,
                    uid: 'someuid',
                    email: 'bob@somedomain.com',
                    displayName: '若狹 健太',
                    photoURL: 'https://example.com/image.png',
                  ),
                ),
              ),
            ],
            child: const MyApp(),
          ),
        );

        /// 投稿前はテストと書かれたWidgetは存在しない
        expect(find.text('テスト'), findsNothing);

        /// PostPageが表示されるまで待つ
        await tester.pumpAndSettle();

        /// テキストを入力する
        await tester.enterText(find.byType(TextFormField), 'テスト');

        /// キーボードの完了ボタンを押す
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        /// 投稿後なのでテストと書かれたWidgetがひとつ存在する
        expect(find.text('テスト'), findsOneWidget);

        /// 投稿者のユーザー名もひとつ存在する
        expect(find.text('若狹 健太'), findsOneWidget);
      });
    },
  );
}
