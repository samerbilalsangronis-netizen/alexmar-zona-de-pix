import '../entities/usuario.dart';

/// Resultado tipado del intento de login (sin excepciones para flujo normal)
sealed class ResultadoLogin {
  const ResultadoLogin();
}

class LoginExitoso extends ResultadoLogin {
  final Usuario usuario;
  const LoginExitoso(this.usuario);
}

class LoginFallido extends ResultadoLogin {
  final String mensaje;
  const LoginFallido(this.mensaje);
}

/// ─────────────────────────────────────────────────────────────────
/// CAPA DOMAIN · Contrato. La capa Presentation SOLO conoce esta
/// interfaz; jamás toca Drift ni SharedPreferences directamente.
/// ─────────────────────────────────────────────────────────────────
abstract interface class AuthRepository {
  /// Valida credenciales contra la base local (100% offline)
  Future<ResultadoLogin> login(String usuario, String password);

  /// Restaura la sesión persistida (para no pedir login en cada apertura)
  Future<Usuario?> restaurarSesion();

  /// Cierra sesión y limpia la persistencia
  Future<void> logout();
}
