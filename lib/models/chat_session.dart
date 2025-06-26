class ChatSession {
  final int id;
  final int characterId;
  final int userId;
  final String summary;
  final String topic;
  final DateTime time;
  final DateTime startTime;

  ChatSession({
    required this.id,
    required this.characterId,
    required this.userId,
    required this.summary,
    required this.topic,
    required this.time,
    required this.startTime,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? 0,
      characterId: json['character'] ?? 0,
      userId: json['user'] ?? 0,
      summary: json['summary'] ?? '',
      topic: json['topic'] ?? 'None',
      time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': characterId,
      'user': userId,
      'summary': summary,
      'topic': topic,
      'time': time.toIso8601String(),
      'start_time': startTime.toIso8601String(),
    };
  }
}
