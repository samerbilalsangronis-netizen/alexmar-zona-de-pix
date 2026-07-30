import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/cuentas_repository_impl.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/entities/linea_cuenta.dart';
import '../../domain/repositories/cuentas_repository.dart';
import 'auth_providers.dart';
import 'clientes_providers.dart';

/// 👶 Providers "family": son enchufes que reciben un parámetro
/// (el ID del cliente) y crean una tubería exclusiva para ESE
/// cliente. Cada Hoja Individual tiene sus propias tuberías.

final cuentasRepositoryProvider = Provider<CuentasRepository>(
  (ref) => CuentasRepositoryImpl(ref.watch(databaseProvider)),
);

/// El cliente del encabezado, en vivo (si cambia su deuda, se repinta)
final clientePorIdProvider =
    StreamProvider.family<Cliente?, String>((ref, idCliente) {
  return ref.watch(databaseProvider).observarClientePorId(idCliente).map(
        (row) => row == null
            ? null
            : Cliente(
                id: row.id,
                cedula: row.cedula,
                nombre: row.nombreCliente,
                telefono: row.telefono,
                direccion: row.direccion,
                facturaN: row.facturaN,
                fechaUltimoAbono: row.fechaUltimoAbono,
                totalAdeudado: row.totalAdeudado,
                fechaCreacion: row.fechaCreacion,
              ),
      );
});

/// El scroll infinito: TODAS las líneas (cargos + abonos) del cliente
final lineasClienteProvider =
    StreamProvider.family<List<LineaCuenta>, String>(
  (ref, idCliente) =>
      ref.watch(cuentasRepositoryProvider).observarLineas(idCliente),
);

/// Los 3 totales del pie: Consumido, Abonado y Saldo Pendiente
final resumenCuentaProvider =
    StreamProvider.family<ResumenCuenta, String>(
  (ref, idCliente) =>
      ref.watch(cuentasRepositoryProvider).observarResumen(idCliente),
);
