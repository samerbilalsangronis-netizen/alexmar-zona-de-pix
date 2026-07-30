import '../entities/nota.dart';

/// ─────────────────────────────────────────────────────────────────
/// CONTRATO: NotasRepository (FASE 9)
/// Define QUÉ se puede hacer con las notas, sin decir CÓMO.
/// La implementación real vive en data/repositories/.
/// ─────────────────────────────────────────────────────────────────
abstract class NotasRepository {
  /// Todas las notas vivas, en vivo (la pizarra se repinta sola).
  Stream<List<Nota>> observarNotas();

  /// Crear una nota nueva. Nada es obligatorio.
  Future<void> crearNota({
    String? titulo,
    String? contenido,
    String color,
  });

  /// Editar una nota existente (título, contenido y/o color).
  Future<void> editarNota({
    required String id,
    String? titulo,
    String? contenido,
    required String color,
  });

  /// Eliminar una nota (borrado lógico, viaja al espejo de Sheets).
  Future<void> eliminarNota(String id);
}
