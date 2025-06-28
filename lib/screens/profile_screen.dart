import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_overlay_widget.dart';
import '../widgets/profile_info_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 선택된 봇 인덱스
  int selectedBotIndex = 0;

  // TODO: 봇별 사용자 설명 예시

  bool showLogin = true;

  // 로그인 폼 컨트롤러
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;
  bool _rememberMe = false; // 자동 로그인 체크박스 상태

  // 회원가입 폼 컨트롤러
  final _signupFormKey = GlobalKey<FormState>();
  final _signupEmailController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();
  bool _signupObscurePassword = true;
  bool _signupObscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 팔로잉/팔로워 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isLoggedIn) {
        authProvider.loadFollowersList();
        authProvider.loadFollowingList();
      }
    });
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupEmailController.dispose();
    _signupNameController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (_loginFormKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
        rememberMe: _rememberMe,
      );
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    }
  }

  Future<void> _signup(BuildContext context) async {
    if (_signupFormKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signup(
        _signupEmailController.text.trim(),
        _signupNameController.text.trim(),
        _signupPasswordController.text,
      );
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }

  void _showFollowers() {
    final authProvider = context.read<AuthProvider>();
    authProvider.loadFollowersList();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('팔로워'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoadingFollowers) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('팔로워 목록을 불러오는 중...'),
                    ],
                  ),
                );
              }
              
              final followers = authProvider.followersList;
              
              if (followers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        '팔로워가 없습니다',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '다른 사용자들이 당신을 팔로우하면\n여기에 표시됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: followers.length,
                itemBuilder: (context, index) {
                  final user = followers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('@${user.email.split('@')[0]}'),
                    trailing: OutlinedButton(
                      onPressed: () {
                        // 팔로우/언팔로우 기능 (나중에 구현)
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        '팔로우',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFollowing() {
    final authProvider = context.read<AuthProvider>();
    authProvider.loadFollowingList();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('팔로잉'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoadingFollowing) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('팔로잉 목록을 불러오는 중...'),
                    ],
                  ),
                );
              }
              
              final following = authProvider.followingList;
              
              if (following.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        '팔로잉이 없습니다',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '다른 사용자들을 팔로우하면\n여기에 표시됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: following.length,
                itemBuilder: (context, index) {
                  final user = following[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('@${user.email.split('@')[0]}'),
                    trailing: OutlinedButton(
                      onPressed: () {
                        // 언팔로우 기능 (나중에 구현)
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        '언팔로우',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        final isLoggedIn = authProvider.isLoggedIn;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white, 
            elevation: 0,
            actions: [
              if (isLoggedIn)
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () => _showLogoutDialog(context),
                  tooltip: '로그아웃',
                ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: ProfileInfoWidget(
                  currentUser: currentUser,
                  selectedBotIndex: selectedBotIndex,
                  onBotChanged: (idx) => setState(() => selectedBotIndex = idx),
                  onFollowersTap: _showFollowers,
                  onFollowingTap: _showFollowing,
                  followersCount: authProvider.followersList.length,
                  followingCount: authProvider.followingList.length,
                ),
              ),
              if (!isLoggedIn) ...[
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: AuthOverlayWidget(
                      showLogin: showLogin,
                      onSwitch: (val) => setState(() => showLogin = val),
                      loginFormKey: _loginFormKey,
                      loginEmailController: _loginEmailController,
                      loginPasswordController: _loginPasswordController,
                      loginObscurePassword: _loginObscurePassword,
                      onToggleLoginObscure:
                          () => setState(
                            () =>
                                _loginObscurePassword = !_loginObscurePassword,
                          ),
                      onLogin: () => _login(context),
                      rememberMe: _rememberMe,
                      onRememberMeChanged: (value) => setState(() => _rememberMe = value),
                      signupFormKey: _signupFormKey,
                      signupEmailController: _signupEmailController,
                      signupNameController: _signupNameController,
                      signupPasswordController: _signupPasswordController,
                      signupConfirmPasswordController:
                          _signupConfirmPasswordController,
                      signupObscurePassword: _signupObscurePassword,
                      signupObscureConfirmPassword:
                          _signupObscureConfirmPassword,
                      onToggleSignupObscure:
                          () => setState(
                            () =>
                                _signupObscurePassword =
                                    !_signupObscurePassword,
                          ),
                      onToggleSignupConfirmObscure:
                          () => setState(
                            () =>
                                _signupObscureConfirmPassword =
                                    !_signupObscureConfirmPassword,
                          ),
                      onSignup: () => _signup(context),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
