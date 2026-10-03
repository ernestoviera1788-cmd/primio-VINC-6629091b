import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/app_user.dart';
import 'api_client.dart';

class AuthResult {
  final AppUser user;
  final AuthSession session;

  const AuthResult(this.user, this.session);
}

class AuthRepository {
  static const _kToken = 'vinco_token';
  static const _kExpiresAt = 'vinco_expires_at';

  final ApiClient _api;
  final FlutterSecureStorage _storage;

  AuthRepository({ApiClient? api, FlutterSecureStorage? storage})
      : _api = api ?? ApiClient(),
        _storage = storage ?? const FlutterSecureStorage();

  Future<AuthResult> register(SignupData data) async =>
      _authFrom(await _api.send('register', data.toArgs()));

  Future<AuthResult> login(String identifier, String password) async =>
      _authFrom(await _api.send('login', {'identifier': identifier, 'password': password}));

  Future<AppUser> getMe(String token) async {
    final data = await _api.send('getme', {'token': token});
    if (data is! Map) throw const ApiException('BAD_RESPONSE');
    return AppUser.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> logout(String token) async {
    await _api.send('logout', {'token': token});
  }

  Future<void> deleteAccount(String token) async {
    await _api.send('deleteaccount', {'token': token, 'confirm': 'DELETE'});
  }

  Future<void> requestPasswordReset(String identifier) async {
    await _api.send('requestpasswordreset', {'identifier': identifier, 'locale': 'es'});
  }

  Future<void> completePasswordReset({
    required String identifier,
    required String code,
    required String newPassword,
  }) async {
    await _api.send('completepasswordreset', {
      'identifier': identifier,
      'code': code,
      'newPassword': newPassword,
      'locale': 'es',
    });
  }

  Future<AuthSession?> readSession() async {
    final token = await _storage.read(key: _kToken);
    final expires = DateTime.tryParse(await _storage.read(key: _kExpiresAt) ?? '');
    if (token == null || expires == null) return null;
    return AuthSession(token: token, expiresAt: expires);
  }

  Future<void> saveSession(AuthSession session) async {
    await _storage.write(key: _kToken, value: session.token);
    await _storage.write(key: _kExpiresAt, value: session.expiresAt.toIso8601String());
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kExpiresAt);
  }

  AuthResult _authFrom(dynamic data) {
    if (data is! Map) throw const ApiException('BAD_RESPONSE');
    final user = data['user'];
    final token = data['token'];
    final expires = DateTime.tryParse('${data['expiresAt']}');
    if (user is! Map || token is! String || expires == null) {
      throw const ApiException('BAD_RESPONSE');
    }
    return AuthResult(
      AppUser.fromJson(Map<String, dynamic>.from(user)),
      AuthSession(token: token, expiresAt: expires),
    );
  }
}
