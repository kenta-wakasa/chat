import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post/post.dart';
import '../providers/auth.dart';
import '../providers/posts_provider.dart';
import '../providers/posts_reference_provider.dart';
import '../widgets/post_widget.dart';
import 'profile_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  Future<void> sendPost(String text) async {
    // まずは user という変数にログイン中のユーザーデータを格納します
    final user = ref.watch(userProvider).value!;
    final posterId = user.uid; // ログイン中のユーザーのIDがとれます
    final posterName = user.displayName!; // Googleアカウントの名前がとれます
    final posterImageUrl = user.photoURL!; // Googleアカウントのアイコンデータがとれます

    final newPost = Post(
      text: text,
      createdAt: null, // null を入れると ServerTimestamp を参照することになっています。
      posterName: posterName,
      posterImageUrl: posterImageUrl,
      posterId: posterId,
      // doc の引数を空にするとランダムなIDが採番されます
      reference: ref.read(postsReferenceProvider).doc(),
    );

    // 先ほど作った newDocumentReference のset関数を実行するとそのドキュメントにデータが保存されます。
    // 引数として Post インスタンスを渡します。
    // 通常は Map しか受け付けませんが、withConverter を使用したことにより Post インスタンスを受け取れるようになります。
    await newPost.reference.set(newPost);
  }

  // build の外でインスタンスを作ります。
  final controller = TextEditingController();

  /// この dispose 関数はこのWidgetが使われなくなったときに実行されます。
  @override
  void dispose() {
    // TextEditingController は使われなくなったら必ず dispose する必要があります。
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold 全体を GestureDetector で囲むことでタップ可能になります。
    return GestureDetector(
      onTap: () {
        // キーボードを閉じたい時はこれを呼びます。
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('チャット'),
          // actions プロパティにWidgetを与えると右端に表示されます。
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const ProfilePage();
                    },
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  ref.watch(userProvider).value!.photoURL!,
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ref.watch(postsProvider).when(
                data: (data) {
                  /// 値が取得できた場合に呼ばれる。
                  return ListView.builder(
                    itemCount: data.docs.length,
                    itemBuilder: (context, index) {
                      final post = data.docs[index].data();
                      return PostWidget(post: post);
                    },
                  );
                },
                error: (_, __) {
                  /// 読み込み中にErrorが発生した場合に呼ばれる。
                  return const Center(
                    child: Text('不具合が発生しました。'),
                  );
                },
                loading: () {
                  /// 読み込み中の場合に呼ばれる。
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextFormField(
                // 上で作ったコントローラーを与えます。
                controller: controller,
                decoration: InputDecoration(
                  // 未選択時の枠線
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                  // 選択時の枠線
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.amber,
                      width: 2,
                    ),
                  ),
                  // 中を塗りつぶす色
                  fillColor: Colors.amber[50],
                  // 中を塗りつぶすかどうか
                  filled: true,
                ),
                onFieldSubmitted: (text) {
                  sendPost(text);
                  // 入力中の文字列を削除します。
                  controller.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
