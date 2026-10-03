import '../models/app_user.dart';
import '../repositories/api_client.dart';
import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _repository;

  AuthService({required AuthRepository repository}) : _repository = repository;

  Future<AuthResult> register(SignupData data) async {
    final result = await _repository.register(data);
    await _repository.saveSession(result.session);
    return result;
  }

  Future<AuthResult> login(String identifier, String password) async {
    final result = await _repository.login(identifier.trim(), password);
    await _repository.saveSession(result.session);
    return result;
  }

  /// Restores a stored session. Returns null when there is none or the server
  /// no longer accepts it; rethrows connectivity and account-status errors so
  /// the user sees them instead of being silently signed out.
  Future<(AuthSession, AppUser)?> restore() async {
    final session = await _repository.readSession();
    if (session == null) return null;
    if (session.isExpired) {
      await _repository.clearSession();
      return null;
    }
    try {
      final user = await _repository.getMe(session.token);
      return (session, user);
    } on ApiException catch (e) {
      final mustSurface = e.code == 'NETWORK' ||
          e.code == 'BAD_RESPONSE' ||
          e.code.startsWith('HTTP_') ||
          e.code.startsWith('ACCOUNT_');
      if (mustSurface) rethrow;
      await _repository.clearSession();
      return null;
    }
  }

  Future<void> logout(String token) async {
    try {
      await _repository.logout(token);
    } on ApiException {
      // The local session is removed below either way; the server token expires on its own.
    } finally {
      await _repository.clearSession();
    }
  }

  Future<void> clearLocalSession() => _repository.clearSession();

  Future<void> deleteAccount(String token) async {
    await _repository.deleteAccount(token);
    await _repository.clearSession();
  }

  Future<void> requestPasswordReset(String identifier) =>
      _repository.requestPasswordReset(identifier.trim());

  Future<void> completePasswordReset(String identifier, String code, String newPassword) =>
      _repository.completePasswordReset(
        identifier: identifier.trim(),
        code: code.trim(),
        newPassword: newPassword,
      );

  static String messageFor(Object error) {
    if (error is! ApiException) return 'Algo no salió como esperábamos. Inténtalo de nuevo en un momento.';
    return switch (error.code) {
      'EMAIL_TAKEN' => 'Ya existe una cuenta con este email. Prueba a iniciar sesión.',
      'PHONE_TAKEN' => 'Este teléfono ya está registrado en otra cuenta.',
      'INVALID_CREDENTIALS' => 'Email, teléfono o contraseña incorrectos.',
      'INVALID_EMAIL' => 'El email no tiene un formato válido.',
      'INVALID_PASSWORD' => 'La contraseña debe tener entre 10 y 100 caracteres.',
      'INVALID_BIRTHDATE' => 'La fecha de nacimiento no es válida.',
      'UNDERAGE' => 'Debes tener al menos 18 años para usar VINCÓ.',
      'TERMS_NOT_ACCEPTED' => 'Debes aceptar los términos y la política de privacidad.',
      'ACCOUNT_SUSPENDED' => 'Tu cuenta está suspendida temporalmente.',
      'ACCOUNT_BANNED' => 'Esta cuenta fue bloqueada por incumplir las normas de la comunidad.',
      'ACCOUNT_DELETED' => 'Esta cuenta fue eliminada.',
      'OTP_INVALID' => 'El código no es correcto.',
      'OTP_EXPIRED' => 'El código ha caducado. Solicita uno nuevo.',
      'RESET_CODE_INVALID' => 'El código de recuperación no es correcto o ha caducado.',
      'SIGN_IN_REQUIRED' => 'Inicia sesión para continuar.',
      'INVALID_CONFIRM' => 'No se confirmó la eliminación de la cuenta.',
      'NETWORK' => 'No pudimos conectar con el servidor de VINCÓ. Revisa tu conexión e inténtalo de nuevo.',
      'BAD_RESPONSE' => 'Recibimos una respuesta que no esperábamos. Inténtalo de nuevo en un momento.',
      final code when code.startsWith('HTTP_') =>
        'Nuestro servidor está teniendo un mal momento. Inténtalo de nuevo en unos minutos.',
      _ => 'No pudimos completar esta acción. Inténtalo de nuevo en un momento.',
    };
  }
}
