/// ─────────────────────────────────────────────────────────────────
/// CAPA DOMAIN · Entidad pura, sin dependencias de Flutter ni Drift.
/// ─────────────────────────────────────────────────────────────────

/// Roles del sistema. La seguridad de toda la app pivota sobre esto.
enum RolUsuario {
  /// Modo JEFE: acceso total (costos, ganancias, deudas, clientes, reportes)
  admin,

  /// Vista Catálogo: SOLO buscador, productos, compatibilidad y PVP.
  /// Bloqueado: costos, ganancias, deudas, índice de clientes.
  empleado;

  /// Serialización estable hacia SQLite y Google Sheets
  String toDb() => switch (this) {
        RolUsuario.admin => 'ADMIN',
        RolUsuario.empleado => 'EMPLEADO',
      };

  static RolUsuario fromDb(String value) => switch (value.toUpperCase()) {
        'ADMIN' => RolUsuario.admin,
        _ => RolUsuario.empleado, // Ante cualquier duda: el rol MENOS privilegiado
      };
}

class Usuario {
  final String id; // UUID generado por la app (espejo: USUARIOS.ID_Usuario)
  final String nombreCompleto;
  final String usuario; // Nombre de login, único
  final RolUsuario rol;
  final bool activo;

  const Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.usuario,
    required this.rol,
    required this.activo,
  });

  bool get esAdmin => rol == RolUsuario.admin;
}
