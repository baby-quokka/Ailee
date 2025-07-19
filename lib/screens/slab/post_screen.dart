import 'package:ailee/providers/interaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    // 더미 Answer 데이터
    final List<Map<String, dynamic>> dummyAnswers = [
      {
        'id': 1,
        'user': {'username': 'kevin0918k'},
        'content': '화이팅!!',
        'created_at': '2024-01-15T10:00:00Z',
        'likes_count': 5,
        'comments': [
          {
            'id': 1,
            'user': {'username': 'mingyun7383'},
            'content': '응원합니다!',
            'created_at': '2024-01-15T11:00:00Z',
            'likes_count': 2,
          },
          {
            'id': 2,
            'user': {'username': 'user123'},
            'content': '저도 화이팅!',
            'created_at': '2024-01-15T12:00:00Z',
            'likes_count': 1,
          },
        ],
      },
      {
        'id': 2,
        'user': {'username': 'mingyun7383'},
        'content': '힘내요',
        'created_at': '2024-01-15T09:00:00Z',
        'likes_count': 3,
        'comments': [],
      },
      {
        'id': 3,
        'user': {'username': post['user']['username'] ?? 'Unknown'},
        'content': '넹',
        'created_at': '2024-01-15T08:00:00Z',
        'likes_count': 1,
        'comments': [],
      },
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
                            post['user']['username'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatTime(post['created_at']),
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
                    if (post['title'] != null) ...[
                      Text(
                        post['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      post['content'] ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 액션 아이콘 (views로 변경)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildLikeButton(post),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.visibility_outlined,
                      size: 22,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${post['views'] ?? 0}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '답변',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // Answer 리스트
              ...dummyAnswers.map((answer) => _buildAnswerWidget(answer)),
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
                  hintText: '답변을 입력하세요...',
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

  Widget _buildAnswerWidget(Map<String, dynamic> answer) {
    final List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(
      answer['comments'] ?? [],
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              answer['user']['username'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatTime(answer['created_at']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          answer['content'],
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        // Answer 액션 버튼들
                        Row(
                          children: [
                            _buildAnswerLikeButton(answer),
                            const SizedBox(width: 16),
                            _buildCommentButton(answer, comments),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Comment 리스트
        if (comments.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 42, right: 16),
            child: Column(
              children:
                  comments
                      .map((comment) => _buildCommentWidget(comment))
                      .toList(),
            ),
          ),
        ],
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildCommentWidget(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['user']['username'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatTime(comment['created_at']),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment['content'], style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                _buildCommentLikeButton(comment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerLikeButton(Map<String, dynamic> answer) {
    return Consumer<InteractionProvider>(
      builder: (context, interactionProvider, child) {
        final answerId = answer['id'] as int;
        final isLiked = interactionProvider.isAnswerLikedByUser(answerId);
        final initialLikesCount = answer['likes_count'] ?? 0;
        final currentLikesCount = interactionProvider.getAnswerLikesCount(
          answerId,
        );
        final likesCount =
            currentLikesCount > 0 ? currentLikesCount : initialLikesCount;

        if (currentLikesCount == 0 && initialLikesCount > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            interactionProvider.setAnswerLikesCount(
              answerId,
              initialLikesCount,
            );
          });
        }

        return GestureDetector(
          onTap: () async {
            final newLikedState = !isLiked;
            interactionProvider.setAnswerLikedByUser(answerId, newLikedState);

            if (newLikedState) {
              interactionProvider.setAnswerLikesCount(answerId, likesCount + 1);
            } else {
              interactionProvider.setAnswerLikesCount(answerId, likesCount - 1);
            }
          },
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 16,
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

  Widget _buildCommentButton(
    Map<String, dynamic> answer,
    List<Map<String, dynamic>> comments,
  ) {
    return GestureDetector(
      onTap: () {
        // TODO: 댓글 입력 다이얼로그 표시
        _showCommentDialog(answer['id']);
      },
      child: Row(
        children: [
          Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            '${comments.length}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentLikeButton(Map<String, dynamic> comment) {
    return Consumer<InteractionProvider>(
      builder: (context, interactionProvider, child) {
        final commentId = comment['id'] as int;
        final isLiked = interactionProvider.isCommentLikedByUser(commentId);
        final initialLikesCount = comment['likes_count'] ?? 0;
        final currentLikesCount = interactionProvider.getCommentLikesCount(
          commentId,
        );
        final likesCount =
            currentLikesCount > 0 ? currentLikesCount : initialLikesCount;

        if (currentLikesCount == 0 && initialLikesCount > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            interactionProvider.setCommentLikesCount(
              commentId,
              initialLikesCount,
            );
          });
        }

        return GestureDetector(
          onTap: () async {
            final newLikedState = !isLiked;
            interactionProvider.setCommentLikedByUser(commentId, newLikedState);

            if (newLikedState) {
              interactionProvider.setCommentLikesCount(
                commentId,
                likesCount + 1,
              );
            } else {
              interactionProvider.setCommentLikesCount(
                commentId,
                likesCount - 1,
              );
            }
          },
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 14,
                color: isLiked ? Colors.red : Colors.grey[700],
              ),
              const SizedBox(width: 4),
              Text(
                '$likesCount',
                style: TextStyle(
                  fontSize: 11,
                  color: isLiked ? Colors.red : Colors.grey[700],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommentDialog(int answerId) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('댓글 작성'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              hintText: '댓글을 입력하세요...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                // TODO: 댓글 추가 로직
                Navigator.of(context).pop();
              },
              child: const Text('작성'),
            ),
          ],
        );
      },
    );
  }

  // 시간 포맷팅 메서드
  String formatTime(String? createdAt) {
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
        if (now.year == created.year) {
          return '${created.month.toString().padLeft(2, '0')}/${created.day.toString().padLeft(2, '0')}';
        } else {
          final year = created.year.toString().substring(2);
          return '$year/${created.month.toString().padLeft(2, '0')}/${created.day.toString().padLeft(2, '0')}';
        }
      }
    } catch (e) {
      return createdAt;
    }
  }
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
