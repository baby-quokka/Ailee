import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
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
    final session = _chatSessions.firstWhere(
      (session) => session.id == sessionId,
    );
    _currentSession = session;
    _currentBot = session.bot ?? _currentBot; // 세션의 챗봇으로 현재 챗봇 변경
    notifyListeners();

    // 세션 선택 시 해당 세션의 메시지 로드
    if (session.messages.isEmpty) {
      loadSessionMessages(sessionId);
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

      // 디버깅: 채팅 세션 정보 출력
      print('=== _loadUserSessions 디버깅 ===');
      print('사용자 ID: $_currentUserId');
      print('서버에서 받은 세션 수: ${sessions.length}');
      print('변환된 세션 수: ${_chatSessions.length}');
      print('--- 각 세션 정보 ---');
      for (int i = 0; i < _chatSessions.length; i++) {
        final session = _chatSessions[i];
        print('세션 ${i + 1}:');
        print('  ID: ${session.id}');
        print('  제목: ${session.displayTitle}');
        print('  봇: ${session.bot?.name} (${session.bot?.id})');
        print('  생성일: ${session.startTime}');
        print('  수정일: ${session.updatedAt}');
        print('  메시지 수: ${session.messages.length}');
        print('  ---');
      }
      print('=== 디버깅 완료 ===');

      notifyListeners();
    } catch (e) {
      print('세션 로드 오류: $e');
    }
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
      }
    } catch (e) {
      print('메시지 로드 오류: $e');
    }
  }

  /// 메시지를 전송하고 응답을 받는 메서드
  Future<void> sendMessage(String content) async {
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
      // 백엔드 API에 메시지 전송
      final response = await _chatApiService.sendMessage(
        sessionId: _currentSession!.id == 0 ? null : _currentSession!.id,
        userInput: content,
        userId: _currentUserId!,
        characterId: ChatSession.getCharacterIdFromBotId(_currentBot.id),
        isWorkflow: false,
      );

      // 봇 응답 메시지 추가
      final botMessage = ChatMessage(
        id: 0, // 임시 ID (백엔드에서 생성됨)
        sessionId: _currentSession!.id == 0 ? 0 : _currentSession!.id,
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

      // 새 세션이 생성된 경우 세션 목록 새로고침
      if (_currentSession!.id == 0) {
        await _loadUserSessions();
      }
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
      messages: [],
      bot: bot,
    );
    _chatSessions.add(_currentSession!);
    notifyListeners();

    // 즉시 초기 메시지 전송
    await sendMessage(initialMessage);
  }
}
