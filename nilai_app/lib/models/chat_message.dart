// ─────────────────────────────────────────────────────────────────────────────
//  models/chat_message.dart
// ─────────────────────────────────────────────────────────────────────────────

enum Role { user, assistant }

class ChatMessage {
  final String text;
  final Role role;
  final DateTime time;

  ChatMessage({required this.text, required this.role}) : time = DateTime.now();
}
