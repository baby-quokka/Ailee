import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/chat_provider.dart';
import '../models/chat/chat_bot.dart';

class WorkflowScreen extends StatelessWidget {
  final ChatBot bot;
  final TextEditingController workflowInputController;
  const WorkflowScreen({
    super.key,
    required this.bot,
    required this.workflowInputController,
  });

  @override
  Widget build(BuildContext context) {
    return _WorkflowScreenBody(
      bot: bot,
      workflowInputController: workflowInputController,
    );
  }
}

class _WorkflowScreenBody extends StatefulWidget {
  final ChatBot bot;
  final TextEditingController workflowInputController;
  const _WorkflowScreenBody({
    required this.bot,
    required this.workflowInputController,
  });

  @override
  State<_WorkflowScreenBody> createState() => _WorkflowScreenBodyState();
}

class _WorkflowScreenBodyState extends State<_WorkflowScreenBody> {
  bool _popped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatProvider = context.watch<ChatProvider>();
    if (!chatProvider.isWorkflow) {
      // 워크플로우가 종료되면 자동 pop하여 ChatScreen으로 돌아감
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          print('[DEBUG] 워크플로우 종료 - ChatScreen으로 돌아감');
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    // isWorkflow가 false로 바뀌면 자동 pop (중복 pop 방지)
    if (!chatProvider.isWorkflow && !_popped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          _popped = true;
          Navigator.of(context).pop();
        }
      });
    }

    final workflowResponse = chatProvider.workflowResponse;
    final isLoading = chatProvider.isLoading;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            final chatProvider = context.read<ChatProvider>();
            final sessionId = chatProvider.currentSession?.id;
            print(
              '[DEBUG] 뒤로가기 클릭 - 현재 세션 ID: ' +
                  (sessionId?.toString() ?? 'null'),
            );
            if (sessionId != null) {
              try {
                await chatProvider.deleteSession(sessionId);
                print('[DEBUG] deleteSession 호출 완료 - 삭제된 세션 ID: $sessionId');
              } catch (e) {
                print('[DEBUG] deleteSession 에러: ' + e.toString());
              }
              await chatProvider.loadSessions();
            }
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          widget.bot.name,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: _buildWorkflowUI(
        context,
        chatProvider,
        workflowResponse,
        isLoading,
      ),
    );
  }

  Widget _buildWorkflowUI(
    BuildContext context,
    ChatProvider chatProvider,
    List<String>? response,
    bool isLoading,
  ) {
    final cardDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 챗봇 말풍선
          Padding(
            padding: const EdgeInsets.only(top: 32, left: 16, right: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 36, color: Colors.grey[400]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: cardDecoration,
                    child:
                        isLoading
                            ? Center(
                              child: SizedBox(
                                height: 28,
                                child: SpinKitThreeBounce(
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ),
                            )
                            : Text(
                              response != null ? response[0] : '',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // 선택지 카드
          ...List.generate(response != null ? response.length - 1 : 0, (i) {
            final text = response != null ? response[i + 1] : '';
            if (text.trim().isEmpty) return SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap:
                    isLoading
                        ? null
                        : () {
                          print('[DEBUG] 워크플로우 선택지 클릭: "$text"');
                          chatProvider.sendMessage(text, isWorkflow: true);
                          FocusScope.of(context).unfocus();
                        },
                child: Container(
                  decoration: cardDecoration,
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5A6CEA),
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          // 입력 카드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: cardDecoration,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.workflowInputController,
                      decoration: InputDecoration(
                        hintText: '직접 입력',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          color: Color(0xFF5A6CEA),
                        ),
                      ),
                      enabled: !isLoading,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty && !isLoading) {
                          print('[DEBUG] 워크플로우 직접 입력: "$text"');
                          chatProvider.sendMessage(text, isWorkflow: true);
                          widget.workflowInputController.clear();
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Color(0xFF5A6CEA)),
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              final text = widget.workflowInputController.text;
                              if (text.trim().isNotEmpty) {
                                print('[DEBUG] 워크플로우 전송 버튼 클릭: "$text"');
                                chatProvider.sendMessage(
                                  text,
                                  isWorkflow: true,
                                );
                                widget.workflowInputController.clear();
                                FocusScope.of(context).unfocus();
                              }
                            },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
