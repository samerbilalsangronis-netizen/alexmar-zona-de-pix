import 'package:drift/drift.dart';

import '../../domain/entities/producto.dart';
import '../../domain/repositories/inventario_repository.dart';
import '../local/app_database.dart';

/// 👶 El traductor del inventario. Lo más importante está en
/// `observarProductos`: si incluirCostos es false (EMPLEADO), el
/// costo se descarta AQUÍ, en la capa de datos. La pantalla del
/// empleado recibe productos donde el costo simplemente no existe.
///
/// ★ FASE 8: costo y pvp viajan como opcionales (double?) hasta la
/// base de datos, cuyas columnas ahora aceptan null (esquema v7).
class InventarioRepositoryImpl implements InventarioRepository {
  final AppDatabase _db;
  InventarioRepositoryImpl(this._db);

  @override
  Stream<List<Producto>> observarProductos({required bool incluirCostos}) =>
      _db.observarProductosActivos().map(
            (filas) => filas
                .map((row) => _mapear(row, incluirCostos: incluirCostos))
                .toList(),
          );

  @override
  Future<void> agregarProducto({
    required String nombre,
    String? descripcion,
    required List<String> categorias,
    required List<String> vehiculos,
    double? costo,
    double? pvp,
    required int stockActual,
    required int stockMinimo,
    String? urlFoto,
  }) {
    final ahora = DateTime.now();
    return _db.insertarProducto(
      InventarioCompanion.insert(
        id: AppDatabase.generarUuid(),
        nombreProducto: nombre.trim(),
        descripcion: Value(_limpiar(descripcion)),
        categoriaTags: Producto.unirTags(categorias),
        compatibilidadVehiculos: Producto.unirTags(vehiculos),
        costo: Value(costo),
        pvp: Value(pvp),
        stockActual: Value(stockActual),
        stockMinimo: Value(stockMinimo),
        urlFoto: Value(_limpiar(urlFoto)),
        fechaCreacion: ahora,
        fechaModificacion: ahora,
      ),
    );
  }

  @override
  Future<void> actualizarProducto({
    required String id,
    required String nombre,
    String? descripcion,
    required List<String> categorias,
    required List<String> vehiculos,
    double? costo,
    double? pvp,
    required int stockActual,
    required int stockMinimo,
    String? urlFoto,
  }) {
    return _db.actualizarProductoPorId(
      id,
      InventarioCompanion(
        nombreProducto: Value(nombre.trim()),
        descripcion: Value(_limpiar(descripcion)),
        categoriaTags: Value(Producto.unirTags(categorias)),
        compatibilidadVehiculos: Value(Producto.unirTags(vehiculos)),
        costo: Value(costo),
        pvp: Value(pvp),
        stockActual: Value(stockActual),
        stockMinimo: Value(stockMinimo),
        urlFoto: Value(_limpiar(urlFoto)),
        fechaModificacion: Value(DateTime.now()),
        pendienteSync: const Value(true), // De vuelta a la cola del espejo
      ),
    );
  }

  /// ★ DUPLICADOR RÁPIDO ★ — clona con UUID nuevo. Si el original no
  /// tiene precios, la copia tampoco (se completan luego, igual).
  @override
  Future<void> duplicarProducto(Producto original, {String? nuevoNombre}) =>
      agregarProducto(
        nombre: nuevoNombre ?? '${original.nombre} (COPIA)',
        descripcion: original.descripcion,
        categorias: original.categorias,
        vehiculos: original.vehiculos,
        costo: original.costo,
        pvp: original.pvp,
        stockActual: original.stockActual,
        stockMinimo: original.stockMinimo,
        urlFoto: original.urlFoto,
      );

  @override
  Future<void> eliminarProducto(String idProducto) =>
      _db.marcarProductoEliminado(idProducto);

  // ── Privados ──

  String? _limpiar(String? v) {
    final t = v?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }

  Producto _mapear(ProductoRow row, {required bool incluirCostos}) =>
      Producto(
        id: row.id,
        nombre: row.nombreProducto,
        descripcion: row.descripcion,
        categorias: Producto.parsearTags(row.categoriaTags),
        vehiculos: Producto.parsearTags(row.compatibilidadVehiculos),
        // 🔒 LA LLAVE: el costo solo se traduce si el rol lo permite
        costo: incluirCostos ? row.costo : null,
        pvp: row.pvp,
        stockActual: row.stockActual,
        stockMinimo: row.stockMinimo,
        urlFoto: row.urlFoto,
        fechaCreacion: row.fechaCreacion,
      );
}
