import '../entities/linea_cuenta.dart';

/// 👶 El contrato de la Hoja Individual: QUÉ se puede hacer con la
/// cuenta de un cliente, sin revelar CÓMO lo hace la base de datos.
abstract interface class CuentasRepository {
  /// Tubería en vivo: todas las líneas (cargos + abonos) del cliente,
  /// ordenadas por fecha. La lista crece sin límite (scroll infinito).
  Stream<List<LineaCuenta>> observarLineas(String idCliente);

  /// Tubería en vivo de los 3 totales del pie de pantalla
  Stream<ResumenCuenta> observarResumen(String idCliente);

  /// Agregar un producto o servicio (CARGO).
  /// Recalcula automáticamente la deuda del cliente en el Índice.
  Future<void> agregarCargo({
    required String idCliente,
    required double cantidad,
    required String descripcion,
    required double precioUnitario,
    double? costoUnitario, // 🔒 opcional: alimenta la Ganancia Neta del BI
  });

  /// ★ CARGA RÁPIDA ★: agrega VARIOS productos/servicios de una vez
  /// (una factura completa) con un solo recálculo. Todo-o-nada.
  Future<void> agregarCargos({
    required String idCliente,
    required List<NuevoCargo> cargos,
  });

  /// Registrar un pago (ABONO, la fila VERDE).
  /// Además actualiza la Fecha_Ultimo_Abono → el semáforo revive.
  Future<void> registrarAbono({
    required String idCliente,
    required String descripcion,
    required double monto,
  });

  /// Borrar una línea equivocada (con recálculo automático)
  Future<void> eliminarLinea(String idLinea, String idCliente);

  /// ★ VACIAR CUENTA ★ (FASE 10): marca como eliminadas TODAS las
  /// líneas activas del cliente de una vez (borrado lógico masivo,
  /// con recálculo y sincronización a Sheets). Útil cuando un cliente
  /// cancela todo pero sigue siendo recurrente: se vacía su hoja
  /// actual sin crear una nueva. La ficha del cliente NO se toca,
  /// solo su historial de movimientos. Devuelve cuántos se vaciaron.
  Future<int> vaciarCuenta(String idCliente);

  /// ★ EDITAR DATOS DE UN CLIENTE YA EXISTENTE ★
  /// 👶 Corrige nombre/cédula/teléfono/dirección de un cliente que ya
  /// tiene cuenta e historial. NO toca cargos ni abonos, solo la ficha.
  /// El cambio se sincroniza solo a Sheets en el próximo ciclo.
  Future<void> actualizarDatosCliente({
    required String idCliente,
    required String nombreCliente,
    String? cedula,
    String? telefono,
    String? direccion,
  });
}
