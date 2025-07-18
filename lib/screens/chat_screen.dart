import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';
import '../providers/auth_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'workflow_screen.dart';
import 'contents_screen.dart';

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
  // research 토글 상태 멤버 변수로 추가
  bool _isResearchActive = false;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  ChatMessage? _selectedMessage;
  int? _expandedMessageIndex; // index 기반으로 변경
  OverlayEntry? _editOptionsOverlay;
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0; // 이전 메시지 개수 추적

  // 편집 모드 상태 변수 추가
  ChatMessage? _editingMessage;
  int? _editingMessageIndex;
  bool get _isEditing => _editingMessage != null;

  void _showEditOptions(BuildContext context, Offset position, ChatMessage message, int index, VoidCallback onEdit) {
    _removeEditOptions();
    final overlay = Overlay.of(context);
    
    _selectedMessage = message;
    _expandedMessageIndex = index;
    
    _editOptionsOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 60,
        top: position.dy + 20,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditOption('복사', Icons.copy, () {
                Clipboard.setData(ClipboardData(text: message.message));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('메시지가 복사되었습니다.')),
                );
                _removeEditOptions();
              }),
              _buildEditOption('편집', Icons.edit, () {
                setState(() {
                  _messageController.text = message.message;
                  _editingMessage = message;
                  _editingMessageIndex = index;
                  _selectedImages.clear();
                });
                _removeEditOptions();
              }),
              _buildEditOption('공유', Icons.share, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공유 기능을 구현하세요.')),
                );
                _removeEditOptions();
              }),
            ],
          ),
        ),
      ),
    );
    overlay.insert(_editOptionsOverlay!);
  }

  Widget _buildEditOption(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  void _removeEditOptions() {
    _editOptionsOverlay?.remove();
    _editOptionsOverlay = null;
    _selectedMessage = null;
    setState(() {
      _expandedMessageIndex = null;
    });
  }

  @override
  void dispose() {
    _removeEditOptions();
    _messageController.dispose();
    _workflowInputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    // 편집 모드일 때는 메시지 수정
    if (_isEditing && _editingMessageIndex != null) {
      _editMessage();
      return;
    }
    
    context.read<ChatProvider>().sendMessage(
      text,
      isResearchActive: _isResearchActive,
      images: _selectedImages.isNotEmpty ? _selectedImages : null,
    );
    _messageController.clear();
    FocusScope.of(context).unfocus();
    
    // 메시지 전송 후 이미지 초기화
    setState(() {
      _selectedImages.clear();
      _isResearchActive = false;
    });
  }

  // 메시지 수정 함수
  void _editMessage() {
    
    if (_editingMessage != null && _editingMessageIndex != null) {
      // 메시지 수정 API 호출
      context.read<ChatProvider>().sendMessage(
        _messageController.text,
        isResearchActive: _isResearchActive,
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
        isEdit: true,
        order: _editingMessage!.order,
      );
      setState(() {
        _editingMessage = null;
        _editingMessageIndex = null;
        _messageController.clear();
      });
      FocusScope.of(context).unfocus();
    }
  }


  void _showContentsScreen() {
    final bot = context.read<ChatProvider>().currentBot;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContentsScreen(
          bot: bot,
          workflowInputController: _workflowInputController,
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
            workflowResponse != null);

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
            icon: const Icon(Symbols.note_stack_add),
            onPressed: () {
              chatProvider.createNewSession();
            },
          ),
        ],
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
                _buildInputField(bot),
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
            width: 150,
            height: 150,
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
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.left,
            ),
            Text(
              '${bot.name}와 고민을 나눠봐요',
              style: TextStyle(
                fontSize: 16,
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
          onTap: _showContentsScreen,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _showContentsScreen,
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

  Widget _buildInputField(ChatBot bot) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: SizedBox(
                  height: 80,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_selectedImages.length, (idx) {
                        final img = _selectedImages[idx];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  File(img.path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(idx);
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            // 상단 텍스트 입력
            TextField(
              controller: _messageController,
              onSubmitted: _sendMessage,
              maxLines: null,
              textInputAction: TextInputAction.send,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 0,
                ),
                hintText: "${bot.name}와 얘기해봐요",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[500]),
              ),
            ),
            // 하단 + 버튼과 검색/수정 버튼
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // + 버튼
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.black, size: 22),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                            ),
                            builder: (context) {
                              final width = MediaQuery.of(context).size.width;
                              return SizedBox(
                                width: width,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 5,
                                          margin: const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          // 파일 선택 기능 구현
                                        },
                                        icon: Icon(Icons.insert_drive_file, size: 28, color: Colors.black),
                                        label: Text('  파일 추가', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Pretendard',)),
                                        style: TextButton.styleFrom(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () async {
                                          // 사진첩에서 이미지 선택
                                          final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                          if (image != null) {
                                            setState(() {
                                              _selectedImages.add(image);
                                            });
                                            Navigator.pop(context); // 사진 선택 후 bottomsheet 닫기
                                          }
                                        },
                                        icon: Icon(Icons.photo, size: 28, color: Colors.black),
                                        label: Text('  사진 추가', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Pretendard',)),
                                        style: TextButton.styleFrom(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          // '웹에서 검색하기' 버튼 클릭 시
                                         setState(() {
                                          _isResearchActive = !_isResearchActive;
                                         });
                                         Navigator.pop(context);
                                        },
                                        icon: Icon(Symbols.language, size: 28, color: _isResearchActive ? Color(0xFF5A6CEA) : Colors.black),
                                        label: Text('  웹에서 검색하기', style: TextStyle(color: _isResearchActive ? Color(0xFF5A6CEA) : Colors.black, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Pretendard',)),
                                        style: TextButton.styleFrom(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        splashRadius: 24,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ),
                ),
                // 검색 x 버튼 또는 편집(수정) 버튼
                if (_isEditing && _isResearchActive) ...[
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE8F0FE),
                            foregroundColor: Color(0xFF5A6CEA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Pretendard',
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            minimumSize: const Size(0, 40),
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() {
                              _editingMessage = null;
                              _editingMessageIndex = null;
                              _messageController.clear();
                            });
                          },
                          child: Row(
                        children: const [
                          Icon(Symbols.edit, size: 24, fill: 1, color: Color(0xFF5A6CEA)),
                          SizedBox(width: 4),
                          Icon(Symbols.close, size: 18, color: Color(0xFF5A6CEA)),
                        ],
                      ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE8F0FE),
                            foregroundColor: Color(0xFF5A6CEA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Pretendard',
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            minimumSize: const Size(0, 40),
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() {
                              _isResearchActive = false;
                            });
                          },
                          child: Row(
                            children: const [
                              Icon(Symbols.language, size: 24, color: Color(0xFF5A6CEA)),
                              SizedBox(width: 4),
                              Icon(Symbols.close, size: 18, color: Color(0xFF5A6CEA)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (_isEditing) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE8F0FE),
                        foregroundColor: Color(0xFF5A6CEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Pretendard',
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        minimumSize: const Size(0, 40),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _editingMessage = null;
                          _editingMessageIndex = null;
                          _messageController.clear();
                        });
                      },
                      child: Row(
                        children: const [
                          Icon(Symbols.edit, size: 24, fill: 1, color: Color(0xFF5A6CEA)),
                          SizedBox(width: 4),
                          Icon(Symbols.close, size: 18, color: Color(0xFF5A6CEA)),
                        ],
                      ),
                    ),
                  ),
                ] else if (_isResearchActive) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE8F0FE),
                        foregroundColor: Color(0xFF5A6CEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Pretendard',
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        minimumSize: const Size(0, 40),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _isResearchActive = false;
                        });
                      },
                      child: Row(
                        children: const [
                          Icon(Symbols.language, size: 24, color: Color(0xFF5A6CEA)),
                          SizedBox(width: 4),
                          Icon(Symbols.close, size: 18, color: Color(0xFF5A6CEA)),
                        ],
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // 전송 버튼 (오른쪽 하단)
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(List<ChatMessage> messages) {
    final chatProvider = context.watch<ChatProvider>();
    final isLoading = chatProvider.isLoading;

    // ScrollController 추가
    // final ScrollController scrollController = ScrollController(); // This line is removed

    // 메시지가 추가되면 자동으로 최하단으로 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatProvider.currentSession?.messages.length != _lastMessageCount) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        _lastMessageCount = chatProvider.currentSession?.messages.length ?? 0;
      }
    });

    return GestureDetector(
      behavior: HitTestBehavior.translucent, // 빈 공간도 인식
      onTap: () {
        if (_editOptionsOverlay != null) {
          _removeEditOptions();
        }
      },
      child: Scrollbar(
        controller: _scrollController,
        thickness: 4, // 스크롤바 두께
        radius: const Radius.circular(2), // 스크롤바 모서리 둥글기
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: messages.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (isLoading && index == messages.length) {
              return _buildLoadingIndicator();
            }
            final msg = messages[index];

            if (msg.isUser) {
              // 사용자 메시지 - AnimatedContainer로 확대 효과 추가
              final isExpanded = _expandedMessageIndex == index;
              
              return GestureDetector(
                onLongPressStart: (details) {
                  setState(() {
                    _expandedMessageIndex = index;
                  });
                  _showEditOptions(
                    context,
                    details.globalPosition,
                    msg,
                    index,
                    () {
                      // TODO: 수정 기능 구현 (예: 다이얼로그 띄우기 등)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('수정 기능을 구현하세요.')),
                      );
                    },
                  );
                },
                onTap: _removeEditOptions,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (msg.localImagePaths != null && msg.localImagePaths!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              children: msg.localImagePaths!.map((path) =>
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(path),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ).toList(),
                            ),
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        transform: isExpanded ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isExpanded ? [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: Text(
                          msg.message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ],
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
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/emoji/man_3d_light.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
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
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
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
