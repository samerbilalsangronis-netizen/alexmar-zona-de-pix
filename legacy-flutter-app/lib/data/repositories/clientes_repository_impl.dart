import 'package:drift/drift.dart';

import '../../domain/entities/cliente.dart';
import '../../domain/repositories/clientes_repository.dart';
import '../local/app_database.dart';

/// ─────────────────────────────────────────────────────────────────
/// 👶 EXPLICACIÓN: Esta clase es el "traductor". La base de datos
/// habla en filas (ClienteRow) y el negocio habla en entidades
/// (Cliente). Aquí se traduce de un idioma al otro, y nada más.
/// ─────────────────────────────────────────────────────────────────
class ClientesRepositoryImpl implements ClientesRepository {
  final AppDatabase _db;
  ClientesRepositoryImpl(this._db);

  @override
  Stream<List<Cliente>> observarIndice() =>
      _db.observarClientesActivos().map(
            (filas) => filas.map(_mapear).toList(),
          );

  @override
  Stream<double> observarTotalGeneral() => _db.observarTotalGeneral();

  /// ★ FOLIO AUTOMÁTICO ★
  /// 👶 Cómo funciona: lee TODOS los folios usados en la historia
  /// (incluso de clientes borrados), extrae el número más alto y
  /// suma 1. padLeft(3, '0') lo viste con ceros: 1 → "001", 99 →
  /// "099", 100 → "100". Si el día de mañana hay folios viejos con
  /// letras, se ignoran las letras y se rescatan los dígitos.
  @override
  Future<String> proximoFolio() async {
    final folios = await _db.todosLosFolios();
    var mayor = 0;
    for (final f in folios) {
      final soloDigitos = f.replaceAll(RegExp(r'[^0-9]'), '');
      final n = int.tryParse(soloDigitos);
      if (n != null && n > mayor) mayor = n;
    }
    return (mayor + 1).toString().padLeft(3, '0');
  }

  @override
  Future<void> agregarCliente({
    String? cedula,
    required String nombre,
    String? telefono, // Opcional
    String? direccion,
  }) async {
    final ahora = DateTime.now();
    await _db.insertarCliente(
      ClientesCompanion.insert(
        id: AppDatabase.generarUuid(),
        cedula: Value(cedula?.trim().isEmpty ?? true ? null : cedula!.trim()),
        nombreCliente: nombre.trim(),
        telefono: Value(telefono?.trim().isEmpty ?? true ? null : telefono!.trim()),
        direccion:
            Value(direccion?.trim().isEmpty ?? true ? null : direccion!.trim()),
        facturaN: Value(await proximoFolio()), // ← El sistema asigna el folio
        totalAdeudado: const Value(0),  // ← Nace en $0: los cargos van
        fechaCreacion: ahora,           //   en su Hoja Individual
        fechaModificacion: ahora,
        // pendienteSync nace en true por defecto → entra a la cola del espejo
      ),
    );
  }

  @override
  Future<void> eliminarCliente(String idCliente) =>
      // Cascada: marca al cliente Y todas sus líneas como eliminados,
      // todo dentro de una transacción (todo-o-nada).
      _db.eliminarClienteEnCascada(idCliente);

  Cliente _mapear(ClienteRow row) => Cliente(
        id: row.id,
        cedula: row.cedula,
        nombre: row.nombreCliente,
        telefono: row.telefono,
        direccion: row.direccion,
        facturaN: row.facturaN,
        fechaUltimoAbono: row.fechaUltimoAbono,
        totalAdeudado: row.totalAdeudado,
        fechaCreacion: row.fechaCreacion,
      );
}
