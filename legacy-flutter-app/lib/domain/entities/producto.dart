/// ─────────────────────────────────────────────────────────────────
/// CAPA DOMAIN · Producto del Catálogo de Inventario Visual.
///
/// 👶 EXPLICACIÓN: Las categorías y los vehículos compatibles se
/// guardan como "etiquetas" (tags) separadas por comas, por ejemplo:
///   categorias = "SONIDO, ELECTRICA"
///   vehiculos  = "FORD, CARGO"
/// Esto hace al catálogo AMPLIABLE: mañana inventan una categoría
/// nueva ("LUCES LED") y simplemente se escribe; no hay que tocar
/// código ni base de datos. El doble filtro cruzado busca dentro de
/// estas listas.
///
/// ★ FASE 8: pvp y costo son OPCIONALES. Muchos productos entran al
/// sistema primero solo con su nombre (carga masiva desde Sheets) y
/// los precios se completan después desde la app. Un producto sin
/// pvp se muestra como "SIN PRECIO" en el catálogo.
/// ─────────────────────────────────────────────────────────────────

/// Categorías iniciales del negocio (la lista crece sola con el uso)
const categoriasIniciales = [
  'SONIDO', 'GARRAS', 'VARIOS', 'EXPLORADORAS', 'ELECTRICA',
];

/// Vehículos iniciales (idem: ampliable con el uso)
const vehiculosIniciales = [
  'FORD', 'CARGO', 'TOYOTA', 'CHEVROLET', 'UNIVERSAL',
];

class Producto {
  final String id;            // UUID (espejo: INVENTARIO.ID_Producto)
  final String nombre;
  final String? descripcion;
  final List<String> categorias;  // Filtro A (tipo de mercancía)
  final List<String> vehiculos;   // Filtro B (marca/modelo compatible)

  /// 🔒 COSTO: solo el ADMIN lo recibe. Para el EMPLEADO este campo
  /// llega como null DESDE LA CAPA DE DATOS (ni siquiera viaja a la
  /// pantalla; no es un truco visual, el dato no existe para él).
  /// ★ Fase 8: también puede ser null porque el producto aún no
  /// tiene precio de compra registrado.
  final double? costo;

  /// Precio de Venta al Público ($) — visible a todos.
  /// ★ Fase 8: null = producto cargado sin precio todavía
  /// (se muestra "SIN PRECIO" y se completa editándolo).
  final double? pvp;

  final int stockActual;
  final int stockMinimo;
  final String? urlFoto;      // Link al storage (o ruta local provisional)
  final DateTime fechaCreacion;

  const Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.categorias,
    required this.vehiculos,
    this.costo,
    this.pvp,
    required this.stockActual,
    required this.stockMinimo,
    this.urlFoto,
    required this.fechaCreacion,
  });

  // ── ★ LÓGICA DE STOCK CRÍTICO ★ ──

  /// Agotado por completo (alerta ROJA parpadeante)
  bool get agotado => stockActual <= 0;

  /// En el umbral o por debajo (alerta NARANJA parpadeante).
  /// 👶 stockMinimo = 0 significa "sin umbral definido" (típico de
  /// los productos cargados en masa desde Sheets): en ese caso no
  /// hay alerta naranja, solo la roja de agotado.
  bool get stockBajo =>
      !agotado && stockMinimo > 0 && stockActual <= stockMinimo;

  /// ¿Necesita alerta visual? (cualquiera de las dos)
  bool get enAlerta => agotado || stockBajo;

  // ── ★ LÓGICA DE PRECIOS (Fase 8) ★ ──

  /// ¿Le falta el precio de venta? (pendiente de completar en la app)
  bool get sinPrecio => pvp == null;

  /// Margen de ganancia: solo tiene sentido si existen AMBOS precios
  /// (y el costo solo llega al ADMIN)
  double? get gananciaUnitaria =>
      (costo == null || pvp == null) ? null : pvp! - costo!;

  // ── Utilidades para las etiquetas ──

  /// "SONIDO, ELECTRICA" → ["SONIDO", "ELECTRICA"] (limpio y en mayúsculas)
  static List<String> parsearTags(String texto) => texto
      .split(',')
      .map((t) => t.trim().toUpperCase())
      .where((t) => t.isNotEmpty)
      .toList();

  /// ["SONIDO", "ELECTRICA"] → "SONIDO, ELECTRICA" (para guardar/mostrar)
  static String unirTags(List<String> tags) => tags.join(', ');
}
