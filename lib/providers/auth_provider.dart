import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && _token != null;

  // 초기화 - 앱 시작 시 로그인 상태 확인
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final user = await _authService.getCurrentUser();
      final token = await _authService.getToken();

      if (user != null && token != null) {
        _currentUser = user;
        _token = token;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // 로그인
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email, password);
      _currentUser = result['user'] as User;
      _token = result['token'] as String;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 회원가입
  Future<bool> signup(String email, String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signup(email, username, password);
      _currentUser = result['user'] as User;
      _token = result['token'] as String;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 로그아웃
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _currentUser = null;
      _token = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // 비밀번호 변경
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.changePassword(currentPassword, newPassword);
      // 현재 사용자 정보 업데이트
      _currentUser = await _authService.getCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 에러 초기화
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // 내부 메서드들
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
