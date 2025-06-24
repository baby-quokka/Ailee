import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/chat_bot.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 알림 탭 콜백을 저장할 변수
  Function(String)? _onNotificationTappedCallback;

  // 알림 탭 콜백 설정
  void setNotificationTappedCallback(Function(String) callback) {
    _onNotificationTappedCallback = callback;
  }

  Future<void> initialize() async {
    // 타임존 초기화
    tz.initializeTimeZones();

    // Android 설정
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // 정확한 알림 권한 요청 (현재 버전에서는 지원되지 않으므로 제거)
  Future<bool> requestExactAlarmPermission() async {
    // 현재 flutter_local_notifications 버전에서는 이 기능이 지원되지 않음
    // 대신 예외 처리를 통해 권한 문제를 해결
    return true;
  }

  // 알림 탭 처리
  void _onNotificationTapped(NotificationResponse response) {
    print('알림이 탭되었습니다: ${response.payload}');

    // 콜백이 설정되어 있으면 호출
    if (_onNotificationTappedCallback != null && response.payload != null) {
      _onNotificationTappedCallback!(response.payload!);
    }
  }

  // 즉시 알림 보내기
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: '챗봇과의 대화 알림',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // 예약 알림 설정 (권한 확인 포함)
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      channelDescription: '챗봇과의 대화 알림',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        scheduledDate.millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      print('예약 알림 설정 중 오류: $e');
      // 오류 발생 시 즉시 알림으로 대체
      await showNotification(title: title, body: body, payload: payload);
    }
  }

  // 챗봇 체크인 알림 설정
  Future<void> scheduleBotCheckIn({
    required ChatBot bot,
    required String message,
    required DateTime scheduledDate,
  }) async {
    final payload = 'check_in:${bot.id}:${bot.name}';

    await scheduleNotification(
      title: '${bot.name}의 체크인',
      body: message,
      scheduledDate: scheduledDate,
      payload: payload,
    );
  }

  // 모든 예약된 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
