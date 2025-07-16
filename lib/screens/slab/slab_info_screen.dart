import 'package:ailee/screens/slab/slab_detail_screen.dart';
import 'package:ailee/screens/slab/slab_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:ailee/screens/home_screen.dart';
import 'package:ailee/models/slab/slab.dart';
import 'package:ailee/providers/slab_provider.dart';
import 'package:provider/provider.dart';

class SlabInfoScreen extends StatefulWidget {
  const SlabInfoScreen({super.key});

  @override
  State<SlabInfoScreen> createState() => _SlabInfoScreenState();
}

class _SlabInfoScreenState extends State<SlabInfoScreen> {
  bool excludeSubscribed = false;
  bool showSecret = false;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 바텀네비게이션바 자동 노출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeState = context.findAncestorStateOfType<HomeScreenState>();
      homeState?.setBottomNavOffset(1.0);
      // 슬랩 데이터 불러오기
      Provider.of<SlabProvider>(context, listen: false).loadSlabs();
    });
  }

  List<Slab> get topSlabs {
    final slabs = Provider.of<SlabProvider>(context).slabs;
    // 비공개 제외, 구독 제외 옵션 적용
    List<Slab> filtered =
        slabs
            .where(
              (s) =>
                  (s.imoji != null && s.imoji != "") &&
                  !(s.description?.contains("비공개") ?? false),
            )
            .toList();
    if (excludeSubscribed) {
      // slabs에 isSubscribed가 없으므로, 추후 사용자 정보와 매칭 필요
    }
    // postCount가 slabs에 없으므로, 임시로 users 수로 정렬
    filtered.sort((a, b) => (b.users.length).compareTo(a.users.length));
    return filtered.take(5).toList();
  }

  List<Slab> get mySlabs {
    final slabs = Provider.of<SlabProvider>(context).slabs;
    // slabs에 isSubscribed, isSecret이 없으므로, 임시로 users에 현재 유저가 포함된 공개 슬랩만
    // TODO:실제 구현 시 사용자 정보 필요
    return slabs
        .where((s) => !(s.description?.contains("비공개") ?? false))
        .toList();
  }

  List<Slab> get mySecretSlabs {
    final slabs = Provider.of<SlabProvider>(context).slabs;
    // TODO:slabs에 isSecret이 없으므로, description에 "비공개" 포함된 것으로 임시 분류
    return slabs
        .where((s) => (s.description?.contains("비공개") ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SlabProvider>(
      builder: (context, slabProvider, child) {
        if (slabProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 텍스트 위주 간단 리스트
                      Card(
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
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${entry.key + 1}.  ',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${entry.value.imoji ?? ''} ',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${entry.value.name} ',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '- ${entry.value.description ?? ''}',
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
                      ListView.separated(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // 스크롤 중복 방지
                        itemCount:
                            showSecret ? mySecretSlabs.length : mySlabs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder:
                            (context, idx) => SlabCard(
                              slab:
                                  showSecret
                                      ? mySecretSlabs[idx]
                                      : mySlabs[idx],
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
      },
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
  const SlabCard({super.key, required this.slab});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => SlabDetailScreen(
                  slabName: slab.name,
                  allPosts: [],
                  onBack: () {
                    Navigator.pop(context);
                  },
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(1.0, 0.0);
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
              Text(slab.imoji ?? '', style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              // 제목/설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slab.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slab.description ?? '',
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
                        '${slab.users.length}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      Text(
                        '${slab.users.length}',
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
