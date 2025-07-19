import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/interaction_provider.dart';
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
              return _buildWorkflowPost(post, index);
            } else {
              return _buildNormalPost(post);
            }
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

  Widget _buildWorkflowPost(Map<String, dynamic> post, int index) {
    // 워크플로우 카드 색상을 랜덤(고정)으로 지정
    int hashSource = post['id']?.hashCode ?? index;
    final gradientIndex = hashSource.abs() % workflowGradients.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                        post['user']['username'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (showSlabName) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap:
                              onSlabNameTap != null && post['slab'] != null
                                  ? () => onSlabNameTap!(post['slab']['name'])
                                  : null,
                          child: Text(
                            '» ${post['slab']['name'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 10),
                      Text(
                        _formatTime(post['created_at']),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.more_horiz, size: 18, color: Colors.grey[600]),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildLikeButton(post),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post['views'] ?? 0}',
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalPost(Map<String, dynamic> post) {
    return InkWell(
      onTap: () => onPostTap?.call(post),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                        post['user']['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (showSlabName) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap:
                              onSlabNameTap != null && post['slab'] != null
                                  ? () => onSlabNameTap!(post['slab']['name'])
                                  : null,
                          child: Text(
                            '» ${post['slab']['name']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 10),
                      Text(
                        _formatTime(post['created_at']),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.more_horiz, size: 18, color: Colors.grey[700]),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post['title'] != null) ...[
                        Text(
                          post['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        post['content'],
                        style: const TextStyle(fontSize: 14, height: 1.6),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildLikeButton(post),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post['views'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.repeat_rounded,
                              size: 18,
                              color: Colors.grey[700],
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
  }

  Widget _buildLikeButton(Map<String, dynamic> post) {
    return Consumer<InteractionProvider>(
      builder: (context, interactionProvider, child) {
        final postId = post['id'] as int;
        final isLiked = interactionProvider.isPostLikedByUser(postId);

        // 더미 데이터의 초기 좋아요 개수 가져오기
        final initialLikesCount = post['likes_count'] ?? 0;
        final currentLikesCount = interactionProvider.getPostLikesCount(postId);

        // 초기값이 설정되지 않았다면 설정
        if (currentLikesCount == 0 && initialLikesCount > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            interactionProvider.setPostLikesCount(postId, initialLikesCount);
          });
        }

        final likesCount =
            currentLikesCount > 0 ? currentLikesCount : initialLikesCount;

        return GestureDetector(
          onTap: () async {
            // TODO: 실제 사용자 ID를 가져와야 함 (현재는 임시로 1 사용)
            // final userId = 1;

            // 실제 API 호출 (잠깐 주석처리)
            // await interactionProvider.togglePostLike(postId, userId);

            // *****************************************************************
            // 임시방편(실제 API 호출하면 삭제)
            // 로컬에서만 좋아요 상태 토글
            final newLikedState = !isLiked;
            interactionProvider.setPostLikedByUser(postId, newLikedState);

            // 좋아요 개수도 함께 업데이트
            if (newLikedState) {
              interactionProvider.setPostLikesCount(postId, likesCount + 1);
            } else {
              interactionProvider.setPostLikesCount(postId, likesCount - 1);
            }
            // *****************************************************************
          },
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isLiked ? Colors.red : Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                '$likesCount',
                style: TextStyle(
                  fontSize: 12,
                  color: isLiked ? Colors.red : Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 시간 포맷팅 헬퍼 함수
  String _formatTime(String? createdAt) {
    if (createdAt == null) return '';

    try {
      final now = DateTime.now();
      final created = DateTime.parse(createdAt);
      final difference = now.difference(created);

      if (difference.inMinutes < 1) {
        return '방금';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}분 전';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}시간 전';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}일 전';
      } else {
        // 같은 해인지 확인
        if (now.year == created.year) {
          // 같은 해: MM/DD 형식 (두 자리 고정)
          return '${created.month.toString().padLeft(2, '0')}/${created.day.toString().padLeft(2, '0')}';
        } else {
          // 다른 해: YY/MM/DD 형식 (두 자리 고정)
          final year = created.year.toString().substring(2); // 2024 -> 24
          return '$year/${created.month.toString().padLeft(2, '0')}/${created.day.toString().padLeft(2, '0')}';
        }
      }
    } catch (e) {
      return createdAt;
    }
  }
}
