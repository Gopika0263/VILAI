// ─────────────────────────────────────────────────────────────────────────────
//  services/groq_service.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/chat_message.dart';

class GroqService {
  static const String _url = 'https://api.groq.com/openai/v1/chat/completions';

  /// Send full conversation history, get reply string back.
  static Future<String> chat(List<ChatMessage> history) async {
    final messages = <Map<String, String>>[
      {'role': 'system', 'content': kSystemPrompt},
      ...history.map((m) => {
            'role': m.role == Role.user ? 'user' : 'assistant',
            'content': m.text,
          }),
    ];

    final response = await http
        .post(
          Uri.parse(_url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $kGroqApiKey',
          },
          body: jsonEncode({
            'model': kGroqModel,
            'messages': messages,
            'max_tokens': 512,
            'temperature': 0.7,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final text = data['choices']?[0]?['message']?['content'];
      if (text != null && text.toString().trim().isNotEmpty) {
        return text.toString().trim();
      }
      throw Exception('Empty response from Groq.');
    } else if (response.statusCode == 401) {
      throw Exception('Invalid Groq API key.');
    } else if (response.statusCode == 429) {
      throw Exception('Rate limit. சிறிது நேரம் கழித்து try பண்ணுங்கள்.');
    } else {
      final err = jsonDecode(response.body);
      throw Exception(
          err['error']?['message'] ?? 'Groq error ${response.statusCode}');
    }
  }
}
