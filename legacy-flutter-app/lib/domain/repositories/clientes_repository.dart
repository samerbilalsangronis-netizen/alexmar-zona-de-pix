import '../entities/cliente.dart';

/// ─────────────────────────────────────────────────────────────────
/// 👶 EXPLICACIÓN: Este archivo es un "contrato". Dice QUÉ se puede
/// hacer con los clientes (verlos, agregarlos, borrarlos) pero no
/// CÓMO se hace por dentro. Las pantallas solo conocen este contrato.
/// Ventaja: si mañana cambiamos la base de datos, las pantallas no
/// se enteran ni se rompen.
/// ─────────────────────────────────────────────────────────────────
abstract interface class ClientesRepository {
  /// Un Stream es como una "tubería en vivo": cada vez que algo
  /// cambia en la base de datos, la lista llega sola a la pantalla
  /// sin que nadie tenga que refrescar a mano.
  Stream<List<Cliente>> observarIndice();

  /// Tubería en vivo del TOTAL GENERAL adeudado en la calle ($)
  Stream<double> observarTotalGeneral();

  /// El folio (Factura Nº) lo asigna el SISTEMA automáticamente:
  /// 001, 002... 099, 100... Nunca se repite ni se reutiliza.
  /// La cuenta nace en $0: los cargos se anotan en su Hoja Individual.
  Future<void> agregarCliente({
    String? cedula,
    required String nombre,
    String? telefono, // Opcional
    String? direccion,
  });

  /// El folio que recibirá el PRÓXIMO cliente (para mostrarlo en el
  /// formulario antes de guardar)
  Future<String> proximoFolio();

  /// Borrado LÓGICO: el cliente se marca como eliminado, no se
  /// destruye la fila (así el espejo de Sheets también se entera).
  /// La eliminación en cascada de sus cargos/abonos llega en Módulo 3.
  Future<void> eliminarCliente(String idCliente);
}
