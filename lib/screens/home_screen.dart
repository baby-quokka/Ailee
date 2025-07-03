import 'package:ailee/screens/chat_screen.dart';
import 'package:ailee/screens/slab/main_screen.dart';
import 'package:ailee/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  double _bottomNavOffset = 1.0; // 1.0: 완전히 보임, 0.0: 완전히 숨김
  Duration _bottomNavDuration = const Duration(milliseconds: 120);

  final List<Widget> _pages = [ChatScreen(), MainScreen(), ProfileScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// 바텀네비게이션바 노출 정도를 조정하는 메서드
  void setBottomNavOffset(double offset, {bool immediate = false}) {
    setState(() {
      if (immediate) {
        _bottomNavDuration = Duration.zero;
      } else {
        _bottomNavDuration = const Duration(milliseconds: 120);
      }
      _bottomNavOffset = offset.clamp(0.0, 1.0);
    });
    if (immediate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _bottomNavDuration = const Duration(milliseconds: 120);
          });
        }
      });
    }
  }

  /// 완전히 숨기기/보이기 위한 헬퍼 (기존 호환)
  void hideBottomNav() => setBottomNavOffset(0.0);
  void showBottomNav() => setBottomNavOffset(1.0);

  /// 채팅 화면으로 전환하는 메서드
  void switchToChatScreen() {
    setState(() {
      _selectedIndex = 0; // 채팅 화면 인덱스
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<ChatProvider>(context, listen: false),
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: SafeArea(
          child: AnimatedContainer(
            duration: _bottomNavDuration,
            height: kBottomNavigationBarHeight * _bottomNavOffset,
            curve: Curves.ease,
            child: Wrap(
              children: [
                Opacity(
                  opacity: _bottomNavOffset,
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    selectedItemColor: Colors.black,
                    unselectedItemColor: Colors.grey[500]!,
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.chat),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
