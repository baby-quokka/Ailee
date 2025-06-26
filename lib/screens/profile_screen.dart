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

  // 회원가입 폼 컨트롤러
  final _signupFormKey = GlobalKey<FormState>();
  final _signupEmailController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();
  bool _signupObscurePassword = true;
  bool _signupObscureConfirmPassword = true;

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

  void _showFollowers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text('팔로워'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('김민수'),
                    subtitle: Text('@minsu_kim'),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('이지은'),
                    subtitle: Text('@jieun_lee'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  void _showFollowing() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text('팔로잉'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('박서연'),
                    subtitle: Text('@seoyeon_park'),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('최준호'),
                    subtitle: Text('@junho_choi'),
                  ),
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('정다은'),
                    subtitle: Text('@daeun_jung'),
                  ),
                ],
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
          appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: ProfileInfoWidget(
                  currentUser: currentUser,
                  selectedBotIndex: selectedBotIndex,
                  onBotChanged: (idx) => setState(() => selectedBotIndex = idx),
                  onFollowersTap: _showFollowers,
                  onFollowingTap: _showFollowing,
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
