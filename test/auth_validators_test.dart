import 'package:flutter_test/flutter_test.dart';
import 'package:primio_app/models/auth_validators.dart';

void main() {
  test('password length must be 10 to 100', () {
    expect(AuthValidators.password('corta'), isNotNull);
    expect(AuthValidators.password('Secreta12345'), isNull);
    expect(AuthValidators.password('a' * 101), isNotNull);
  });

  test('age is computed with birthday boundaries', () {
    final now = DateTime(2026, 5, 14);
    expect(AuthValidators.ageOn(DateTime(2008, 5, 14), now), 18);
    expect(AuthValidators.ageOn(DateTime(2008, 5, 15), now), 17);
  });

  test('api date is strict YYYY-MM-DD', () {
    expect(AuthValidators.apiDate(DateTime(1990, 5, 4)), '1990-05-04');
  });

  test('email and phone formats', () {
    expect(AuthValidators.email('ana@example.com'), isNull);
    expect(AuthValidators.email('ana@'), isNotNull);
    expect(AuthValidators.optionalPhone(''), isNull);
    expect(AuthValidators.optionalPhone('+15125550199'), isNull);
    expect(AuthValidators.optionalPhone('5125550199'), isNotNull);
  });
}
