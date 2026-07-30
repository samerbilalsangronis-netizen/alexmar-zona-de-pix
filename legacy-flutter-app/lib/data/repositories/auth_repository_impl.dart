import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../local/app_database.dart';

/// ─────────────────────────────────────────────────────────────────
/// CAPA DATA · Implementación concreta del contrato AuthRepository.
/// Funciona 100% OFFLINE: valida contra SQLite local.
/// ─────────────────────────────────────────────────────────────────
class AuthRepositoryImpl implements AuthRepository {
  final AppDatabase _db;
  static const _kSesionUserId = 'alexmar_sesion_user_id';

  AuthRepositoryImpl(this._db);

  @override
  Future<ResultadoLogin> login(String usuario, String password) async {
    final row = await _db.buscarPorUsuario(usuario);

    // Mensaje deliberadamente idéntico para usuario inexistente y
    // contraseña errónea: no le regalamos pistas a un atacante.
    const credencialesInvalidas =
        LoginFallido('CREDENCIALES INVÁLIDAS. VERIFIQUE E INTENTE DE NUEVO.');

    if (row == null) return credencialesInvalidas;

    if (!row.activo) {
      return const LoginFallido(
          'USUARIO DESACTIVADO. CONTACTE AL ADMINISTRADOR.');
    }

    final hashIntento = AppDatabase.hashPassword(password, row.salt);
    if (hashIntento != row.passwordHash) return credencialesInvalidas;

    // Persistir sesión para no pedir login en cada apertura
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSesionUserId, row.id);

    return LoginExitoso(_mapear(row));
  }

  @override
  Future<Usuario?> restaurarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_kSesionUserId);
    if (id == null) return null;

    final row = await _db.buscarPorId(id);
    if (row == null || !row.activo) {
      // Sesión huérfana o usuario desactivado mientras estaba fuera
      await prefs.remove(_kSesionUserId);
      return null;
    }
    return _mapear(row);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSesionUserId);
  }

  Usuario _mapear(UsuarioRow row) => Usuario(
        id: row.id,
        nombreCompleto: row.nombreCompleto,
        usuario: row.usuario,
        rol: RolUsuario.fromDb(row.rol),
        activo: row.activo,
      );
}
