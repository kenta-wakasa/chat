import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/post/post.dart';

final postsReferenceWithConverter =
    Collection.posts.reference(FirebaseFirestore.instance).withConverter<Post>(
  fromFirestore: ((snapshot, _) {
    // 第二引数は使わないのでその場合は _ で不使用であることを分かりやすくしています。
    return Post.fromFirestore(snapshot); // 先ほど定期着した fromFirestore がここで活躍します。
  }),
  toFirestore: ((value, _) {
    return value.toMap(); // 先ほど適宜した toMap がここで活躍します。
  }),
);

enum Collection {
  posts;

  CollectionReference<Map<String, dynamic>> reference(
    FirebaseFirestore firestore,
  ) {
    return firestore.collection(name);
  }
}
