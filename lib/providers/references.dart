import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post/post.dart';

final firebaseFirestoreProvider = Provider((ref) {
  return FirebaseFirestore.instance;
});

final postsReferenceWithConverterProvider = Provider((ref) {
  final firebaseFirestore = ref.read(firebaseFirestoreProvider);
  return firebaseFirestore.collection(('posts')).withConverter<Post>(
    fromFirestore: ((snapshot, _) {
      // 第二引数は使わないのでその場合は _ で不使用であることを分かりやすくしています。
      return Post.fromFirestore(snapshot); // 先ほど定期着した fromFirestore がここで活躍します。
    }),
    toFirestore: ((value, _) {
      return value.toMap(); // 先ほど適宜した toMap がここで活躍します。
    }),
  );
});
