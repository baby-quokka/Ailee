import 'package:ailee/screens/slab/slab_detail_screen.dart';
import 'package:flutter/material.dart';
import 'slab_search_screen.dart';
import 'package:ailee/screens/slab/top_slab_list_screen.dart';
import 'package:ailee/screens/home_screen.dart';
import 'dummy_post.dart';

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
  const SlabInfoScreen({super.key});

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

  bool excludeSubscribed = false;
  bool showSecret = false;

  // Top 5 슬랩: isSecret과 isSubscribed가 false인 슬랩 중 postCount 내림차순 상위 5개
  List<Slab> get topSlabs {
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
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색창+여백 흰색 배경
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildSearchBar(),
            ),
            // 검색창 아래에 추가
            Container(
              height: 36,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white, // 위쪽 완전 흰색
                    Color(0xFFF8F9FA), // 중간 단계 (연회색, grey[50]와 비슷)
                    Color(0xFFF8F9FA), // 아래쪽 연회색
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
            ),
            // 나머지 전체 패딩
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. 인기 슬랩
                  const Text(
                    '인기 슬랩',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  // 텍스트 위주 간단 리스트
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  TopSlabListScreen(
                                    slabs: allSlabs,
                                    allPosts: dummyPosts,
                                  ),
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
                    child: Card(
                      color: Colors.white,
                      elevation: 0.1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              topSlabs
                                  .map(
                                    (slab) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                        horizontal: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${topSlabs.indexOf(slab) + 1}.  ',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${slab.emoji} ',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${slab.title} ',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Expanded(
                                            child: Text(
                                              '- ${slab.desc}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
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
                  // const SizedBox(height: 4),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // 스크롤 중복 방지
                    itemCount:
                        showSecret ? mySecretSlabs.length : mySlabs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder:
                        (context, idx) => SlabCard(
                          slab: showSecret ? mySecretSlabs[idx] : mySlabs[idx],
                          allPosts: dummyPosts,
                        ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
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
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => SlabDetailScreen(
                  slabName: slab.title,
                  allPosts: allPosts,
                  onBack: () => Navigator.of(context).pop(),
                ),
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
      child: Card(
        color: Colors.white,
        elevation: 0.1,
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
