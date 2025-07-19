import '../user.dart';

class Answer {
  final int id;
  final int postId;
  final User user;
  final String content;
  final String createdAt;
  final int likesCount;

  Answer({
    required this.id,
    required this.postId,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.likesCount,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      postId: json['post'],
      user: User.fromJson(json['user']),
      content: json['content'],
      createdAt: json['created_at'],
      likesCount: json['likes_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post': postId,
      'user': user.toJson(),
      'content': content,
      'created_at': createdAt,
      'likes_count': likesCount,
    };
  }
}
