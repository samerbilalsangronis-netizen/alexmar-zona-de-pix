import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/clientes_repository_impl.dart';
import '../../data/sync/sheets_api_client.dart';
import '../../data/sync/sincronizacion_bajada_service.dart';
import '../../data/sync/sync_service.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/repositories/clientes_repository.dart';
import 'auth_providers.dart';

/// 👶 Los "providers" son los enchufes de la app: las pantallas se
/// conectan a ellos y reciben los datos en vivo, sin saber de dónde
/// vienen ni cómo se calculan.

final clientesRepositoryProvider = Provider<ClientesRepository>(
  (ref) => ClientesRepositoryImpl(ref.watch(databaseProvider)),
);

/// Lista en vivo del Índice Maestro (se actualiza sola ante cualquier cambio)
final indiceClientesProvider = StreamProvider<List<Cliente>>(
  (ref) => ref.watch(clientesRepositoryProvider).observarIndice(),
);

/// ── BUSCADOR DEL ÍNDICE ──
/// Guarda lo que el usuario está escribiendo en la cajita de búsqueda.
/// StateProvider: un valor simple que cambia con cada letra escrita.
final textoBusquedaProvider = StateProvider<String>((ref) => '');

/// Lista YA FILTRADA según el texto de búsqueda (nombre, cédula o
/// teléfono). Si la cajita está vacía, muestra todos los clientes
/// igual que antes — no rompe nada de lo existente.
final indiceClientesFiltradosProvider = Provider<AsyncValue<List<Cliente>>>(
  (ref) {
    final lista = ref.watch(indiceClientesProvider);
    final texto = ref.watch(textoBusquedaProvider).trim().toLowerCase();

    return lista.whenData((clientes) {
      if (texto.isEmpty) return clientes;
      return clientes.where((c) {
        final nombre = c.nombre.toLowerCase();
        final cedula = (c.cedula ?? '').toLowerCase();
        final telefono = (c.telefono ?? '').toLowerCase();
        return nombre.contains(texto) ||
            cedula.contains(texto) ||
            telefono.contains(texto);
      }).toList();
    });
  },
);

/// TOTAL GENERAL en la calle ($), también en vivo
final totalGeneralProvider = StreamProvider<double>(
  (ref) => ref.watch(clientesRepositoryProvider).observarTotalGeneral(),
);

/// Cuántos datos esperan en la cola del espejo (banderitas encendidas).
/// Suma dos tuberías: clientes pendientes + líneas de cuenta pendientes.
final _pendientesClientesProvider = StreamProvider<int>(
  (ref) => ref.watch(databaseProvider).observarPendientesDeSync(),
);
final _pendientesDetalleProvider = StreamProvider<int>(
  (ref) => ref.watch(databaseProvider).observarPendientesDetalle(),
);
final _pendientesInventarioProvider = StreamProvider<int>(
  (ref) => ref.watch(databaseProvider).observarPendientesInventario(),
);
final pendientesSyncProvider = Provider<int>((ref) {
  final clientes = ref.watch(_pendientesClientesProvider).value ?? 0;
  final detalle = ref.watch(_pendientesDetalleProvider).value ?? 0;
  final inventario = ref.watch(_pendientesInventarioProvider).value ?? 0;
  return clientes + detalle + inventario;
});

/// El motor de sincronización, encendido una sola vez para toda la app
final syncServiceProvider = Provider<SyncService>((ref) {
  final servicio = SyncService(
    ref.watch(databaseProvider),
    SheetsApiClient(),
  );
  servicio.iniciar();
  ref.onDispose(servicio.detener);
  return servicio;
});

/// Proveedor del servicio de bajada INTELIGENTE (polling + timestamp)
/// keepAlive = true: el timer NUNCA se destruye mientras la sesión
/// esté activa. Así el polling sigue corriendo aunque el usuario
/// navegue entre pantallas o la app quede en segundo plano.
final sincronizacionBajadaProvider =
    Provider<SincronizacionBajadaService>((ref) {
  // keepAlive: evita que Riverpod destruya este proveedor
  ref.keepAlive();

  final servicio = SincronizacionBajadaService(
    ref.read(databaseProvider),
    SheetsApiClient(),
  );
  servicio.iniciarPolling();
  ref.onDispose(servicio.detenerPolling);
  return servicio;
});
