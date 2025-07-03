import 'package:ailee/screens/home_screen.dart';
import 'package:ailee/screens/slab/slab_detail_screen.dart';
import 'package:flutter/material.dart';
import 'post_screen.dart';

class CommunityScreen extends StatefulWidget {
  final bool showSubscribeLabel;
  const CommunityScreen({super.key, required this.showSubscribeLabel});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Map<String, dynamic>> _dummyPosts = [
    {
      'username': 'baby_quokka520',
      'content':
          '오늘은 정말 기분이 좋은 하루였어요! 친구들과 공원에서 산책하고 맛있는 아이스크림도 먹었어요. 덕분에 스트레스가 확 풀렸답니다. 여러분은 오늘 뭐 하셨나요?',
      'image':
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'time': '방금',
      'slab': '자유',
      'likes': 12,
      'comments': 3,
      'shares': 1,
    },
    {
      'username': 'career_hopeful',
      'content':
          '요즘 진로 때문에 너무 고민이에요. 디자인 쪽으로 가고 싶은데, 부모님은 안정적인 직장을 원하시네요. 어떻게 설득하면 좋을까요?',
      'image':
          'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
      'time': '10분 전',
      'slab': '진로',
      'likes': 5,
      'comments': 2,
      'shares': 0,
    },
    {
      'username': 'study_holic',
      'content': '오늘은 밤새서 통계학 공부했어요. 베이즈 정리가 이렇게 어렵다니... 혹시 쉽게 이해하는 팁 있나요?',
      'image':
          'https://images.unsplash.com/photo-1513258496099-48168024aec0?auto=format&fit=crop&w=400&q=80',
      'time': '30분 전',
      'slab': '학업',
      'likes': 8,
      'comments': 4,
      'shares': 0,
    },
    {
      'username': 'hikinglover',
      'content': '이번 주말에 북한산 등반 계획 있는데 같이 가실 분 구해요~ 초보 환영이고, 끝나고 맛집도 가요!',
      'image': null,
      'time': '1시간 전',
      'slab': '취미/모임',
      'likes': 3,
      'comments': 1,
      'shares': 1,
    },
    {
      'username': 'relation_talk',
      'content':
          '친구랑 사소한 일로 다퉜는데 너무 마음이 무거워요. 먼저 연락하는 게 좋을까요? 경험 있으신 분 조언 부탁드려요.',
      'image': null,
      'time': '2시간 전',
      'slab': '인간관계',
      'likes': 6,
      'comments': 2,
      'shares': 0,
    },
    {
      'username': 'love_diary',
      'content': '썸타는 사람과 오늘도 연락했는데, 답장이 늦으면 괜히 불안해지네요. 이런 감정 어떻게 조절하시나요?',
      'image': null,
      'time': '3시간 전',
      'slab': '연애',
      'likes': 9,
      'comments': 3,
      'shares': 1,
    },
    {
      'username': 'mind_care',
      'content': '요즘 무기력하고 아무것도 하기 싫어요. 이런 상태가 계속되는데, 혹시 다들 이럴 때 어떻게 극복하시나요?',
      'image': null,
      'time': '4시간 전',
      'slab': '심리',
      'likes': 15,
      'comments': 5,
      'shares': 2,
    },
    {
      'username': 'fitness_guru',
      'content': '오늘 하체 운동 제대로 했더니 다리가 후들거리네요 ㅋㅋ 여러분은 스쿼트 몇 kg까지 치세요?',
      'image': null,
      'time': '5시간 전',
      'slab': '운동',
      'likes': 13,
      'comments': 4,
      'shares': 0,
    },
    {
      'username': 'foodie_jjang',
      'content':
          '신사동에 새로 생긴 파스타집 다녀왔어요! 크림 파스타가 진짜 고소하고 담백해서 완전 제 스타일이었어요. 추천합니다~',
      'image': null,
      'time': '6시간 전',
      'slab': '맛집',
      'likes': 20,
      'comments': 6,
      'shares': 3,
    },
    {
      'username': 'open_talker',
      'content': '다들 오늘 하루 어땠나요? 저는 일이 많아서 정신없었는데, 이렇게 소통할 수 있어 좋아요!',
      'image': null,
      'time': '7시간 전',
      'slab': '소통',
      'likes': 4,
      'comments': 2,
      'shares': 0,
    },
    {
      'username': 'game_addict',
      'content': '롤 신규 챔피언 해보신 분? 스킬셋이 재밌어 보여서 궁금하네요. 메타에 적합한지 후기 부탁드립니다!',
      'image': null,
      'time': '8시간 전',
      'slab': '게임',
      'likes': 11,
      'comments': 3,
      'shares': 1,
    },
    {
      'username': 'music_healer',
      'content':
          '오늘은 아이유 노래 들으면서 하루를 시작했어요. 가사가 너무 예쁘고 위로가 되네요. 여러분은 어떤 노래로 하루를 시작하시나요?',
      'image': null,
      'time': '9시간 전',
      'slab': '음악',
      'likes': 18,
      'comments': 4,
      'shares': 2,
    },
    {
      'username': 'study_buddy',
      'content': '중간고사 끝났는데 결과가 생각보다 안 좋네요... 다들 시험 끝나고 슬럼프는 어떻게 극복하시나요?',
      'image': null,
      'time': '10시간 전',
      'slab': '학업',
      'likes': 7,
      'comments': 2,
      'shares': 0,
    },
    {
      'username': 'lover101',
      'content': '짝사랑 중인데, 오늘 눈 마주쳤어요! 괜히 두근거려서 공부가 안되네요 ㅠㅠ',
      'image': null,
      'time': '11시간 전',
      'slab': '연애',
      'likes': 14,
      'comments': 3,
      'shares': 0,
    },
    {
      'username': 'mental_health',
      'content': '불면증 때문에 새벽 4시까지 잠 못 자고 있어요. 잠드는 팁 있으면 알려주세요...',
      'image': null,
      'time': '12시간 전',
      'slab': '심리',
      'likes': 10,
      'comments': 5,
      'shares': 1,
    },
    {
      'username': 'gymrat',
      'content': '벤치프레스 기록 갱신! 60kg에서 65kg 성공했어요. 다음 목표는 70kg입니다🔥',
      'image': null,
      'time': '13시간 전',
      'slab': '운동',
      'likes': 16,
      'comments': 2,
      'shares': 2,
    },
    {
      'username': 'food_hunter',
      'content':
          '부산에서 밀면 먹고 왔어요. 여름에는 시원한 밀면이 최고네요. 혹시 부산 사시는 분들, 숨겨진 맛집 추천해주세요!',
      'image': null,
      'time': '14시간 전',
      'slab': '맛집',
      'likes': 19,
      'comments': 4,
      'shares': 1,
    },
    {
      'username': 'friend_maker',
      'content': '소통하고 싶어요~ 오늘 하루 있었던 재미있는 일 한 가지씩 공유해볼까요?',
      'image': null,
      'time': '15시간 전',
      'slab': '소통',
      'likes': 5,
      'comments': 1,
      'shares': 0,
    },
    {
      'username': 'game_master',
      'content': '디아블로4 시즌 시작했는데 진짜 재밌네요. 혹시 같이 파티하실 분 있나요?',
      'image': null,
      'time': '16시간 전',
      'slab': '게임',
      'likes': 12,
      'comments': 2,
      'shares': 0,
    },
    {
      'username': 'music_junkie',
      'content': '요즘 뉴진스 노래에 푹 빠졌어요. 톡톡 튀는 사운드가 듣기만 해도 기분 좋아지네요!',
      'image':
          'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=400&q=80',
      'time': '17시간 전',
      'slab': '음악',
      'likes': 17,
      'comments': 3,
      'shares': 2,
    },
  ];

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
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final post = posts[index];
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
                                    MaterialPageRoute(
                                      builder:
                                          (_) => SlabDetailScreen(
                                            slabName: post['slab'],
                                            allPosts: _dummyPosts,
                                            onBack:
                                                () =>
                                                    Navigator.of(context).pop(),
                                          ),
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
        );
  }

  @override
  Widget build(BuildContext context) {
    // 구독 라벨 표시 여부에 따라 자유 슬랩 포스트만 표시 - TODO: 추후 수정 예정
    // 구독 슬랩 목록을 서버에서 받아온 후 -> allPosts.where((p) => mySubscribedSlabs.contains(p['slab'])).toList()
    final posts =
        widget.showSubscribeLabel
            ? _dummyPosts.where((p) => p['slab'] == '자유').toList()
            : _dummyPosts;
    return _buildPostList(posts);
  }
}
