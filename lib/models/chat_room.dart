import 'chat_message.dart';
import 'chat_bot.dart';

/// 채팅방의 정보를 담는 모델 클래스
class ChatRoom {
  final String id; // 채팅방의 고유 식별자
  final String title; // 채팅방의 제목
  final ChatBot bot; // 이 채팅방에서 사용할 챗봇
  final List<ChatMessage> messages; // 채팅 메시지 목록
  final DateTime createdAt; // 채팅방 생성 시간
  final DateTime updatedAt; // 마지막 메시지 시간

  ChatRoom({
    required this.id,
    required this.title,
    required this.bot,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 객체의 일부 속성만 변경하여 새로운 객체를 생성하는 메서드
  /// null이 아닌 매개변수만 새로운 값으로 변경됨
  ChatRoom copyWith({
    String? id,
    String? title,
    ChatBot? bot,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      bot: bot ?? this.bot,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
