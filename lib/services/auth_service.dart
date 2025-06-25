import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // 더미 사용자 데이터
  static final List<Map<String, dynamic>> _dummyUsers = [
    {
      'id': '1',
      'email': 'test@example.com',
      'username': 'testuser',
      'password': 'password123',
      'profileImage': null,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    },
    {
      'id': '2',
      'email': 'admin@example.com',
      'username': 'admin',
      'password': 'admin123',
      'profileImage': null,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    },
  ];

  // 로그인
  Future<Map<String, dynamic>> login(String email, String password) async {
    // 더미 데이터에서 사용자 찾기
    final user = _dummyUsers.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.'),
    );

    // User 객체 생성
    final userObj = User.fromJson(user);

    // 더미 토큰 생성
    final token =
        'dummy_token_${userObj.id}_${DateTime.now().millisecondsSinceEpoch}';

    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userObj.toJson()));
    await prefs.setString(_tokenKey, token);

    return {'user': userObj, 'token': token};
  }

  // 회원가입
  Future<Map<String, dynamic>> signup(
    String email,
    String username,
    String password,
  ) async {
    // 이메일 중복 확인
    if (_dummyUsers.any((user) => user['email'] == email)) {
      throw Exception('이미 존재하는 이메일입니다.');
    }

    // 사용자명 중복 확인
    if (_dummyUsers.any((user) => user['username'] == username)) {
      throw Exception('이미 존재하는 사용자명입니다.');
    }

    // 새 사용자 생성
    final newUser = {
      'id': (_dummyUsers.length + 1).toString(),
      'email': email,
      'username': username,
      'password': password,
      'profileImage': null,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // 더미 데이터에 추가
    _dummyUsers.add(newUser);

    // User 객체 생성
    final userObj = User.fromJson(newUser);

    // 더미 토큰 생성
    final token =
        'dummy_token_${userObj.id}_${DateTime.now().millisecondsSinceEpoch}';

    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userObj.toJson()));
    await prefs.setString(_tokenKey, token);

    return {'user': userObj, 'token': token};
  }

  // 로그아웃
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  // 현재 사용자 가져오기
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }

    return null;
  }

  // 토큰 가져오기
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    final token = await getToken();
    return user != null && token != null;
  }

  // 비밀번호 변경 (더미)
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다.');
    }

    // 더미 데이터에서 사용자 찾기
    final userIndex = _dummyUsers.indexWhere(
      (user) => user['id'] == currentUser.id,
    );
    if (userIndex == -1) {
      throw Exception('사용자를 찾을 수 없습니다.');
    }

    // 현재 비밀번호 확인
    if (_dummyUsers[userIndex]['password'] != currentPassword) {
      throw Exception('현재 비밀번호가 올바르지 않습니다.');
    }

    // 비밀번호 변경
    _dummyUsers[userIndex]['password'] = newPassword;
    _dummyUsers[userIndex]['updatedAt'] = DateTime.now().toIso8601String();

    // SharedPreferences 업데이트
    final updatedUser = User.fromJson(_dummyUsers[userIndex]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
  }
}
