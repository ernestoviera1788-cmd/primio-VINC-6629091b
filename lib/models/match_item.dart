import 'profile.dart';

class LastMessage {
  final String body;
  final DateTime createdAt;
  final bool mine;

  const LastMessage({required this.body, required this.createdAt, required this.mine});
}

/// A match from listmatches; each one owns exactly one conversation.
class MatchItem {
  final String matchId;
  final String conversationId;
  final DateTime createdAt;
  final Profile user;
  final LastMessage? lastMessage;

  const MatchItem({
    required this.matchId,
    required this.conversationId,
    required this.createdAt,
    required this.user,
    required this.lastMessage,
  });

  DateTime get lastActivity => lastMessage?.createdAt ?? createdAt;
}
