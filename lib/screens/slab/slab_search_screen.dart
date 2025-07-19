import 'package:ailee/models/slab/slab.dart';
import 'package:ailee/providers/slab_provider.dart';
import 'package:ailee/screens/slab/slab_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SlabSearchScreen extends StatefulWidget {
  const SlabSearchScreen({super.key});

  @override
  State<SlabSearchScreen> createState() => _SlabSearchScreenState();
}

class _SlabSearchScreenState extends State<SlabSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String query = '';

  List<Slab> get filteredSlabs {
    if (query.isEmpty) return [];
    return Provider.of<SlabProvider>(
      context,
    ).slabs.where((s) => s.name.contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('슬랩 검색'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        elevation: 1,
      ),
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
                        // 해당 슬랩의 포스트만 필터링
                        final slabPosts =
                            Provider.of<SlabProvider>(context, listen: false)
                                .allPosts
                                .where(
                                  (post) => post['slab']['name'] == slab.name,
                                )
                                .toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SlabDetailScreen(
                                  slabName: slab.name,
                                  allPosts: slabPosts,
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
                          slab.imoji ?? '',
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          slab.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          slab.description ?? '',
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
                                  '${slab.users.length}',
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
