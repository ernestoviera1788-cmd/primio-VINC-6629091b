import '../models/profile.dart';
import 'api_client.dart';

/// Parses the public profile card shared by listdiscovery and listmatches.
class ProfileParser {
  ProfileParser._();

  static Profile? parse(Map<String, dynamic> m) {
    final id = m['id']?.toString();
    final name = text(m['firstName']);
    final age = m['age'] is num ? (m['age'] as num).toInt() : ageFrom(m['birthDate']);
    if (id == null || id.isEmpty || name == null || age == null) return null;
    return Profile(
      id: id,
      name: name,
      age: age,
      city: text(m['city']),
      state: text(m['state']),
      country: text(m['country']),
      intention: text(m['intention']),
      hobbies: text(m['hobbies']),
      lifestyle: text(m['lifestyle']),
      job: text(m['occupation']),
      education: text(m['education']),
      gender: Gender.preferNotToSay,
      distanceKm: 0,
      bio: text(m['bio']) ?? '',
      photos: photos(m['photos']),
      interests: const [],
      intent: RelationshipIntent.exploring,
    );
  }

  /// Photo URLs with the primary photo first.
  static List<String> photos(dynamic raw) {
    if (raw is! List) return const [];
    final maps = raw.whereType<Map>().toList()
      ..sort((a, b) => (b['isPrimary'] == true ? 1 : 0) - (a['isPrimary'] == true ? 1 : 0));
    return [
      for (final p in maps)
        if (resolveUrl(p['url']) case final String url) url,
    ];
  }

  /// Keeps http(s) and data: URLs; relative paths get the server origin.
  static String? resolveUrl(dynamic value) {
    final s = value?.toString();
    if (s == null || s.isEmpty) return null;
    if (s.startsWith('http') || s.startsWith('data:')) return s;
    return '${ApiClient.baseUrl}${s.startsWith('/') ? '' : '/'}$s';
  }

  static String? text(dynamic v) {
    if (v == null) return null;
    final s = (v is List ? v.map((e) => '$e').join(', ') : '$v').trim();
    return s.isEmpty ? null : s;
  }

  static DateTime date(dynamic v) => DateTime.tryParse('$v')?.toLocal() ?? DateTime.now();

  static DateTime? dateOrNull(dynamic v) => v == null ? null : DateTime.tryParse('$v')?.toLocal();

  static int? ageFrom(dynamic birthDate) {
    final birth = DateTime.tryParse('$birthDate');
    if (birth == null) return null;
    final now = DateTime.now();
    var age = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) age--;
    return age;
  }
}
