/// ─────────────────────────────────────────────────────────────────
/// CAPA DOMAIN · Cierre Mensual (Business Intelligence).
///
/// 👶 EXPLICACIÓN: Un "cierre mensual" es una FOTOGRAFÍA congelada
/// de las finanzas de un mes ya terminado. Una vez tomada, no cambia
/// jamás (los meses pasados no se editan). Con 12 fotografías se arma
/// la película del año: crecimiento, mes récord y efectividad.
/// Todos los montos en DÓLARES NETOS ($).
/// ─────────────────────────────────────────────────────────────────

const nombresMeses = [
  'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
  'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE',
];

class CierreMensual {
  final String id;            // UUID (espejo: CIERRES_MENSUALES.ID_Cierre)
  final int anio;             // → Anio (ej: 2026)
  final int mes;              // → Mes (1 a 12)
  final double totalFacturado;       // Σ de CARGOS del mes ($)
  final double totalCobrado;         // Σ de ABONOS del mes ($)
  final double gananciaNeta;         // Facturado − costo de lo vendido ($)
  final double carteraPendienteCierre; // Foto del total en la calle al cerrar
  final DateTime fechaCierre;

  const CierreMensual({
    required this.id,
    required this.anio,
    required this.mes,
    required this.totalFacturado,
    required this.totalCobrado,
    required this.gananciaNeta,
    required this.carteraPendienteCierre,
    required this.fechaCierre,
  });

  String get nombreMes => nombresMeses[mes - 1];

  /// ★ EFECTIVIDAD DE COBRO ★
  /// De cada $100 facturados en el mes, ¿cuántos entraron en caja?
  /// (Cobrado ÷ Facturado) × 100. Si no se facturó nada, es 0.
  double get efectividadCobro =>
      totalFacturado <= 0 ? 0 : (totalCobrado / totalFacturado) * 100;
}

/// El consolidado de los 12 meses para el Reporte Ejecutivo Anual
class ResumenAnual {
  final int anio;
  final List<CierreMensual> cierres; // Solo los meses cerrados del año

  const ResumenAnual({required this.anio, required this.cierres});

  double get facturadoAnual =>
      cierres.fold(0, (s, c) => s + c.totalFacturado);
  double get cobradoAnual => cierres.fold(0, (s, c) => s + c.totalCobrado);
  double get gananciaAnual => cierres.fold(0, (s, c) => s + c.gananciaNeta);

  double get efectividadAnual =>
      facturadoAnual <= 0 ? 0 : (cobradoAnual / facturadoAnual) * 100;

  /// "EL MES RÉCORD" en ventas (el de mayor facturación)
  CierreMensual? get mesRecordVentas => cierres.isEmpty
      ? null
      : cierres.reduce(
          (a, b) => a.totalFacturado >= b.totalFacturado ? a : b);

  /// "EL MES RÉCORD" en cobranza (el de mayor recaudación)
  CierreMensual? get mesRecordCobranza => cierres.isEmpty
      ? null
      : cierres.reduce((a, b) => a.totalCobrado >= b.totalCobrado ? a : b);

  /// ★ CURVA DE CRECIMIENTO ★
  /// Compara la facturación del primer mes con datos contra la del
  /// último: +35.0 significa "el taller creció 35% en el año".
  double? get crecimientoPorcentual {
    final conVentas =
        cierres.where((c) => c.totalFacturado > 0).toList();
    if (conVentas.length < 2) return null; // Falta historia para comparar
    final primero = conVentas.first.totalFacturado;
    final ultimo = conVentas.last.totalFacturado;
    return ((ultimo - primero) / primero) * 100;
  }
}
