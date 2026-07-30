import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/cierre_mensual_service.dart';
import '../../domain/entities/cierre_mensual.dart';
import 'auth_providers.dart';

/// 👶 Los enchufes del panel gerencial. El flujo completo:
/// el motor revisa y genera cierres → la tubería de cierres se
/// actualiza sola → el año seleccionado filtra → el ResumenAnual
/// calcula récords y crecimiento → la pantalla solo pinta.

/// El motor del contador nocturno. Al "enchufarse" por primera vez
/// revisa toda la historia y genera los cierres que falten.
final cierreServiceProvider = Provider<CierreMensualService>(
  (ref) => CierreMensualService(ref.watch(databaseProvider)),
);

/// Disparo de la revisión (FutureProvider = se ejecuta una vez y
/// guarda el resultado; devuelve cuántos cierres nuevos generó).
final verificarCierresProvider = FutureProvider<int>(
  (ref) => ref.watch(cierreServiceProvider).verificarYGenerarCierres(),
);

/// Tubería en vivo de TODOS los cierres históricos (orden cronológico)
final cierresProvider = StreamProvider<List<CierreMensual>>((ref) {
  return ref.watch(databaseProvider).observarCierres().map(
        (filas) => filas
            .map((c) => CierreMensual(
                  id: c.id,
                  anio: c.anio,
                  mes: c.mes,
                  totalFacturado: c.totalFacturado,
                  totalCobrado: c.totalCobrado,
                  gananciaNeta: c.gananciaNeta,
                  carteraPendienteCierre: c.carteraPendienteCierre,
                  fechaCierre: c.fechaCierre,
                ))
            .toList(),
      );
});

/// Años que tienen al menos un cierre (para el selector de año)
final aniosDisponiblesProvider = Provider<List<int>>((ref) {
  final cierres = ref.watch(cierresProvider).value ?? const [];
  final set = cierres.map((c) => c.anio).toSet().toList()..sort();
  return set;
});

/// El año que el jefe está mirando (null = el más reciente disponible)
final anioSeleccionadoProvider = StateProvider<int?>((ref) => null);

/// ★ EL CONSOLIDADO ★ — ResumenAnual del año seleccionado
final resumenAnualProvider = Provider<ResumenAnual?>((ref) {
  final cierres = ref.watch(cierresProvider).value ?? const [];
  if (cierres.isEmpty) return null;

  final anios = ref.watch(aniosDisponiblesProvider);
  final anio = ref.watch(anioSeleccionadoProvider) ?? anios.last;

  return ResumenAnual(
    anio: anio,
    cierres: cierres.where((c) => c.anio == anio).toList()
      ..sort((a, b) => a.mes.compareTo(b.mes)),
  );
});
