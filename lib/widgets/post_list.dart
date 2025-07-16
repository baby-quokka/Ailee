import 'package:flutter/material.dart';
import 'workflow_card.dart';

class PostListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final bool showSlabName;
  final ScrollController? scrollController;
  final VoidCallback? onFabTap;
  final bool showFab;
  final void Function(Map<String, dynamic> post)? onPostTap;
  final List<List<Color>> workflowGradients;
  final void Function(String slabName)? onSlabNameTap;

  const PostListWidget({
    super.key,
    required this.posts,
    required this.workflowGradients,
    this.showSlabName = false,
    this.scrollController,
    this.onFabTap,
    this.showFab = true,
    this.onPostTap,
    this.onSlabNameTap,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '아직 게시글이 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  '첫 번째 게시글을 작성해보세요!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (showFab && onFabTap != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: onFabTap,
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
        ],
      );
    }
    return Stack(
      children: [
        ListView.separated(
          controller: scrollController,
          itemCount: posts.length,
          separatorBuilder:
              (context, index) => Divider(height: 1, color: Colors.grey[200]),
          itemBuilder: (context, index) {
            final post = posts[index];
            if (post['type'] == 'workflow') {
              // 워크플로우 카드 색상을 랜덤(고정)으로 지정
              int hashSource;
              if (post['id'] != null) {
                hashSource = post['id'].hashCode;
              } else {
                hashSource = index;
              }
              final gradientIndex = hashSource.abs() % workflowGradients.length;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onPostTap?.call(post),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  post['username'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (showSlabName) ...[
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap:
                                        onSlabNameTap != null &&
                                                post['slab'] != null
                                            ? () => onSlabNameTap!(post['slab'])
                                            : null,
                                    child: Text(
                                      '» ${post['slab'] ?? ''}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 10),
                                Text(
                                  post['time'] ?? '',
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
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: GestureDetector(
                                onTap: () {},
                                child: WorkflowCard(
                                  post: post,
                                  gradient: workflowGradients[gradientIndex],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        '${post['likes'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(width: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.mode_comment_outlined,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${post['comments'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(width: 10),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.share_outlined,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${post['shares'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(width: 10),
                                  Icon(
                                    Icons.repeat_rounded,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            // 일반 포스트 카드
            return InkWell(
              onTap: () => onPostTap?.call(post),
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
                              if (showSlabName) ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap:
                                      onSlabNameTap != null &&
                                              post['slab'] != null
                                          ? () => onSlabNameTap!(post['slab'])
                                          : null,
                                  child: Text(
                                    '» ${post['slab']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
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
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    // const SizedBox(width: 10),
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
                                    // const SizedBox(width: 10),
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
                                    // const SizedBox(width: 10),
                                    Icon(
                                      Icons.repeat_rounded,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ],
                                ),
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
        if (showFab && onFabTap != null)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: onFabTap,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
      ],
    );
  }
}
