import 'package:drift/drift.dart';

import '../../domain/entities/linea_cuenta.dart';
import '../../domain/repositories/cuentas_repository.dart';
import '../local/app_database.dart';

/// 👶 El "traductor" entre las filas de la base (LineaRow) y las
/// entidades del negocio (LineaCuenta). Igual que con los clientes.
class CuentasRepositoryImpl implements CuentasRepository {
  final AppDatabase _db;
  CuentasRepositoryImpl(this._db);

  @override
  Stream<List<LineaCuenta>> observarLineas(String idCliente) =>
      _db.observarLineasDeCliente(idCliente).map(
            (filas) => filas.map(_mapear).toList(),
          );

  @override
  Stream<ResumenCuenta> observarResumen(String idCliente) =>
      // Reusamos la misma tubería de líneas y sumamos al vuelo:
      // cada vez que cambia UNA línea, los 3 totales se recalculan.
      observarLineas(idCliente).map((lineas) {
        double consumido = 0, abonado = 0;
        for (final l in lineas) {
          // Los títulos de vehículo son separadores, no dinero
          if (l.esTitulo) continue;
          l.esAbono ? abonado += l.totalLinea : consumido += l.totalLinea;
        }
        return ResumenCuenta(
            totalConsumido: consumido, totalAbonado: abonado);
      });

  @override
  Future<void> agregarCargo({
    required String idCliente,
    required double cantidad,
    required String descripcion,
    required double precioUnitario,
    double? costoUnitario,
  }) {
    final ahora = DateTime.now();
    return _db.insertarLineaYRecalcular(
      DetalleCuentasCompanion.insert(
        id: AppDatabase.generarUuid(),
        idCliente: idCliente,
        tipoLinea: 'CARGO',
        fecha: ahora,
        cantidad: cantidad,
        descripcion: descripcion.trim(),
        precioUnitario: Value(precioUnitario),
        costoUnitario: Value(costoUnitario), // Foto del costo del día
        totalLinea: cantidad * precioUnitario, // P. Total = Cant × P. Unit
        fechaCreacion: ahora,
        fechaModificacion: ahora,
      ),
      idCliente,
    );
  }

  @override
  Future<void> agregarCargos({
    required String idCliente,
    required List<NuevoCargo> cargos,
  }) {
    final ahora = DateTime.now();
    // Traducir cada borrador (NuevoCargo) a una fila de base de datos
    final lote = cargos
        .map((c) => DetalleCuentasCompanion.insert(
              id: AppDatabase.generarUuid(),
              idCliente: idCliente,
              tipoLinea: 'CARGO',
              fecha: ahora,
              cantidad: c.cantidad,
              descripcion: c.descripcion.trim(),
              precioUnitario: Value(c.precioUnitario),
              costoUnitario: Value(c.costoUnitario),
              totalLinea: c.cantidad * c.precioUnitario,
              fechaCreacion: ahora,
              fechaModificacion: ahora,
            ))
        .toList();
    // Una transacción, un recálculo: la factura entra completa o no entra
    return _db.insertarLoteYRecalcular(lote, idCliente);
  }

  @override
  Future<void> registrarAbono({
    required String idCliente,
    required String descripcion,
    required double monto,
  }) {
    final ahora = DateTime.now();
    return _db.insertarLineaYRecalcular(
      DetalleCuentasCompanion.insert(
        id: AppDatabase.generarUuid(),
        idCliente: idCliente,
        tipoLinea: 'ABONO',
        fecha: ahora,
        cantidad: 1, // Regla del negocio: los abonos siempre llevan cantidad 1
        descripcion: descripcion.trim().isEmpty
            ? 'Abono a cuenta'
            : descripcion.trim(),
        precioUnitario: const Value(null), // En abonos el P.Unit va vacío
        totalLinea: monto,
        fechaCreacion: ahora,
        fechaModificacion: ahora,
      ),
      idCliente,
    );
  }

  @override
  Future<void> eliminarLinea(String idLinea, String idCliente) =>
      _db.eliminarLineaYRecalcular(idLinea, idCliente);

  /// ★ VACIAR CUENTA (FASE 10) ★ — cartero directo hacia la base:
  /// ella marca todas las líneas activas del cliente como eliminadas,
  /// recalcula una vez y las deja pendienteSync para que suban solas.
  @override
  Future<int> vaciarCuenta(String idCliente) =>
      _db.vaciarCuentaCliente(idCliente);

  /// ★ EDITAR DATOS DE UN CLIENTE YA EXISTENTE ★
  /// 👶 Este método es solo un "cartero": recibe los datos corregidos
  /// desde la pantalla (hoja_cliente_screen.dart) y se los entrega
  /// directo a app_database.dart, que ya sabe cómo guardarlos y
  /// marcarlos pendienteSync para que se suban solos a Sheets.
  @override
  Future<void> actualizarDatosCliente({
    required String idCliente,
    required String nombreCliente,
    String? cedula,
    String? telefono,
    String? direccion,
  }) =>
      _db.actualizarDatosCliente(
        idCliente: idCliente,
        nombreCliente: nombreCliente,
        cedula: cedula,
        telefono: telefono,
        direccion: direccion,
      );

  LineaCuenta _mapear(LineaRow row) => LineaCuenta(
        id: row.id,
        idCliente: row.idCliente,
        tipo: TipoLinea.fromDb(row.tipoLinea),
        fecha: row.fecha,
        cantidad: row.cantidad,
        descripcion: row.descripcion,
        precioUnitario: row.precioUnitario,
        totalLinea: row.totalLinea,
      );
}
