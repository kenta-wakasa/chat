import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'posts_reference_provider.dart';

/// 全投稿データをstreamで提供するProvider
final postsProvider = StreamProvider((ref) {
  final postsReference = ref.read(postsReferenceProvider);
  return postsReference.orderBy('createdAt').snapshots();
});
