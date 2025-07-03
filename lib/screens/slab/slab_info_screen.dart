import 'package:ailee/screens/slab/slab_detail_screen.dart';
import 'package:flutter/material.dart';
import 'slab_search_screen.dart';
import 'package:ailee/screens/home_screen.dart';

// 슬랩 임시 모델
class Slab {
  final String emoji;
  final String title;
  final String desc;
  final int postCount;
  final int memberCount;
  final bool isSecret;
  final bool isSubscribed;
  Slab({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.postCount,
    required this.memberCount,
    required this.isSecret,
    required this.isSubscribed,
  });
}

class SlabInfoScreen extends StatefulWidget {
  SlabInfoScreen({super.key});

  @override
  State<SlabInfoScreen> createState() => _SlabInfoScreenState();
}

class _SlabInfoScreenState extends State<SlabInfoScreen> {
  // 전체 슬랩 더미 데이터 12개 (isSubscribed는 나중에 user로 대체)
  final List<Slab> allSlabs = [
    Slab(
      emoji: '🗽',
      title: '자유',
      desc: '자유롭게 이야기하는 공간',
      postCount: 140,
      memberCount: 600,
      isSecret: false,
      isSubscribed: false,
    ),
    Slab(
      emoji: '💼',
      title: '진로',
      desc: '진로 관련 질문, 고민, 꿀팁 나눔',
      postCount: 130,
      memberCount: 500,
      isSecret: false,
      isSubscribed: false,
    ),
    Slab(
      emoji: '🔥',
      title: '학업',
      desc: '학업 관련 질문, 고민, 꿀팁 나눔',
      postCount: 120,
      memberCount: 340,
      isSecret: false,
      isSubscribed: false,
    ),
    Slab(
      emoji: '💖',
      title: '연애',
      desc: '연애 관련 질문, 고민, 꿀팁 나눔',
      postCount: 98,
      memberCount: 210,
      isSecret: false,
      isSubscribed: true,
    ),
    Slab(
      emoji: '🤔',
      title: '취미/모임',
      desc: '취미, 소모임, 동호회',
      postCount: 75,
      memberCount: 180,
      isSecret: false,
      isSubscribed: false,
    ),
    Slab(
      emoji: '👥',
      title: '인간관계',
      desc: '인간관계 관련 질문, 고민, 꿀팁 나눔',
      postCount: 60,
      memberCount: 150,
      isSecret: false,
      isSubscribed: false,
    ),
    Slab(
      emoji: '🍔',
      title: '맛집',
      desc: '맛집 추천, 음식 이야기',
      postCount: 55,
      memberCount: 100,
      isSecret: true,
      isSubscribed: true,
    ),
    Slab(
      emoji: '🧠',
      title: '심리',
      desc: '심리 관련 질문, 고민, 꿀팁 나눔',
      postCount: 50,
      memberCount: 80,
      isSecret: false,
      isSubscribed: true,
    ),
    Slab(
      emoji: '💬',
      title: '소통',
      desc: '소통 관련 질문, 고민, 꿀팁 나눔',
      postCount: 45,
      memberCount: 120,
      isSecret: false,
      isSubscribed: false,
    ),
    Slab(
      emoji: '🎮',
      title: '게임',
      desc: '게임 정보, 친구 구함',
      postCount: 40,
      memberCount: 90,
      isSecret: true,
      isSubscribed: true,
    ),
    Slab(
      emoji: '🏋️',
      title: '운동',
      desc: '운동, 건강, 다이어트',
      postCount: 35,
      memberCount: 70,
      isSecret: false,
      isSubscribed: true,
    ),
    Slab(
      emoji: '🎵',
      title: '음악',
      desc: '음악 추천, 공연 정보',
      postCount: 25,
      memberCount: 60,
      isSecret: true,
      isSubscribed: false,
    ),
  ];

  // 더미 포스트 데이터 (community_screen.dart에서 복사)
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

  bool excludeSubscribed = false;
  bool showSecret = false;

  // Top 5 슬랩: isSecret과 isSubscribed가 false인 슬랩 중 postCount 내림차순 상위 5개
  List<Slab> get top5Slabs {
    List<Slab> filtered = allSlabs.where((s) => !s.isSecret).toList();
    if (excludeSubscribed) {
      filtered = filtered.where((s) => !s.isSubscribed).toList();
    }
    filtered.sort((a, b) => b.postCount.compareTo(a.postCount));
    return filtered.take(5).toList();
  }

  // MY슬랩 - 공개
  List<Slab> get mySlabs {
    return allSlabs.where((s) => s.isSubscribed && !s.isSecret).toList();
  }

  // MY슬랩 - 비공개
  List<Slab> get mySecretSlabs {
    return allSlabs.where((s) => s.isSubscribed && s.isSecret).toList();
  }

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 바텀네비게이션바 자동 노출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeState = context.findAncestorStateOfType<HomeScreenState>();
      homeState?.setBottomNavOffset(1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 검색창
              _buildSearchBar(),
              const SizedBox(height: 24),
              // 2. Top 5 슬랩
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top 5 슬랩',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  // 구독 제외 체크박스
                  Row(
                    children: [
                      const Text('구독 제외', style: TextStyle(fontSize: 14)),
                      Checkbox(
                        value: excludeSubscribed,
                        onChanged: (val) {
                          setState(() {
                            excludeSubscribed = val ?? true;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: top5Slabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder:
                      (context, idx) => SizedBox(
                        width: 260,
                        child: SlabCard(
                          slab: top5Slabs[idx],
                          allPosts: _dummyPosts,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 32),
              // 3. MY슬랩 + 비공개 체크박스
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MY슬랩',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Row(
                    children: [
                      const Text('비공개', style: TextStyle(fontSize: 14)),
                      Checkbox(
                        value: showSecret,
                        onChanged: (val) {
                          setState(() {
                            showSecret = val ?? false;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // 스크롤 중복 방지
                itemCount: showSecret ? mySecretSlabs.length : mySlabs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder:
                    (context, idx) => SlabCard(
                      slab: showSecret ? mySecretSlabs[idx] : mySlabs[idx],
                      allPosts: _dummyPosts,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SlabSearchScreen()),
        );
      },
      child: AbsorbPointer(
        child: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: '슬랩 검색',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
    );
  }
}

class SlabCard extends StatelessWidget {
  final Slab slab;
  final List<Map<String, dynamic>> allPosts;
  const SlabCard({super.key, required this.slab, required this.allPosts});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SlabDetailScreen(
                  slabName: slab.title,
                  allPosts: allPosts,
                  onBack: () {
                    Navigator.pop(context);
                  },
                ),
          ),
        );
      },
      child: Card(
        color: Colors.grey[100],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              // 이모티콘
              Text(slab.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              // 제목/설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slab.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slab.desc,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // 게시글 수/인원 수
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.article, size: 16),
                      Text(
                        '${slab.postCount}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      Text(
                        '${slab.memberCount}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
