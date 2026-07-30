/// ─────────────────────────────────────────────────────────────────
/// CAPA DOMAIN · Cliente del Índice Maestro.
///
/// 👶 EXPLICACIÓN PARA PRINCIPIANTES:
/// Una "entidad" es la ficha en limpio de un concepto del negocio.
/// Aquí decimos: "un Cliente tiene cédula, nombre, teléfono..." y
/// TAMBIÉN ponemos la regla del semáforo, porque esa regla es del
/// NEGOCIO (no de la pantalla ni de la base de datos). Así, si un
/// día cambian los días del semáforo, se cambia en UN solo lugar.
/// ─────────────────────────────────────────────────────────────────

/// El semáforo de cobranza con sus reglas oficiales:
enum EstatusCartera {
  verde,    // Activo: abonó hace 8 días o menos
  amarillo, // Inactivo: entre 9 y 15 días sin abonar
  rojo;     // Mora: más de 15 días sin abonar

  /// Texto que se muestra en pantalla y se guarda en el espejo de Sheets
  String get etiqueta => switch (this) {
        EstatusCartera.verde => 'ACTIVO',
        EstatusCartera.amarillo => 'INACTIVO',
        EstatusCartera.rojo => 'MORA',
      };

  String toDb() => switch (this) {
        EstatusCartera.verde => 'VERDE',
        EstatusCartera.amarillo => 'AMARILLO',
        EstatusCartera.rojo => 'ROJO',
      };

  /// ★ LA REGLA DE ORO DEL SEMÁFORO ★
  /// Recibe la fecha del último abono (o de creación de la cuenta si
  /// nunca ha abonado) y devuelve el color según los días pasados.
  static EstatusCartera calcular(DateTime fechaReferencia, {DateTime? hoy}) {
    final ahora = hoy ?? DateTime.now();
    final dias = ahora.difference(fechaReferencia).inDays;
    if (dias <= 8) return EstatusCartera.verde;
    if (dias <= 15) return EstatusCartera.amarillo;
    return EstatusCartera.rojo;
  }
}

class Cliente {
  final String id;              // UUID (espejo: CLIENTES.ID_Cliente)
  final String? cedula;         // Opcional, según regla del negocio
  final String nombre;
  final String? telefono; // Opcional: puede faltar
  final String? direccion;      // Se usa en la Hoja Individual (Módulo 3)
  final String? facturaN; // El sistema lo asigna; puede venir vacío de Sheets
  final DateTime? fechaUltimoAbono;
  final double totalAdeudado;   // SIEMPRE en dólares ($)
  final DateTime fechaCreacion;

  const Cliente({
    required this.id,
    this.cedula,
    required this.nombre,
    required this.telefono,
    this.direccion,
    required this.facturaN,
    this.fechaUltimoAbono,
    required this.totalAdeudado,
    required this.fechaCreacion,
  });

  /// Fecha desde la que se cuentan los días del semáforo:
  /// el último abono, o si nunca abonó, el día que se abrió la cuenta.
  DateTime get fechaReferenciaSemaforo => fechaUltimoAbono ?? fechaCreacion;

  /// El color se CALCULA al momento, nunca se confía en un dato viejo.
  EstatusCartera get estatus =>
      EstatusCartera.calcular(fechaReferenciaSemaforo);

  /// Días transcurridos (para mostrar "hace X días" en pantalla)
  int get diasSinAbonar =>
      DateTime.now().difference(fechaReferenciaSemaforo).inDays;
}
