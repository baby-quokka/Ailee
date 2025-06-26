import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';
import '../models/chat_room.dart';
import '../services/chat_api_service.dart';
import '../services/notification_service.dart';

/// 채팅 관련 상태를 관리하는 Provider 클래스
class ChatProvider with ChangeNotifier {
  final ChatApiService _chatApiService = ChatApiService();
  final NotificationService _notificationService = NotificationService();
  final List<ChatRoom> _chatRooms = []; // 모든 채팅방 목록
  ChatBot _currentBot = ChatBot.bots[0]; // 현재 선택된 챗봇
  ChatRoom? _currentRoom; // 현재 열린 채팅방
  bool _isLoading = false; // 메시지 전송 중 여부
  VoidCallback? _notificationCallback; // 알림 탭 시 호출될 콜백
  int? _currentUserId; // 현재 로그인한 사용자 ID

  // Getter 메서드들
  List<ChatRoom> get chatRooms => _chatRooms;
  ChatBot get currentBot => _currentBot;
  ChatRoom? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;

  /// 사용자 ID 설정
  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    // 사용자 ID가 0이면 로그아웃 상태로 처리
    if (userId == 0) {
      _currentUserId = null;
      _chatRooms.clear();
      _currentRoom = null;
      notifyListeners();
      return;
    }

    _loadUserSessions(); // 사용자 세션 로드
  }

  /// 알림 콜백 설정
  void setNotificationCallback(VoidCallback callback) {
    _notificationCallback = callback;
  }

  /// 현재 챗봇을 변경하는 메서드
  void setCurrentBot(ChatBot bot) {
    if (_currentBot.id != bot.id) {
      _currentBot = bot;
      _currentRoom = null; // 챗봇 변경 시 현재 채팅방 초기화
      notifyListeners();
    }
  }

  /// 새 채팅방을 생성하는 메서드
  void createNewRoom() {
    _currentRoom = null; // 현재 채팅방 초기화
    notifyListeners();
  }

  /// 특정 채팅방을 선택하는 메서드
  void selectRoom(String roomId) {
    final room = _chatRooms.firstWhere((room) => room.id == roomId);
    _currentRoom = room;
    _currentBot = room.bot; // 채팅방의 챗봇으로 현재 챗봇 변경
    notifyListeners();
    
    // 채팅방 선택 시 해당 세션의 메시지 로드
    if (room.messages.isEmpty) {
      loadSessionMessages(roomId);
    }
  }

  /// 사용자의 채팅 세션을 로드하는 메서드
  Future<void> _loadUserSessions() async {
    if (_currentUserId == null) return;

    try {
      final sessions = await _chatApiService.getUserSessions(_currentUserId!);

      // 세션을 ChatRoom으로 변환
      _chatRooms.clear();
      for (final session in sessions) {
        final bot = ChatBot.bots.firstWhere(
          (bot) => bot.id == _getBotIdFromCharacterId(session.characterId),
          orElse: () => ChatBot.bots[0],
        );

        final room = ChatRoom(
          id: session.id.toString(),
          title: session.summary.isNotEmpty ? session.summary : '새로운 대화',
          bot: bot,
          messages: [], // 메시지는 필요할 때 로드
          createdAt: session.startTime,
          updatedAt: session.time,
        );
        _chatRooms.add(room);
      }

      // 디버깅: 채팅방 정보 출력
      print('=== _loadUserSessions 디버깅 ===');
      print('사용자 ID: $_currentUserId');
      print('서버에서 받은 세션 수: ${sessions.length}');
      print('변환된 채팅방 수: ${_chatRooms.length}');
      print('--- 각 채팅방 정보 ---');
      for (int i = 0; i < _chatRooms.length; i++) {
        final room = _chatRooms[i];
        print('채팅방 ${i + 1}:');
        print('  ID: ${room.id}');
        print('  제목: ${room.title}');
        print('  봇: ${room.bot.name} (${room.bot.id})');
        print('  생성일: ${room.createdAt}');
        print('  수정일: ${room.updatedAt}');
        print('  메시지 수: ${room.messages.length}');
        print('  ---');
      }
      print('=== 디버깅 완료 ===');

      notifyListeners();
    } catch (e) {
      print('세션 로드 오류: $e');
    }
  }

  /// 세션의 메시지를 로드하는 메서드
  Future<void> loadSessionMessages(String sessionId) async {
    try {
      final messages = await _chatApiService.getSessionMessages(
        int.parse(sessionId),
      );

      // ChatMessage를 ChatRoom의 메시지 형식으로 변환
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

      // 현재 채팅방 업데이트
      if (_currentRoom != null && _currentRoom!.id == sessionId) {
        final updatedRoom = _currentRoom!.copyWith(
          messages: chatMessages,
          updatedAt: DateTime.now(),
        );
        _updateRoom(updatedRoom);
        _currentRoom = updatedRoom;
        notifyListeners();
      }
    } catch (e) {
      print('메시지 로드 오류: $e');
    }
  }

  /// 메시지를 전송하고 응답을 받는 메서드
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _currentUserId == null) return;

    // 첫 메시지인 경우 새 채팅방 생성
    if (_currentRoom == null) {
      _currentRoom = ChatRoom(
        id: const Uuid().v4(), // 임시 ID (백엔드에서 생성됨)
        title: content.length > 30 ? '${content.substring(0, 30)}...' : content,
        bot: _currentBot,
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _chatRooms.add(_currentRoom!);
    }

    // 사용자 메시지 추가
    final userMessage = ChatMessage(
      id: 0, // 임시 ID (백엔드에서 생성됨)
      sessionId: _currentRoom!.id == const Uuid().v4() ? 0 : int.parse(_currentRoom!.id),
      message: content,
      sender: 'user',
      order: _currentRoom!.messages.length,
    );

    // 현재 채팅방에 사용자 메시지 추가
    final updatedRoom = _currentRoom!.copyWith(
      messages: [..._currentRoom!.messages, userMessage],
      updatedAt: DateTime.now(),
    );
    _updateRoom(updatedRoom);
    _currentRoom = updatedRoom;
    notifyListeners();

    // 로딩 상태 시작
    _isLoading = true;
    notifyListeners();

    try {
      // 백엔드 API에 메시지 전송
      final response = await _chatApiService.sendMessage(
        sessionId:
            _currentRoom!.id != const Uuid().v4()
                ? int.parse(_currentRoom!.id)
                : null,
        userInput: content,
        userId: _currentUserId!,
        characterId: _getCharacterIdFromBotId(_currentBot.id),
        isWorkflow: false,
      );

      // 봇 응답 메시지 추가
      final botMessage = ChatMessage(
        id: 0, // 임시 ID (백엔드에서 생성됨)
        sessionId: _currentRoom!.id == const Uuid().v4() ? 0 : int.parse(_currentRoom!.id),
        message: response['response'],
        sender: 'model',
        order: _currentRoom!.messages.length,
      );

      // 현재 채팅방에 봇 응답 추가
      final updatedRoomWithResponse = _currentRoom!.copyWith(
        messages: [..._currentRoom!.messages, botMessage],
        updatedAt: DateTime.now(),
      );
      _updateRoom(updatedRoomWithResponse);
      _currentRoom = updatedRoomWithResponse;

      // 새 세션이 생성된 경우 세션 목록 새로고침
      if (_currentRoom!.id == const Uuid().v4()) {
        await _loadUserSessions();
      }
    } catch (e) {
      // 에러 발생 시 에러 메시지 추가
      final errorMessage = ChatMessage(
        id: 0, // 임시 ID (백엔드에서 생성됨)
        sessionId: _currentRoom!.id == const Uuid().v4() ? 0 : int.parse(_currentRoom!.id),
        message: 'Error: ${e.toString()}',
        sender: 'model',
        order: _currentRoom!.messages.length,
      );
      final updatedRoomWithError = _currentRoom!.copyWith(
        messages: [..._currentRoom!.messages, errorMessage],
        updatedAt: DateTime.now(),
      );
      _updateRoom(updatedRoomWithError);
      _currentRoom = updatedRoomWithError;
    } finally {
      // 로딩 상태 종료
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 채팅방 정보를 업데이트하는 내부 메서드
  void _updateRoom(ChatRoom updatedRoom) {
    final index = _chatRooms.indexWhere((room) => room.id == updatedRoom.id);
    if (index != -1) {
      _chatRooms[index] = updatedRoom;
    }
  }

  /// Bot ID를 Character ID로 변환
  int _getCharacterIdFromBotId(String botId) {
    // 임시 매핑 (실제로는 백엔드의 Character ID와 매핑 필요)
    switch (botId) {
      case 'ailee':
        return 1;
      case 'joon':
        return 2;
      case 'nick':
        return 3;
      case 'chad':
        return 4;
      case 'rin':
        return 5;
      default:
        return 1;
    }
  }

  /// Character ID를 Bot ID로 변환
  String _getBotIdFromCharacterId(int characterId) {
    // 임시 매핑 (실제로는 백엔드의 Character ID와 매핑 필요)
    switch (characterId) {
      case 1:
        return 'ailee';
      case 2:
        return 'joon';
      case 3:
        return 'nick';
      case 4:
        return 'chad';
      case 5:
        return 'rin';
      default:
        return 'ailee';
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

    // 새 채팅방 생성
    _currentRoom = ChatRoom(
      id: const Uuid().v4(),
      title: topic,
      bot: bot,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _chatRooms.add(_currentRoom!);
    notifyListeners();

    // 즉시 초기 메시지 전송
    await sendMessage(initialMessage);
  }

  /// 알림을 통해 대화 시작
  Future<void> startConversationFromNotification({
    required ChatBot bot,
    required String message,
  }) async {
    // 챗봇 변경
    setCurrentBot(bot);

    // 새 채팅방 생성
    _currentRoom = ChatRoom(
      id: const Uuid().v4(),
      title: '체크인',
      bot: bot,
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _chatRooms.add(_currentRoom!);
    notifyListeners();

    // 화면 전환
    if (_notificationCallback != null) {
      _notificationCallback!();

      // 화면 전환 후 메시지 전송
      await Future.delayed(const Duration(seconds: 2));
      await sendMessage('요즘 힘든일이 있어.');
    }
  }

  /// 챗봇 체크인 알림 예약
  Future<void> scheduleBotCheckIn({
    required ChatBot bot,
    required String message,
    required DateTime scheduledDate,
  }) async {
    await _notificationService.scheduleBotCheckIn(
      bot: bot,
      message: message,
      scheduledDate: scheduledDate,
    );
  }

  /// 즉시 테스트 알림 보내기
  Future<void> sendTestNotification() async {
    await _notificationService.showNotification(
      title: '${_currentBot.name}의 체크인',
      body: '요즘 힘든 일 없어?',
      payload:
          {
            'botId': _currentBot.id,
            'botName': _currentBot.name,
            'message': '요즘 힘든 일 없어?',
            'type': 'check_in',
          }.toString(),
    );
  }

  /// 알림 페이로드 처리
  void handleNotificationPayload(String payload) {
    try {
      // 페이로드 파싱: "check_in:botId:botName" 형식
      if (payload.startsWith('check_in:')) {
        final parts = payload.split(':');

        if (parts.length >= 3) {
          final botId = parts[1];
          final bot = ChatBot.bots.firstWhere(
            (b) => b.id == botId,
            orElse: () => ChatBot.bots[0], // 기본값으로 Ailee
          );

          startConversationFromNotification(bot: bot, message: '요즘 힘든일이 있어.');
        }
      }
    } catch (e) {
      print('알림 페이로드 처리 중 오류: $e');
    }
  }
}
