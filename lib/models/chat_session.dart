import 'chat_message.dart';
import 'chat_bot.dart';

class ChatSession {
  final int id;
  final int characterId;
  final int userId;
  final String summary;
  final String topic;
  final DateTime time;
  final DateTime startTime;

  // UI를 위한 추가 필드들
  final List<ChatMessage> messages;
  final ChatBot? bot; // UI 표시용 (null일 수 있음)

  ChatSession({
    required this.id,
    required this.characterId,
    required this.userId,
    required this.summary,
    required this.topic,
    required this.time,
    required this.startTime,
    this.messages = const [],
    this.bot,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] ?? 0,
      characterId: json['character'] ?? 0,
      userId: json['user'] ?? 0,
      summary: json['summary'] ?? '',
      topic: json['topic'] ?? 'None',
      time:
          json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
      startTime:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'])
              : DateTime.now(),
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

  /// UI 표시용 제목 반환
  String get displayTitle {
    return summary.isNotEmpty ? summary : '새로운 대화';
  }

  /// 마지막 업데이트 시간 (time 필드 사용)
  DateTime get updatedAt => time;

  /// 객체의 일부 속성만 변경하여 새로운 객체를 생성하는 메서드
  ChatSession copyWith({
    int? id,
    int? characterId,
    int? userId,
    String? summary,
    String? topic,
    DateTime? time,
    DateTime? startTime,
    List<ChatMessage>? messages,
    ChatBot? bot,
  }) {
    return ChatSession(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      userId: userId ?? this.userId,
      summary: summary ?? this.summary,
      topic: topic ?? this.topic,
      time: time ?? this.time,
      startTime: startTime ?? this.startTime,
      messages: messages ?? this.messages,
      bot: bot ?? this.bot,
    );
  }

  /// Bot ID를 Character ID로 변환하는 헬퍼 메서드
  static int getCharacterIdFromBotId(String botId) {
    switch (botId) {
      case 'ailee':
        return 1;
      case 'joon':
        return 2;
      case 'nick':
        return 3;
      case 'chad':
        return 4;
      case 'rin':
        return 5;
      default:
        return 1;
    }
  }

  /// Character ID를 Bot ID로 변환하는 헬퍼 메서드
  static String getBotIdFromCharacterId(int characterId) {
    switch (characterId) {
      case 1:
        return 'ailee';
      case 2:
        return 'joon';
      case 3:
        return 'nick';
      case 4:
        return 'chad';
      case 5:
        return 'rin';
      default:
        return 'ailee';
    }
  }
}
