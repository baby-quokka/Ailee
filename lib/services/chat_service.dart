import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_bot.dart';

/// ChatGPT API와 통신하는 서비스 클래스
class ChatService {
  /// ChatGPT API 엔드포인트 URL
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// API 인증을 위한 키
  final String apiKey;

  ChatService({required this.apiKey});

  /// ChatGPT API에 메시지를 전송하고 응답을 받는 메서드
  ///
  /// [message] 사용자가 입력한 메시지
  /// [bot] 현재 선택된 챗봇 (시스템 프롬프트에 사용)
  ///
  /// Returns: ChatGPT의 응답 메시지
  Future<String> sendMessage(String message, ChatBot bot) async {
    try {
      // API 요청 보내기
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': bot.systemPrompt}, // 챗봇의 성격 설정
            {'role': 'user', 'content': message}, // 사용자 메시지
          ],
          'temperature': 0.7, // 응답의 창의성 정도 (0.0 ~ 1.0)
        }),
      );

      // 응답 처리
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
