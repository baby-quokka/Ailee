/// 챗봇의 기본 정보를 담는 모델 클래스
class ChatBot {
  final String id; // 챗봇의 고유 식별자
  final String name; // 챗봇의 이름

  const ChatBot({required this.id, required this.name});

  /// 사용 가능한 모든 챗봇 목록
  static const List<ChatBot> bots = [
    ChatBot(id: 'ailee', name: 'Ailee'),
    ChatBot(id: 'joon', name: 'Joon'),
    ChatBot(id: 'rin', name: 'Rin'),
    ChatBot(id: 'nick', name: 'Nick'),
    ChatBot(id: 'chad', name: 'Chad'),
  ];
}
