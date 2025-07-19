import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';
import '../models/chat_session.dart';
import '../services/chat_api_service.dart';
import 'package:file_picker/file_picker.dart';

/// 채팅 관련 상태를 관리하는 Provider 클래스
class ChatProvider with ChangeNotifier {
  final ChatApiService _chatApiService = ChatApiService();
  final List<ChatSession> _chatSessions = []; // 모든 채팅 세션 목록
  ChatBot _currentBot = ChatBot.bots[0]; // 현재 선택된 챗봇
  ChatSession? _currentSession; // 현재 열린 채팅 세션
  bool _isLoading = false; // 메시지 전송 중 여부
  int? _currentUserId; // 현재 로그인한 사용자 ID
  List<String>? _workflowResponse;
  bool get isWorkflow => _currentSession?.isWorkflow ?? false;
  List<String>? get workflowResponse => _workflowResponse;

  // Getter 메서드들
  List<ChatSession> get chatSessions => _chatSessions;
  ChatBot get currentBot => _currentBot;
  ChatSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;

  /// 사용자 ID 설정
  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    // 사용자 ID가 0이면 로그아웃 상태로 처리
    if (userId == 0) {
      _currentUserId = null;
      _chatSessions.clear();
      _currentSession = null;
      notifyListeners();
      return;
    }

    _loadUserSessions(); // 사용자 세션 로드
  }

  /// 현재 챗봇을 변경하는 메서드
  void setCurrentBot(ChatBot bot) {
    if (_currentBot.id != bot.id) {
      _currentBot = bot;
      _currentSession = null; // 챗봇 변경 시 현재 세션 초기화
      notifyListeners();
    }
  }

  /// 새 채팅 세션을 생성하는 메서드
  void createNewSession() {
    _currentSession = null; // 현재 세션 초기화
    notifyListeners();
  }

  /// 특정 채팅 세션을 선택하는 메서드
  void selectSession(int sessionId) {
    final session = _chatSessions.firstWhere(
      (session) => session.id == sessionId,
    );
    
    _currentSession = session;
    _currentBot = session.bot ?? _currentBot; // 세션의 챗봇으로 현재 챗봇 변경
    notifyListeners();

    // 세션 선택 시 해당 세션의 메시지 로드
    // 세션 ID가 0인 경우(임시 세션)는 로컬 메시지 사용, 그 외에는 메시지가 없을 때만 서버에서 로드
    if (sessionId == 0) {
    } else if (session.messages.isEmpty) {
      loadSessionMessages(sessionId);
    } else {
    }
  }

  /// 사용자의 채팅 세션을 로드하는 메서드
  Future<void> _loadUserSessions() async {
    if (_currentUserId == null) return;

    try {
      final sessions = await _chatApiService.getUserSessions(_currentUserId!);

      // 세션에 bot 정보 추가
      _chatSessions.clear();
      for (final session in sessions) {
        final bot = ChatBot.bots.firstWhere(
          (bot) =>
              bot.id ==
              ChatSession.getBotIdFromCharacterId(session.characterId),
          orElse: () => ChatBot.bots[0],
        );

        final sessionWithBot = session.copyWith(bot: bot);
        _chatSessions.add(sessionWithBot);
      }

      notifyListeners();
    } catch (e) {
      print('세션 로드 오류: $e');
    }
  }

  /// 사용자의 채팅 세션을 로드하는 public 메서드
  Future<void> loadSessions() async {
    await _loadUserSessions();
  }

  /// 세션의 메시지를 로드하는 메서드
  Future<void> loadSessionMessages(int sessionId) async {
    try {
      final messages = await _chatApiService.getSessionMessages(sessionId);

      // ChatMessage를 ChatSession의 메시지 형식으로 변환
      final chatMessages =
          messages
              .map(
                (msg) => ChatMessage(
                  id: msg.id,
                  sessionId: msg.sessionId,
                  message: msg.message,
                  sender: msg.sender,
                  order: msg.order,
                ),
              )
              .toList();

      // 현재 세션 업데이트
      if (_currentSession != null && _currentSession!.id == sessionId) {
        final updatedSession = _currentSession!.copyWith(
          messages: chatMessages,
          time: DateTime.now(),
        );
        
        _updateSession(updatedSession);
        _currentSession = updatedSession;
        notifyListeners();
      } else {
      }
    } catch (e) {
      print('메시지 로드 오류: $e');
      print('에러 타입: ${e.runtimeType}');
    }
  }

  /// 메시지 전송 및 수정 통합 메서드
  Future<void> sendMessage(String content, {bool? isWorkflow, bool? isResearchActive, List<XFile>? images, List<PlatformFile>? files, bool isEdit = false, int? messageId, int? order}) async {
    if (isEdit && order != null) {
      // 메시지 수정 모드: editMessage 호출
      await _chatApiService.editMessage(
        sessionId: _currentSession!.id == 0 ? null : _currentSession!.id,
        isResearchActive: isResearchActive ?? false,
        images: images,
        text: content,
        order: order,
      );
      // 수정 후 해당 세션의 메시지 전체 재조회
      if (_currentSession != null) {
        await loadSessionMessages(_currentSession!.id);
      }
      return;
    }

    // 첫 메시지인 경우 새 세션 생성
    if (_currentSession == null) {
      _currentSession = ChatSession(
        id: 0, // 임시 ID (백엔드에서 생성됨)
        characterId: ChatSession.getCharacterIdFromBotId(_currentBot.id),
        userId: _currentUserId!,
        summary:
            content.length > 30 ? '${content.substring(0, 30)}...' : content,
        topic: 'None',
        time: DateTime.now(),
        startTime: DateTime.now(),
        isWorkflow: isWorkflow ?? false, // 매개변수로 받은 값 사용
        messages: [],
        bot: _currentBot,
      );
      _chatSessions.add(_currentSession!);
    } else {
    }

    // 사용자 메시지 추가
    final userMessage = ChatMessage(
      id: 0, // 임시 ID (백엔드에서 생성됨)
      sessionId: _currentSession!.id == 0 ? 0 : _currentSession!.id,
      message: content,
      sender: 'user',
      order: _currentSession!.messages.length,
      localImagePaths: images?.map((img) => img.path).toList(),
    );

    // 현재 세션에 사용자 메시지 추가
    final updatedSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, userMessage],
      time: DateTime.now(),
    );
    _updateSession(updatedSession);
    _currentSession = updatedSession;
    notifyListeners();

    // 로딩 상태 시작
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatApiService.sendMessage(
        sessionId: _currentSession!.id == 0 ? null : _currentSession!.id,
        userInput: content,
        userId: _currentUserId!,
        characterId: ChatSession.getCharacterIdFromBotId(_currentBot.id),
        isWorkflow: _currentSession!.isWorkflow,
        isResearchActive: isResearchActive ?? false,
        images: images,
        files: files,
      );
      
      // 워크플로우 응답 저장
      if (response['is_workflow'] == true && response['response'] is List) {
        _workflowResponse = List<String>.from(response['response']);
      } else {
        // 워크플로우가 끝나면 workflowResponse를 null로 설정하여 일반 채팅으로 전환
        _workflowResponse = null;
      }
      // 새 세션이 생성된 경우 세션 ID와 isWorkflow 업데이트
      if (_currentSession!.id == 0 && response['session_id'] != null) {
        final newSessionId = response['session_id'];
        final newIsWorkflow = response['is_workflow'] ?? false;
        
        final updatedSessionWithId = _currentSession!.copyWith(
          id: newSessionId,
          isWorkflow: newIsWorkflow,
          time: DateTime.now(),
        );
        _currentSession = updatedSessionWithId;

        // 세션 목록에서 임시 세션(ID 0)을 제거하고 새로운 세션으로 교체
        _chatSessions.removeWhere((session) => session.id == 0);
        _chatSessions.add(updatedSessionWithId);
      } else if (_currentSession!.id > 0) {
        // 기존 세션의 경우 isWorkflow 값 업데이트
        final newIsWorkflow =
            response['is_workflow'] ?? _currentSession!.isWorkflow;
        
        if (newIsWorkflow != _currentSession!.isWorkflow) {
          final updatedSessionWithWorkflow = _currentSession!.copyWith(
            isWorkflow: newIsWorkflow,
            time: DateTime.now(),
          );
          _currentSession = updatedSessionWithWorkflow;
          _updateSession(updatedSessionWithWorkflow);
        }
      }

      // 봇 응답 메시지 추가
      final botMessage = ChatMessage(
        id: 0,
        sessionId: _currentSession!.id,
        message: response['response'][0],
        sender: 'model',
        order: _currentSession!.messages.length,
      );

      // 현재 세션에 봇 응답 추가
      final updatedSessionWithResponse = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, botMessage],
        time: DateTime.now(),
      );
      _updateSession(updatedSessionWithResponse);
      _currentSession = updatedSessionWithResponse;

      // 실제 대화가 이루어진 후에만 세션을 맨 위로 이동
      _moveSessionToTop(_currentSession!);
    } catch (e) {
      print('=== sendMessage 에러 발생 ===');
      print('에러 타입: ${e.runtimeType}');
      print('에러 메시지: $e');
      print('에러 스택 트레이스:');
      print(e);
      
      // 에러 발생 시 에러 메시지 추가
      final errorMessage = ChatMessage(
        id: 0, // 임시 ID (백엔드에서 생성됨)
        sessionId: _currentSession!.id == 0 ? 0 : _currentSession!.id,
        message: 'Error: ${e.toString()}',
        sender: 'model',
        order: _currentSession!.messages.length,
      );
      
      final updatedSessionWithError = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, errorMessage],
        time: DateTime.now(),
      );
      _updateSession(updatedSessionWithError);
      _currentSession = updatedSessionWithError;
    } finally {
      // 로딩 상태 종료
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 세션 정보를 업데이트하는 내부 메서드
  void _updateSession(ChatSession updatedSession) {
    
    final index = _chatSessions.indexWhere(
      (session) => session.id == updatedSession.id,
    );
    if (index != -1) {
      _chatSessions[index] = updatedSession;
    }
  }

  /// 세션을 목록의 맨 앞으로 이동시키는 메서드
  void _moveSessionToTop(ChatSession session) {
    final index = _chatSessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _chatSessions.removeAt(index);
      _chatSessions.insert(0, session);
    }
  }

  /// 특정 주제로 대화를 시작하는 메서드
  Future<void> startTopicConversation(
    ChatBot bot,
    String topic,
    String initialMessage,
  ) async {
    // 챗봇 변경
    setCurrentBot(bot);

    // 새 세션 생성
    _currentSession = ChatSession(
      id: 0,
      characterId: ChatSession.getCharacterIdFromBotId(bot.id),
      userId: _currentUserId!,
      summary: topic,
      topic: topic,
      time: DateTime.now(),
      startTime: DateTime.now(),
      isWorkflow: false, // 초기값
      messages: [],
      bot: bot,
    );
    _chatSessions.add(_currentSession!);
    notifyListeners();

    // 즉시 초기 메시지 전송
    await sendMessage(initialMessage);
  }

  /// 현재 세션의 isWorkflow 값을 변경하는 메서드
  void setCurrentSessionWorkflow(bool isWorkflow) {
    if (_currentSession != null) {
      final updatedSession = _currentSession!.copyWith(
        isWorkflow: isWorkflow,
        time: DateTime.now(),
      );
      _currentSession = updatedSession;
      _updateSession(updatedSession);
      notifyListeners();
    }
  }

  /// 특정 세션 삭제
  Future<void> deleteSession(int sessionId) async {
    try {
      await _chatApiService.deleteChatSession(sessionId);
      _chatSessions.removeWhere((session) => session.id == sessionId);
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
      }
      notifyListeners();
    } catch (e) {
      print('세션 삭제 오류: $e');
      rethrow;
    }
  }
}
