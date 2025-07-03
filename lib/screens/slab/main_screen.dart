import 'package:flutter/material.dart';
import 'community_screen.dart';
import 'slab_info_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 탭 뷰 라우팅 -> 바텀네비게이션바 유지
    return Navigator(
      onGenerateRoute: (settings) {
        Widget page;
        // 상세화면 등 추가 라우트가 있으면 여기에 분기
        // 예: if (settings.name == '/detail') { ... }
        page = const _MainTabView();
        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}

class _MainTabView extends StatefulWidget {
  const _MainTabView();

  @override
  State<_MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<_MainTabView> {
  int _selectedIndex = 0;
  bool _showSubscribeLabel = false;
  final PageController _pageController = PageController();

  void _onTabTap(int index) {
    if (_selectedIndex == index) {
      setState(() {
        _showSubscribeLabel = !_showSubscribeLabel;
      });
    } else {
      setState(() {
        _selectedIndex = index;
        _showSubscribeLabel = false;
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabButton('커뮤니티', 0),
            const SizedBox(width: 24),
            _buildTabButton('검색', 1),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[500]!, height: 0.5),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged:
            (idx) => setState(() {
              _selectedIndex = idx;
              _showSubscribeLabel = false;
            }),
        children: [
          CommunityScreen(showSubscribeLabel: _showSubscribeLabel),
          SlabInfoScreen(),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isSelected ? Colors.black : Colors.grey[400],
            ),
          ),
          if (isSelected && index == 0 && _showSubscribeLabel)
            const Text(
              '구독',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
