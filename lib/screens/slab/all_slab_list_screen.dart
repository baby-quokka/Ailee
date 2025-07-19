import 'package:ailee/providers/slab_provider.dart';
import 'package:flutter/material.dart';
import 'community_screen.dart';
import 'slab_info_screen.dart';
import 'create_slab_screen.dart';
import 'package:provider/provider.dart';

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
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateSlabScreen()),
              );
            },
          ),
        ],
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(1),
        //   child: Container(color: Colors.grey[500]!, height: 0.5),
        // ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[100]),
              child: const Text('메뉴', style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('전체 슬랩 보기'),
              onTap: () {
                Navigator.pop(context); // drawer 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AllSlabListScreen()),
                );
              },
            ),
          ],
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

class AllSlabListScreen extends StatefulWidget {
  @override
  State<AllSlabListScreen> createState() => _AllSlabListScreenState();
}

class _AllSlabListScreenState extends State<AllSlabListScreen> {
  @override
  void initState() {
    super.initState();
    // 슬랩 목록 자동 로드
    Future.microtask(
      () => Provider.of<SlabProvider>(context, listen: false).loadSlabs(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
        ),
        title: const Text('전체 슬랩 목록'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateSlabScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<SlabProvider>(
        builder: (context, slabProvider, child) {
          final slabs = slabProvider.slabs;
          if (slabs.isEmpty) {
            return const Center(child: Text('슬랩이 없습니다.'));
          }
          return ListView.builder(
            itemCount: slabs.length,
            itemBuilder: (context, index) {
              final slab = slabs[index];
              return ListTile(
                leading:
                    (slab.imoji != null && slab.imoji!.isNotEmpty)
                        ? Text(slab.imoji!, style: TextStyle(fontSize: 24))
                        : Icon(Icons.layers),
                title: Text(slab.name),
                subtitle: Text(slab.description ?? ''),
                onTap: () {
                  // TODO: 슬랩 상세 화면으로 이동
                },
              );
            },
          );
        },
      ),
    );
  }
}
