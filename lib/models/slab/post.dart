import 'slab.dart';
import '../user.dart';

class Post {
  final int id;
  final Slab slab;
  final User user;
  final String? title;
  final String content;
  final String createdAt;
  final int views;

  Post({
    required this.id,
    required this.slab,
    required this.user,
    this.title,
    required this.content,
    required this.createdAt,
    required this.views,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      slab: Slab.fromJson(json['slab']),
      user: User.fromJson(json['user']),
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
      views: json['views'] ?? 0,
    );
  }
}
