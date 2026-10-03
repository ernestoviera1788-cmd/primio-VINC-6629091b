class ChatMessage {
  final String id;
  final String senderId;
  final String body;
  final DateTime? readAt;
  final DateTime createdAt;
  final bool mine;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.body,
    required this.readAt,
    required this.createdAt,
    required this.mine,
  });

  bool get isRead => readAt != null;
}
