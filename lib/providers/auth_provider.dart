import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/chat_provider.dart';
import '../models/user.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ChatProvider? _chatProvider;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // 팔로잉/팔로워 관련 상태
  List<User> _followingList = [];
  List<User> _followersList = [];
  bool _isLoadingFollowing = false;
  bool _isLoadingFollowers = false;

  // SharedPreferences 키
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';
  static const String _keyAutoLogin = 'auto_login_enabled';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // 팔로잉/팔로워 getter
  List<User> get followingList => _followingList;
  List<User> get followersList => _followersList;
  bool get isLoadingFollowing => _isLoadingFollowing;
  bool get isLoadingFollowers => _isLoadingFollowers;

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
  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.login(email, password);
      
      // success 키가 있으면 그것을 사용하고, 없으면 사용자 정보가 있으면 성공으로 처리
      final isSuccess = result['success'] == true || result['id'] != null;
      
      if (isSuccess) {
        // user 키가 있으면 user 객체를 사용, 없으면 result 자체를 사용자 정보로 사용
        final userData = result['user'] ?? result;
        _currentUser = User.fromJson(userData);
        
        // 자동 로그인 설정
        if (rememberMe) {
          await setAutoLoginEnabled(true);
          await saveLoginCredentials(email, password);
        } else {
          await setAutoLoginEnabled(false);
          await clearSavedCredentials();
        }

        // ChatProvider에 사용자 ID 설정
        if (_chatProvider != null) {
          _chatProvider!.setCurrentUserId(_currentUser!.id);
        }

        // 채팅 관련 데이터 로드
        await _loadChatData();

        // 팔로잉/팔로워 목록 로드
        await loadFollowingList();
        await loadFollowersList();

        notifyListeners();
        return true;
      } else {
        _error = result['message'] ?? '로그인에 실패했습니다.';
        notifyListeners();
        return false;
      }
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
      
      // 자동 로그인 정보 삭제
      await clearSavedCredentials();

      // ChatProvider에서 사용자 ID 초기화
      if (_chatProvider != null) {
        _chatProvider!.setCurrentUserId(0); // 0은 유효하지 않은 ID로 처리
      }

      // 팔로잉/팔로워 데이터 초기화
      clearFollowingData();

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
      final updatedUser = await _apiService.updateProfile(_currentUser!.id, updateData);
      _currentUser = updatedUser;
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

  // 사용자 팔로우/언팔로우
  Future<bool> followUser(int targetUserId) async {
    if (_currentUser == null) return false;

    try {
      final response = await _apiService.followUser(_currentUser!.id, targetUserId);
      
      // 팔로잉 목록 새로고침
      await loadFollowingList();
      
      return response['success'] ?? false;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '팔로우 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 팔로잉 목록 로드
  Future<void> loadFollowingList() async {
    if (_currentUser == null) return;

    _isLoadingFollowing = true;
    notifyListeners();

    try {
      _followingList = await _apiService.getFollowingList(_currentUser!.id);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = '팔로잉 목록 로드 중 오류가 발생했습니다: $e';
    } finally {
      _isLoadingFollowing = false;
      notifyListeners();
    }
  }

  // 팔로워 목록 로드
  Future<void> loadFollowersList() async {
    if (_currentUser == null) return;

    _isLoadingFollowers = true;
    notifyListeners();

    try {
      _followersList = await _apiService.getFollowersList(_currentUser!.id);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = '팔로워 목록 로드 중 오류가 발생했습니다: $e';
    } finally {
      _isLoadingFollowers = false;
      notifyListeners();
    }
  }

  // 팔로잉/팔로워 목록 초기화
  void clearFollowingData() {
    _followingList.clear();
    _followersList.clear();
    notifyListeners();
  }

  // 자동 로그인 관련 메서드
  Future<bool> isAutoLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoLogin) ?? false;
  }

  Future<void> setAutoLoginEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoLogin, enabled);
  }

  Future<void> saveLoginCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
  }

  Future<Map<String, String>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail);
    final password = prefs.getString(_keyPassword);
    
    if (email != null && password != null) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyAutoLogin, false);
  }

  // 자동 로그인 시도
  Future<bool> tryAutoLogin() async {
    try {
      final isEnabled = await isAutoLoginEnabled();
      if (!isEnabled) {
        return false;
      }

      final credentials = await getSavedCredentials();
      if (credentials == null) {
        return false;
      }

      _isLoading = true;
      notifyListeners();

      final result = await _apiService.login(
        credentials['email']!,
        credentials['password']!,
      );

      // success 키가 있으면 그것을 사용하고, 없으면 사용자 정보가 있으면 성공으로 처리
      final isSuccess = result['success'] == true || result['id'] != null;

      if (isSuccess) {
        _currentUser = User.fromJson(result['user'] ?? result);
        _error = null;
        
        // ChatProvider에 사용자 ID 설정
        if (_chatProvider != null) {
          _chatProvider!.setCurrentUserId(_currentUser!.id);
        }

        // 채팅 관련 데이터 로드
        await _loadChatData();
        
        // 팔로잉/팔로워 목록 로드
        await loadFollowingList();
        await loadFollowersList();
        
        notifyListeners();
        return true;
      } else {
        final errorMsg = result['message'] ?? '자동 로그인에 실패했습니다.';
        _error = errorMsg;
        await clearSavedCredentials(); // 실패 시 저장된 정보 삭제
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '자동 로그인 중 오류가 발생했습니다: $e';
      await clearSavedCredentials(); // 오류 시 저장된 정보 삭제
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 채팅 데이터 로드
  Future<void> _loadChatData() async {
    if (_chatProvider != null) {
      await _chatProvider!.loadSessions();
    }
  }
}
