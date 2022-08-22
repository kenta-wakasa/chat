import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post/post.dart';
import 'auth.dart';
import 'references.dart';

final postsProvider = StreamProvider((ref) {
  return ref.read(postRepositoryProvider).steamPosts();
});

final postRepositoryProvider = Provider((ref) => PostRepository(ref));

class PostRepository {
  PostRepository(this._ref);

  final ProviderRef _ref;

  late final _postsReferenceWithConverter =
      _ref.read(postsReferenceWithConverterProvider);

  Stream<QuerySnapshot<Post>> steamPosts() {
    return _postsReferenceWithConverter.orderBy('createdAt').snapshots();
  }

  Future<void> sendPost(String text) async {
    final user = _ref.watch(userProvider).value;
    if (user == null) {
      return;
    }
    // まずは user という変数にログイン中のユーザーデータを格納します

    final posterId = user.uid; // ログイン中のユーザーのIDがとれます
    final posterName = user.displayName!; // Googleアカウントの名前がとれます
    final posterImageUrl = user.photoURL!; // Googleアカウントのアイコンデータがとれます

    // 先ほど作った postsReference からランダムなIDのドキュメントリファレンスを作成します
    // doc の引数を空にするとランダムなIDが採番されます
    final newDocumentReference = _postsReferenceWithConverter.doc();

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
    await newPost.reference.set(newPost);
  }
}
