import 'package:drift/drift.dart';

import '../../domain/entities/nota.dart';
import '../../domain/repositories/notas_repository.dart';
import '../local/app_database.dart';

/// ─────────────────────────────────────────────────────────────────
/// IMPLEMENTACIÓN: NotasRepositoryImpl (FASE 9)
///
/// 👶 El puente entre la pizarra (pantalla) y la base de datos:
///  · Guarda en SQLite local al instante (offline-first).
///  · Marca pendienteSync = true → el mensajero (SyncService) la
///    sube a la pestaña NOTAS de Sheets en su próximo ciclo de 60s.
///  · Los cambios hechos en otra PC bajan solos con el polling.
/// ─────────────────────────────────────────────────────────────────
class NotasRepositoryImpl implements NotasRepository {
  final AppDatabase _db;

  NotasRepositoryImpl(this._db);

  @override
  Stream<List<Nota>> observarNotas() =>
      _db.observarNotasActivas().map((filas) => filas
          .map((n) => Nota(
                id: n.id,
                titulo: n.titulo,
                contenido: n.contenido,
                color: n.color,
                fechaCreacion: n.fechaCreacion,
                fechaModificacion: n.fechaModificacion,
              ))
          .toList());

  @override
  Future<void> crearNota({
    String? titulo,
    String? contenido,
    String color = 'NARANJA',
  }) {
    final ahora = DateTime.now();
    return _db.insertarNota(
      NotasCompanion.insert(
        id: AppDatabase.generarUuid(),
        titulo: Value(_limpiar(titulo)),
        contenido: Value(_limpiar(contenido)),
        color: Value(color),
        fechaCreacion: ahora,
        fechaModificacion: ahora,
        pendienteSync: const Value(true),
      ),
    );
  }

  @override
  Future<void> editarNota({
    required String id,
    String? titulo,
    String? contenido,
    required String color,
  }) =>
      _db.actualizarNotaPorId(
        id,
        NotasCompanion(
          titulo: Value(_limpiar(titulo)),
          contenido: Value(_limpiar(contenido)),
          color: Value(color),
          fechaModificacion: Value(DateTime.now()),
          pendienteSync: const Value(true),
        ),
      );

  @override
  Future<void> eliminarNota(String id) => _db.marcarNotaEliminada(id);

  /// Texto vacío o solo espacios → null (celda vacía en Sheets)
  String? _limpiar(String? texto) {
    final t = texto?.trim() ?? '';
    return t.isEmpty ? null : t;
  }
}
