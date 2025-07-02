import 'package:flutter/material.dart';
import 'post_screen.dart';

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

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts =
        widget.allPosts.where((p) => p['slab'] == widget.slabName).toList();
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();
        return false; // 기본 뒤로가기 동작을 막고 onBack 콜백만 실행
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.slabName),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
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
                      : ListView.separated(
                        itemCount: posts.length,
                        separatorBuilder:
                            (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              post['username'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(post['content']),
                            trailing: Text(
                              post['time'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(post: post),
                                ),
                              );
                            },
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
