import '../repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository repository;

  NotificationService({required this.repository});

  bool get hasSession => repository.hasSession;

  Future<NotificationPage> load() => repository.list();

  Future<void> markRead(String id) => repository.markRead(id);

  Future<void> updateSettings({
    required bool likes,
    required bool matches,
    required bool messages,
  }) =>
      repository.updateSettings(likes: likes, matches: matches, messages: messages);
}
