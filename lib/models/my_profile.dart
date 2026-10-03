import 'profile.dart';

/// Values offered in the edit form. The backend stores free text, so a value
/// already saved that is not in these lists is kept and shown as an option.
const intentionOptions = [
  'Relación estable',
  'Algo a corto plazo',
  'Amistad',
  'Citas casuales',
  'Abierto a explorar',
];

const preferredGenderOptions = ['Mujer', 'Hombre', 'No binario', 'Todos'];

List<String> optionsWith(List<String> options, String current) =>
    current.isEmpty || options.contains(current) ? options : [current, ...options];

/// The signed-in user's own profile (getme / updateprofile).
class MyProfile {
  final String firstName;
  final String bio;
  final String city;
  final String state;
  final String country;
  final String gender;
  final String intention;
  final String occupation;
  final String education;
  final String hobbies;
  final String lifestyle;
  final String preferredGender;
  final int ageMin;
  final int ageMax;
  final int distanceMax;
  final String birthDate;

  const MyProfile({
    required this.firstName,
    required this.bio,
    required this.city,
    required this.state,
    required this.country,
    required this.gender,
    required this.intention,
    required this.occupation,
    required this.education,
    required this.hobbies,
    required this.lifestyle,
    required this.preferredGender,
    required this.ageMin,
    required this.ageMax,
    required this.distanceMax,
    this.birthDate = '',
  });

  /// getme returns user fields at the top level plus a `settings` object;
  /// preference fields are read from either place.
  factory MyProfile.fromJson(Map<String, dynamic> j) {
    final settings = j['settings'] is Map ? Map<String, dynamic>.from(j['settings'] as Map) : const <String, dynamic>{};
    dynamic v(String k) => j[k] ?? settings[k];
    String s(String k) {
      final x = v(k);
      if (x == null) return '';
      return x is List ? x.map((e) => '$e').join(', ') : '$x';
    }

    int n(String k, int fallback) {
      final x = v(k);
      return x is num ? x.toInt() : int.tryParse('$x') ?? fallback;
    }

    return MyProfile(
      firstName: s('firstName'),
      bio: s('bio'),
      city: s('city'),
      state: s('state'),
      country: s('country'),
      gender: s('gender'),
      intention: s('intention'),
      occupation: s('occupation'),
      education: s('education'),
      hobbies: s('hobbies'),
      lifestyle: s('lifestyle'),
      preferredGender: s('preferredGender'),
      ageMin: n('ageMin', 18),
      ageMax: n('ageMax', 99),
      distanceMax: n('distanceMax', 50),
      birthDate: s('birthDate'),
    );
  }

  Map<String, dynamic> toArgs() => {
        'firstName': firstName,
        'bio': bio,
        'city': city,
        'state': state,
        'country': country,
        'gender': gender,
        'intention': intention,
        'occupation': occupation,
        'education': education,
        'hobbies': hobbies,
        'lifestyle': lifestyle,
        'preferredGender': preferredGender,
        'ageMin': ageMin,
        'ageMax': ageMax,
        'distanceMax': distanceMax,
      };

  int? get age {
    final birth = DateTime.tryParse(birthDate);
    if (birth == null) return null;
    final now = DateTime.now();
    var a = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) a--;
    return a;
  }

  /// How other people see this profile (only approved photos are passed in).
  Profile toPublic({required List<String> photos}) {
    String? opt(String s) => s.trim().isEmpty ? null : s.trim();
    return Profile(
      id: 'me',
      name: firstName,
      age: age ?? 0,
      city: opt(city),
      state: opt(state),
      country: opt(country),
      intention: opt(intention),
      hobbies: opt(hobbies),
      lifestyle: opt(lifestyle),
      job: opt(occupation),
      education: opt(education),
      gender: Gender.preferNotToSay,
      distanceKm: 0,
      bio: bio,
      photos: photos,
      interests: const [],
      intent: RelationshipIntent.exploring,
    );
  }
}
