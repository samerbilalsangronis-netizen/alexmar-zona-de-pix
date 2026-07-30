import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/notas_repository_impl.dart';
import '../../domain/entities/nota.dart';
import '../../domain/repositories/notas_repository.dart';
import 'auth_providers.dart';

/// ─────────────────────────────────────────────────────────────────
/// PROVIDERS DE LA PIZARRA DE NOTAS (FASE 9)
///
/// 👶 Mismo patrón exacto que los clientes: un provider arma el
/// repositorio (con la base de datos adentro) y otro provider abre
/// la "tubería en vivo" (Stream) para que la pantalla se repinte
/// sola cada vez que se crea, edita o borra una nota.
/// ─────────────────────────────────────────────────────────────────

final notasRepositoryProvider = Provider<NotasRepository>(
  (ref) => NotasRepositoryImpl(ref.watch(databaseProvider)),
);

/// Lista en vivo de la pizarra (la más recién tocada, primero)
final notasProvider = StreamProvider<List<Nota>>(
  (ref) => ref.watch(notasRepositoryProvider).observarNotas(),
);
