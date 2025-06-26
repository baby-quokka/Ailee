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
      id: json['id'],
      characterId: json['character'],
      userId: json['user'],
      summary: json['summary'] ?? '',
      topic: json['topic'] ?? 'None',
      time: DateTime.parse(json['time']),
      startTime: DateTime.parse(json['start_time']),
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
