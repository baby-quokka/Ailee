import 'package:ailee/screens/slab/slab_detail_screen.dart';
import 'package:flutter/material.dart';

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

class SlabSearchScreen extends StatefulWidget {
  const SlabSearchScreen({super.key});

  @override
  State<SlabSearchScreen> createState() => _SlabSearchScreenState();
}

class _SlabSearchScreenState extends State<SlabSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String query = '';

  // 임시 슬랩 데이터 (info_screen과 동일)
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

  List<Slab> get filteredSlabs {
    if (query.isEmpty) return [];
    return allSlabs.where((s) => s.title.contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('슬랩 검색')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '슬랩 이름을 입력하세요',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  query = val;
                });
              },
            ),
            const SizedBox(height: 16),
            if (filteredSlabs.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: filteredSlabs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, idx) {
                    final slab = filteredSlabs[idx];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SlabDetailScreen(
                                  slabName: slab.title,
                                  allPosts: [],
                                  onBack: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Text(
                          slab.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          slab.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          slab.desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                              mainAxisSize: MainAxisSize.min,
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
                      ),
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