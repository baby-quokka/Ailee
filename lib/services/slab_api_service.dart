import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/slab/slab.dart';
import '../models/slab/post.dart';

class SlabApiService {
  static final SlabApiService _instance = SlabApiService._internal();
  factory SlabApiService() => _instance;
  SlabApiService._internal();

  http.Client? _client;

  http.Client get _getClient {
    _client ??= http.Client();
    return _client!;
  }

  Map<String, String> get _headers => {...ApiConfig.defaultHeaders};

  void _handleError(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage = '알 수 없는 오류가 발생했습니다.';
      try {
        if (response.headers['content-type']?.contains('application/json') ==
            true) {
          final errorData = json.decode(response.body);
          errorMessage =
              errorData['error'] ?? errorData['message'] ?? errorMessage;
        } else {
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
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final response = await _getClient
            .get(Uri.parse('${ApiConfig.baseUrl}$endpoint'), headers: _headers)
            .timeout(ApiConfig.timeout);

        _handleError(response);
        return json.decode(utf8.decode(response.bodyBytes)) as T;
      } catch (e) {
        retryCount++;
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
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

  // POST 요청 헬퍼
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
        return json.decode(utf8.decode(response.bodyBytes)) as T;
      } catch (e) {
        retryCount++;
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
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
  Future<void> _put(String endpoint, Map<String, dynamic> data) async {
    int retryCount = 0;
    const maxRetries = 3;
    while (retryCount < maxRetries) {
      try {
        final response = await _getClient
            .put(
              Uri.parse('${ApiConfig.baseUrl}$endpoint'),
              headers: _headers,
              body: json.encode(data),
            )
            .timeout(ApiConfig.timeout);
        _handleError(response);
        return;
      } catch (e) {
        retryCount++;
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
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

  // DELETE 요청 헬퍼
  Future<void> _delete(String endpoint) async {
    int retryCount = 0;
    const maxRetries = 3;
    while (retryCount < maxRetries) {
      try {
        final response = await _getClient
            .delete(
              Uri.parse('${ApiConfig.baseUrl}$endpoint'),
              headers: _headers,
            )
            .timeout(ApiConfig.timeout);
        _handleError(response);
        return;
      } catch (e) {
        retryCount++;
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
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

  // 슬랩 목록 가져오기
  Future<List<Slab>> fetchSlabs() async {
    final response = await _get<List<dynamic>>('/slabs/');
    return response.map((json) => Slab.fromJson(json)).toList();
  }

  // 특정 슬랩의 포스트 목록 가져오기
  Future<List<Post>> fetchPosts(int slabId, {bool isTimeOrder = false}) async {
    String endpoint = '/slabs/$slabId/posts/';
    if (isTimeOrder) {
      endpoint += '?is_time_order=true';
    }
    final response = await _get<List<dynamic>>(endpoint);
    return response.map((json) => Post.fromJson(json)).toList();
  }

  // 포스트 상세 정보 가져오기
  Future<Post> fetchPostDetail(int postId) async {
    final response = await _get<Map<String, dynamic>>('/slabs/posts/$postId/');
    return Post.fromJson(response);
  }

  // 포스트 생성
  Future<Post> createPost(
    int slabId,
    int userId,
    String content, {
    String? title,
    bool isWorkflow = false,
  }) async {
    String endpoint = '/slabs/posts/0/';
    if (isWorkflow) {
      endpoint += '?is_workflow=true';
    }
    final data = {
      'slab_id': slabId,
      'user_id': userId,
      'content': content,
      if (title != null) 'title': title,
    };
    final response = await _post<Map<String, dynamic>>(endpoint, data);
    return Post.fromJson(response);
  }

  // 포스트 수정
  Future<void> updatePost(int postId, String content) async {
    final endpoint = '/slabs/posts/$postId/';
    final data = {'content': content};
    await _put(endpoint, data);
  }

  // 포스트 삭제
  Future<void> deletePost(int postId) async {
    final endpoint = '/slabs/posts/$postId/';
    await _delete(endpoint);
  }

  // 슬랩 생성
  Future<Slab> createSlab(
    String name,
    String? description,
    String? emoji,
  ) async {
    final data = {'name': name, 'description': description, 'imoji': emoji};
    final response = await _post<Map<String, dynamic>>('/slabs/', data);
    return Slab.fromJson(response);
  }

  // 슬랩 수정
  Future<Slab> editSlab(
    int slabId, {
    String? name,
    String? description,
    String? emoji,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (emoji != null) data['imoji'] = emoji;
    final endpoint = '/slabs/$slabId/';
    final response = await _putWithResponse<Map<String, dynamic>>(
      endpoint,
      data,
    );
    return Slab.fromJson(response);
  }

  // 슬랩 삭제
  Future<void> removeSlab(int slabId) async {
    final endpoint = '/slabs/$slabId/';
    await _delete(endpoint);
  }

  // PUT 요청 헬퍼(응답 반환)
  Future<T> _putWithResponse<T>(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    while (retryCount < maxRetries) {
      try {
        final response = await _getClient
            .put(
              Uri.parse('${ApiConfig.baseUrl}$endpoint'),
              headers: _headers,
              body: json.encode(data),
            )
            .timeout(ApiConfig.timeout);
        _handleError(response);
        return json.decode(utf8.decode(response.bodyBytes)) as T;
      } catch (e) {
        retryCount++;
        if (e.toString().contains('Connection closed') ||
            e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(seconds: retryCount * 2));
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
