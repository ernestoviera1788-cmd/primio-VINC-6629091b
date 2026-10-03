import '../models/profile.dart';
import '../repositories/profile_repository.dart';

/// Ranking, filtering by preferences and exclusion of seen profiles are done
/// by the backend; this service only turns its profiles into cards.
class DiscoveryService {
  final ProfileRepository repository;

  DiscoveryService({required this.repository});

  bool get hasSession => repository.hasSession;

  Future<List<DiscoveryCandidate>> loadPage({int offset = 0}) async {
    final page = await repository.fetchDiscovery(offset: offset);
    return [
      for (final p in page.profiles)
        DiscoveryCandidate(
          profile: p,
          compatibility: 0,
          sharedInterests: const [],
          distanceLabel: [p.city, p.state].whereType<String>().join(', '),
        ),
    ];
  }

  Future<ReactionResult> react(String profileId, SwipeDecision decision) =>
      repository.react(profileId, decision);
}
