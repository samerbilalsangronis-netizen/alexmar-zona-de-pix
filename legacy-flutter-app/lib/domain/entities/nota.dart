/// ─────────────────────────────────────────────────────────────────
/// ENTIDAD: Nota (FASE 9 — Pizarra del jefe)
///
/// 👶 Una nota es como un papelito pegado en la pizarra del taller:
/// puede tener título, contenido, ambos o hasta ninguno mientras la
/// estás escribiendo. El color es la etiqueta visual de la tarjeta.
/// ─────────────────────────────────────────────────────────────────
class Nota {
  final String id;
  final String? titulo;      // Opcional
  final String? contenido;   // Opcional
  final String color;        // NARANJA | CYAN | VERDE | AMARILLO
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;

  const Nota({
    required this.id,
    this.titulo,
    this.contenido,
    this.color = 'NARANJA',
    required this.fechaCreacion,
    required this.fechaModificacion,
  });

  /// ¿La nota está totalmente vacía? (ni título ni contenido)
  bool get estaVacia =>
      (titulo == null || titulo!.trim().isEmpty) &&
      (contenido == null || contenido!.trim().isEmpty);
}
