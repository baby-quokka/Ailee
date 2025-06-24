import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_bot.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ailee Practice',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlueAccent],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 헤더 섹션
              Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: [
                    Text(
                      '어떤 대화를 시작하시겠어요?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AI 친구들과 특별한 주제로 대화해보세요',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // 메인 콘텐츠
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 특별 주제 섹션
                        const Text(
                          '특별한 대화 주제',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                            children: [
                              _buildTopicCard(
                                context,
                                'Ailee가 본 당신은\n에겐일까 테토일까?',
                                'Ailee',
                                Colors.pink,
                                Icons.psychology,
                                '안녕, 나는 에겐일까 테토일까?',
                              ),
                              _buildTopicCard(
                                context,
                                'Ben과 함께 하는\n사주 풀이',
                                'Ben',
                                Colors.orange,
                                Icons.star,
                                '안녕, 나의 사주를 풀어주세요.',
                              ),
                              _buildTopicCard(
                                context,
                                'Clara의 고민상담',
                                'Clara',
                                Colors.purple,
                                Icons.favorite,
                                '안녕, 고민이 있어서 상담받고 싶어요.',
                              ),
                              _buildTopicCard(
                                context,
                                'David의 비즈니스\n전략 컨설팅',
                                'David',
                                Colors.indigo,
                                Icons.business,
                                '안녕, 비즈니스 전략에 대해 조언받고 싶어요.',
                              ),
                              _buildTopicCard(
                                context,
                                'Emma와 함께하는\n학습 도우미',
                                'Emma',
                                Colors.teal,
                                Icons.school,
                                '안녕, 학습에 도움이 필요해요.',
                              ),
                              _buildTopicCard(
                                context,
                                '자유로운 대화',
                                'Ailee',
                                Colors.blue,
                                Icons.chat,
                                '안녕, 자유롭게 대화해요.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    String title,
    String botName,
    Color color,
    IconData icon,
    String initialMessage,
  ) {
    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap:
            () => _startTopicConversation(
              context,
              botName,
              title,
              initialMessage,
            ),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'with $botName',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startTopicConversation(
    BuildContext context,
    String botName,
    String topic,
    String initialMessage,
  ) {
    // 챗봇 찾기
    final bot = ChatBot.bots.firstWhere(
      (bot) => bot.name == botName,
      orElse: () => ChatBot.bots[0], // 기본값으로 Ailee
    );

    // ChatProvider 인스턴스를 미리 가져오기
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // HomeScreen의 switchToChatScreen 메서드 호출
    final homeScreen = context.findAncestorStateOfType<HomeScreenState>();
    if (homeScreen != null) {
      homeScreen.switchToChatScreen();

      // 채팅 화면으로 전환 후 즉시 특정 주제 대화 시작
      WidgetsBinding.instance.addPostFrameCallback((_) {
        chatProvider.startTopicConversation(bot, topic, initialMessage);
      });
    }
  }
}
