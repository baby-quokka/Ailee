import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'services/chat_api_service.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 서버 연결 상태 확인
  final chatApiService = ChatApiService();
  final isServerConnected = await chatApiService.checkServerConnection();
  print('서버 연결 상태: $isServerConnected');

  await InternetAddress.lookup('localhost');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final authProvider = AuthProvider();

            // ChatProvider와 AuthProvider 연결
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final chatProvider = Provider.of<ChatProvider>(
                context,
                listen: false,
              );
              authProvider.setChatProvider(chatProvider);
            });

            return authProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Ailee',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Pretendard',
        ),
        home: const HomeScreen(),
        routes: {'/main': (context) => const HomeScreen()},
      ),
    );
  }
}
