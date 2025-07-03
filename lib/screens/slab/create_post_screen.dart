import 'package:flutter/material.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포스트 작성')),
      body: const Center(child: Text('여기에 포스트 작성 UI가 들어갑니다.')),
    );
  }
}
