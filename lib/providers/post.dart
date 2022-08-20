import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post/post.dart';
import 'auth.dart';
import 'references.dart';

final postsProvider = StreamProvider((ref) {
  final postsReferenceWithConverter =
      ref.read(postsReferenceWithConverterProvider);
  return postsReferenceWithConverter.orderBy('createdAt').snapshots();
});

final sendPostProvider = Provider((ref) {
  return (String text) async {
    final user = ref.watch(userProvider).value;
    if (user == null) {
      return;
    }
    final postsReferenceWithConverter =
        ref.read(postsReferenceWithConverterProvider);
    // まずは user という変数にログイン中のユーザーデータを格納します

    final posterId = user.uid; // ログイン中のユーザーのIDがとれます
    final posterName = user.displayName!; // Googleアカウントの名前がとれます
    final posterImageUrl = user.photoURL!; // Googleアカウントのアイコンデータがとれます

    // 先ほど作った postsReference からランダムなIDのドキュメントリファレンスを作成します
    // doc の引数を空にするとランダムなIDが採番されます
    final newDocumentReference = postsReferenceWithConverter.doc();

    final newPost = Post(
      text: text,
      createdAt: null, // null を入れると ServerTimestamp を参照することになっています。
      posterName: posterName,
      posterImageUrl: posterImageUrl,
      posterId: posterId,
      reference: newDocumentReference,
    );

    // 先ほど作った newDocumentReference のset関数を実行するとそのドキュメントにデータが保存されます。
    // 引数として Post インスタンスを渡します。
    // 通常は Map しか受け付けませんが、withConverter を使用したことにより Post インスタンスを受け取れるようになります。
    await newDocumentReference.set(newPost);
  };
});
