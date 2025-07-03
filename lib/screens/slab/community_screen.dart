import 'package:ailee/screens/home_screen.dart';
import 'package:ailee/screens/slab/slab_detail_screen.dart';
import 'package:flutter/material.dart';
import 'post_screen.dart';
import 'dummy_post.dart';
import 'create_post_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
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

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildPostList(List<Map<String, dynamic>> posts) {
    return posts.isEmpty
        ? const Center(child: Text('포스트가 없습니다.'))
        : ListView.separated(
          controller: _scrollController,
          itemCount: posts.length,
          separatorBuilder:
              (context, index) => Divider(height: 1, color: Colors.grey[200]),
          itemBuilder: (context, index) {
            final post = posts[index];
            return InkWell(
              onTap: () {
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
                      const begin = Offset(1.0, 0.0); // 오른쪽에서 시작
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
                      child: Icon(Icons.person, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                          ) => SlabDetailScreen(
                                            slabName: post['slab'],
                                            allPosts: dummyPosts,
                                            onBack:
                                                () =>
                                                    Navigator.of(context).pop(),
                                          ),
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
                                child: Text(
                                  '» ${post['slab']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    post['image'],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              height: 180,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(Icons.broken_image),
                                              ),
                                            ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                  const SizedBox(width: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.mode_comment_outlined,
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
                                  const SizedBox(width: 10),
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
                                  const SizedBox(width: 10),
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
        );
  }

  @override
  Widget build(BuildContext context) {
    // 구독 라벨 표시 여부에 따라 자유 슬랩 포스트만 표시 - TODO: 추후 수정 예정
    // 구독 슬랩 목록을 서버에서 받아온 후 -> allPosts.where((p) => mySubscribedSlabs.contains(p['slab'])).toList()
    final posts =
        widget.showSubscribeLabel
            ? dummyPosts.where((p) => p['slab'] == '자유').toList()
            : dummyPosts;
    return Scaffold(
      body: _buildPostList(posts),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
