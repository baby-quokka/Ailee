import 'package:flutter/material.dart';
import '../../screens/home_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('포스트 작성'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _showBottomNavBar();
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(child: Text('여기에 포스트 작성 UI가 들어갑니다.')),
    );
  }
}
