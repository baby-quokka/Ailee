class ChatMessage {
  final int id;
  final int sessionId;
  final String sender; // 'user' or 'model'
  final String message;
  final int order;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.sender,
    required this.message,
    required this.order,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      sessionId: json['session'] ?? 0,
      sender: json['sender'] ?? 'user',
      message: json['message'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session': sessionId,
      'sender': sender,
      'message': message,
      'order': order,
    };
  }

  bool get isUser => sender == 'user';
  bool get isModel => sender == 'model';

  /// 객체의 일부 속성만 변경하여 새로운 객체를 생성하는 메서드
  ChatMessage copyWith({
    int? id,
    int? sessionId,
    String? sender,
    String? message,
    int? order,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      order: order ?? this.order,
    );
  }
}
