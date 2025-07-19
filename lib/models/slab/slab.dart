import 'package:ailee/models/user.dart';

class Slab {
  final int id;
  final String name;
  final String? description;
  final List<User> users;
  final String? imoji;
  final String createdAt;

  Slab({
    required this.id,
    required this.name,
    this.description,
    required this.users,
    this.imoji,
    required this.createdAt,
  });

  factory Slab.fromJson(Map<String, dynamic> json) {
    return Slab(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      users:
          (json['user'] as List<dynamic>?)
              ?.map((u) => User.fromJson(u))
              .toList() ??
          [],
      imoji: json['imoji'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'user': users.map((u) => u.toJson()).toList(),
      'imoji': imoji,
      'created_at': createdAt,
    };
  }
}
