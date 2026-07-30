import '../entities/producto.dart';

/// 👶 El contrato del inventario. Fíjense en `incluirCostos`: es la
/// llave de seguridad de la capa de datos. Cuando es false (empleado),
/// el costo NI SIQUIERA SE LEE de la base de datos.
///
/// ★ FASE 8: costo y pvp son OPCIONALES (double?). Un producto puede
/// registrarse solo con su nombre y completarse después.
abstract interface class InventarioRepository {
  /// Tubería en vivo de todos los productos activos.
  /// incluirCostos = false → los productos llegan con costo = null.
  Stream<List<Producto>> observarProductos({required bool incluirCostos});

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
  });

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
  });

  /// ★ DUPLICADOR RÁPIDO ★: clona un producto con UUID nuevo
  /// (el formulario se abre prellenado para cambiar solo un detalle)
  Future<void> duplicarProducto(Producto original, {String? nuevoNombre});

  Future<void> eliminarProducto(String idProducto);
}
