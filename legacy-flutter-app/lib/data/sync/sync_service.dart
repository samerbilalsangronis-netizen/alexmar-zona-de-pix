import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/cliente.dart';
import '../local/app_database.dart';
import 'sheets_api_client.dart';

/// Estado visible del motor (para el indicador en pantalla)
enum EstadoSync {
  inactivo,      // Esperando su próximo turno
  sincronizando, // Subiendo datos ahora mismo
  sinConexion,   // No hay internet: la cola espera paciente
  noConfigurado, // Aún no se ha pegado la URL del Apps Script
}

/// ─────────────────────────────────────────────────────────────────
/// MOTOR DE SINCRONIZACIÓN OFFLINE-FIRST · "El mensajero"
///
/// 👶 EXPLICACIÓN DEL CICLO (así de simple):
///  1. Tú guardas un cliente → se escribe en SQLite con la
///     banderita `pendienteSync = true`. La app sigue su vida.
///  2. Cada 40 segundos, Y ADEMÁS cada vez que el teléfono detecta
///     que volvió el internet, este motor despierta.
///  3. Pregunta a la base: "¿hay banderitas encendidas?"
///  4. Si hay internet, empaqueta esas filas y se las manda al
///     Apps Script de Google Sheets.
///  5. Solo si Google confirma "ok", apaga las banderitas.
///     Si algo falla, no apaga nada: se reintenta en el próximo
///     ciclo. NUNCA se pierde un dato.
///
/// ★ FASE 10: el ciclo bajó de 60s a 40s para que los cambios
/// (cargos, notas, vaciados...) viajen más rápido entre dispositivos.
/// ─────────────────────────────────────────────────────────────────
class SyncService {
  final AppDatabase _db;
  final SheetsApiClient _api;

  Timer? _temporizador;
  StreamSubscription? _vigiaConexion;
  bool _ocupado = false; // Evita dos sincronizaciones a la vez

  final ValueNotifier<EstadoSync> estado =
      ValueNotifier(EstadoSync.inactivo);
  final ValueNotifier<DateTime?> ultimaSyncExitosa = ValueNotifier(null);

  SyncService(this._db, this._api);

  /// Encender el motor (se llama una sola vez al iniciar la app)
  void iniciar() {
    // Reloj: intenta cada 40 segundos (antes 60)
    _temporizador =
        Timer.periodic(const Duration(seconds: 40), (_) => sincronizarAhora());

    // Oído: si el internet vuelve, intenta de inmediato sin esperar el reloj
    _vigiaConexion =
        Connectivity().onConnectivityChanged.listen((resultados) {
      final hayRed = resultados.any((r) => r != ConnectivityResult.none);
      if (hayRed) sincronizarAhora();
    });

    sincronizarAhora(); // Primer intento al arrancar
  }

  /// Un ciclo completo del mensajero
  Future<void> sincronizarAhora() async {
    if (_ocupado) return;
    _ocupado = true;

    try {
      if (!_api.configurado) {
        estado.value = EstadoSync.noConfigurado;
        return;
      }

      final conexion = await Connectivity().checkConnectivity();
      final hayRed = conexion.any((r) => r != ConnectivityResult.none);
      if (!hayRed) {
        estado.value = EstadoSync.sinConexion;
        return;
      }

      estado.value = EstadoSync.sincronizando;

      await _subirClientesPendientes();
      await _subirDetallePendientes();
      await _subirInventarioPendiente();
      await _subirNotasPendientes(); // ★ FASE 9
      await _subirCierresPendientes();
      await _subirUsuariosPendientes();

      ultimaSyncExitosa.value = DateTime.now();
      estado.value = EstadoSync.inactivo;
    } finally {
      _ocupado = false;
    }
  }

  Future<void> _subirClientesPendientes() async {
    final pendientes = await _db.clientesPendientesDeSync();
    if (pendientes.isEmpty) return;

    // Empaquetar cada fila con los MISMOS nombres de columna que la
    // pestaña CLIENTES de ALEXMAR_DB (espejo exacto, sin sorpresas).
    final filas = pendientes.map((c) {
      final estatus =
          EstatusCartera.calcular(c.fechaUltimoAbono ?? c.fechaCreacion);
      return {
        'ID_Cliente': c.id,
        'Cedula': c.cedula ?? '',
        'Nombre_Cliente': c.nombreCliente,
        'Telefono': c.telefono,
        'Direccion': c.direccion ?? '',
        'Factura_N': c.facturaN,
        'Fecha_Ultimo_Abono': c.fechaUltimoAbono?.toIso8601String() ?? '',
        'Estatus': estatus.toDb(),
        'Total_Adeudado': c.totalAdeudado, // En dólares ($)
        'Eliminado': c.eliminado ? 'SI' : 'NO',
        'Fecha_Creacion': c.fechaCreacion.toIso8601String(),
        'Fecha_Modificacion': c.fechaModificacion.toIso8601String(),
      };
    }).toList();

    final ok = await _api.subirLote(tabla: 'CLIENTES', filas: filas);
    if (ok) {
      await _db
          .marcarClientesSincronizados(pendientes.map((c) => c.id).toList());
    }
  }

  Future<void> _subirDetallePendientes() async {
    final pendientes = await _db.lineasPendientesDeSync();
    if (pendientes.isEmpty) return;

    // Espejo exacto de la pestaña DETALLE_CUENTAS de ALEXMAR_DB
    final filas = pendientes
        .map((l) => {
              'ID_Linea': l.id,
              'ID_Cliente': l.idCliente,
              'Tipo_Linea': l.tipoLinea,
              'Fecha': l.fecha.toIso8601String(),
              'Cantidad': l.cantidad,
              'Descripcion': l.descripcion,
              'Precio_Unitario': l.precioUnitario ?? '',
              'Total_Linea': l.totalLinea, // En dólares ($)
              'ID_Producto': l.idProducto ?? '',
              'Eliminado': l.eliminado ? 'SI' : 'NO',
              'Fecha_Creacion': l.fechaCreacion.toIso8601String(),
              'Fecha_Modificacion': l.fechaModificacion.toIso8601String(),
            })
        .toList();

    final ok = await _api.subirLote(tabla: 'DETALLE_CUENTAS', filas: filas);
    if (ok) {
      await _db
          .marcarLineasSincronizadas(pendientes.map((l) => l.id).toList());
    }
  }

  Future<void> _subirInventarioPendiente() async {
    final pendientes = await _db.productosPendientesDeSync();
    if (pendientes.isEmpty) return;

    // ★ FASE 8 — Espejo exacto de la pestaña INVENTARIO de ALEXMAR_DB.
    // 🐛 BUG CORREGIDO: antes se enviaban nombres que NO existían en
    // Sheets (Categoria_Tags, Costo, PVP, Stock_Actual...) y esas
    // columnas se perdían en el viaje. Ahora cada campo viaja con el
    // nombre EXACTO de su columna en Sheets.
    // Nota: si la foto aún es una ruta local del teléfono, al espejo
    // viaja vacía; cuando se active la subida a la nube (FotoService.
    // subirANube) viajará el link https definitivo.
    final filas = pendientes
        .map((pr) => {
              'ID_Producto': pr.id,
              'Categoria': pr.categoriaTags,
              'Nombre_Producto': pr.nombreProducto,
              'Descripcion': pr.descripcion ?? '',
              'Compatibilidad_Vehiculos': pr.compatibilidadVehiculos,
              // Precios opcionales: null viaja como celda vacía
              'Precio_Publico': pr.pvp ?? '',  // En dólares ($)
              'Precio_Compra': pr.costo ?? '', // En dólares ($) — solo JEFE
              'Unidades_Disponibles': pr.stockActual,
              'Stock_Minimo': pr.stockMinimo,
              'URL_Foto':
                  pr.urlFoto != null && pr.urlFoto!.startsWith('http')
                      ? pr.urlFoto
                      : '',
              'Eliminado': pr.eliminado ? 'SI' : 'NO',
              'Fecha_Creacion': pr.fechaCreacion.toIso8601String(),
              'Fecha_Modificacion': pr.fechaModificacion.toIso8601String(),
            })
        .toList();

    final ok = await _api.subirLote(tabla: 'INVENTARIO', filas: filas);
    if (ok) {
      await _db.marcarProductosSincronizados(
          pendientes.map((pr) => pr.id).toList());
    }
  }

  /// ★ FASE 9 — Subir las notas de la pizarra a la pestaña NOTAS.
  /// Mismo patrón probado de las demás tablas: empaquetar con los
  /// nombres EXACTOS de columna de Sheets, y apagar las banderitas
  /// solo cuando Google confirma "ok".
  Future<void> _subirNotasPendientes() async {
    final pendientes = await _db.notasPendientesDeSync();
    if (pendientes.isEmpty) return;

    final filas = pendientes
        .map((n) => {
              'ID_Nota': n.id,
              'Titulo': n.titulo ?? '',
              'Contenido': n.contenido ?? '',
              'Color': n.color,
              'Eliminado': n.eliminado ? 'SI' : 'NO',
              'Fecha_Creacion': n.fechaCreacion.toIso8601String(),
              'Fecha_Modificacion': n.fechaModificacion.toIso8601String(),
            })
        .toList();

    final ok = await _api.subirLote(tabla: 'NOTAS', filas: filas);
    if (ok) {
      await _db
          .marcarNotasSincronizadas(pendientes.map((n) => n.id).toList());
    }
  }

  Future<void> _subirCierresPendientes() async {
    final pendientes = await _db.cierresPendientesDeSync();
    if (pendientes.isEmpty) return;

    // Espejo exacto de la pestaña CIERRES_MENSUALES de ALEXMAR_DB
    final filas = pendientes
        .map((c) => {
              'ID_Cierre': c.id,
              'Anio': c.anio,
              'Mes': c.mes,
              'Total_Facturado': c.totalFacturado, // $ netos
              'Total_Cobrado': c.totalCobrado,     // $ netos
              'Ganancia_Neta': c.gananciaNeta,     // $ netos
              'Cartera_Pendiente_Cierre': c.carteraPendienteCierre,
              'Fecha_Cierre': c.fechaCierre.toIso8601String(),
            })
        .toList();

    final ok =
        await _api.subirLote(tabla: 'CIERRES_MENSUALES', filas: filas);
    if (ok) {
      await _db
          .marcarCierresSincronizados(pendientes.map((c) => c.id).toList());
    }
  }

  Future<void> _subirUsuariosPendientes() async {
    final pendientes = await _db.usuariosPendientesDeSync();
    if (pendientes.isEmpty) return;

    final filas = pendientes
        .map((u) => {
              'ID_Usuario': u.id,
              'Nombre_Completo': u.nombreCompleto,
              'Usuario': u.usuario,
              'Password_Hash': u.passwordHash, // Hash, JAMÁS la contraseña
              'Rol': u.rol,
              'Activo': u.activo ? 'SI' : 'NO',
              'Fecha_Creacion': u.fechaCreacion.toIso8601String(),
              'Fecha_Modificacion': u.fechaModificacion.toIso8601String(),
            })
        .toList();

    final ok = await _api.subirLote(tabla: 'USUARIOS', filas: filas);
    if (ok) {
      await _db
          .marcarUsuariosSincronizados(pendientes.map((u) => u.id).toList());
    }
  }

  /// Apagar el motor (al cerrar la app)
  void detener() {
    _temporizador?.cancel();
    _vigiaConexion?.cancel();
  }
}
