/// Account returned by the VINCÓ backend. Email and phone are private:
/// they are only ever shown to the owner, never on public profiles.
class AppUser {
  final String id;
  final String email;
  final String firstName;
  final String birthDate;
  final String gender;
  final String city;
  final String? state;
  final String country;
  final String? phone;
  final String locale;
  final bool emailVerified;
  final bool phoneVerified;

  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.birthDate,
    required this.gender,
    required this.city,
    required this.state,
    required this.country,
    required this.phone,
    required this.locale,
    required this.emailVerified,
    required this.phoneVerified,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: '${j['id'] ?? ''}',
        email: j['email'] as String? ?? '',
        firstName: j['firstName'] as String? ?? '',
        birthDate: j['birthDate'] as String? ?? '',
        gender: j['gender'] as String? ?? '',
        city: j['city'] as String? ?? '',
        state: j['state'] as String?,
        country: j['country'] as String? ?? '',
        phone: j['phone'] as String?,
        locale: j['locale'] as String? ?? 'es',
        emailVerified: j['emailVerified'] == true,
        phoneVerified: j['phoneVerified'] == true,
      );
}

class AuthSession {
  final String token;
  final DateTime expiresAt;

  const AuthSession({required this.token, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Gender values sent to the backend as-is (free text on the server).
const genderOptions = ['Mujer', 'Hombre', 'No binario', 'Prefiero no decir'];

class SignupData {
  final String email;
  final String password;
  final String firstName;
  final String birthDate;
  final String gender;
  final String city;
  final String state;
  final String country;
  final String phone;

  const SignupData({
    required this.email,
    required this.password,
    required this.firstName,
    required this.birthDate,
    required this.gender,
    required this.city,
    required this.state,
    required this.country,
    required this.phone,
  });

  Map<String, dynamic> toArgs() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'birthDate': birthDate,
        'gender': gender,
        'city': city,
        if (state.isNotEmpty) 'state': state,
        'country': country,
        if (phone.isNotEmpty) 'phone': phone,
        'locale': 'es',
        'acceptedTerms': true,
      };
}
