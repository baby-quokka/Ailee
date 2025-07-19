import 'package:ailee/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'post_screen.dart';
import 'create_post_screen.dart';
import 'package:ailee/widgets/post_list.dart';
import 'slab_detail_screen.dart';
import 'package:ailee/providers/slab_provider.dart';

const List<List<Color>> workflowGradients = [
  [Color(0xFF36D1C4), Color(0xFF1E90FF)],
  [Color(0xFFFFE53B), Color(0xFFFF2525)],
  [Color(0xFF43E97B), Color(0xFF38F9D7)],
  [Color(0xFFFF5F6D), Color(0xFFFFC371)],
  [Color(0xFF8E2DE2), Color(0xFFFD6E6A)],
];

class CommunityScreen extends StatefulWidget {
  final bool showSubscribeLabel;
  const CommunityScreen({super.key, required this.showSubscribeLabel});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late final ScrollController _scrollController;
  double _lastOffset = 0;
  double _bottomNavOffset = 1.0;
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // 포스트 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SlabProvider>().loadAllPosts();
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

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SlabProvider>(
      builder: (context, slabProvider, child) {
        // 구독 라벨 표시 여부에 따라 포스트 필터링
        List<Map<String, dynamic>> posts;

        if (widget.showSubscribeLabel) {
          // 구독한 슬랩의 포스트만 표시 (임시로 '자유', '심리' 슬랩만)
          posts = slabProvider.getSubscribedPosts(['자유', '심리']);
        } else {
          // 전체 포스트 표시
          posts = slabProvider.allPosts;
        }

        return Scaffold(
          body: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.idle) {
                final homeState =
                    context.findAncestorStateOfType<HomeScreenState>();
                if (homeState == null) return false;
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (_bottomNavOffset < 0.5) {
                    homeState.setBottomNavOffset(0.0);
                  } else {
                    homeState.setBottomNavOffset(1.0);
                  }
                });
              }
              return false;
            },
            child:
                slabProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : PostListWidget(
                      posts: posts,
                      workflowGradients: workflowGradients,
                      showSlabName: true,
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
                        final homeState =
                            context.findAncestorStateOfType<HomeScreenState>();
                        homeState?.setBottomNavOffset(0.0, immediate: true);
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
                      onSlabNameTap: (slabName) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SlabDetailScreen(
                                      slabName: slabName,
                                      allPosts: slabProvider.allPosts,
                                      onBack: () => Navigator.of(context).pop(),
                                    ),
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
        );
      },
    );
  }
}
