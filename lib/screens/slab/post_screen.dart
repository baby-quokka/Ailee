import 'package:flutter/material.dart';
import '../../screens/home_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeState = context.findAncestorStateOfType<HomeScreenState>();
      homeState?.setBottomNavOffset(0.0, immediate: true);
    });
  }

  void _showBottomNavBar() {
    final homeState = context.findAncestorStateOfType<HomeScreenState>();
    homeState?.setBottomNavOffset(1.0, immediate: true);
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final List<Map<String, String>> dummyComments = [
      {'user': 'kevin0918k', 'content': '화이팅!!', 'time': '7시간 전'},
      {'user': 'mingyun7383', 'content': '힘내요', 'time': '13시간 전'},
      {'user': post['username'], 'content': '넹', 'time': '8시간 전'},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _showBottomNavBar();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            post['time'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(60, 32),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('팔로우'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['content'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (post['image'] != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post['image'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 액션 아이콘
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite_border, size: 22),
                    const SizedBox(width: 8),
                    Text('${post['likes']}'),
                    const SizedBox(width: 16),
                    Icon(Icons.mode_comment_outlined, size: 22),
                    const SizedBox(width: 8),
                    Text('${post['comments']}'),
                    const SizedBox(width: 16),
                    Icon(Icons.share_outlined, size: 22),
                    const SizedBox(width: 8),
                    Text('${post['shares']}'),
                  ],
                ),
              ),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '댓글',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // 댓글 리스트
              ...dummyComments.map(
                (c) => Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        c['user']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(c['content']!),
                      trailing: Text(
                        c['time']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                ),
              ),
              // 댓글 입력창은 body에서 제거
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '댓글을 입력하세요...',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.send), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
