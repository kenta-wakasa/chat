import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/post/post.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              post.posterImageUrl,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post.posterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      // toDate() で Timestamp から DateTime に変換できます。
                      DateFormat('MM/dd HH:mm').format(post.createdAt!),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // 角丸にするにはこれを追加します。
                        // 4 の数字を大きくするともっと丸くなります。
                        borderRadius: BorderRadius.circular(4),
                        // 色はここで変えられます
                        // [100] この数字を小さくすると色が薄くなります。
                        // [条件式] ? A : B の三項演算子を使っています。
                        color: FirebaseAuth.instance.currentUser!.uid ==
                                post.posterId
                            ? Colors.amber[100]
                            : Colors.blue[100],
                      ),
                      child: Text(post.text),
                    ),

                    /// Row のなかに Row をいれて要素をまとめます
                    /// if文もこのRowの上に移動して、それぞれのボタンに書いていたものは削除してOKです。
                    ///
                    ///  List の中の場合は if 文であっても {} この波かっこはつけなくてよい
                    if (FirebaseAuth.instance.currentUser!.uid == post.posterId)
                      Row(
                        children: [
                          /// 編集ボタン
                          if (FirebaseAuth.instance.currentUser!.uid ==
                              post.posterId)
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: TextFormField(
                                        initialValue: post.text,
                                        autofocus: true,
                                        onFieldSubmitted: (newText) {
                                          post.reference
                                              .update({'text': newText});
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.edit),
                            ),

                          /// 削除ボタン
                          IconButton(
                            onPressed: () {
                              // 削除は reference に対して delete() を呼ぶだけでよい。
                              post.reference.delete();
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
