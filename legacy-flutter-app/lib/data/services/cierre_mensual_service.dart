import 'package:drift/drift.dart';

import '../local/app_database.dart';

/// ─────────────────────────────────────────────────────────────────
/// MOTOR DE CIERRE MENSUAL AUTOMÁTICO · "El contador nocturno"
///
/// 👶 ¿CÓMO FUNCIONA? Cada vez que el ADMIN abre la app, este motor
/// se hace una pregunta simple: "¿hay meses TERMINADOS que aún no
/// tienen su fotografía financiera?". Si los hay, los fotografía uno
/// por uno y guarda el cierre. Es IDEMPOTENTE: aunque revise mil
/// veces, jamás duplica un cierre (primero pregunta si ya existe).
///
/// ¿Por qué "al abrir la app" y no "a medianoche del día 31"?
/// Porque un teléfono puede estar apagado esa noche. Con esta
/// estrategia, el cierre se genera en cuanto alguien abre la app en
/// el mes nuevo, con los MISMOS datos exactos. Cero pérdidas.
///
/// LA MATEMÁTICA DE CADA FOTOGRAFÍA (todo en $ netos):
///   Total_Facturado = Σ CARGOS del mes
///   Total_Cobrado   = Σ ABONOS del mes
///   Ganancia_Neta   = Facturado − Σ (costo unitario × cantidad)
///     · Si una línea no tiene costo registrado (típico en SERVICIOS
///       como mano de obra), su costo cuenta como $0 → ganancia plena.
///   Cartera_Pendiente_Cierre = total en la calle al momento del cierre
/// ─────────────────────────────────────────────────────────────────
class CierreMensualService {
  final AppDatabase _db;
  CierreMensualService(this._db);

  /// Revisa toda la historia y genera los cierres que falten.
  /// Devuelve cuántas fotografías nuevas tomó.
  Future<int> verificarYGenerarCierres() async {
    final primerMovimiento = await _db.primeraFechaMovimiento();
    if (primerMovimiento == null) return 0; // Aún no hay historia

    // Cursor: arranca en el mes del primer movimiento...
    var cursor = DateTime(primerMovimiento.year, primerMovimiento.month);
    final ahora = DateTime.now();
    // ...y avanza SOLO por meses ya terminados (nunca el mes en curso,
    // porque su película aún no acaba).
    final mesEnCurso = DateTime(ahora.year, ahora.month);

    var generados = 0;
    while (cursor.isBefore(mesEnCurso)) {
      final yaExiste = await _db.existeCierre(cursor.year, cursor.month);
      if (!yaExiste) {
        await _fotografiarMes(cursor.year, cursor.month);
        generados++;
      }
      // Saltar al mes siguiente (Dart normaliza mes 13 → enero del otro año)
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return generados;
  }

  /// Toma la fotografía financiera de UN mes terminado
  Future<void> _fotografiarMes(int anio, int mes) async {
    final inicio = DateTime(anio, mes);          // Día 1 a las 00:00
    final fin = DateTime(anio, mes + 1);         // Día 1 del mes siguiente
    final lineas = await _db.lineasDelRango(inicio, fin);

    double facturado = 0, cobrado = 0, costoVendido = 0;
    for (final l in lineas) {
      // Los títulos de vehículo son separadores visuales, no dinero
      if (l.tipoLinea == 'TITULO') continue;
      if (l.tipoLinea == 'ABONO') {
        cobrado += l.totalLinea;
      } else {
        facturado += l.totalLinea;
        // Costo congelado al momento de la venta (0 si no se registró)
        costoVendido += (l.costoUnitario ?? 0) * l.cantidad;
      }
    }

    await _db.insertarCierre(
      CierresMensualesCompanion.insert(
        id: AppDatabase.generarUuid(),
        anio: anio,
        mes: mes,
        totalFacturado: facturado,
        totalCobrado: cobrado,
        gananciaNeta: facturado - costoVendido,
        carteraPendienteCierre: await _db.totalGeneralAhora(),
        fechaCierre: DateTime.now(),
        // pendienteSync nace true → viaja solo al espejo de Sheets
      ),
    );
  }
}
