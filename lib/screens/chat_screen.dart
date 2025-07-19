import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/chat_provider.dart';
import '../models/chat/chat_message.dart';
import '../models/chat/chat_bot.dart';
import '../models/chat/chat_session.dart';
import '../providers/auth_provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'workflow_screen.dart';
import 'contents_screen.dart';
import 'package:file_picker/file_picker.dart';
import '../config/api_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _workflowInputController =
      TextEditingController();
  // 검색 기능을 위한 컨트롤러 추가
  final TextEditingController _searchController = TextEditingController();
  
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

  List<PlatformFile> _selectedFiles = [];
  
  // 검색 관련 상태 변수 추가
  String _searchQuery = '';
  bool _isSearching = false;

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
                if (mounted) {
                  setState(() {
                    _messageController.text = message.message;
                    _editingMessage = message;
                    _editingMessageIndex = index;
                    _selectedImages.clear();
                  });
                }
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
    _expandedMessageIndex = null;
  }

  @override
  void dispose() {
    _removeEditOptions();
    _messageController.dispose();
    _workflowInputController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 검색 기능을 위한 메서드들
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      _searchController.clear();
    });
  }

  List<ChatSession> _getFilteredSessions(List<ChatSession> sessions) {
    if (_searchQuery.isEmpty) {
      return sessions;
    }
    
    return sessions.where((session) {
      return session.summary.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
      files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
    );
    _messageController.clear();
    FocusScope.of(context).unfocus();
    
    // 메시지 전송 후 이미지, 파일 초기화
    if (mounted) {
      setState(() {
        _selectedImages.clear();
        _selectedFiles.clear();
        _isResearchActive = false;
      });
    }
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
      if (mounted) {
        setState(() {
          _editingMessage = null;
          _editingMessageIndex = null;
          _messageController.clear();
        });
      }
      FocusScope.of(context).unfocus();
    }
  }

  void _showContentsScreen() {
    final bot = context.read<ChatProvider>().currentBot;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => ContentsScreen(
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
        _forceWorkflow || (isWorkflow && workflowResponse != null);

    // 워크플로우 진입 시 새로운 스크린 push
    if (showWorkflow && !_workflowScreenPushed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _workflowScreenPushed = true;
          });
        }
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
              if (mounted) {
                setState(() {
                  _workflowScreenPushed = false;
                });
              }
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
            if (_selectedFiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _selectedFiles.map((file) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        backgroundColor: Colors.white,
                        label: Text(file.name, style: const TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'Pretendard')),
                        onDeleted: () {
                          if (mounted) {
                            setState(() {
                              _selectedFiles.remove(file);
                            });
                          }
                        },
                      ),
                    )).toList(),
                  ),
                ),
              ),
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
                                    if (mounted) {
                                      setState(() {
                                        _selectedImages.removeAt(idx);
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
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
                        icon: const Icon(
                          Icons.add,
                          color: Colors.black,
                          size: 22,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                            ),
                            builder: (context) {
                              final width = MediaQuery.of(context).size.width;
                              return SizedBox(
                                width: width,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    60,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 5,
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () async {
                                          // 파일 선택 기능 구현
                                          FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
                                          if (result != null) {
                                            if (mounted) {
                                              setState(() {
                                                _selectedFiles.addAll(result.files);
                                              });
                                            }
                                            Navigator.pop(context);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.insert_drive_file,
                                          size: 28,
                                          color: Colors.black,
                                        ),
                                        label: Text(
                                          '  파일 추가',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Pretendard',
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () async {
                                          // 사진첩에서 여러 이미지 선택
                                          final List<XFile> images = await _picker
                                              .pickMultiImage();
                                          if (images.isNotEmpty) {
                                            if (mounted) {
                                              setState(() {
                                                _selectedImages.addAll(images);
                                              });
                                            }
                                            Navigator.pop(context); // 사진 선택 후 bottomsheet 닫기
                                          }
                                        },
                                        icon: Icon(
                                          Icons.photo,
                                          size: 28,
                                          color: Colors.black,
                                        ),
                                        label: Text(
                                          '  사진 추가',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Pretendard',
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {
                                          // '웹에서 검색하기' 버튼 클릭 시
                                         if (mounted) {
                                           setState(() {
                                             _isResearchActive = !_isResearchActive;
                                           });
                                         }
                                         Navigator.pop(context);
                                        },
                                        icon: Icon(
                                          Symbols.language,
                                          size: 28,
                                          color:
                                              _isResearchActive
                                                  ? Color(0xFF5A6CEA)
                                                  : Colors.black,
                                        ),
                                        label: Text(
                                          '  웹에서 검색하기',
                                          style: TextStyle(
                                            color:
                                                _isResearchActive
                                                    ? Color(0xFF5A6CEA)
                                                    : Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Pretendard',
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
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
                            if (mounted) {
                              setState(() {
                                _editingMessage = null;
                                _editingMessageIndex = null;
                                _messageController.clear();
                              });
                            }
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
                            if (mounted) {
                              setState(() {
                                _isResearchActive = false;
                              });
                            }
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
                        if (mounted) {
                          setState(() {
                            _editingMessage = null;
                            _editingMessageIndex = null;
                            _messageController.clear();
                          });
                        }
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
                        if (mounted) {
                          setState(() {
                            _isResearchActive = false;
                          });
                        }
                      },
                      child: Row(
                        children: const [
                          Icon(
                            Symbols.language,
                            size: 24,
                            color: Color(0xFF5A6CEA),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Symbols.close,
                            size: 18,
                            color: Color(0xFF5A6CEA),
                          ),
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
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
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
                  if (mounted) {
                    setState(() {
                      _expandedMessageIndex = index;
                    });
                  }
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
                      if ((msg.localImagePaths != null && msg.localImagePaths!.isNotEmpty) ||
                          (msg.localFilePaths != null && msg.localFilePaths!.isNotEmpty) ||
                          (msg.serverImageUrls.isNotEmpty) ||
                          (msg.serverFileUrls.isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              children: [
                                // 로컬 이미지들
                                ...(msg.localImagePaths ?? []).map((path) =>
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
                                ),
                                // 서버 이미지들
                                ...msg.serverImageUrls.map((imageUrl) {
                                  final fullImageUrl = '${ApiConfig.baseUrl.replaceAll('/api', '')}$imageUrl';
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        fullImageUrl,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.error,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }),
                                // 로컬 파일들
                                ...(msg.localFilePaths ?? []).map((filePath) {
                                  final fileName = filePath.split('/').last;
                                  final fileExtension = fileName.split('.').last.toLowerCase();
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getFileIcon(fileExtension),
                                            size: 32,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            fileName.length > 8 ? '${fileName.substring(0, 8)}...' : fileName,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                              fontFamily: 'Pretendard',
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                // 서버 파일들
                                ...msg.serverFileUrls.map((fileUrl) {
                                  final fullFileUrl = '${ApiConfig.baseUrl.replaceAll('/api', '')}$fileUrl';
                                  final fileName = fileUrl.split('/').last;
                                  final fileExtension = fileName.split('.').last.toLowerCase();
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _getFileIcon(fileExtension),
                                            size: 32,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            fileName.length > 8 ? '${fileName.substring(0, 8)}...' : fileName,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                              fontFamily: 'Pretendard',
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
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
                        child: _buildFormattedText(
                          msg.message,
                          const TextStyle(
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
                    // AI 답변 텍스트와 이미지
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 서버 이미지나 파일이 있는 경우 표시
                          if (msg.serverImageUrls.isNotEmpty || msg.serverFileUrls.isNotEmpty || 
                              (msg.localFilePaths != null && msg.localFilePaths!.isNotEmpty))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SizedBox(
                                height: 80,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  children: [
                                    // 서버 이미지들
                                    ...msg.serverImageUrls.map((imageUrl) {
                                      final fullImageUrl = '${ApiConfig.baseUrl.replaceAll('/api', '')}$imageUrl';
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            fullImageUrl,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: loadingProgress.expectedTotalBytes != null
                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                            loadingProgress.expectedTotalBytes!
                                                        : null,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.error,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }),
                                    // 로컬 파일들
                                    ...(msg.localFilePaths ?? []).map((filePath) {
                                      final fileName = filePath.split('/').last;
                                      final fileExtension = fileName.split('.').last.toLowerCase();
                                      
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _getFileIcon(fileExtension),
                                                size: 32,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                fileName.length > 8 ? '${fileName.substring(0, 8)}...' : fileName,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                  fontFamily: 'Pretendard',
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                    // 서버 파일들
                                    ...msg.serverFileUrls.map((fileUrl) {
                                      final fullFileUrl = '${ApiConfig.baseUrl.replaceAll('/api', '')}$fileUrl';
                                      final fileName = fileUrl.split('/').last;
                                      final fileExtension = fileName.split('.').last.toLowerCase();
                                      
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _getFileIcon(fileExtension),
                                                size: 32,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                fileName.length > 8 ? '${fileName.substring(0, 8)}...' : fileName,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                  fontFamily: 'Pretendard',
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          // 텍스트 메시지
                          _buildFormattedText(
                            msg.message,
                            const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.4,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
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

  // 볼드 처리를 위한 텍스트 포맷팅 위젯
  Widget _buildFormattedText(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    
    int lastIndex = 0;
    
    for (final Match match in boldPattern.allMatches(text)) {
      // 볼드 처리되지 않은 텍스트 추가
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }
      
      // 볼드 처리된 텍스트 추가
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      
      lastIndex = match.end;
    }
    
    // 마지막 부분의 일반 텍스트 추가
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }
    
    // 볼드 패턴이 없는 경우 원본 텍스트 반환
    if (spans.isEmpty) {
      return Text(text, style: baseStyle);
    }
    
    return RichText(
      text: TextSpan(children: spans),
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

    // 검색된 세션들 필터링
    final filteredSessions = _getFilteredSessions(sessions);

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: '채팅 검색',
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Past Conversations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_isSearching)
                  Text(
                    '${filteredSessions.length}개 결과',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Pretendard',
                    ),
                  ),
              ],
            ),
          ),
          if (filteredSessions.isEmpty && _isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '검색 결과가 없습니다',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"$_searchQuery"와 관련된 대화를 찾을 수 없습니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            )
          else
            ...filteredSessions.map((session) {
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

  /// 파일 확장자에 따른 아이콘을 반환하는 메서드
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audiotrack;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.videocam;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
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
