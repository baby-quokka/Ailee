import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';
import '../providers/auth_provider.dart';

class WorkflowScreen extends StatelessWidget {
  final ChatBot bot;
  final TextEditingController workflowInputController;
  const WorkflowScreen({
    Key? key,
    required this.bot,
    required this.workflowInputController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _WorkflowScreenBody(
      bot: bot,
      workflowInputController: workflowInputController,
    );
  }
}

class _WorkflowScreenBody extends StatefulWidget {
  final ChatBot bot;
  final TextEditingController workflowInputController;
  const _WorkflowScreenBody({
    required this.bot,
    required this.workflowInputController,
  });

  @override
  State<_WorkflowScreenBody> createState() => _WorkflowScreenBodyState();
}

class _WorkflowScreenBodyState extends State<_WorkflowScreenBody> {
  bool _popped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatProvider = context.watch<ChatProvider>();
    if (!chatProvider.isWorkflow) {
      // 워크플로우가 종료되면 자동 pop
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    // isWorkflow가 false로 바뀌면 자동 pop (중복 pop 방지)
    if (!chatProvider.isWorkflow && !_popped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          _popped = true;
          Navigator.of(context).pop();
        }
      });
    }

    final workflowResponse = chatProvider.workflowResponse;
    final isLoading = chatProvider.isLoading;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            final chatProvider = context.read<ChatProvider>();
            final sessionId = chatProvider.currentSession?.id;
            print(
              '[DEBUG] 뒤로가기 클릭 - 현재 세션 ID: ' +
                  (sessionId?.toString() ?? 'null'),
            );
            if (sessionId != null) {
              try {
                await chatProvider.deleteSession(sessionId);
                print('[DEBUG] deleteSession 호출 완료 - 삭제된 세션 ID: $sessionId');
              } catch (e) {
                print('[DEBUG] deleteSession 에러: ' + e.toString());
              }
              await chatProvider.loadSessions();
            }
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          widget.bot.name,
          style: TextStyle(fontWeight: FontWeight.w500),
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
      ),
      body: _buildWorkflowUI(
        context,
        chatProvider,
        workflowResponse,
        isLoading,
      ),
    );
  }

  Widget _buildWorkflowUI(
    BuildContext context,
    ChatProvider chatProvider,
    List<String>? response,
    bool isLoading,
  ) {
    final cardDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 챗봇 말풍선
          Padding(
            padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 36, color: Colors.grey[400]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: cardDecoration,
                    child:
                        isLoading
                            ? Center(
                              child: SizedBox(
                                height: 28,
                                child: SpinKitThreeBounce(
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ),
                            )
                            : Text(
                              response != null ? response[0] : '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // 선택지 카드
          ...List.generate(4, (i) {
            final text = response != null ? response[i + 1] : '';
            if (text == null || text.trim().isEmpty) return SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap:
                    isLoading
                        ? null
                        : () {
                          chatProvider.sendMessage(text, isWorkflow: true);
                          FocusScope.of(context).unfocus();
                        },
                child: Container(
                  decoration: cardDecoration,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A6CEA),
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          // 입력 카드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: cardDecoration,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.workflowInputController,
                      decoration: InputDecoration(
                        hintText: '직접 입력',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Color(0xFF5A6CEA),
                        ),
                      ),
                      enabled: !isLoading,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty && !isLoading) {
                          chatProvider.sendMessage(text, isWorkflow: true);
                          widget.workflowInputController.clear();
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Color(0xFF5A6CEA)),
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              final text = widget.workflowInputController.text;
                              if (text.trim().isNotEmpty) {
                                chatProvider.sendMessage(
                                  text,
                                  isWorkflow: true,
                                );
                                widget.workflowInputController.clear();
                                FocusScope.of(context).unfocus();
                              }
                            },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _workflowInputController =
      TextEditingController();
  final List<String> samplePrompts = [
    '감정 조절 및 정서적 문제 해결',
    '의사결정 및 선택',
    '대인관계 및 커뮤니케이션',
    '자기 인식 및 정체성',
    '동기부여 및 습관/행동 변화, 생산성 및 시간관리',
    '학습/공부 전략 및 개념 이해',
  ];

  // 워크플로우 임시 진입 상태
  bool _forceWorkflow = false;
  bool _workflowScreenPushed = false;

  @override
  void dispose() {
    _messageController.dispose();
    _workflowInputController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(text);
    _messageController.clear();
    FocusScope.of(context).unfocus();
  }

  void _sendMessageWithWorkflow(String text, bool isWorkflow) {
    if (text.trim().isEmpty) return;
    setState(() {
      _forceWorkflow = isWorkflow;
    });
    context.read<ChatProvider>().sendMessage(text, isWorkflow: isWorkflow).then(
      (_) {
        setState(() {
          _forceWorkflow = false;
        });
      },
    );
    _messageController.clear();
    FocusScope.of(context).unfocus();
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
    final isWorkflow = chatProvider.isWorkflow;
    final workflowResponse = chatProvider.workflowResponse;
    final messages = chatProvider.currentSession?.messages ?? [];
    final hasStartedChat = messages.isNotEmpty;
    final bot = chatProvider.currentBot;

    // prompt 버튼을 누른 직후에는 무조건 워크플로우 UI 진입
    final showWorkflow =
        _forceWorkflow ||
        (isWorkflow &&
            workflowResponse != null &&
            workflowResponse.length == 5);

    // 워크플로우 진입 시 새로운 스크린 push
    if (showWorkflow && !_workflowScreenPushed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _workflowScreenPushed = true;
        });
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder:
                    (_) => WorkflowScreen(
                      bot: bot,
                      workflowInputController: _workflowInputController,
                    ),
              ),
            )
            .then((_) {
              setState(() {
                _workflowScreenPushed = false;
              });
            });
      });
    }

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
      body: Builder(
        builder: (context) {
          if (showWorkflow) {
            // 워크플로우 스크린이 push된 상태에서는 아래 UI를 비워둠
            return const SizedBox.shrink();
          }
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Column(
              children: [
                Expanded(
                  child:
                      hasStartedChat
                          ? _buildChatList(messages)
                          : _buildInitialCenterCharacter(bot),
                ),
                if (!hasStartedChat) ...[
                  _buildInitialGreeting(bot),
                  _buildSamplePromptButtons(),
                ],
                _buildInputField(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialCenterCharacter(ChatBot bot) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Image.asset(
            'assets/emoji/man_tipping_hand_3d_light.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialGreeting(ChatBot bot) {
    final userName =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.name ??
        '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕하세요, $userName님!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.left,
            ),
            Text(
              '${bot.name}와 고민을 나눠봐요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplePromptButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        height: 80,
        child: FloatingButton(
          onTap: () => _sendMessageWithWorkflow('고민 상담하기', true),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _sendMessageWithWorkflow('고민 상담하기', true),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFe0c3fc), Color(0xFF8ec5fc)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/emoji/hand_with_fingers_splayed_3d_default.png',
                      width: 36,
                      height: 36,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '지금 무슨 고민 있어요?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pretendard',
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
                maxLines: null,
                textInputAction: TextInputAction.send,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 18,
                  ),
                  hintText: "Ask whatever you want",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () => _sendMessage(_messageController.text),
                  splashRadius: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(List<ChatMessage> messages) {
    final chatProvider = context.watch<ChatProvider>();
    final isLoading = chatProvider.isLoading;

    // ScrollController 추가
    final ScrollController scrollController = ScrollController();

    // 메시지가 추가되면 자동으로 최하단으로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scrollbar(
      controller: scrollController,
      thickness: 4, // 스크롤바 두께
      radius: const Radius.circular(2), // 스크롤바 모서리 둥글기
      child: ListView.builder(
        controller: scrollController,
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
      ),
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
              child: Dismissible(
                key: ValueKey('session_${session.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                confirmDismiss: (direction) async {
                  // 삭제 확인 없이 바로 삭제
                  await chatProvider.deleteSession(session.id);
                  return true;
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color:
                          isCurrentSession ? Colors.black : Colors.grey[300]!,
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
                    child: Container(
                      decoration: BoxDecoration(
                        // ... 기존 코드 ...
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.displayTitle.isNotEmpty
                                      ? session.displayTitle
                                      : 'No Title',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                if (session.messages.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      session.messages.last.message,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    _formatTimeAgo(session.updatedAt),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

class FloatingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const FloatingButton({super.key, required this.child, required this.onTap});

  @override
  State<FloatingButton> createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 5,
      end: -5,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: GestureDetector(onTap: widget.onTap, child: widget.child),
    );
  }
}
