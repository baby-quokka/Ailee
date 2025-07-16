import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/slab_provider.dart';

class CreateSlabScreen extends StatefulWidget {
  @override
  State<CreateSlabScreen> createState() => _CreateSlabScreenState();
}

class _CreateSlabScreenState extends State<CreateSlabScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _description;
  String? _emoji;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('슬랩 생성')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: '이름'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? '이름을 입력하세요' : null,
                onSaved: (value) => _name = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: '설명'),
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: '이모지 (예: 😊)'),
                onSaved: (value) => _emoji = value,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              _formKey.currentState?.save();
                              setState(() => _isLoading = true);
                              final provider = Provider.of<SlabProvider>(
                                context,
                                listen: false,
                              );
                              final newSlab = await provider.createSlab(
                                name: _name!,
                                description: _description,
                                emoji: _emoji,
                              );
                              setState(() => _isLoading = false);
                              if (newSlab != null) {
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('슬랩 생성에 실패했습니다.'),
                                  ),
                                );
                              }
                            }
                          },
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('슬랩 생성'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
