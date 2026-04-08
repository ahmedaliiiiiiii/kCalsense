enum MessageRole { user, ai }

class ChatMessage {
  final String text;
  final MessageRole role;

  ChatMessage({required this.text, required this.role});
}
