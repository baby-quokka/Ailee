class ApiConfig {
  // 개발 환경
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // API 엔드포인트
  static const String userCreate = '/user/create/';
  static const String userLogin = '/user/login/';
  static const String userProfile = '/user/'; // /user/{user_id}/

  // 채팅 API 엔드포인트
  static const String chatSessions =
      '/chat/users/'; // /chat/users/{user_id}/sessions/
  static const String chatSession =
      '/chat/sessions/'; // /chat/sessions/{session_id}/

  // 헤더 설정
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 타임아웃 설정
  static const Duration timeout = Duration(seconds: 10);
}
