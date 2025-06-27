import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

/// 백엔드 API와 통신하는 채팅 서비스 클래스
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
      String errorMessage = '알 수 없는 오류가 발생했습니다.';

      try {
        // JSON 응답인지 확인
        if (response.headers['content-type']?.contains('application/json') ==
            true) {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['error'] ?? errorData['message'] ?? errorMessage;
        } else {
          // HTML 응답인 경우 (서버 에러 페이지)
          if (response.body.contains('<!DOCTYPE html>') ||
              response.body.contains('<html>')) {
            switch (response.statusCode) {
              case 404:
                errorMessage = '요청한 API 엔드포인트를 찾을 수 없습니다.';
                break;
              case 500:
                errorMessage = '서버 내부 오류가 발생했습니다.';
                break;
              case 401:
                errorMessage = '인증이 필요합니다. 로그인을 다시 시도해주세요.';
                break;
              case 403:
                errorMessage = '접근 권한이 없습니다.';
                break;
              default:
                errorMessage = '서버 오류가 발생했습니다. (${response.statusCode})';
            }
          } else {
            errorMessage = '서버 응답을 처리할 수 없습니다. (${response.statusCode})';
          }
        }
      } catch (e) {
        // JSON 파싱 실패 시
        if (response.body.contains('<!DOCTYPE html>') ||
            response.body.contains('<html>')) {
          errorMessage = '서버에서 HTML 페이지를 반환했습니다. (${response.statusCode})';
        } else {
          errorMessage = '응답을 처리할 수 없습니다. (${response.statusCode})';
        }
      }

      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // GET 요청 헬퍼
  Future<T> _get<T>(String endpoint) async {
    try {
      print('=== API 요청 디버깅 (GET) ===');
      print('URL: ${ApiConfig.baseUrl}$endpoint');
      print('Headers: $_headers');

      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
          .timeout(ApiConfig.timeout);

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print(
        'Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...',
      );
      print('=== 디버깅 완료 (GET) ===');

      _handleError(response);
      return json.decode(response.body) as T;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  // POST 요청 헬퍼
  Future<T> _post<T>(String endpoint, Map<String, dynamic> data) async {
    try {
      print('=== API 요청 디버깅 ===');
      print('URL: ${ApiConfig.baseUrl}$endpoint');
      print('Headers: $_headers');
      print('Data: $data');

      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: json.encode(data),
          )
          .timeout(ApiConfig.timeout);

      print('Response Status: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print(
        'Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...',
      );
      print('=== 디버깅 완료 ===');

      _handleError(response);
      return json.decode(response.body) as T;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  // 서버 연결 상태 확인
  Future<bool> checkServerConnection() async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}/health/'), headers: _headers)
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('서버 연결 확인 실패: $e');
      return false;
    }
  }

  // 유저의 모든 채팅 세션 조회
  Future<List<ChatSession>> getUserSessions(int userId) async {
    final response = await _get<List<dynamic>>(
      '${ApiConfig.chatSessions}$userId/sessions/',
    );
    return response.map((json) => ChatSession.fromJson(json)).toList();
  }

  // 특정 세션의 메시지 조회
  Future<List<ChatMessage>> getSessionMessages(int sessionId) async {
    final response = await _get<List<dynamic>>(
      '${ApiConfig.chatSession}$sessionId/',
    );
    return response.map((json) => ChatMessage.fromJson(json)).toList();
  }

  // 메시지 전송 및 챗봇 답변 받기
  Future<Map<String, dynamic>> sendMessage({
    int? sessionId,
    required String userInput,
    required int userId,
    required int characterId,
    bool isWorkflow = false,
  }) async {
    if (userInput == 'start!') {
      isWorkflow = true;
    }
    final data = <String, dynamic>{
      'user_input': userInput,
      'user_id': userId,
      'character_id': characterId,
      'is_workflow': isWorkflow,
    };

    // 기존 세션이 있으면 session_id 추가
    if (sessionId != null) {
      data['session_id'] = sessionId;
    }

    final response = await _post<Map<String, dynamic>>(
      ApiConfig.chatSession,
      data,
    );

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
