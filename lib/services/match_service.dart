import '../models/chat_message.dart';
import '../models/match_item.dart';
import '../repositories/match_repository.dart';

class MatchService {
  static const maxMessageLength = 2000;

  final MatchRepository repository;

  MatchService({required this.repository});

  bool get hasSession => repository.hasSession;

  /// Newest match first.
  Future<List<MatchItem>> matches() async =>
      (await repository.listMatches())..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<void> unmatch(String matchId) => repository.unmatch(matchId);

  Future<List<ChatMessage>> messages(String conversationId) => repository.listMessages(conversationId);

  Future<ChatMessage> send(String conversationId, String body) => repository.sendMessage(conversationId, body);
}
