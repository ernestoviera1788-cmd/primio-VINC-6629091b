/// Client-side checks mirroring the backend rules, so most mistakes are
/// caught before a request is sent. The server stays the source of truth.
class AuthValidators {
  AuthValidators._();

  static const minPasswordLength = 10;
  static const maxPasswordLength = 100;
  static const minimumAge = 18;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phonePattern = RegExp(r'^\+[1-9]\d{6,14}$');

  static String? required(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Escribe tu email';
    if (!_emailPattern.hasMatch(v)) return 'Este email no parece válido';
    return null;
  }

  static String? optionalPhone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    if (!_phonePattern.hasMatch(v)) return 'Usa formato internacional, ej. +15125550199';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.length < minPasswordLength) return 'Mínimo $minPasswordLength caracteres';
    if (v.length > maxPasswordLength) return 'Máximo $maxPasswordLength caracteres';
    return null;
  }

  static int ageOn(DateTime birth, DateTime now) {
    var age = now.year - birth.year;
    if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) age--;
    return age;
  }

  static String? birthDate(DateTime? value) {
    if (value == null) return 'Indica tu fecha de nacimiento';
    if (ageOn(value, DateTime.now()) < minimumAge) {
      return 'Debes tener al menos $minimumAge años para usar VINCÓ';
    }
    return null;
  }

  /// Strict YYYY-MM-DD, as the backend expects.
  static String apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String displayDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
