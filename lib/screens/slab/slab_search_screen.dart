import 'package:flutter/material.dart';
import 'slab_detail_screen.dart';

class SlabSearchScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allPosts;
  const SlabSearchScreen({super.key, required this.allPosts});

  @override
  State<SlabSearchScreen> createState() => _SlabSearchScreenState();
}

class _SlabSearchScreenState extends State<SlabSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _boards = [
    {'title': '자유', 'desc': '아무 이야기나 자유롭게!'},
    {'title': '정보 공유', 'desc': '유용한 정보, 꿀팁 나눔'},
    {'title': '고민 상담', 'desc': '고민, 질문, 익명 상담'},
    {'title': '유머/짤방', 'desc': '웃긴 이야기, 짤, 밈'},
    {'title': '취미/모임', 'desc': '취미, 소모임, 동호회'},
  ];
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boards = _boards.where((b) => b['title']!.contains(_search)).toList();
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '검색',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: boards.length,
              itemBuilder: (context, idx) {
                final board = boards[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      board['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(board['desc']!),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => SlabDetailScreen(
                                slabName: board['title']!,
                                allPosts: widget.allPosts,
                                onBack: () {
                                  Navigator.pop(context);
                                },
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
