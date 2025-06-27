import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> samplePrompts = ['나의 강점이 뭘까?', '스트레스 해소법 추천해줘'];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(text);
    _messageController.clear();
    FocusScope.of(context).unfocus();
  }

  void _onPromptSelected(String prompt) {
    _sendMessage(prompt);
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(maxWidth: 40),
        child: const SpinKitPulse(color: Colors.grey, size: 24.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final messages = chatProvider.currentSession?.messages ?? [];
    final hasStartedChat = messages.isNotEmpty;
    final bot = chatProvider.currentBot;

    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bot.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              chatProvider.createNewSession();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[500]!, height: 0.5),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                hasStartedChat
                    ? _buildChatList(messages)
                    : _buildInitialCenterCharacter(bot),
          ),
          if (!hasStartedChat) _buildSamplePromptButtons(),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildInitialCenterCharacter(ChatBot bot) {
    return Center(
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100]!, Colors.blue[300]!],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            bot.name,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSamplePromptButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 10,
        children:
            samplePrompts
                .map(
                  (prompt) => ElevatedButton(
                    onPressed: () => _onPromptSelected(prompt),
                    child: Text(prompt),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100], // 연한 배경
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onSubmitted: _sendMessage,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                  hintText: "Type your message...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: () => _sendMessage(_messageController.text),
              splashRadius: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(List<ChatMessage> messages) {
    final chatProvider = context.watch<ChatProvider>();
    final isLoading = chatProvider.isLoading;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (isLoading && index == messages.length) {
          return _buildLoadingIndicator();
        }
        final msg = messages[index];

        if (msg.isUser) {
          // 사용자 메시지 - 기존 박스 스타일 유지
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                msg.message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                  // fontFamily: 'NanumGothicBold',
                ),
              ),
            ),
          );
        } else {
          // AI 답변 - 봇 이미지와 텍스트로 표시
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI 봇 이미지
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[100]!, Colors.blue[300]!],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // AI 답변 텍스트
                Expanded(
                  child: Text(
                    msg.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                      // fontFamily: 'NanumGothicBold',
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildDrawer() {
    final chatProvider = context.watch<ChatProvider>();
    final botList = ChatBot.bots;
    final currentBot = chatProvider.currentBot;
    final sessions =
        chatProvider.chatSessions
            .where((session) => session.bot?.id == currentBot.id)
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          const SizedBox(
            height: 48,
            child: Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16.0),
              child: Text(
                'Select Character',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // const Divider(),
          ...botList.map(
            (bot) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  chatProvider.setCurrentBot(bot);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        currentBot.id == bot.id
                            ? Colors.black
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      // Icon(
                      //   Icons.android,
                      //   color: Colors.white,
                      // ), // 나중에 이미지로 교체 가능
                      const SizedBox(width: 12),
                      Text(
                        bot.name,
                        style: TextStyle(
                          color:
                              currentBot.id == bot.id
                                  ? Colors.white
                                  : Colors.black, // 선택 시 흰색, 아니면 검정
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Past Conversations",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...sessions.map((session) {
            final isCurrentSession =
                chatProvider.currentSession?.id == session.id;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isCurrentSession ? Colors.black : Colors.grey[300]!,
                    width: isCurrentSession ? 1.0 : 0.5,
                  ),
                ),
                elevation: 0.5,
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    chatProvider.selectSession(session.id);
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        // Icon(
                        //   Icons.chat_bubble_outline_rounded,
                        //   color: Colors.grey[600],
                        // ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.displayTitle,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              // if (session.messages.isNotEmpty)
                              //   Padding(
                              //     padding: const EdgeInsets.only(top: 2.0),
                              //     child: Text(
                              //       session.messages.last.message,
                              //       maxLines: 1,
                              //       overflow: TextOverflow.ellipsis,
                              //       style: TextStyle(
                              //         color: Colors.grey[700],
                              //         fontSize: 13,
                              //       ),
                              //     ),
                              //   ),
                              // 시간 표시 로직 추가 필요
                              // Padding(
                              //   padding: const EdgeInsets.only(top: 4.0),
                              //   child: Text(
                              //     '1시간 전', // 시간 표시 함수로 교체 가능
                              //     style: TextStyle(
                              //       color: Colors.grey[500],
                              //       fontSize: 12,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
