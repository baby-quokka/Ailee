import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'post_screen.dart';
import '../../screens/home_screen.dart';

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
            // 게시글 리스트
            Expanded(
              child:
                  posts.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.forum_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '아직 게시글이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '첫 번째 게시글을 작성해보세요!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                      : NotificationListener<UserScrollNotification>(
                        onNotification: (notification) {
                          if (notification.direction == ScrollDirection.idle) {
                            final homeState =
                                context
                                    .findAncestorStateOfType<HomeScreenState>();
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
                        child: ListView.separated(
                          controller: _scrollController,
                          itemCount: posts.length,
                          separatorBuilder:
                              (context, index) =>
                                  Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => PostDetailScreen(post: post),
                                    transitionsBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      const begin = Offset(
                                        1.0,
                                        0.0,
                                      ); // 오른쪽에서 시작
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
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 16,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[200],
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                post['username'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                post['time'],
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.more_horiz,
                                                size: 18,
                                                color: Colors.grey[600],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post['content'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  height: 1.6,
                                                ),
                                              ),
                                              if (post['image'] != null) ...[
                                                const SizedBox(height: 10),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    post['image'],
                                                    height: 180,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Container(
                                                          height: 180,
                                                          color:
                                                              Colors.grey[200],
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons
                                                                  .broken_image,
                                                            ),
                                                          ),
                                                        ),
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 14),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.favorite_border,
                                                        size: 18,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${post['likes']}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .mode_comment_outlined,
                                                        size: 18,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${post['comments']}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.share_outlined,
                                                        size: 18,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${post['shares']}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Icon(
                                                    Icons.repeat_rounded,
                                                    size: 18,
                                                    color: Colors.grey[600],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
