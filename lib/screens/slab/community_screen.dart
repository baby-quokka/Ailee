import 'package:flutter/material.dart';
import 'post_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Map<String, dynamic>> _dummyPosts = [
    {
      'username': 'baby_quokka520',
      'content':
          '오늘은 정말 기분이 좋은 하루였어요! 친구들과 함께 공원에서 산책도 하고, 맛있는 것도 많이 먹었답니다. 여러분은 오늘 뭐 하셨어요? #행복 #일상',
      'time': '방금',
      'slab': null,
      'likes': 12,
      'comments': 3,
      'shares': 1,
    },
    {
      'username': 'majakkrungethep',
      'content':
          '스레드에서 진짜 유명한 분이 진짜 대박인게 이것도 하고 저것도 하고 진짜.. 말도 안되는 짓을 많이 하셔서..ㅋㅋㅋ 오늘도 레전드! 내일은 또 무슨 일이 있을지 기대됩니다.',
      'time': '2시간 전',
      'slab': null,
      'likes': 8,
      'comments': 1,
      'shares': 0,
    },
    {
      'username': 'wyxkfh',
      'content':
          '어벤져스 엔드게임 스포 레전드 ㅋㅋ 마지막 장면에서 진짜 소름 돋았음. 혹시 아직 안 본 사람 있나요? 스포 조심하세요!',
      'time': '4시간 전',
      'slab': '유머/짤방',
      'likes': 21,
      'comments': 5,
      'shares': 2,
    },
    {
      'username': '_news_topic_',
      'content':
          "배스킨라빈스, 새 모델로 걸그룹 르세라핌 발탁... '애망빙'으로 출발! 신제품 출시 소식도 함께 전해드립니다. 여러분은 어떤 맛을 제일 좋아하세요?",
      'time': '14시간 전',
      'slab': '정보 공유',
      'likes': 5,
      'comments': 0,
      'shares': 0,
    },
    {
      'username': 'user1',
      'content': '첫 번째 자유 글입니다. 오늘은 새로운 시작을 다짐하는 날! 모두 힘내세요. #자유 #응원',
      'time': '1분 전',
      'slab': '자유',
      'likes': 2,
      'comments': 0,
      'shares': 0,
    },
    {
      'username': 'user2',
      'content': '고민 상담 좀 해주세요! 요즘 진로 때문에 너무 고민이 많아요. 선배님들 조언 부탁드려요 ㅠㅠ',
      'time': '10분 전',
      'slab': '고민 상담',
      'likes': 0,
      'comments': 2,
      'shares': 0,
    },
    {
      'username': 'user3',
      'content': '취미/모임에서 같이 할 사람 구해요~ 이번 주말에 등산 가실 분? 초보 환영입니다!',
      'time': '1시간 전',
      'slab': '취미/모임',
      'likes': 3,
      'comments': 1,
      'shares': 1,
    },
  ];

  Widget _buildPostList(List<Map<String, dynamic>> posts) {
    return posts.isEmpty
        ? const Center(child: Text('포스트가 없습니다.'))
        : ListView.separated(
          itemCount: posts.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final post = posts[index];
            String nickname = post['username'];
            String? slab = post['slab'];
            String slabName = slab ?? '자유';
            int likes = post['likes'] ?? 0;
            int comments = post['comments'] ?? 0;
            int shares = post['shares'] ?? 0;
            String time = post['time'];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
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
                    const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                nickname,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '/$slabName',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            post['content'],
                            style: const TextStyle(fontSize: 14, height: 1.6),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$likes',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.mode_comment_outlined,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$comments',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.share_outlined,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$shares',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
        );
  }

  @override
  Widget build(BuildContext context) {
    return _buildPostList(_dummyPosts);
  }
}
