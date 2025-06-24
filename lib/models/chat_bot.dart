/// 챗봇의 기본 정보를 담는 모델 클래스
class ChatBot {
  final String id; // 챗봇의 고유 식별자
  final String name; // 챗봇의 이름
  final String description; // 챗봇의 설명
  final String systemPrompt; // ChatGPT API에 전달할 시스템 프롬프트

  const ChatBot({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
  });

  /// 사용 가능한 모든 챗봇 목록
  static const List<ChatBot> bots = [
    ChatBot(
      id: 'ailee',
      name: 'Ailee',
      description: '친근하고 도움이 되는 AI 어시스턴트',
      systemPrompt: 'You are Ailee, a friendly and helpful AI assistant.',
    ),
    ChatBot(
      id: 'ben',
      name: 'Ben',
      description: '전문적인 기술 전문가',
      systemPrompt:
          'You are Ben, a technical expert who provides detailed and accurate information.',
    ),
    ChatBot(
      id: 'clara',
      name: 'Clara',
      description: '창의적인 아이디어 생성기',
      systemPrompt:
          'You are Clara, a creative AI that helps generate innovative ideas.',
    ),
    ChatBot(
      id: 'david',
      name: 'David',
      description: '비즈니스 컨설턴트',
      systemPrompt:
          'You are David, a business consultant who provides strategic advice.',
    ),
    ChatBot(
      id: 'emma',
      name: 'Emma',
      description: '학습 도우미',
      systemPrompt:
          'You are Emma, an educational assistant who helps with learning and understanding concepts.',
    ),
  ];
}
