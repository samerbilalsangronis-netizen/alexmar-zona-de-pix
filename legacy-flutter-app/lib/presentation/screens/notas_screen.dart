import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fondo_chip.dart';
import '../../domain/entities/nota.dart';
import '../providers/notas_providers.dart';
import '../widgets/nota_rapida.dart';

/// ─────────────────────────────────────────────────────────────────
/// MIS NOTAS · La pizarra del jefe (FASE 9)
///
/// 👶 Es el corcho del taller, pero digital: cada nota es un papelito
/// de color. Se crea con el botón "+ NOTA NUEVA" (o desde la
/// pestañita naranja de cualquier pantalla), se corrige tocándola,
/// y se bota con el tacho. Todo viaja solo a Google Sheets, así que
/// lo que escribas en la PC del taller aparece también en el teléfono.
/// ─────────────────────────────────────────────────────────────────
class NotasScreen extends ConsumerWidget {
  const NotasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notasAsync = ref.watch(notasProvider);
    final textTheme = Theme.of(context).textTheme;

    return FondoChip(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.racingOrange),
            onPressed: () => context.go(AppRoutes.adminDashboard),
          ),
          title: const Text('MIS NOTAS'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.racingOrange,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add),
          label: const Text('NOTA NUEVA'),
          onPressed: () => mostrarEditorNota(context, ref),
        ),
        body: SafeArea(
          child: notasAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.racingOrange),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se pudo abrir la pizarra:\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textDisabled)),
              ),
            ),
            data: (notas) {
              if (notas.isEmpty) return const _PizarraVacia();
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                itemCount: notas.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${notas.length} NOTA${notas.length == 1 ? '' : 'S'} EN LA PIZARRA',
                            style: textTheme.labelSmall
                                ?.copyWith(color: AppColors.neonCyan),
                          ),
                          const SizedBox(height: 4),
                          Text('Pendientes y recordatorios',
                              style: textTheme.displayMedium),
                        ],
                      ),
                    );
                  }
                  return _TarjetaNota(nota: notas[i - 1]);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Mensaje cuando todavía no hay ninguna nota
class _PizarraVacia extends StatelessWidget {
  const _PizarraVacia();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sticky_note_2_outlined,
                size: 64, color: AppColors.textDisabled),
            const SizedBox(height: 20),
            Text('LA PIZARRA ESTÁ VACÍA',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            const Text(
              'Usa "+ NOTA NUEVA" aquí abajo, o la pestañita naranja '
              'del borde derecho desde cualquier pantalla de la app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textDisabled, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Una nota = un papelito de color en la pizarra
class _TarjetaNota extends ConsumerWidget {
  final Nota nota;
  const _TarjetaNota({required this.nota});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final acento = colorDeNota(nota.color);
    final tieneTitulo = nota.titulo != null && nota.titulo!.trim().isNotEmpty;
    final tieneContenido =
        nota.contenido != null && nota.contenido!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        child: InkWell(
          onTap: () => mostrarEditorNota(context, ref, nota: nota),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra de acento lateral (mismo estilo HUD del panel)
                Container(width: 3, height: 52, color: acento),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tieneTitulo)
                        Text(
                          nota.titulo!,
                          style: textTheme.titleLarge
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                      if (tieneTitulo && tieneContenido)
                        const SizedBox(height: 6),
                      if (tieneContenido)
                        Text(
                          nota.contenido!,
                          style: textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        _fechaLegible(nota.fechaModificacion),
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.textDisabled),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Botar esta nota',
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.textDisabled),
                  onPressed: () => _confirmarBorrado(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Pide confirmación antes de botar (borrado lógico, igual que en
  /// clientes: la nota se marca eliminada y así viaja a Sheets)
  Future<void> _confirmarBorrado(BuildContext context, WidgetRef ref) async {
    final titulo = (nota.titulo?.trim().isNotEmpty ?? false)
        ? nota.titulo!.trim()
        : 'esta nota';

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text('¿BOTAR LA NOTA?',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: Text(
          'Vas a eliminar: $titulo\n\n'
          'Se quitará también de las demás apps en su próxima '
          'sincronización.',
          style: const TextStyle(color: AppColors.textDisabled, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCELAR',
                style: TextStyle(color: AppColors.textDisabled)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.racingOrange,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('SÍ, BOTAR'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;
    await ref.read(notasRepositoryProvider).eliminarNota(nota.id);
  }

  /// Fecha en formato del taller: dd/mm/aaaa · hh:mm
  static String _fechaLegible(DateTime f) {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(f.day)}/${dos(f.month)}/${f.year} · '
        '${dos(f.hour)}:${dos(f.minute)}';
  }
}
