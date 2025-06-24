import 'package:ailee/screens/chat_screen.dart';
import 'package:ailee/screens/main_screen.dart';
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

  final List<Widget> _pages = [ChatScreen(), MainScreen(), ProfileScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// 채팅 화면으로 전환하는 메서드
  void switchToChatScreen() {
    setState(() {
      _selectedIndex = 0; // 채팅 화면 인덱스
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Provider.of<ChatProvider>(context, listen: false),
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
          ],
        ),
      ),
    );
  }
}
