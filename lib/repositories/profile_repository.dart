import '../models/profile.dart';
import 'api_client.dart';
import 'profile_parser.dart';

class ReactionResult {
  final bool matched;
  final String? matchId;
  final String? conversationId;

  const ReactionResult({required this.matched, this.matchId, this.conversationId});
}

class DiscoveryPage {
  final List<Profile> profiles;
  final int total;

  const DiscoveryPage(this.profiles, this.total);
}

/// Discovery data from the VINCÓ backend (listdiscovery / reacttoprofile).
class ProfileRepository {
  static const pageSize = 20;

  final ApiClient _api;
  final String? Function() _token;

  ProfileRepository({ApiClient? api, required String? Function() tokenProvider})
      : _api = api ?? ApiClient(),
        _token = tokenProvider;

  bool get hasSession => _token() != null;

  Future<DiscoveryPage> fetchDiscovery({int offset = 0}) async => parsePage(
        await _api.sendAuthed('listdiscovery', _token(), {'limit': pageSize, 'offset': offset}),
      );

  Future<ReactionResult> react(String targetId, SwipeDecision decision) async {
    final kind = switch (decision) {
      SwipeDecision.like => 'LIKE',
      SwipeDecision.pass => 'PASS',
      SwipeDecision.spark => 'SUPER_LIKE',
    };
    return parseReaction(
      await _api.sendAuthed('reacttoprofile', _token(), {'targetId': targetId, 'kind': kind}),
    );
  }

  static DiscoveryPage parsePage(dynamic data) {
    if (data is! Map || data['users'] is! List) {
      throw ApiException('BAD_RESPONSE', 'listdiscovery no devolvió "users": $data');
    }
    final users = data['users'] as List;
    final profiles = [
      for (final u in users)
        if (u is Map) ProfileParser.parse(Map<String, dynamic>.from(u)),
    ].whereType<Profile>().toList();
    if (users.isNotEmpty && profiles.isEmpty) {
      throw ApiException('BAD_RESPONSE', 'No pudimos leer los perfiles. Primer elemento: ${users.first}');
    }
    final total = data['total'] is num ? (data['total'] as num).toInt() : profiles.length;
    return DiscoveryPage(profiles, total);
  }

  static ReactionResult parseReaction(dynamic data) {
    if (data is! Map) return const ReactionResult(matched: false);
    return ReactionResult(
      matched: data['matched'] == true,
      matchId: data['matchId']?.toString(),
      conversationId: data['conversationId']?.toString(),
    );
  }
}
