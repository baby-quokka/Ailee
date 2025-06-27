import 'package:flutter/material.dart';
import '../providers/chat_provider.dart';
import '../models/user.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ChatProvider? _chatProvider;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // ChatProvider 설정 메서드
  void setChatProvider(ChatProvider chatProvider) {
    _chatProvider = chatProvider;
  }

  // 초기화 - 앱 시작 시 로그인 상태 확인
  Future<void> initialize() async {
    // TODO: SharedPreferences에서 저장된 사용자 정보 불러오기
    // 현재는 더미 데이터 사용
    _setLoading(false);
  }

  // 로그인
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _apiService.login(email, password);
      _currentUser = user;
      // TODO: SharedPreferences에 사용자 정보 저장

      // ChatProvider에 사용자 ID 설정
      if (_chatProvider != null) {
        _chatProvider!.setCurrentUserId(user.id);
      }

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '로그인 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 회원가입
  Future<bool> signup(String email, String name, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // 기본값으로 회원가입 (나중에 상세 정보 입력 화면 추가)
      final user = await _apiService.signup(
        email: email,
        password: password,
        name: name,
        mainCharacter: 'Ailee', // 기본값
        country: 'KR', // 기본값
        birthDate: DateTime.now(), // 기본값
        activationTime: 'morning', // 기본값
        iE: 50, // 기본값
        nS: 50, // 기본값
        tF: 50, // 기본값
        pJ: 50, // 기본값
      );

      _currentUser = user;
      // TODO: SharedPreferences에 사용자 정보 저장

      // ChatProvider에 사용자 ID 설정
      if (_chatProvider != null) {
        _chatProvider!.setCurrentUserId(user.id);
      }

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '회원가입 중 오류가 발생했습니다: $e';
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
      _currentUser = null;
      // TODO: SharedPreferences에서 사용자 정보 삭제

      // ChatProvider에서 사용자 ID 초기화
      if (_chatProvider != null) {
        _chatProvider!.setCurrentUserId(0); // 0은 유효하지 않은 ID로 처리
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _error = '로그아웃 중 오류가 발생했습니다: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // 프로필 업데이트
  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _apiService.updateProfile(
        _currentUser!.id,
        updateData,
      );
      _currentUser = updatedUser;
      // TODO: SharedPreferences에 업데이트된 사용자 정보 저장
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '프로필 업데이트 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 프로필 새로고침
  Future<bool> refreshProfile() async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final user = await _apiService.getProfile(_currentUser!.id);
      _currentUser = user;
      // TODO: SharedPreferences에 업데이트된 사용자 정보 저장
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '프로필 새로고침 중 오류가 발생했습니다: $e';
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
