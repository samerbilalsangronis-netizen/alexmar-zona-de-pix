import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/inventario_repository_impl.dart';
import '../../domain/entities/producto.dart';
import '../../domain/repositories/inventario_repository.dart';
import 'auth_providers.dart';

/// 👶 Aquí vive el BUSCADOR INTELIGENTE. La idea: tenemos UNA tubería
/// con todos los productos, y tres "perillas" de filtro (texto,
/// categoría, vehículo). Un provider final cruza las cuatro cosas y
/// entrega la lista filtrada. Si giras cualquier perilla, la pantalla
/// se repinta al instante, porque todos están conectados.

final inventarioRepositoryProvider = Provider<InventarioRepository>(
  (ref) => InventarioRepositoryImpl(ref.watch(databaseProvider)),
);

/// La tubería madre. 🔒 Fíjense: incluirCostos depende del ROL.
/// El empleado recibe productos SIN costo desde la capa de datos.
final productosProvider = StreamProvider<List<Producto>>((ref) {
  final esAdmin = ref.watch(esAdminProvider);
  return ref
      .watch(inventarioRepositoryProvider)
      .observarProductos(incluirCostos: esAdmin);
});

// ── Las 3 perillas del buscador ──

/// Perilla 1: texto libre del buscador
final busquedaTextoProvider = StateProvider<String>((ref) => '');

/// Perilla 2 · Filtro A: categoría seleccionada (null = TODAS)
final filtroCategoriaProvider = StateProvider<String?>((ref) => null);

/// Perilla 3 · Filtro B: vehículo seleccionado (null = TODOS)
final filtroVehiculoProvider = StateProvider<String?>((ref) => null);

/// Opciones de los desplegables: las iniciales del negocio + las que
/// aparezcan en los productos reales (catálogo ampliable por uso).
final categoriasDisponiblesProvider = Provider<List<String>>((ref) {
  final productos = ref.watch(productosProvider).value ?? const [];
  final set = {...categoriasIniciales};
  for (final p in productos) {
    set.addAll(p.categorias);
  }
  return set.toList()..sort();
});

final vehiculosDisponiblesProvider = Provider<List<String>>((ref) {
  final productos = ref.watch(productosProvider).value ?? const [];
  final set = {...vehiculosIniciales};
  for (final p in productos) {
    set.addAll(p.vehiculos);
  }
  return set.toList()..sort();
});

/// ★ EL CRUCE FINAL ★ — texto + Filtro A + Filtro B, todo a la vez.
/// Un producto pasa solo si cumple LAS TRES condiciones activas.
final productosFiltradosProvider = Provider<List<Producto>>((ref) {
  final productos = ref.watch(productosProvider).value ?? const [];
  final texto = ref.watch(busquedaTextoProvider).trim().toUpperCase();
  final categoria = ref.watch(filtroCategoriaProvider);
  final vehiculo = ref.watch(filtroVehiculoProvider);

  return productos.where((p) {
    // Condición 1: el texto aparece en nombre, descripción o etiquetas
    final pasaTexto = texto.isEmpty ||
        p.nombre.toUpperCase().contains(texto) ||
        (p.descripcion ?? '').toUpperCase().contains(texto) ||
        p.categorias.any((c) => c.contains(texto)) ||
        p.vehiculos.any((v) => v.contains(texto));

    // Condición 2 · Filtro A: la categoría elegida está en sus tags
    final pasaCategoria = categoria == null || p.categorias.contains(categoria);

    // Condición 3 · Filtro B: el vehículo elegido está en sus tags
    final pasaVehiculo = vehiculo == null || p.vehiculos.contains(vehiculo);

    return pasaTexto && pasaCategoria && pasaVehiculo;
  }).toList();
});

/// Cuántos productos están en alerta de stock (para el contador rojo)
final productosEnAlertaProvider = Provider<int>((ref) {
  final productos = ref.watch(productosProvider).value ?? const [];
  return productos.where((p) => p.enAlerta).length;
});
