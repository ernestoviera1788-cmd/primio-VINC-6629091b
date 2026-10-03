/// Flexible gender values. Gender is never used to rank; only explicit
/// "who I want to discover" preferences filter candidates.
enum Gender { male, female, nonBinary, preferNotToSay }

enum RelationshipIntent { longTerm, shortTerm, friendship, casual, exploring }

enum VerificationStatus { notVerified, pending, verified, rejected }

enum SwipeDecision { like, pass, spark }

/// Public profile data only: no email, phone, exact coordinates or internal ids
/// beyond an opaque reference used for navigation.
class Profile {
  final String id;
  final String name;
  final int age;
  final String? city;
  final String? state;
  final String? country;
  final String? intention;
  final String? hobbies;
  final String? lifestyle;
  final Gender gender;
  final String? pronouns;
  final double distanceKm;
  final String bio;
  final List<String> photos;
  final List<String> interests;
  final RelationshipIntent intent;
  final VerificationStatus verification;
  final String? job;
  final String? education;
  final int? heightCm;
  final List<String> languages;
  final Duration lastActive;
  final double completeness;

  /// Demo-only flag standing in for the reciprocal like that the backend
  /// will detect in Phase 5.
  final bool hasLikedViewer;

  const Profile({
    required this.id,
    required this.name,
    required this.age,
    this.city,
    this.state,
    this.country,
    this.intention,
    this.hobbies,
    this.lifestyle,
    required this.gender,
    this.pronouns,
    required this.distanceKm,
    required this.bio,
    required this.photos,
    required this.interests,
    required this.intent,
    this.verification = VerificationStatus.notVerified,
    this.job,
    this.education,
    this.heightCm,
    this.languages = const [],
    this.lastActive = Duration.zero,
    this.completeness = 1.0,
    this.hasLikedViewer = false,
  });

  bool get isVerified => verification == VerificationStatus.verified;
}

/// A ranked profile ready for display.
class DiscoveryCandidate {
  final Profile profile;
  final int compatibility;
  final List<String> sharedInterests;
  final String distanceLabel;

  const DiscoveryCandidate({
    required this.profile,
    required this.compatibility,
    required this.sharedInterests,
    required this.distanceLabel,
  });
}
