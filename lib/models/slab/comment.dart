import '../user.dart';

class Comment {
  final int id;
  final int answerId;
  final User user;
  final String content;
  final String createdAt;
  final int likesCount;

  Comment({
    required this.id,
    required this.answerId,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.likesCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      answerId: json['answer'],
      user: User.fromJson(json['user']),
      content: json['content'],
      createdAt: json['created_at'],
      likesCount: json['likes_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'answer': answerId,
      'user': user.toJson(),
      'content': content,
      'created_at': createdAt,
      'likes_count': likesCount,
    };
  }
}
