import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post/post.dart';
import 'firestore_provider.dart';

final postsReferenceProvider = Provider((ref) {
  /// ほかの provider を参照したい場合は ref をつかう。
  final firestore = ref.read(firestoreProvider);
  return firestore.collection('posts').withConverter<Post>(
    fromFirestore: ((snapshot, _) {
      // 第二引数は使わないのでその場合は _ で不使用であることを分かりやすくしています。
      return Post.fromFirestore(snapshot); // 先ほど定期着した fromFirestore がここで活躍します。
    }),
    toFirestore: ((value, _) {
      return value.toMap(); // 先ほど適宜した toMap がここで活躍します。
    }),
  );
});
