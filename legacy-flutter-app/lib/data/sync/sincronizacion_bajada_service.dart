import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../local/app_database.dart';
import '../sync/sheets_api_client.dart';

/// ─────────────────────────────────────────────────────────────────
/// SERVICIO DE BAJADA INTELIGENTE (Sheets → App)
///
/// 👶 CÓMO FUNCIONA (la estrategia inteligente):
///
///  1. Cada 40 segundos, la app le pregunta a Sheets:
///     "¿Cuándo fue tu último cambio?"
///
///  2. Sheets responde con un número (timestamp en milisegundos).
///
///  3. La app compara ese número con el de su última sincronización
///     (guardado en el dispositivo):
///     · Si Sheets cambió DESPUÉS → descarga los datos nuevos.
///     · Si Sheets NO cambió → no descarga nada. Cero tráfico.
///
///  4. Cuando alguien escribe en Sheets directamente, en menos de
///     40 segundos aparece en todas las apps automáticamente.
///
///  5. Cuando la base local está vacía (web recién abierta), siempre
///     descarga sin preguntar el timestamp (no hay nada que perder).
///
/// ★ FASE 10: el ciclo bajó de 2 min a 40s para que los cambios
/// entre dispositivos (cargos, notas, vaciados) aparezcan más rápido.
///
/// VENTAJA: cuando Sheets tiene 50+ clientes, solo descarga si hay
/// cambios reales — no todo cada ciclo. Eficiente y rápido.
/// ─────────────────────────────────────────────────────────────────
class SincronizacionBajadaService {
  final AppDatabase _db;

  // Clave donde guardamos cuándo fue la última sincronización exitosa
  static const _keyUltimaSync = 'alexmar_ultima_sync_ms';

  // 🔍 CHIVATO DE DIAGNÓSTICO (temporal): guarda el detalle del último
  // intento de DESCARGA, para ver POR QUÉ falla. Se quita al resolver.
  static String ultimoDiagnosticoBajada = 'aún no se ha intentado descargar';

  // El temporizador del polling (pregunta cada 40 segundos)
  Timer? _timer;

  SincronizacionBajadaService(this._db, SheetsApiClient _);

  /// ── Arrancar el motor de polling ──
  /// Llámalo una vez al iniciar la app. Cada 40 segundos verifica si
  /// hay cambios en Sheets y descarga solo si los hay.
  void iniciarPolling() {
    _timer?.cancel();
    // Verificar inmediatamente al arrancar, luego cada 40 segundos
    _verificarYSincronizar();
    _timer = Timer.periodic(
      const Duration(seconds: 40),
      (_) => _verificarYSincronizar(),
    );
  }

  /// Detener el polling (cuando el usuario cierra sesión)
  void detenerPolling() => _timer?.cancel();

  /// ── Verificación inteligente (el corazón del sistema) ──
  Future<void> _verificarYSincronizar() async {
    if (SheetsApiClient.urlWebApp.isEmpty) return;
    try {
      // 1) ¿Hay datos locales?
      final totalLocal = await _db.contarClientes();
      if (totalLocal == 0) {
        // Base vacía → descargar siempre sin preguntar timestamp
        await _descargarYCargar();
        return;
      }

      // 2) Preguntar a Sheets cuándo fue su último cambio
      final ultimoCambioSheets = await _consultarUltimoCambio();
      if (ultimoCambioSheets == null) return; // Sin internet o error

      // 3) Comparar con nuestra última sync guardada
      final prefs = await SharedPreferences.getInstance();
      final ultimaSyncLocal = prefs.getInt(_keyUltimaSync) ?? 0;

      if (ultimoCambioSheets > ultimaSyncLocal) {
        // Sheets tiene datos más nuevos → descargar
        await _descargarYCargar();
      }
      // Si no hay cambios → no hacer nada (cero tráfico)
    } catch (_) {
      // Error de red o cualquier otro: ignorar silenciosamente.
      // El siguiente ciclo lo reintentará solo.
    }
  }

  /// Consulta cuándo fue el último cambio en Sheets (timestamp en ms)
  Future<int?> _consultarUltimoCambio() async {
    final url =
        '${SheetsApiClient.urlWebApp}?clave=${SheetsApiClient.claveApi}&accion=ultimoCambio';
    final respuesta = await _hacerGet(url);
    if (respuesta == null) return null;
    final json = jsonDecode(respuesta) as Map<String, dynamic>;
    if (json['ok'] != true) return null;
    return (json['ultimoCambio'] as num?)?.toInt();
  }

  /// Descarga clientes + detalles + inventario + notas de Sheets y
  /// los carga en la base local. ★ FASE 8 sumó el INVENTARIO;
  /// ★ FASE 9 suma las NOTAS (pizarra del jefe).
  Future<void> _descargarYCargar() async {
    final clientes = await _descargarTabla('CLIENTES');
    final detalles = await _descargarTabla('DETALLE_CUENTAS');
    final productos = await _descargarTabla('INVENTARIO');
    final notas = await _descargarNotasSeguro(); // ★ FASE 9
    await _db.reemplazarDesdNube(
      clientesJson: clientes,
      detallesJson: detalles,
    );
    await _db.reemplazarInventarioDesdeNube(productos);
    if (notas != null) await _db.reemplazarNotasDesdeNube(notas);
    // Guardar el timestamp de esta sync para la próxima comparación
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUltimaSync, DateTime.now().millisecondsSinceEpoch);
  }

  /// Versión pública para el botón ☁️ manual (con resumen para mostrar)
  Future<ResumenBajada> sincronizarDesdeNube() async {
    if (SheetsApiClient.urlWebApp.isEmpty) {
      throw Exception('La conexión con la nube no está configurada.');
    }
    final clientes = await _descargarTabla('CLIENTES');
    final detalles = await _descargarTabla('DETALLE_CUENTAS');
    final productos = await _descargarTabla('INVENTARIO'); // ★ FASE 8
    final notas = await _descargarNotasSeguro(); // ★ FASE 9
    await _db.reemplazarDesdNube(
      clientesJson: clientes,
      detallesJson: detalles,
    );
    await _db.reemplazarInventarioDesdeNube(productos); // ★ FASE 8
    if (notas != null) await _db.reemplazarNotasDesdeNube(notas); // ★ FASE 9
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUltimaSync, DateTime.now().millisecondsSinceEpoch);
    return ResumenBajada(
      clientesCargados: clientes.length,
      detallesCargados: detalles.length,
      productosCargados: productos.length,
      notasCargadas: notas?.length ?? 0,
    );
  }

  /// ★ FASE 9 — Bajada de NOTAS con red de seguridad.
  /// 👶 Si el Code.gs instalado todavía es viejo (v9.0, sin la tabla
  /// NOTAS), el servidor respondería "Tabla desconocida" y eso NO
  /// debe tumbar la bajada de clientes e inventario. Por eso:
  ///  · Si la descarga funciona → devuelve la lista (aunque venga vacía).
  ///  · Si falla → devuelve null y las notas locales se quedan como
  ///    están (jamás se borran por un error de red o de versión).
  Future<List<Map<String, dynamic>>?> _descargarNotasSeguro() async {
    try {
      return await _descargarTabla('NOTAS');
    } catch (_) {
      return null;
    }
  }

  /// Descarga una tabla específica de Sheets (maneja la redirección 302)
  Future<List<Map<String, dynamic>>> _descargarTabla(String tabla) async {
    final url =
        '${SheetsApiClient.urlWebApp}?clave=${SheetsApiClient.claveApi}&tabla=$tabla';
    final cuerpo = await _hacerGet(url);
    if (cuerpo == null) {
      // 🔍 Ahora el error dice EXACTAMENTE qué pasó y en qué tabla.
      throw Exception(
          'Sin respuesta del servidor [$tabla] → $ultimoDiagnosticoBajada');
    }
    final json = jsonDecode(cuerpo) as Map<String, dynamic>;
    if (json['ok'] != true) {
      throw Exception('El servidor rechazó [$tabla]: ${json['error']}');
    }
    return (json['filas'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /// GET universal: en web el navegador sigue el 302; en móvil lo hacemos
  /// a mano (el mismo patrón que usamos en la subida y que funciona bien)
  Future<String?> _hacerGet(String url) async {
    try {
      if (kIsWeb) {
        final resp = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 60));
        ultimoDiagnosticoBajada =
            'WEB · Código ${resp.statusCode} · cuerpo ${resp.body.length} chars';
        return resp.statusCode == 200 ? resp.body : null;
      }
      // Móvil/escritorio: seguir el 302 manualmente
      final cliente = http.Client();
      try {
        var destino = Uri.parse(url);
        for (var salto = 0; salto < 8; salto++) {
          final peticion = http.Request('GET', destino)
            ..followRedirects = false;
          final flujo = await cliente
              .send(peticion)
              .timeout(const Duration(seconds: 60));
          final resp = await http.Response.fromStream(flujo);
          if (resp.statusCode >= 300 && resp.statusCode < 400) {
            final loc = resp.headers['location'];
            if (loc == null) {
              ultimoDiagnosticoBajada =
                  'Salto $salto: redirección ${resp.statusCode} SIN location';
              return null;
            }
            destino = Uri.parse(loc);
            continue;
          }
          ultimoDiagnosticoBajada =
              'Salto $salto · Código ${resp.statusCode} · cuerpo ${resp.body.length} chars';
          return resp.statusCode == 200 ? resp.body : null;
        }
        ultimoDiagnosticoBajada =
            'Se superaron los 8 saltos de redirección sin llegar a la respuesta';
        return null;
      } finally {
        cliente.close();
      }
    } catch (e) {
      ultimoDiagnosticoBajada = 'EXCEPCIÓN: ${e.runtimeType} · $e';
      return null;
    }
  }
}

class ResumenBajada {
  final int clientesCargados;
  final int detallesCargados;
  final int productosCargados; // ★ FASE 8
  final int notasCargadas;     // ★ FASE 9
  const ResumenBajada({
    required this.clientesCargados,
    required this.detallesCargados,
    this.productosCargados = 0,
    this.notasCargadas = 0,
  });
  String get mensaje =>
      '$clientesCargados clientes, $detallesCargados líneas, '
      '$productosCargados productos y $notasCargadas notas '
      'cargados desde la nube. ✔';
}
