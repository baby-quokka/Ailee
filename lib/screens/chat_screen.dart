import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';

/// 메인 채팅 화면 위젯
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        // 앱바 중앙에 챗봇 선택 위젯 배치
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return InkWell(
              onTap: () => _showBotSelectionDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chatProvider.currentBot.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 24),
                ],
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          // 새 채팅방 생성 버튼
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<ChatProvider>().createNewRoom();
            },
          ),
        ],
      ),
      // 좌측 메뉴 (채팅방 목록)
      drawer: const _ChatDrawer(),
      body: Column(
        children: [
          // 채팅 메시지 목록
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.currentRoom?.messages ?? [];
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          // 하단 메시지 입력 영역
          const _MessageInput(),
        ],
      ),
    );
  }

  /// 챗봇 선택 다이얼로그 표시
  void _showBotSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Bot'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ChatBot.bots.length,
                itemBuilder: (context, index) {
                  final bot = ChatBot.bots[index];
                  return ListTile(
                    title: Text(bot.name),
                    subtitle: Text(bot.description),
                    onTap: () {
                      context.read<ChatProvider>().setCurrentBot(bot);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
    );
  }

  /// 채팅 메시지 버블 위젯
  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      // 사용자/봇 메시지에 따라 정렬 위치 변경
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // 사용자/봇 메시지에 따라 색상 변경
          color: message.isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Text(
          message.content,
          style: TextStyle(color: message.isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

/// 좌측 메뉴 (채팅방 목록) 위젯
class _ChatDrawer extends StatelessWidget {
  const _ChatDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // 현재 선택된 챗봇의 채팅방만 필터링
          final rooms =
              chatProvider.chatRooms
                  .where((room) => room.bot.id == chatProvider.currentBot.id)
                  .toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // 최신순 정렬

          return Column(
            children: [
              // 드로어 헤더 (현재 챗봇 이름 표시)
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Center(
                  child: Text(
                    '${chatProvider.currentBot.name}\'s Chats',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              // 채팅방 목록
              Expanded(
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final isSelected = room.id == chatProvider.currentRoom?.id;

                    return ListTile(
                      title: Text(room.title),
                      subtitle: Text(
                        room.messages.isEmpty
                            ? 'No messages'
                            : room.messages.last.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: isSelected,
                      onTap: () {
                        chatProvider.selectRoom(room.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 하단 메시지 입력 영역 위젯
class _MessageInput extends StatefulWidget {
  const _MessageInput();

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 메시지 전송 처리
  void _sendMessage() {
    final message = _controller.text;
    if (message.trim().isNotEmpty) {
      context.read<ChatProvider>().sendMessage(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 메시지 입력 필드
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          // 전송 버튼
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return IconButton(
                onPressed: chatProvider.isLoading ? null : _sendMessage,
                icon:
                    chatProvider.isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.send),
                color: Colors.blue,
              );
            },
          ),
        ],
      ),
    );
  }
}
