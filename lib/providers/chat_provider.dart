import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';
import '../models/chat_room.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';

/// 채팅 관련 상태를 관리하는 Provider 클래스
class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  final NotificationService _notificationService = NotificationService();
  final List<ChatRoom> _chatRooms = []; // 모든 채팅방 목록
  ChatBot _currentBot = ChatBot.bots[0]; // 현재 선택된 챗봇
  ChatRoom? _currentRoom; // 현재 열린 채팅방
  bool _isLoading = false; // 메시지 전송 중 여부
  VoidCallback? _notificationCallback; // 알림 탭 시 호출될 콜백

  ChatProvider({required ChatService chatService}) : _chatService = chatService;

  // Getter 메서드들
  List<ChatRoom> get chatRooms => _chatRooms;
  ChatBot get currentBot => _currentBot;
  ChatRoom? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;

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
  }

  /// 메시지를 전송하고 응답을 받는 메서드
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // 첫 메시지인 경우 새 채팅방 생성
    if (_currentRoom == null) {
      _currentRoom = ChatRoom(
        id: const Uuid().v4(), // 고유 ID 생성
        title:
            content.length > 30
                ? '${content.substring(0, 30)}...'
                : content, // 첫 메시지로 제목 설정
        bot: _currentBot,
        messages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _chatRooms.add(_currentRoom!);
    }

    // 사용자 메시지 추가
    final userMessage = ChatMessage(
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
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
      // ChatGPT API에 메시지 전송
      final response = await _chatService.sendMessage(content, _currentBot);

      // 봇 응답 메시지 추가
      final botMessage = ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // 현재 채팅방에 봇 응답 추가
      final updatedRoomWithResponse = _currentRoom!.copyWith(
        messages: [..._currentRoom!.messages, botMessage],
        updatedAt: DateTime.now(),
      );
      _updateRoom(updatedRoomWithResponse);
      _currentRoom = updatedRoomWithResponse;
    } catch (e) {
      // 에러 발생 시 에러 메시지 추가
      final errorMessage = ChatMessage(
        content: 'Error: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
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

  /// 특정 주제로 대화를 시작하는 메서드
  Future<void> startTopicConversation(ChatBot bot, String topic, String initialMessage) async {
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
      payload: {
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
          
          startConversationFromNotification(
            bot: bot,
            message: '요즘 힘든일이 있어.',
          );
        }
      }
    } catch (e) {
      print('알림 페이로드 처리 중 오류: $e');
    }
  }
}
