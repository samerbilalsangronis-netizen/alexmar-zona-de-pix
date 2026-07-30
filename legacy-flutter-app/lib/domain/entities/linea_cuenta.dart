/// ─────────────────────────────────────────────────────────────────
/// CAPA DOMAIN · Línea de la Hoja Individual del Cliente.
///
/// 👶 EXPLICACIÓN: Como acordamos en el diseño, CARGOS (productos y
/// servicios que SUMAN deuda) y ABONOS (pagos que RESTAN deuda)
/// viven en LA MISMA lista, diferenciados por `tipo`. Así el scroll
/// de la pantalla es una sola columna ordenada por fecha, igual que
/// la página física del índice, y la matemática es simple:
///
///     SALDO PENDIENTE = (suma de CARGOS) − (suma de ABONOS)
/// ─────────────────────────────────────────────────────────────────

enum TipoLinea {
  cargo, // Producto o servicio → SUMA a la deuda
  abono, // Pago del cliente   → RESTA (fila resaltada en VERDE)
  titulo; // Separador de vehículo (ej: "NPR") → NO suma ni resta nada

  String toDb() => switch (this) {
        TipoLinea.cargo => 'CARGO',
        TipoLinea.abono => 'ABONO',
        TipoLinea.titulo => 'TITULO',
      };

  static TipoLinea fromDb(String v) {
    final up = v.toUpperCase();
    if (up == 'ABONO') return TipoLinea.abono;
    if (up == 'TITULO') return TipoLinea.titulo;
    return TipoLinea.cargo;
  }
}

class LineaCuenta {
  final String id;            // UUID (espejo: DETALLE_CUENTAS.ID_Linea)
  final String idCliente;     // A qué cliente pertenece (clave foránea)
  final TipoLinea tipo;
  final DateTime fecha;
  final double cantidad;      // En abonos SIEMPRE es 1 (regla del negocio)
  final String descripcion;   // Producto-Servicio o descripción del pago
  final double? precioUnitario; // Vacío (null) en los abonos
  final double totalLinea;    // CARGO: cantidad × P.Unit · ABONO: monto pagado

  const LineaCuenta({
    required this.id,
    required this.idCliente,
    required this.tipo,
    required this.fecha,
    required this.cantidad,
    required this.descripcion,
    this.precioUnitario,
    required this.totalLinea,
  });

  bool get esAbono => tipo == TipoLinea.abono;
  bool get esTitulo => tipo == TipoLinea.titulo;
}

/// Resumen matemático de la cuenta (los 3 totales del pie de pantalla)
class ResumenCuenta {
  final double totalConsumido; // Σ de todos los CARGOS ($)
  final double totalAbonado;   // Σ de todos los ABONOS ($)

  const ResumenCuenta({
    required this.totalConsumido,
    required this.totalAbonado,
  });

  /// La resta sagrada del negocio, calculada SIEMPRE al vuelo:
  double get saldoPendiente => totalConsumido - totalAbonado;
}

/// Una fila de la CARGA RÁPIDA, lista para guardarse en lote.
/// 👶 Es el "borrador" de un cargo: la rejilla junta varios de estos
/// y los entrega todos juntos al repositorio de un solo golpe.
class NuevoCargo {
  final double cantidad;
  final String descripcion;
  final double precioUnitario;
  final double? costoUnitario; // 🔒 opcional, alimenta la Ganancia Neta

  const NuevoCargo({
    required this.cantidad,
    required this.descripcion,
    required this.precioUnitario,
    this.costoUnitario,
  });
}
