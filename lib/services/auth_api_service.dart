import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

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
        if (response.headers['content-type']?.contains('application/json') == true) {
          final errorData = json.decode(response.body);
          errorMessage = errorData['error'] ?? errorData['message'] ?? errorMessage;
        } else {
          // HTML 응답인 경우 (서버 에러 페이지)
          if (response.body.contains('<!DOCTYPE html>') || response.body.contains('<html>')) {
            // HTML에서 에러 메시지 추출 시도
            if (response.body.contains('IntegrityError')) {
              errorMessage = '이미 존재하는 이메일입니다.';
            } else if (response.body.contains('ValidationError')) {
              errorMessage = '입력 데이터가 올바르지 않습니다.';
            } else {
              switch (response.statusCode) {
                case 400:
                  errorMessage = '잘못된 요청입니다.';
                  break;
                case 401:
                  errorMessage = '인증이 필요합니다.';
                  break;
                case 403:
                  errorMessage = '접근 권한이 없습니다.';
                  break;
                case 404:
                  errorMessage = '요청한 리소스를 찾을 수 없습니다.';
                  break;
                case 500:
                  errorMessage = '서버 내부 오류가 발생했습니다.';
                  break;
                default:
                  errorMessage = '서버 오류가 발생했습니다. (${response.statusCode})';
              }
            }
          } else {
            errorMessage = '서버 응답을 처리할 수 없습니다. (${response.statusCode})';
          }
        }
      } catch (e) {
        // JSON 파싱 실패 시
        if (response.body.contains('IntegrityError')) {
          errorMessage = '이미 존재하는 이메일입니다.';
        } else if (response.body.contains('ValidationError')) {
          errorMessage = '입력 데이터가 올바르지 않습니다.';
        } else {
          errorMessage = '서버 응답을 처리할 수 없습니다. (${response.statusCode})';
        }
      }
      
      throw ApiException(errorMessage, response.statusCode);
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
      throw ApiException('네트워크 오류가 발생했습니다: $e', 0);
    }
  }

  // PUT 요청 헬퍼
  Future<Map<String, dynamic>> _put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client
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

  // 회원가입
  Future<User> signup({
    required String email,
    required String password,
    required String name,
    required String mainCharacter,
    required String country,
    required DateTime birthDate,
    required String activationTime,
    required int iE,
    required int nS,
    required int tF,
    required int pJ,
  }) async {
    final userData = {
      'email': email,
      'password': password,
      'name': name,
      'main_character': mainCharacter,
      'country': country,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'activation_time': activationTime,
      'i_e': iE,
      'n_s': nS,
      't_f': tF,
      'p_j': pJ,
    };

    try {
      await _post(ApiConfig.userCreate, userData);
      
      // 회원가입 성공 후 로그인하여 사용자 정보 반환
      final loginResponse = await login(email, password);
      return User.fromJson(loginResponse);
    } catch (e) {
      rethrow;
    }
  }

  // 로그인
  Future<Map<String, dynamic>> login(String email, String password) async {
    final loginData = {'email': email, 'password': password};

    final response = await _post(ApiConfig.userLogin, loginData);
    return response;
  }

  // 프로필 조회
  Future<User> getProfile(int userId) async {
    final response = await _get('${ApiConfig.userProfile}$userId/');
    return User.fromJson(response);
  }

  // 프로필 수정
  Future<User> updateProfile(
    int userId,
    Map<String, dynamic> updateData,
  ) async {
    final response = await _put('${ApiConfig.userProfile}$userId/', updateData);
    return User.fromJson(response);
  }

  // 사용자 팔로우/언팔로우
  Future<Map<String, dynamic>> followUser(int userId, int targetUserId) async {
    final response = await _post('${ApiConfig.userFollow}$targetUserId/follow/', {
      'user_id': userId,
    });
    return response;
  }

  // 팔로잉 목록 조회 (내가 팔로우하는 사람들)
  Future<List<User>> getFollowingList(int userId) async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userFollowing}$userId/following/'), 
               headers: _headers)
          .timeout(ApiConfig.timeout);

      _handleError(response);
      final decodedResponse = json.decode(response.body);
      
      List<dynamic> followingList;
      
      if (decodedResponse is List) {
        // 서버에서 배열을 직접 반환하는 경우
        followingList = decodedResponse;
      } else if (decodedResponse is Map) {
        // 서버에서 Map을 반환하는 경우
        followingList = decodedResponse['following'] ?? [];
      } else {
        return [];
      }
      
      final users = followingList.map((json) => User.fromJson(json)).toList();
      return users;
    } catch (e) {
      rethrow;
    }
  }

  // 팔로워 목록 조회 (나를 팔로우하는 사람들)
  Future<List<User>> getFollowersList(int userId) async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userFollowers}$userId/followers/'), 
               headers: _headers)
          .timeout(ApiConfig.timeout);

      _handleError(response);
      final decodedResponse = json.decode(response.body);
      
      List<dynamic> followersList;
      
      if (decodedResponse is List) {
        // 서버에서 배열을 직접 반환하는 경우
        followersList = decodedResponse;
      } else if (decodedResponse is Map) {
        // 서버에서 Map을 반환하는 경우
        followersList = decodedResponse['followers'] ?? [];
      } else {
        return [];
      }
      
      final users = followersList.map((json) => User.fromJson(json)).toList();
      return users;
    } catch (e) {
      rethrow;
    }
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
