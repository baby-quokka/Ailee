import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

class ChatApiService {
  static final ChatApiService _instance = ChatApiService._internal();
  factory ChatApiService() => _instance;
  ChatApiService._internal();

  // HTTP 클라이언트
  final http.Client _client = http.Client();

  // 기본 헤더
  Map<String, String> get _headers => {...ApiConfig.defaultHeaders};

  // 에러 처리
  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      final errorData = json.decode(response.body);
      final message =
          errorData['error'] ?? errorData['message'] ?? '알 수 없는 오류가 발생했습니다.';
      throw ApiException(message, response.statusCode);
    }
  }

  // GET 요청 헬퍼
  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
          .timeout(ApiConfig.timeout);

      _handleError(response);
      return json.decode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('chat_api_service, get 네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  // POST 요청 헬퍼
  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(ApiConfig.timeout);

      _handleError(response);
      return json.decode(response.body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  // 유저의 모든 채팅 세션 조회
  Future<List<ChatSession>> getUserSessions(int userId) async {
    final response = await _get('${ApiConfig.chatSessions}$userId/sessions/');
    final List<dynamic> sessionsJson = (response as List<dynamic>);
    return sessionsJson.map((json) => ChatSession.fromJson(json)).toList();
  }

  // 특정 세션의 메시지 조회
  Future<List<ChatMessage>> getSessionMessages(int sessionId) async {
    final response = await _get('${ApiConfig.chatSession}$sessionId/');
    final List<dynamic> messagesJson = (response as List<dynamic>);
    return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
  }

  // 메시지 전송 및 챗봇 답변 받기
  Future<Map<String, dynamic>> sendMessage({
    int? sessionId,
    required String userInput,
    required int userId,
    required int characterId,
    bool isWorkflow = false,
  }) async {
    final data = {
      'user_input': userInput,
      'user_id': userId,
      'character_id': characterId,
      'is_workflow': isWorkflow,
    };

    // 기존 세션이 있으면 session_id 추가
    if (sessionId != null) {
      data['session_id'] = sessionId;
    }

    final response = await _post(ApiConfig.chatSession, data);
    return {
      'response': response['response'],
      'is_fa': response['is_fa'] ?? false,
    };
  }

  // 연결 해제
  void dispose() {
    _client.close();
  }
}

// API 예외 클래스
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
