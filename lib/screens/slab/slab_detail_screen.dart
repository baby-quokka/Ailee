import 'package:ailee/screens/slab/create_post_screen.dart';
import 'package:flutter/material.dart';
import 'post_screen.dart';
import '../../screens/home_screen.dart';
import 'package:ailee/widgets/post_list.dart';

const List<List<Color>> workflowGradients = [
  [Color(0xFF36D1C4), Color(0xFF1E90FF)],
  [Color(0xFFFFE53B), Color(0xFFFF2525)],
  [Color(0xFF43E97B), Color(0xFF38F9D7)],
  [Color(0xFFFF5F6D), Color(0xFFFFC371)],
  [Color(0xFF8E2DE2), Color(0xFFFD6E6A)],
];

class SlabDetailScreen extends StatefulWidget {
  final String slabName;
  final List<Map<String, dynamic>> allPosts;
  final VoidCallback onBack;

  const SlabDetailScreen({
    super.key,
    required this.slabName,
    required this.allPosts,
    required this.onBack,
  });

  @override
  State<SlabDetailScreen> createState() => _SlabDetailScreenState();
}

class _SlabDetailScreenState extends State<SlabDetailScreen> {
  final TextEditingController _postController = TextEditingController();
  late final ScrollController _scrollController;
  double _lastOffset = 0;
  double _bottomNavOffset = 1.0;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeState = context.findAncestorStateOfType<HomeScreenState>();
      homeState?.setBottomNavOffset(1.0, immediate: true);
    });
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final homeState = context.findAncestorStateOfType<HomeScreenState>();
    if (homeState == null) return;
    double delta = offset - _lastOffset;
    _bottomNavOffset -= delta / 80.0; // 80px 스크롤에 완전히 사라지도록
    _bottomNavOffset = _bottomNavOffset.clamp(0.0, 1.0);
    homeState.setBottomNavOffset(_bottomNavOffset);

    // FAB는 네비게이션바가 완전히 사라질 때만 사라지게, 올라올 때는 바로 나타나게
    if (_bottomNavOffset == 0.0 && _showFab) {
      setState(() {
        _showFab = false;
      });
    } else if (_bottomNavOffset > 0.0 && !_showFab) {
      setState(() {
        _showFab = true;
      });
    }
    _lastOffset = offset;
  }

  void _handleBack() {
    final homeState = context.findAncestorStateOfType<HomeScreenState>();
    homeState?.setBottomNavOffset(1.0, immediate: true);
    widget.onBack();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts =
        widget.allPosts.where((p) => p['slab'] == widget.slabName).toList();
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false; // 기본 뒤로가기 동작을 막고 onBack 콜백만 실행
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.slabName),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
          // TODO: 나중에 슬랩 구독 버튼 추가 (구독 되어있으면 체크표시)
          actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
          surfaceTintColor: Colors.white, // 앱바가 스크롤 시에도 흰색 유지
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey[500]!, height: 0.5),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: PostListWidget(
                posts: posts,
                workflowGradients: workflowGradients,
                showSlabName: false,
                scrollController: _scrollController,
                showFab: _showFab,
                onFabTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              CreatePostScreen(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        final tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                onPostTap: (post) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              PostDetailScreen(post: post),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        final tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
