import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat/chat_message.dart';
import '../models/chat/chat_bot.dart';
import '../models/chat/chat_session.dart';
import '../services/chat_api_service.dart';

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
      print(
        '서버에서 메시지를 로드합니다. (sessionId: $sessionId, messages.isEmpty: ${session.messages.isEmpty})',
      );
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
  Future<void> sendMessage(
    String content, {
    bool? isWorkflow,
    bool? isResearchActive,
    List<XFile>? images,
  }) async {
    print('=== sendMessage 디버깅 시작 ===');
    print('전송할 메시지: "$content"');
    print('매개변수:');
    print('  isWorkflow: $isWorkflow');
    print('  isResearchActive: $isResearchActive');
    print('  images: ${images?.length ?? 0}개');
    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        print('    이미지 ${i + 1}: ${images[i].path}');
      }
    }
    print('현재 상태:');
    print('  currentUserId: $_currentUserId');
    print('  currentBot: ${_currentBot.name} (ID: ${_currentBot.id})');
    print('  currentSession: ${_currentSession?.id ?? 'null'}');
    print('  isLoading: $_isLoading');

    if (content.trim().isEmpty || _currentUserId == null) {
      print('조건 검사 실패:');
      print('  content.trim().isEmpty: ${content.trim().isEmpty}');
      print('  _currentUserId == null: ${_currentUserId == null}');
      print('=== sendMessage 디버깅 종료 (조건 실패) ===');
      return;
    }

    // 첫 메시지인 경우 새 세션 생성
    if (_currentSession == null) {
      print('새 세션 생성 중...');
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
      print('새 세션 생성 완료:');
      print('  세션 ID: ${_currentSession!.id}');
      print('  characterId: ${_currentSession!.characterId}');
      print('  isWorkflow: ${_currentSession!.isWorkflow}');
      print('  summary: ${_currentSession!.summary}');
    } else {
      print('기존 세션 사용:');
      print('  세션 ID: ${_currentSession!.id}');
      print('  isWorkflow: ${_currentSession!.isWorkflow}');
      print('  기존 메시지 수: ${_currentSession!.messages.length}');
    }

    // 사용자 메시지 추가
    print('사용자 메시지 생성 중...');
    final userMessage = ChatMessage(
      id: 0, // 임시 ID (백엔드에서 생성됨)
      sessionId: _currentSession!.id == 0 ? 0 : _currentSession!.id,
      message: content,
      sender: 'user',
      order: _currentSession!.messages.length,
      localImagePaths: images?.map((img) => img.path).toList(),
    );
    print('사용자 메시지 생성 완료:');
    print('  메시지 ID: ${userMessage.id}');
    print('  세션 ID: ${userMessage.sessionId}');
    print('  메시지: "${userMessage.message}"');
    print('  이미지 경로: ${userMessage.localImagePaths?.length ?? 0}개');
    if (userMessage.localImagePaths != null &&
        userMessage.localImagePaths!.isNotEmpty) {
      for (int i = 0; i < userMessage.localImagePaths!.length; i++) {
        print('    이미지 ${i + 1}: ${userMessage.localImagePaths![i]}');
      }
    }

    // 현재 세션에 사용자 메시지 추가
    print('세션에 사용자 메시지 추가 중...');
    final updatedSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, userMessage],
      time: DateTime.now(),
    );
    _updateSession(updatedSession);
    _currentSession = updatedSession;
    print('사용자 메시지 추가 완료 - 총 메시지 수: ${_currentSession!.messages.length}');
    notifyListeners();

    // 로딩 상태 시작
    print('로딩 상태 시작');
    _isLoading = true;
    notifyListeners();

    try {
      print('API 호출 시작...');
      print('API 호출 매개변수:');
      print(
        '  sessionId: ${_currentSession!.id == 0 ? null : _currentSession!.id}',
      );
      print('  userInput: "$content"');
      print('  userId: $_currentUserId');
      print(
        '  characterId: ${ChatSession.getCharacterIdFromBotId(_currentBot.id)}',
      );
      print('  isWorkflow: ${_currentSession!.isWorkflow}');
      print('  isResearchActive: ${isResearchActive ?? false}');
      print('  images: ${images?.length ?? 0}개');

      final response = await _chatApiService.sendMessage(
        sessionId: _currentSession!.id == 0 ? null : _currentSession!.id,
        userInput: content,
        userId: _currentUserId!,
        characterId: ChatSession.getCharacterIdFromBotId(_currentBot.id),
        isWorkflow: _currentSession!.isWorkflow,
        isResearchActive: isResearchActive ?? false,
        images: images,
      );

      print('API 호출 성공!');
      print('응답 데이터:');
      print('  응답 타입: ${response.runtimeType}');
      print('  응답 키: ${response.keys.toList()}');
      if (response.containsKey('session_id')) {
        print('  session_id: ${response['session_id']}');
      }
      if (response.containsKey('is_workflow')) {
        print('  is_workflow: ${response['is_workflow']}');
      }
      if (response.containsKey('response')) {
        print('  response 타입: ${response['response'].runtimeType}');
        if (response['response'] is List) {
          print('  response 길이: ${response['response'].length}');
          for (int i = 0; i < response['response'].length; i++) {
            print('    response[$i]: "${response['response'][i]}"');
          }
        } else {
          print('  response: "${response['response']}"');
        }
      }
      // 워크플로우 응답 저장
      print('워크플로우 응답 처리 중...');
      print('  response[\'is_workflow\']: ${response['is_workflow']}');
      print(
        '  response[\'response\'] is List: ${response['response'] is List}',
      );
      if (response['response'] is List) {
        print(
          '  response[\'response\'].length: ${response['response'].length}',
        );
      }

      if (response['is_workflow'] == true && response['response'] is List) {
        _workflowResponse = List<String>.from(response['response']);
        print('워크플로우 응답 저장됨 - 길이: ${_workflowResponse!.length}');
      } else {
        // 워크플로우가 끝나면 workflowResponse를 null로 설정하여 일반 채팅으로 전환
        _workflowResponse = null;
        print('워크플로우 응답이 아님 - _workflowResponse를 null로 설정 (일반 채팅으로 전환)');
      }
      // 새 세션이 생성된 경우 세션 ID와 isWorkflow 업데이트
      print('세션 업데이트 처리 중...');
      print('  현재 세션 ID: ${_currentSession!.id}');
      print('  response[\'session_id\']: ${response['session_id']}');

      if (_currentSession!.id == 0 && response['session_id'] != null) {
        final newSessionId = response['session_id'];
        final newIsWorkflow = response['is_workflow'] ?? false;

        print('새 세션 ID 할당:');
        print('  이전 세션 ID: ${_currentSession!.id}');
        print('  새 세션 ID: $newSessionId');
        print('  새 isWorkflow: $newIsWorkflow');

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
        print('세션 목록 업데이트 완료');
      } else if (_currentSession!.id > 0) {
        // 기존 세션의 경우 isWorkflow 값 업데이트
        final newIsWorkflow =
            response['is_workflow'] ?? _currentSession!.isWorkflow;
        print('기존 세션 isWorkflow 업데이트:');
        print('  이전 isWorkflow: ${_currentSession!.isWorkflow}');
        print('  새 isWorkflow: $newIsWorkflow');

        if (newIsWorkflow != _currentSession!.isWorkflow) {
          final updatedSessionWithWorkflow = _currentSession!.copyWith(
            isWorkflow: newIsWorkflow,
            time: DateTime.now(),
          );
          _currentSession = updatedSessionWithWorkflow;
          _updateSession(updatedSessionWithWorkflow);
          print('isWorkflow 업데이트 완료');
        } else {
          print('isWorkflow 변경 없음');
        }
      }

      // 봇 응답 메시지 추가
      print('봇 응답 메시지 생성 중...');
      final botMessage = ChatMessage(
        id: 0,
        sessionId: _currentSession!.id,
        message: response['response'][0],
        sender: 'model',
        order: _currentSession!.messages.length,
      );
      print('봇 응답 메시지 생성 완료:');
      print('  메시지 ID: ${botMessage.id}');
      print('  세션 ID: ${botMessage.sessionId}');
      print('  메시지: "${botMessage.message}"');
      print('  순서: ${botMessage.order}');

      // 현재 세션에 봇 응답 추가
      print('세션에 봇 응답 추가 중...');
      final updatedSessionWithResponse = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, botMessage],
        time: DateTime.now(),
      );
      _updateSession(updatedSessionWithResponse);
      _currentSession = updatedSessionWithResponse;
      print('봇 응답 추가 완료 - 총 메시지 수: ${_currentSession!.messages.length}');

      // 실제 대화가 이루어진 후에만 세션을 맨 위로 이동
      print('세션을 맨 위로 이동 중...');
      _moveSessionToTop(_currentSession!);
      print('세션 이동 완료');
    } catch (e) {
      print('=== sendMessage 에러 발생 ===');
      print('에러 타입: ${e.runtimeType}');
      print('에러 메시지: $e');
      print('에러 스택 트레이스:');
      print(e);

      // 에러 발생 시 에러 메시지 추가
      print('에러 메시지 생성 중...');
      final errorMessage = ChatMessage(
        id: 0, // 임시 ID (백엔드에서 생성됨)
        sessionId: _currentSession!.id == 0 ? 0 : _currentSession!.id,
        message: 'Error: ${e.toString()}',
        sender: 'model',
        order: _currentSession!.messages.length,
      );
      print('에러 메시지 생성 완료: "${errorMessage.message}"');

      final updatedSessionWithError = _currentSession!.copyWith(
        messages: [..._currentSession!.messages, errorMessage],
        time: DateTime.now(),
      );
      _updateSession(updatedSessionWithError);
      _currentSession = updatedSessionWithError;
      print('에러 메시지 추가 완료');
    } finally {
      // 로딩 상태 종료
      print('로딩 상태 종료');
      _isLoading = false;
      notifyListeners();
      print('=== sendMessage 디버깅 완료 ===');
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
