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

  // HTTP 클라이언트 - 연결 관리를 위해 수정
  http.Client? _client;

  // HTTP 클라이언트 초기화
  http.Client get _getClient {
    _client ??= http.Client();
    return _client!;
  }

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

  // GET 요청 헬퍼 (재시도 로직 포함)
  Future<T> _get<T>(String endpoint) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await _getClient
            .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
            .timeout(ApiConfig.timeout);

        _handleError(response);
        return json.decode(response.body) as T;
      } catch (e) {
        retryCount++;

        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));

            // 클라이언트 재생성
            _client?.close();
            _client = null;
            continue;
          }
        }

        if (e is ApiException) rethrow;
        throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
      }
    }

    throw ApiException('최대 재시도 횟수를 초과했습니다.', 0);
  }

  // POST 요청 헬퍼 (재시도 로직 포함)
  Future<T> _post<T>(String endpoint, Map<String, dynamic> data) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await _getClient
            .post(
              Uri.parse('${ApiConfig.baseUrl}$endpoint'),
              headers: _headers,
              body: json.encode(data),
            )
            .timeout(ApiConfig.timeout);

        _handleError(response);
        return json.decode(response.body) as T;
      } catch (e) {
        retryCount++;

        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));

            // 클라이언트 재생성
            _client?.close();
            _client = null;
            continue;
          }
        }

        if (e is ApiException) rethrow;
        throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
      }
    }

    throw ApiException('최대 재시도 횟수를 초과했습니다.', 0);
  }

  // 서버 연결 상태 확인
  Future<bool> checkServerConnection() async {
    try {
      final response = await _getClient
          .get(Uri.parse('${ApiConfig.baseUrl}/user/1'), headers: _headers)
          .timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
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
      'session_id': response['session_id'],
      'is_workflow': response['is_workflow'] ?? false,
      'is_fa': response['is_fa'] ?? false,
    };
  }

  // 연결 해제
  void dispose() {
    _client?.close();
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
