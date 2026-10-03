import '../models/chat_message.dart';
import '../models/match_item.dart';
import 'api_client.dart';
import 'profile_parser.dart';

/// Matches and their conversations (listmatches, unmatch, listmessages, sendmessage).
class MatchRepository {
  final ApiClient _api;
  final String? Function() _token;

  MatchRepository({ApiClient? api, required String? Function() tokenProvider})
      : _api = api ?? ApiClient(),
        _token = tokenProvider;

  bool get hasSession => _token() != null;

  Future<List<MatchItem>> listMatches() async => parseMatches(await _api.sendAuthed('listmatches', _token()));

  Future<void> unmatch(String matchId) async {
    await _api.sendAuthed('unmatch', _token(), {'matchId': matchId});
  }

  /// Also marks the other person's messages as read on the server.
  Future<List<ChatMessage>> listMessages(String conversationId) async {
    final data = await _api.sendAuthed('listmessages', _token(), {'conversationId': conversationId});
    if (data is! Map || data['messages'] is! List) {
      throw ApiException('BAD_RESPONSE', 'listmessages: $data');
    }
    return [
      for (final m in data['messages'] as List)
        if (m is Map) parseMessage(m),
    ];
  }

  Future<ChatMessage> sendMessage(String conversationId, String body) async {
    final data = await _api.sendAuthed('sendmessage', _token(), {'conversationId': conversationId, 'body': body});
    if (data is! Map) throw ApiException('BAD_RESPONSE', 'sendmessage: $data');
    return parseMessage(data);
  }

  static List<MatchItem> parseMatches(dynamic data) {
    if (data is! Map || data['matches'] is! List) {
      throw ApiException('BAD_RESPONSE', 'listmatches: $data');
    }
    final raw = data['matches'] as List;
    final out = <MatchItem>[];
    for (final m in raw) {
      if (m is! Map) continue;
      final user = m['user'] is Map ? ProfileParser.parse(Map<String, dynamic>.from(m['user'] as Map)) : null;
      final matchId = m['matchId']?.toString();
      final conversationId = m['conversationId']?.toString();
      if (user == null || matchId == null || conversationId == null) continue;
      final last = m['lastMessage'];
      out.add(MatchItem(
        matchId: matchId,
        conversationId: conversationId,
        createdAt: ProfileParser.date(m['createdAt']),
        user: user,
        lastMessage: last is Map
            ? LastMessage(
                body: '${last['body'] ?? ''}',
                createdAt: ProfileParser.date(last['createdAt']),
                mine: last['mine'] == true,
              )
            : null,
      ));
    }
    if (raw.isNotEmpty && out.isEmpty) {
      throw ApiException('BAD_RESPONSE', 'No pudimos leer los vínculos. Primer elemento: ${raw.first}');
    }
    return out;
  }

  static ChatMessage parseMessage(Map m) => ChatMessage(
        id: '${m['id']}',
        senderId: '${m['senderId'] ?? ''}',
        body: '${m['body'] ?? ''}',
        readAt: ProfileParser.dateOrNull(m['readAt']),
        createdAt: ProfileParser.date(m['createdAt']),
        mine: m['mine'] == true,
      );
}
