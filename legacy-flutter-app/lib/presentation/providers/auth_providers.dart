import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';

/// ── Inyección de dependencias ──
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(databaseProvider)),
);

/// ── Estado de autenticación ──
sealed class AuthState {
  const AuthState();
}

class AuthInicializando extends AuthState {
  const AuthInicializando();
}

class AuthSinSesion extends AuthState {
  const AuthSinSesion();
}

class AuthVerificando extends AuthState {
  const AuthVerificando(); // Spinner durante el login
}

class AuthError extends AuthState {
  final String mensaje;
  const AuthError(this.mensaje);
}

class AuthConSesion extends AuthState {
  final Usuario usuario;
  const AuthConSesion(this.usuario);
}

/// ─────────────────────────────────────────────────────────────────
/// AuthController: ÚNICA fuente de verdad sobre quién está logueado
/// y con qué rol. El router (guard) y todas las pantallas observan
/// este estado.
/// ─────────────────────────────────────────────────────────────────
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restaurar();
    return const AuthInicializando();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> _restaurar() async {
    final usuario = await _repo.restaurarSesion();
    state =
        usuario != null ? AuthConSesion(usuario) : const AuthSinSesion();
  }

  Future<void> login(String usuario, String password) async {
    state = const AuthVerificando();
    final resultado = await _repo.login(usuario, password);
    state = switch (resultado) {
      LoginExitoso(usuario: final u) => AuthConSesion(u),
      LoginFallido(mensaje: final m) => AuthError(m),
    };
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthSinSesion();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Acceso directo al usuario actual (null si no hay sesión)
final usuarioActualProvider = Provider<Usuario?>((ref) {
  final s = ref.watch(authControllerProvider);
  return s is AuthConSesion ? s.usuario : null;
});

/// ¿El usuario actual es ADMIN? — Atajo para los guards de UI
final esAdminProvider = Provider<bool>(
  (ref) => ref.watch(usuarioActualProvider)?.esAdmin ?? false,
);
