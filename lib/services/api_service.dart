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
      final errorData = json.decode(response.body);
      final message =
          errorData['error'] ?? errorData['message'] ?? '알 수 없는 오류가 발생했습니다.';
      throw ApiException(message, response.statusCode);
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
      'gmail': email,
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

    await _post(ApiConfig.userCreate, userData);

    // 회원가입 성공 후 로그인하여 사용자 정보 반환
    return await login(email, password);
  }

  // 로그인
  Future<User> login(String email, String password) async {
    final loginData = {'email': email, 'password': password};

    final response = await _post(ApiConfig.userLogin, loginData);
    return User.fromJson(response);
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
