import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _chatProvider.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    _chatProvider.removeListener(_onProviderChange);
    super.dispose();
  }

  void _onProviderChange() {
    // 사용자가 메시지를 보낸 직후 (ChatProvider의 isLoading 상태가 true로 변경될 때)
    if (_chatProvider.isLoading && mounted) {
      final messages = _chatProvider.currentRoom?.messages ?? [];
      if (messages.isNotEmpty) {
        // 마지막 사용자 메시지의 인덱스를 찾음
        final lastUserMessageIndex = messages.lastIndexWhere((m) => m.isUser);

        if (lastUserMessageIndex != -1) {
          // 위젯 빌드가 완료된 후 스크롤 실행
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_itemScrollController.isAttached) {
              _itemScrollController.scrollTo(
                index: lastUserMessageIndex,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                // Alignment를 0으로 설정하여 아이템의 시작(상단)이 뷰포트의 시작(상단)에 오도록 함
                alignment: 0,
              );
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<ChatProvider>().createNewRoom();
            },
          ),
        ],
      ),
      drawer: const _ChatDrawer(),
      body: Column(
        children: [
          Expanded(
            // 1. LayoutBuilder로 감싸서 실제 사용 가능한 높이를 얻음
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    final messages = chatProvider.currentRoom?.messages ?? [];
                    final isLoading = chatProvider.isLoading;

                    return ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      padding: const EdgeInsets.all(8),
                      // 2. 맨 마지막에 공백을 추가하기 위해 아이템 카운트 +1
                      itemCount: messages.length + (isLoading ? 1 : 0) + 1,
                      itemBuilder: (context, index) {
                        final messageCount = messages.length;
                        final loadingItemIndex = messageCount;
                        final spacerIndex = messageCount + (isLoading ? 1 : 0);

                        // 로딩 인디케이터
                        if (isLoading && index == loadingItemIndex) {
                          return _buildLoadingIndicator();
                        }

                        // 3. 마지막 인덱스에 도달하면, 계산된 높이의 공백(SizedBox)을 추가
                        if (index == spacerIndex) {
                          // 화면 높이에서 메시지 하나 정도의 높이를 뺀 만큼 공백을 주어
                          // 마지막 메시지가 화면 상단에 위치할 수 있는 충분한 공간을 확보
                          return SizedBox(height: constraints.maxHeight - 80);
                        }

                        // 일반 메시지 버블
                        final message = messages[index];
                        return _buildMessageBubble(message);
                      },
                    );
                  },
                );
              },
            ),
          ),
          const _MessageInput(),
        ],
      ),
    );
  }

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

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Text(
          message.message,
          style: TextStyle(color: message.isUser ? Colors.white : Colors.black),
        ),
      ),
    );
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
}

// _ChatDrawer와 _MessageInput 위젯은 변경사항이 없으므로 그대로 유지합니다.
class _ChatDrawer extends StatelessWidget {
  const _ChatDrawer();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final rooms =
              chatProvider.chatRooms
                  .where((room) => room.bot.id == chatProvider.currentBot.id)
                  .toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Center(
                  child: Text(
                    '${chatProvider.currentBot.name}\'s Chats',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
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
                            : room.messages.last.message,
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

  void _sendMessage() {
    final message = _controller.text;
    if (message.trim().isNotEmpty) {
      context.read<ChatProvider>().sendMessage(message);
      _controller.clear();
      FocusScope.of(context).unfocus();
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
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return IconButton(
                onPressed: chatProvider.isLoading ? null : _sendMessage,
                icon: const Icon(Icons.send),
                color: Colors.blue,
              );
            },
          ),
        ],
      ),
    );
  }
}
