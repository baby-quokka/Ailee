import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'services/notification_service.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 알림 서비스 초기화
  final notificationService = NotificationService();
  await notificationService.initialize();

  requestNotificationPermission();

  runApp(const MyApp());
}

void requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final chatProvider = ChatProvider();

            // 알림 탭 콜백 설정
            NotificationService().setNotificationTappedCallback(
              (payload) => chatProvider.handleNotificationPayload(payload),
            );

            return chatProvider;
          },
        ),
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
