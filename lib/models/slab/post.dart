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
  final String? type; // 워크플로우 구분용
  final int likesCount; // 좋아요 개수

  Post({
    required this.id,
    required this.slab,
    required this.user,
    this.title,
    required this.content,
    required this.createdAt,
    required this.views,
    this.type,
    required this.likesCount,
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
      type: json['type'],
      likesCount: json['likes_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slab': slab.toJson(),
      'user': user.toJson(),
      'title': title,
      'content': content,
      'created_at': createdAt,
      'views': views,
      'type': type,
      'likes_count': likesCount,
    };
  }
}
