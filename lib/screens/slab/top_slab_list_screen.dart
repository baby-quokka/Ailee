// import 'package:flutter/material.dart';
// import 'slab_info_screen.dart';

// class TopSlabListScreen extends StatefulWidget {
//   final List<Slab> slabs;
//   final List<Map<String, dynamic>> allPosts;
//   const TopSlabListScreen({
//     super.key,
//     required this.slabs,
//     required this.allPosts,
//   });

//   @override
//   State<TopSlabListScreen> createState() => _TopSlabListScreenState();
// }

// class _TopSlabListScreenState extends State<TopSlabListScreen> {
//   bool excludeSubscribed = false;

//   List<Slab> get filteredSlabs {
//     List<Slab> filtered = widget.slabs.where((s) => !s.isSecret).toList();
//     if (excludeSubscribed) {
//       filtered = filtered.where((s) => !s.isSubscribed).toList();
//     }
//     filtered.sort((a, b) => b.postCount.compareTo(a.postCount));
//     return filtered.take(10).toList(); // 일단 10개로
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('인기 슬랩'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         surfaceTintColor: Colors.white,
//         actions: [
//           Row(
//             children: [
//               const Text('구독 제외', style: TextStyle(fontSize: 14)),
//               Checkbox(
//                 value: excludeSubscribed,
//                 onChanged: (val) {
//                   setState(() {
//                     excludeSubscribed = val ?? true;
//                   });
//                 },
//                 activeColor: Colors.blue,
//               ),
//               const SizedBox(width: 8),
//             ],
//           ),
//         ],
//       ),
//       backgroundColor: Colors.grey[50],
//       body: ListView.separated(
//         padding: const EdgeInsets.all(16),
//         itemCount: filteredSlabs.length,
//         separatorBuilder: (_, __) => const SizedBox(height: 0),
//         itemBuilder:
//             (context, idx) =>
//                 SlabCard(slab: filteredSlabs[idx], allPosts: widget.allPosts),
//       ),
//     );
//   }
// }
