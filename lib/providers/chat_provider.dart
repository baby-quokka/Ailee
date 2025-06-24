import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/chat_bot.dart';
import '../models/chat_room.dart';
import '../services/chat_service.dart';

/// 채팅 관련 상태를 관리하는 Provider 클래스
class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  final List<ChatRoom> _chatRooms = []; // 모든 채팅방 목록
  ChatBot _currentBot = ChatBot.bots[0]; // 현재 선택된 챗봇
  ChatRoom? _currentRoom; // 현재 열린 채팅방
  bool _isLoading = false; // 메시지 전송 중 여부

  ChatProvider({required ChatService chatService}) : _chatService = chatService;

  // Getter 메서드들
  List<ChatRoom> get chatRooms => _chatRooms;
  ChatBot get currentBot => _currentBot;
  ChatRoom? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;

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
}
