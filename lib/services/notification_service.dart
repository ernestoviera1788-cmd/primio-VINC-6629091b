import '../repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository repository;

  NotificationService({required this.repository});

  bool get hasSession => repository.hasSession;

  Future<NotificationPage> load() => repository.list();

  Future<void> markRead(String id) => repository.markRead(id);
}
