import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import 'package:file_picker/file_picker.dart';
import '../models/chat/chat_session.dart';
import '../models/chat/chat_message.dart';

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
        final parsedResponse = json.decode(response.body) as T;
        return parsedResponse;
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

  // PUT 요청 헬퍼
  Future<Map<String, dynamic>> _put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _getClient
          .put(
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

  // 메시지 수정 API
  Future<void> editMessage({required int? sessionId, required String text, required int order, required bool isResearchActive, required List<XFile>? images}) async {
    final data = {
      'session_id': sessionId,
      'user_input': text,
      'order': order,
      'is_search': isResearchActive,
      'images': images,
    };
    print('=== editMessage 요청 ===');
    print('요청 데이터:');
    print(data);
    try {
      final response = await _put(
        ApiConfig.chatSession,
        data
      );
      print('editMessage 응답:');
      print(response);
    } catch (e) {
      print('editMessage 에러: $e');
      rethrow;
    }
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

    print('getSessionMessages 응답:');
    print(response);
    return response.map((json) => ChatMessage.fromJson(json)).toList();
  }

  // 메시지 전송 및 챗봇 답변 받기
  Future<Map<String, dynamic>> sendMessage({
    int? sessionId,
    int? workflowId,
    required String userInput,
    required int userId,
    required int characterId,
    bool isWorkflow = false,
    bool isResearchActive = false,
    List<XFile>? images,
    List<PlatformFile>? files,
  }) async {
    if (userInput == 'start!') {
      isWorkflow = true;
    }
    
    // multipart/form-data를 사용해서 이미지 파일들을 직접 전송
    if ((images != null && images.isNotEmpty) || (files != null && files.isNotEmpty)) {
      return await _sendMessageWithImages(
        sessionId: sessionId,
        workflowId: workflowId,
        userInput: userInput,
        userId: userId,
        characterId: characterId,
        isWorkflow: isWorkflow,
        isResearchActive: isResearchActive,
        images: images,
        files: files,
      );
    }

    // audios
    
    // 이미지가 없는 경우 기존 방식 사용
    final data = <String, dynamic>{
      'user_input': userInput,
      'user_id': userId,
      'character_id': characterId,
      'is_workflow': isWorkflow,
      'is_search': isResearchActive,
    };

    // 기존 세션이 있으면 session_id 추가
    if (sessionId != null) {
      data['session_id'] = sessionId;
    }
    if (workflowId != null) {
      data['workflow_id'] = workflowId;
    }
    print(data);
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

  // 이미지와 함께 메시지 전송하는 메서드
  Future<Map<String, dynamic>> _sendMessageWithImages({
    int? sessionId,
    int? workflowId,
    required String userInput,
    required int userId,
    required int characterId,
    bool isWorkflow = false,
    bool isResearchActive = false,
    List<XFile>? images,
    List<PlatformFile>? files,
  }) async {
    // 디버깅: 함수 진입 및 파라미터 출력
    print('[_sendMessageWithImages] 호출됨');
    print('  userInput: $userInput');
    print('  userId: $userId, characterId: $characterId');
    print('  isWorkflow: $isWorkflow, isResearchActive: $isResearchActive');
    if (images != null) print('  images: ${images.length}개');
    if (files != null) print('  files: ${files.length}개');
    if (sessionId != null) print('  sessionId: $sessionId');
    if (workflowId != null) print('  workflowId: $workflowId');
    
    
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chatSession}'),
      );

      // 헤더 추가 (Content-Type은 추가하지 않음)
      final filteredHeaders = Map<String, String>.from(_headers)
        ..removeWhere((key, value) => key.toLowerCase() == 'content-type');
      request.headers.addAll(filteredHeaders);

      // 텍스트 필드들 추가
      request.fields['user_input'] = userInput;
      request.fields['user_id'] = userId.toString();
      request.fields['character_id'] = characterId.toString();
      request.fields['is_workflow'] = isWorkflow.toString();
      request.fields['is_search'] = isResearchActive.toString();

      if (sessionId != null) {
        request.fields['session_id'] = sessionId.toString();
      }
      if (workflowId != null) {
        request.fields['workflow_id'] = workflowId.toString();
      }

      // 이미지 파일들 추가
      if (images != null && images.isNotEmpty) {
        final List<XFile> imagesCopy = List<XFile>.from(images);
        final int originalLength = imagesCopy.length;
        for (int i = 0; i < originalLength; i++) {
          final image = imagesCopy[i];
          // 파일 존재 확인
          final file = File(image.path);
          if (!await file.exists()) {
            continue;
          }
          // 파일 크기 확인
          final fileSize = await file.length();
          if (fileSize == 0) {
            continue;
          }
          // 이미지 파일 읽기
          List<int> imageBytes;
          try {
            imageBytes = await image.readAsBytes();
          } catch (e) {
            continue;
          }
          // 바이트 배열 유효성 검사
          if (imageBytes.isEmpty) {
            continue;
          }
          final fileName = image.name;
          final fileExtension = fileName.split('.').isNotEmpty 
              ? fileName.split('.').last.toLowerCase() 
              : 'jpg';
          String contentType;
          switch (fileExtension) {
            case 'jpg':
            case 'jpeg':
              contentType = 'image/jpeg';
              break;
            case 'png':
              contentType = 'image/png';
              break;
            case 'gif':
              contentType = 'image/gif';
              break;
            case 'webp':
              contentType = 'image/webp';
              break;
            default:
              contentType = 'image/jpeg'; // 기본값
          }
          final mediaType = MediaType.parse(contentType);
          request.files.add(
            http.MultipartFile.fromBytes(
              'images',
              imageBytes,
              filename: fileName,
              contentType: mediaType,
            ),
          );
        }
      }
      
      // files가 있으면 파일도 첨부
      if (files != null && files.isNotEmpty) {
        final List<PlatformFile> filesCopy = List<PlatformFile>.from(files);
        for (final file in filesCopy) {
          if (file.path == null) continue;
          final fileObj = File(file.path!);
          if (!await fileObj.exists()) continue;
          final fileBytes = await fileObj.readAsBytes();
          if (fileBytes.isEmpty) continue;
          final fileName = file.name;
          final fileExtension = fileName.split('.').isNotEmpty 
              ? fileName.split('.').last.toLowerCase() 
              : '';
          String contentType;
          switch (fileExtension) {
            case 'pdf':
              contentType = 'application/pdf';
              break;
            case 'txt':
              contentType = 'text/plain';
              break;
            case 'doc':
            case 'docx':
              contentType = 'application/msword';
              break;
            case 'ppt':
            case 'pptx':
              contentType = 'application/vnd.ms-powerpoint';
              break;
            case 'xls':
            case 'xlsx':
              contentType = 'application/vnd.ms-excel';
              break;
            case 'jpg':
            case 'jpeg':
              contentType = 'image/jpeg';
              break;
            case 'png':
              contentType = 'image/png';
              break;
            default:
              contentType = 'application/octet-stream';
          }
          final mediaType = MediaType.parse(contentType);
          request.files.add(
            http.MultipartFile.fromBytes(
              'files',
              fileBytes,
              filename: fileName,
              contentType: mediaType,
            ),
          );
        }
      }
      print('  request.files: ${request.files.length}개');
      for (int i = 0; i < request.files.length; i++) {
        print('    [${i}] ${request.files[i].field} - ${request.files[i].filename}');
      }
      // 업로드할 파일이 없으면 에러
      if (request.files.isEmpty) {
        throw ApiException('처리할 수 있는 유효한 이미지 파일이 없습니다.', 0);
      }

      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      
      final response = await http.Response.fromStream(streamedResponse);
      print('  서버 응답 status: ${response.statusCode}');
      print('  서버 응답 body: ${response.body}');
      // 응답 파싱
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        print('  [파싱 에러] $e');
        throw ApiException('서버 응답을 파싱할 수 없습니다: $e', response.statusCode);
      }
      print('  파싱된 응답: $responseData');
      return {
        'response': responseData['response'],
        'session_id': responseData['session_id'],
        'is_workflow': responseData['is_workflow'] ?? false,
        'is_fa': responseData['is_fa'] ?? false,
      };
    } catch (e) {
      print('[_sendMessageWithImages] 에러: $e');
      if (e is ApiException) rethrow;
      throw ApiException('이미지 업로드 중 오류가 발생했습니다: $e', 0);
    }
  }

  // 특정 세션 삭제
  Future<void> deleteChatSession(int sessionId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/chat/sessions/$sessionId/');
    try {
      final response = await _getClient.delete(url, headers: _headers);
      _handleError(response);
    } catch (e) {
      rethrow;
    }
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