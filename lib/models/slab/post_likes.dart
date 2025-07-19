import 'package:ailee/models/slab/post.dart';
import 'package:ailee/models/user.dart';

class PostLikes {
  final int id;
  final Post post;
  final User user;
  final String createdAt;

  PostLikes({
    required this.id,
    required this.post,
    required this.user,
    required this.createdAt,
  });

  factory PostLikes.fromJson(Map<String, dynamic> json) {
    return PostLikes(
      id: json['id'],
      post: Post.fromJson(json['post']),
      user: User.fromJson(json['user']),
      createdAt: json['created_at'],
    );
  }
}
