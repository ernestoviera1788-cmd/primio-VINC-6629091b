import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

enum AuthStatus { restoring, restoreFailed, signedOut, guest, signedIn }

/// App-global session state. Action methods return a user-facing error
/// message, or null on success.
class AuthProvider extends ChangeNotifier {
  final AuthService _service;

  AuthProvider({required AuthService service}) : _service = service;

  AuthStatus _status = AuthStatus.restoring;
  AppUser? _user;
  AuthSession? _session;
  bool _busy = false;
  String? _restoreError;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get busy => _busy;
  String? get token => _session?.token;
  String? get restoreError => _restoreError;

  Future<void> restore() async {
    _status = AuthStatus.restoring;
    _restoreError = null;
    notifyListeners();
    try {
      final restored = await _service.restore();
      if (restored == null) {
        _status = AuthStatus.signedOut;
      } else {
        _session = restored.$1;
        _user = restored.$2;
        _status = AuthStatus.signedIn;
      }
    } catch (e) {
      _restoreError = AuthService.messageFor(e);
      _status = AuthStatus.restoreFailed;
    }
    notifyListeners();
  }

  Future<String?> login(String identifier, String password) =>
      _run(() async => _apply(await _service.login(identifier, password)));

  Future<String?> register(SignupData data) =>
      _run(() async => _apply(await _service.register(data)));

  Future<String?> requestPasswordReset(String identifier) =>
      _run(() => _service.requestPasswordReset(identifier));

  Future<String?> completePasswordReset(String identifier, String code, String newPassword) =>
      _run(() => _service.completePasswordReset(identifier, code, newPassword));

  void continueAsGuest() {
    _status = AuthStatus.guest;
    notifyListeners();
  }

  void leaveGuestMode() {
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  Future<void> logout() async {
    final session = _session;
    _busy = true;
    notifyListeners();
    if (session != null) await _service.logout(session.token);
    _session = null;
    _user = null;
    _busy = false;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  Future<String?> deleteAccount() async {
    final session = _session;
    if (session == null) return 'Inicia sesión para eliminar tu cuenta.';
    final error = await _run(() => _service.deleteAccount(session.token));
    if (error == null) {
      _session = null;
      _user = null;
      _status = AuthStatus.signedOut;
      notifyListeners();
    }
    return error;
  }

  Future<void> discardStoredSession() async {
    await _service.clearLocalSession();
    _restoreError = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  void _apply(AuthResult result) {
    _user = result.user;
    _session = result.session;
    _status = AuthStatus.signedIn;
  }

  Future<String?> _run(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
      return null;
    } catch (e) {
      return AuthService.messageFor(e);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
