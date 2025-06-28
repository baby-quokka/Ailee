import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';
import '../models/chat_session.dart';
import '../services/chat_api_service.dart';

/// 채팅 관련 상태를 관리하는 Provider 클래스
class ChatProvider with ChangeNotifier {
  final ChatApiService _chatApiService = ChatApiService();
  final List<ChatSession> _chatSessions = []; // 모든 채팅 세션 목록
  ChatBot _currentBot = ChatBot.bots[0]; // 현재 선택된 챗봇
  ChatSession? _currentSession; // 현재 열린 채팅 세션
  bool _isLoading = false; // 메시지 전송 중 여부
  int? _currentUserId; // 현재 로그인한 사용자 ID

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
    print('=== selectSession 디버깅 시작 ===');
    print('선택하려는 세션 ID: $sessionId');
    print('현재 세션 목록 수: ${_chatSessions.length}');
    
    final session = _chatSessions.firstWhere(
      (session) => session.id == sessionId,
    );
    
    print('찾은 세션 정보:');
    print('  ID: ${session.id}');
    print('  제목: ${session.displayTitle}');
    print('  메시지 수: ${session.messages.length}');
    print('  isWorkflow: ${session.isWorkflow}');
    
    _currentSession = session;
    _currentBot = session.bot ?? _currentBot; // 세션의 챗봇으로 현재 챗봇 변경
    notifyListeners();

    // 세션 선택 시 해당 세션의 메시지 로드
    // 세션 ID가 0인 경우(임시 세션)는 로컬 메시지 사용, 그 외에는 메시지가 없을 때만 서버에서 로드
    if (sessionId == 0) {
      print('임시 세션(ID: 0)이므로 로컬 메시지를 사용합니다.');
    } else if (session.messages.isEmpty) {
      print('서버에서 메시지를 로드합니다. (sessionId: $sessionId, messages.isEmpty: ${session.messages.isEmpty})');
      loadSessionMessages(sessionId);
    } else {
      print('로컬 메시지를 사용합니다. (메시지 수: ${session.messages.length})');
    }
    
    print('=== selectSession 디버깅 완료 ===');
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

      // 디버깅: 채팅 세션 정보 출력
      // print('=== _loadUserSessions 디버깅 ===');
      // print('사용자 ID: $_currentUserId');
      // print('서버에서 받은 세션 수: ${sessions.length}');
      // print('변환된 세션 수: ${_chatSessions.length}');
      // print('--- 각 세션 정보 ---');
      // for (int i = 0; i < _chatSessions.length; i++) {
      //   final session = _chatSessions[i];
      //   print('세션 ${i + 1}:');
      //   print('  ID: ${session.id}');
      //   print('  제목: ${session.displayTitle}');
      //   print('  봇: ${session.bot?.name} (${session.bot?.id})');
      //   print('  생성일: ${session.startTime}');
      //   print('  수정일: ${session.updatedAt}');
      //   print('  메시지 수: ${session.messages.length}');
      //   print('  ---');
      // }
      // print('=== 디버깅 완료 ===');

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
    print('=== loadSessionMessages 디버깅 시작 ===');
    print('로드하려는 세션 ID: $sessionId');
    print('현재 세션 ID: ${_currentSession?.id}');
    
    try {
      print('API 호출 시작...');
      final messages = await _chatApiService.getSessionMessages(sessionId);
      print('API 호출 성공 - 받은 메시지 수: ${messages.length}');

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

      print('변환된 ChatMessage 수: ${chatMessages.length}');

      // 현재 세션 업데이트
      if (_currentSession != null && _currentSession!.id == sessionId) {
        print('현재 세션 업데이트 중...');
        print('업데이트 전 메시지 수: ${_currentSession!.messages.length}');
        
        final updatedSession = _currentSession!.copyWith(
          messages: chatMessages,
          time: DateTime.now(),
        );
        
        print('업데이트 후 메시지 수: ${updatedSession.messages.length}');
        
        _updateSession(updatedSession);
        _currentSession = updatedSession;
        notifyListeners();
        
        print('세션 업데이트 완료');
      } else {
        print('현재 세션을 찾을 수 없거나 세션 ID가 일치하지 않음');
        print('현재 세션 ID: ${_currentSession?.id}, 요청한 세션 ID: $sessionId');
      }
    } catch (e) {
      print('메시지 로드 오류: $e');
      print('에러 타입: ${e.runtimeType}');
    }
    
    print('=== loadSessionMessages 디버깅 완료 ===');
  }

  /// 메시지를 전송하고 응답을 받는 메서드
  Future<void> sendMessage(String content, {bool? isWorkflow}) async {
    if (content.trim().isEmpty || _currentUserId == null) return;

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
    }

    // 사용자 메시지 추가
    final userMessage = ChatMessage(
      id: 0, // 임시 ID (백엔드에서 생성됨)
      sessionId: _currentSession!.id == 0 ? 0 : _currentSession!.id,
      message: content,
      sender: 'user',
      order: _currentSession!.messages.length,
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
      // 백엔드 API에 메시지 전송 - 현재 세션의 isWorkflow 값 사용
      final response = await _chatApiService.sendMessage(
        sessionId: _currentSession!.id == 0 ? null : _currentSession!.id,
        userInput: content,
        userId: _currentUserId!,
        characterId: ChatSession.getCharacterIdFromBotId(_currentBot.id),
        isWorkflow: _currentSession!.isWorkflow, // 세션에 저장된 값 사용
      );
      
      // 새 세션이 생성된 경우 세션 ID와 isWorkflow 업데이트
      if (_currentSession!.id == 0 && response['session_id'] != null) {
        final newSessionId = response['session_id'];
        final newIsWorkflow = response['is_workflow'] ?? false;

        // 현재 세션의 ID와 isWorkflow를 실제 값으로 업데이트
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
        id: 0, // 임시 ID (백엔드에서 생성됨)
        sessionId: _currentSession!.id,
        message: response['response'],
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
}
