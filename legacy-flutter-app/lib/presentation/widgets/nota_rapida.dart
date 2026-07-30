import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/nota.dart';
import '../providers/notas_providers.dart';

/// ─────────────────────────────────────────────────────────────────
/// NOTA RÁPIDA (FASE 9) — "el bolsillo del jefe"
///
/// 👶 QUÉ RESUELVE: estás cargando un cliente y de repente recuerdas
/// "tengo que pedir bombillos H4". No hay que salir de donde estás:
/// tocas la pestañita naranja del borde derecho, escribes la nota,
/// guardas, y sigues con lo tuyo. La nota queda esperándote en
/// MODO JEFE → MIS NOTAS.
///
/// Este archivo tiene DOS cosas:
///  1. NotaRapidaOverlay → la pestañita flotante que se pega encima
///     de CUALQUIER pantalla (se enchufa desde app_router.dart, así
///     no hay que tocar ni una sola pantalla existente).
///  2. mostrarEditorNota() → el cuadrito para escribir/editar una
///     nota. Lo usan la pestañita rápida Y la pizarra de notas, así
///     el diseño es idéntico en los dos lados.
/// ─────────────────────────────────────────────────────────────────

/// Los 4 colores de etiqueta disponibles (guardados como texto en
/// la base y en Sheets, para que se lean claro también en el Excel)
const List<String> etiquetasDeColor = ['NARANJA', 'CYAN', 'VERDE', 'AMARILLO'];

/// Traduce la etiqueta de texto al color real de la paleta cyberpunk
Color colorDeNota(String etiqueta) {
  switch (etiqueta.toUpperCase().trim()) {
    case 'CYAN':
      return AppColors.neonCyan;
    case 'VERDE':
      return AppColors.statusGreen;
    case 'AMARILLO':
      return AppColors.statusYellow;
    case 'NARANJA':
    default:
      return AppColors.racingOrange;
  }
}

// ═══════════════════════════════════════════════════════════════════
//  1. LA PESTAÑITA FLOTANTE (visible en toda la app)
// ═══════════════════════════════════════════════════════════════════

class NotaRapidaOverlay extends StatelessWidget {
  final Widget child;
  const NotaRapidaOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // La pantalla normal, intacta (no se le toca nada)
        child,
        // La pestañita, pegada al borde derecho, a media altura.
        // Se pone AHÍ a propósito: no estorba a los botones de abajo
        // (CARGO / ABONO / COBRAR) ni al menú de arriba.
        Positioned(
          right: 0,
          top: MediaQuery.of(context).size.height * 0.34,
          child: const _PestanaNotaRapida(),
        ),
      ],
    );
  }
}

class _PestanaNotaRapida extends ConsumerWidget {
  const _PestanaNotaRapida();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => mostrarEditorNota(context, ref),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: Container(
          width: 40,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.panelDark,
            border: Border.all(color: AppColors.racingOrange, width: 1.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.racingOrange.withOpacity(0.35),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sticky_note_2_outlined,
                  color: AppColors.racingOrange, size: 22),
              SizedBox(height: 6),
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'NOTA',
                  style: TextStyle(
                    color: AppColors.racingOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  2. EL EDITOR DE NOTAS (crear o corregir)
// ═══════════════════════════════════════════════════════════════════
//
//  👶 Si le pasas una nota → la EDITA. Si no le pasas nada → CREA
//  una nueva. Ningún campo es obligatorio: puedes guardar solo con
//  título, solo con contenido, o con ambos.
//
Future<void> mostrarEditorNota(
  BuildContext context,
  WidgetRef ref, {
  Nota? nota,
}) async {
  final esNueva = nota == null;
  final ctrlTitulo = TextEditingController(text: nota?.titulo ?? '');
  final ctrlContenido = TextEditingController(text: nota?.contenido ?? '');
  var colorElegido = nota?.color ?? 'NARANJA';

  await showDialog<void>(
    context: context,
    builder: (contextoDialogo) => StatefulBuilder(
      builder: (contextoInterno, refrescarDialogo) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colorDeNota(colorElegido), width: 1.5),
        ),
        title: Row(
          children: [
            Icon(Icons.sticky_note_2_outlined,
                color: colorDeNota(colorElegido), size: 22),
            const SizedBox(width: 10),
            Text(
              esNueva ? 'NOTA NUEVA' : 'EDITAR NOTA',
              style: TextStyle(
                color: colorDeNota(colorElegido),
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Título (opcional) ──
              TextField(
                controller: ctrlTitulo,
                autofocus: esNueva,
                style: const TextStyle(color: AppColors.textPrimary),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Título (opcional)',
                  hintText: 'Ej: Pedir bombillos',
                  labelStyle: const TextStyle(color: AppColors.textDisabled),
                  hintStyle: const TextStyle(color: AppColors.textDisabled),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textDisabled),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: colorDeNota(colorElegido), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Contenido (opcional, varias líneas) ──
              TextField(
                controller: ctrlContenido,
                maxLines: 5,
                minLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Contenido (opcional)',
                  hintText: 'Ej: 4 bombillos H4 para el Ford del jueves',
                  alignLabelWithHint: true,
                  labelStyle: const TextStyle(color: AppColors.textDisabled),
                  hintStyle: const TextStyle(color: AppColors.textDisabled),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.textDisabled),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: colorDeNota(colorElegido), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Etiqueta de color ──
              const Text('ETIQUETA DE COLOR',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 10),
              Row(
                children: etiquetasDeColor.map((etiqueta) {
                  final activo = etiqueta == colorElegido;
                  final color = colorDeNota(etiqueta);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () =>
                          refrescarDialogo(() => colorElegido = etiqueta),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color.withOpacity(activo ? 1 : 0.35),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: activo
                                ? AppColors.textPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: activo
                            ? const Icon(Icons.check,
                                color: Colors.black, size: 20)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contextoDialogo).pop(),
            child: const Text('CANCELAR',
                style: TextStyle(color: AppColors.textDisabled)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorDeNota(colorElegido),
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('GUARDAR'),
            onPressed: () async {
              final titulo = ctrlTitulo.text.trim();
              final contenido = ctrlContenido.text.trim();

              // 👶 Nada es obligatorio, pero una nota TOTALMENTE vacía
              // no sirve de nada: se avisa con cariño y no se guarda.
              if (titulo.isEmpty && contenido.isEmpty) {
                ScaffoldMessenger.of(contextoInterno).showSnackBar(
                  const SnackBar(
                    content: Text('La nota está vacía: escribe algo primero.'),
                  ),
                );
                return;
              }

              final repo = ref.read(notasRepositoryProvider);
              if (esNueva) {
                await repo.crearNota(
                  titulo: titulo,
                  contenido: contenido,
                  color: colorElegido,
                );
              } else {
                await repo.editarNota(
                  id: nota.id,
                  titulo: titulo,
                  contenido: contenido,
                  color: colorElegido,
                );
              }

              if (!contextoDialogo.mounted) return;
              Navigator.of(contextoDialogo).pop();
              ScaffoldMessenger.of(contextoInterno).showSnackBar(
                SnackBar(
                  content: Text(esNueva
                      ? '✔ Nota guardada. La ves en MODO JEFE → MIS NOTAS.'
                      : '✔ Nota actualizada.'),
                  backgroundColor: AppColors.panelDark,
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
