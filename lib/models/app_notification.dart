class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  /// Notifications about a chat carry its conversation in `data`.
  String? get conversationId {
    final c = data['conversationId'];
    return c is String && c.isNotEmpty ? c : null;
  }

  AppNotification markedRead() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        data: data,
        readAt: DateTime.now(),
        createdAt: createdAt,
      );
}
