import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../models/chat_bot.dart';
import '../providers/chat_provider.dart';
import 'workflow_screen.dart';
import 'voice_screen.dart';

class ContentsScreen extends StatefulWidget {
  final ChatBot bot;
  final TextEditingController workflowInputController;
  const ContentsScreen({
    Key? key,
    required this.bot,
    required this.workflowInputController,
  }) : super(key: key);

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('고민 방식 선택', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0, bottom: 40.0),
        child: _isLoading ? _buildLoadingColumn() : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              '어떤 방식으로 고민을 나누시겠어요?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pretendard',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: '텍스트',
                      imagePath: 'assets/emoji/page_with_curl_3d.png',
                      color: const Color(0xFF5A6CEA),
                      textColor: Colors.white,
                      onTap: _isLoading ? null : () async {
                        setState(() { _isLoading = true; });
                        try {
                          final chatProvider = context.read<ChatProvider>();
                          await chatProvider.sendMessage('고민 상담하기', isWorkflow: true);
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('오류가 발생했습니다: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() { _isLoading = false; });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildTypeButton(
                      label: '음성',
                      imagePath: 'assets/emoji/mobile_phone_3d.png',
                      color: const Color(0xFFE8F0FE),
                      textColor: const Color(0xFF5A6CEA),
                      onTap: _isLoading ? null : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const VoiceScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required String imagePath,
    required Color color,
    required Color textColor,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: 'Pretendard',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingColumn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 30,
          height: 30,
          child: SpinKitThreeBounce(
            color: Color(0xFF5A6CEA),
            size: 20,
          ),
        ),
        const SizedBox(height: 40),
        const Text('준비 중...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Pretendard')),
      ],
      ),
    );
  }
}