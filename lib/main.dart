import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/chat_service.dart';
import 'providers/chat_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // ChangeNotifierProvider는 상태 관리를 위한 위젯입니다.
      // 이 위젯은 하위 위젯 트리에 상태를 제공하고, 상태가 변경될 때 위젯을 다시 빌드합니다.
      // 여기서는 ChatProvider를 상태로 제공합니다.
      create:
          (context) => ChatProvider(
            // create 콜백은 ChangeNotifierProvider가 처음 생성될 때 호출됩니다.
            // 이 콜백은 상태 객체(ChatProvider)의 인스턴스를 생성하고 반환합니다.
            // context 매개변수는 위젯 트리의 BuildContext를 제공합니다.
            chatService: ChatService(
              apiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
            ),
          ),
      child: MaterialApp(
        title: 'ChatGPT Chat',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}
