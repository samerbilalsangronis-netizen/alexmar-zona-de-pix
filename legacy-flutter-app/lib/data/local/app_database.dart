import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// ─────────────────────────────────────────────────────────────────
/// CAPA DATA · SQLite (Drift) — Fuente de verdad OFFLINE.
/// Versión 3 del esquema: Usuarios + Clientes + DetalleCuentas.
///
/// 👶 RECORDATORIO: `pendienteSync = true` es la banderita que dice
/// "este dato aún no viajó al espejo de Google Sheets". El motor de
/// sincronización las busca y las apaga cuando Google confirma.
/// ─────────────────────────────────────────────────────────────────

@DataClassName('UsuarioRow')
class Usuarios extends Table {
  TextColumn get id => text()();
  TextColumn get nombreCompleto => text()();
  TextColumn get usuario => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get salt => text()();
  TextColumn get rol => text()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get fechaCreacion => dateTime()();
  DateTimeColumn get fechaModificacion => dateTime()();
  BoolColumn get pendienteSync =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Espejo 1:1 de la pestaña CLIENTES en ALEXMAR_DB
@DataClassName('ClienteRow')
class Clientes extends Table {
  TextColumn get id => text()();
  TextColumn get cedula => text().nullable()();     // Opcional: puede faltar
  TextColumn get nombreCliente => text()();          // Solo este es obligatorio
  TextColumn get telefono => text().nullable()();    // Opcional: puede faltar
  TextColumn get direccion => text().nullable()();   // Opcional: puede faltar
  TextColumn get facturaN => text().nullable()();    // El sistema lo asigna si no viene
  DateTimeColumn get fechaUltimoAbono => dateTime().nullable()();
  RealColumn get totalAdeudado => real().withDefault(const Constant(0))();
  BoolColumn get eliminado => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fechaCreacion => dateTime()();
  DateTimeColumn get fechaModificacion => dateTime()();
  BoolColumn get pendienteSync =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Espejo 1:1 de la pestaña DETALLE_CUENTAS en ALEXMAR_DB.
/// Una sola tabla para CARGOS y ABONOS, diferenciados por tipoLinea.
@DataClassName('LineaRow')
class DetalleCuentas extends Table {
  TextColumn get id => text()();                        // → ID_Linea (UUID)
  TextColumn get idCliente => text()();                 // → ID_Cliente (foránea)
  TextColumn get tipoLinea => text()();                 // → Tipo_Linea: CARGO|ABONO
  DateTimeColumn get fecha => dateTime()();             // → Fecha
  RealColumn get cantidad => real()();                  // → Cantidad (abonos: 1)
  TextColumn get descripcion => text()();               // → Descripcion
  RealColumn get precioUnitario => real().nullable()(); // → Precio_Unitario ($)
  RealColumn get totalLinea => real()();                // → Total_Linea ($)

  /// 🔒 FOTO DEL COSTO al momento de vender (solo cargos, opcional).
  /// 👶 ¿Por qué guardarlo aquí y no mirar el inventario? Porque los
  /// costos cambian con el tiempo: si en marzo el faro costó $10 y
  /// en julio cuesta $14, la ganancia de marzo debe calcularse con
  /// los \$10 de ESE día. Por eso congelamos el costo en la línea.
  RealColumn get costoUnitario => real().nullable()();
  TextColumn get idProducto => text().nullable()();     // → ID_Producto (Módulo 4)
  BoolColumn get eliminado => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fechaCreacion => dateTime()();
  DateTimeColumn get fechaModificacion => dateTime()();
  BoolColumn get pendienteSync =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}


/// Espejo 1:1 de la pestaña INVENTARIO en ALEXMAR_DB.
/// Todos los montos en dólares netos ($).
///
/// ★ v7 (FASE 8): costo y pvp son OPCIONALES. Muchos productos se
/// cargan primero solo con su nombre (desde Sheets) y los precios se
/// completan después desde la app. Un pvp null se muestra en el
/// catálogo como "SIN PRECIO".
@DataClassName('ProductoRow')
class Inventario extends Table {
  TextColumn get id => text()();                          // → ID_Producto (UUID)
  TextColumn get nombreProducto => text()();              // → Nombre_Producto (único obligatorio)
  TextColumn get descripcion => text().nullable()();      // → Descripcion
  TextColumn get categoriaTags => text()();               // → Categoria (CSV de etiquetas)
  TextColumn get compatibilidadVehiculos => text()();     // → Compatibilidad_Vehiculos (CSV)
  RealColumn get costo => real().nullable()();            // → Precio_Compra ($) 🔒 solo ADMIN · opcional
  RealColumn get pvp => real().nullable()();              // → Precio_Publico ($) · opcional
  IntColumn get stockActual =>
      integer().withDefault(const Constant(0))();         // → Unidades_Disponibles (vacío = 0)
  IntColumn get stockMinimo =>
      integer().withDefault(const Constant(0))();         // → Stock_Minimo (vacío = 0, sin alerta)
  TextColumn get urlFoto => text().nullable()();          // → URL_Foto
  BoolColumn get eliminado => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fechaCreacion => dateTime()();
  DateTimeColumn get fechaModificacion => dateTime()();
  BoolColumn get pendienteSync =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}


/// Espejo 1:1 de la pestaña CIERRES_MENSUALES en ALEXMAR_DB.
/// Las fotografías financieras de cada mes terminado ($ netos).
@DataClassName('CierreRow')
class CierresMensuales extends Table {
  TextColumn get id => text()();                         // → ID_Cierre (UUID)
  IntColumn get anio => integer()();                     // → Anio
  IntColumn get mes => integer()();                      // → Mes (1-12)
  RealColumn get totalFacturado => real()();             // → Total_Facturado ($)
  RealColumn get totalCobrado => real()();               // → Total_Cobrado ($)
  RealColumn get gananciaNeta => real()();               // → Ganancia_Neta ($)
  RealColumn get carteraPendienteCierre => real()();     // → Cartera_Pendiente_Cierre ($)
  DateTimeColumn get fechaCierre => dateTime()();        // → Fecha_Cierre
  BoolColumn get pendienteSync =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// ★ FASE 9 — PIZARRA DE NOTAS ★
/// Espejo 1:1 de la pestaña NOTAS en ALEXMAR_DB.
/// 👶 La libreta personal del jefe dentro de la app: pendientes,
/// compras, recordatorios. NINGÚN campo es obligatorio — una nota
/// puede tener solo título, solo contenido, o ambos. El color es
/// la etiqueta visual de la tarjeta (NARANJA, CYAN, VERDE, AMARILLO).
@DataClassName('NotaRow')
class Notas extends Table {
  TextColumn get id => text()();                      // → ID_Nota (UUID)
  TextColumn get titulo => text().nullable()();       // → Titulo (opcional)
  TextColumn get contenido => text().nullable()();    // → Contenido (opcional)
  TextColumn get color =>
      text().withDefault(const Constant('NARANJA'))(); // → Color
  BoolColumn get eliminado => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fechaCreacion => dateTime()();
  DateTimeColumn get fechaModificacion => dateTime()();
  BoolColumn get pendienteSync =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Usuarios, Clientes, DetalleCuentas, Inventario, CierresMensuales, Notas])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  @override
  int get schemaVersion => 8; // Edición 8 (FASE 9): tabla NOTAS (pizarra del jefe)

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _sembrarAdminInicial();
        },
        // 👶 beforeOpen se ejecuta CADA VEZ que la app abre la base,
        // sea instalación nueva o vieja. Aquí garantizamos que el
        // usuario de mostrador exista SIEMPRE, sin duplicarlo jamás
        // (primero pregunta si ya está). Así no importa si la app ya
        // estaba instalada con datos: el vendedor nace igual.
        beforeOpen: (detalles) async {
          await _sembrarEmpleadoSiFalta();
        },
        onUpgrade: (m, desde, hasta) async {
          if (desde < 2) await m.createTable(clientes);
          if (desde < 3) await m.createTable(detalleCuentas);
          if (desde < 4) await m.createTable(inventario);
          if (desde < 5) {
            await m.createTable(cierresMensuales);
            await m.addColumn(detalleCuentas, detalleCuentas.costoUnitario);
          }
          if (desde < 6) {
            // telefono y facturaN pasan a nullable. En SQLite, la
            // restricción NOT NULL está grabada físicamente en la
            // tabla — cambiarla en el código Dart no basta, hay que
            // RECONSTRUIR la tabla. m.createAll() no la toca si ya
            // existe, así que la borramos primero y la recreamos
            // con el nuevo esquema (sin esa restricción).
            // Los clientes se recuperan con el botón ☁️ (ya están
            // todos respaldados en Sheets).
            await m.deleteTable('clientes');
            await m.createTable(clientes);
          }
          if (desde < 7) {
            // ★ FASE 8: costo y pvp pasan a nullable, y los stocks
            // ganan valor por defecto 0. Misma técnica probada en la
            // v6: SQLite guarda el NOT NULL físicamente, así que hay
            // que RECONSTRUIR la tabla. El inventario está vacío en
            // este punto (aún no se ha cargado nada), y aunque no lo
            // estuviera, el espejo de Sheets lo repondría en la
            // próxima bajada.
            await m.deleteTable('inventario');
            await m.createTable(inventario);
          }
          if (desde < 8) {
            // ★ FASE 9: nace la pizarra de NOTAS. Es una tabla NUEVA
            // (no toca ninguna existente), así que basta con crearla.
            // Los clientes, cuentas e inventario quedan intactos.
            await m.createTable(notas);
          }
        },
      );

  // ════════════════════ SEGURIDAD ════════════════════

  static String hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt$password')).toString();

  static String generarSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String generarUuid() {
    final rng = Random.secure();
    final b = List<int>.generate(16, (_) => rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String hex(int i) => b[i].toRadixString(16).padLeft(2, '0');
    return '${hex(0)}${hex(1)}${hex(2)}${hex(3)}-${hex(4)}${hex(5)}-'
        '${hex(6)}${hex(7)}-${hex(8)}${hex(9)}-'
        '${hex(10)}${hex(11)}${hex(12)}${hex(13)}${hex(14)}${hex(15)}';
  }

  Future<void> _sembrarAdminInicial() async {
    final ahora = DateTime.now();
    final salt = generarSalt();
    await into(usuarios).insert(
      UsuariosCompanion.insert(
        id: generarUuid(),
        nombreCompleto: 'Administrador Alexmar',
        usuario: 'admin',
        passwordHash: hashPassword('alexmar2026', salt),
        salt: salt,
        rol: 'ADMIN',
        fechaCreacion: ahora,
        fechaModificacion: ahora,
      ),
    );
  }

  /// ★ USUARIO SEMILLA DEL MOSTRADOR (Rol: EMPLEADO) ★
  /// 👶 Es IDEMPOTENTE: primero pregunta "¿ya existe vendedor1?".
  /// Solo lo crea si falta. Nace con rol EMPLEADO, así que las tres
  /// capas de seguridad (router, widgets y datos) le bloquean de
  /// fábrica los costos, las ganancias y el índice de deudas.
  /// ⚠️ Cambiar esta contraseña cuando el negocio arranque en serio.
  Future<void> _sembrarEmpleadoSiFalta() async {
    final yaExiste = await buscarPorUsuario('vendedor1');
    if (yaExiste != null) return; // Ya está sembrado: no hacer nada

    final ahora = DateTime.now();
    final salt = generarSalt();
    await into(usuarios).insert(
      UsuariosCompanion.insert(
        id: generarUuid(),
        nombreCompleto: 'Vendedor de Mostrador',
        usuario: 'vendedor1',
        passwordHash: hashPassword('alexmar2026', salt),
        salt: salt,
        rol: 'EMPLEADO', // ← La llave que activa todos los bloqueos
        fechaCreacion: ahora,
        fechaModificacion: ahora,
      ),
    );
  }

  // ════════════════ CONSULTAS: USUARIOS ════════════════

  Future<UsuarioRow?> buscarPorUsuario(String nombreUsuario) =>
      (select(usuarios)
            ..where((u) => u.usuario.equals(nombreUsuario.trim().toLowerCase())))
          .getSingleOrNull();

  Future<UsuarioRow?> buscarPorId(String idUsuario) =>
      (select(usuarios)..where((u) => u.id.equals(idUsuario)))
          .getSingleOrNull();

  // ════════════════ CONSULTAS: CLIENTES ════════════════

  Stream<List<ClienteRow>> observarClientesActivos() =>
      (select(clientes)
            ..where((c) => c.eliminado.equals(false))
            ..orderBy([(c) => OrderingTerm.desc(c.totalAdeudado)]))
          .watch();

  /// Un solo cliente, en vivo (para el encabezado de la Hoja Individual)
  Stream<ClienteRow?> observarClientePorId(String idCliente) =>
      (select(clientes)..where((c) => c.id.equals(idCliente)))
          .watchSingleOrNull();

  Stream<double> observarTotalGeneral() {
    final suma = clientes.totalAdeudado.sum();
    final consulta = selectOnly(clientes)
      ..addColumns([suma])
      ..where(clientes.eliminado.equals(false));
    return consulta.watchSingle().map((fila) => fila.read(suma) ?? 0);
  }

  Future<void> insertarCliente(ClientesCompanion datos) =>
      into(clientes).insert(datos);

  /// ★ EDITAR DATOS DE UN CLIENTE YA EXISTENTE ★
  /// 👶 A diferencia de insertarCliente (que crea uno nuevo), esto
  /// CORRIGE nombre/cédula/teléfono/dirección de un cliente que ya
  /// tiene su cuenta, saldo e historial. NO toca nada de eso — solo
  /// la ficha. Marca pendienteSync para que en el próximo ciclo de
  /// 60s el mensajero (SyncService) lo suba a Sheets, y Sheets a su
  /// vez actualiza el membrete de la hoja individual automáticamente.
  Future<void> actualizarDatosCliente({
    required String idCliente,
    required String nombreCliente,
    String? cedula,
    String? telefono,
    String? direccion,
  }) =>
      (update(clientes)..where((c) => c.id.equals(idCliente))).write(
        ClientesCompanion(
          nombreCliente: Value(nombreCliente),
          cedula: Value(cedula),
          telefono: Value(telefono),
          direccion: Value(direccion),
          fechaModificacion: Value(DateTime.now()),
          pendienteSync: const Value(true),
        ),
      );

  /// Cuenta cuántos clientes no eliminados hay en la base local.
  /// Lo usa el servicio de bajada para saber si la base está vacía.
  Future<int> contarClientes() async {
    final consulta = selectOnly(clientes)
      ..addColumns([clientes.id.count()])
      ..where(clientes.eliminado.equals(false));
    final fila = await consulta.getSingle();
    return fila.read(clientes.id.count()) ?? 0;
  }

  /// TODOS los folios usados en la historia (incluso de clientes
  /// eliminados): el folio es como la página del índice físico,
  /// jamás se reutiliza aunque se arranque la hoja.
  Future<List<String>> todosLosFolios() async {
    final consulta = selectOnly(clientes)..addColumns([clientes.facturaN]);
    final filas = await consulta.get();
    return filas.map((f) => f.read(clientes.facturaN) ?? '').toList();
  }

  /// ★ ELIMINACIÓN EN CASCADA (borrado lógico coordinado) ★
  /// 👶 Una "transacción" es un paquete todo-o-nada: o se ejecutan
  /// TODOS los pasos, o ninguno. Así jamás queda un cliente borrado
  /// con líneas vivas (datos huérfanos). Usamos borrado LÓGICO
  /// (marcar Eliminado = SI) en vez de destruir las filas, para que
  /// el espejo de Google Sheets también reciba la noticia y el
  /// historial quede auditable.
  Future<void> eliminarClienteEnCascada(String idCliente) =>
      transaction(() async {
        final ahora = DateTime.now();
        // Paso 1: marcar el cliente como eliminado
        await (update(clientes)..where((c) => c.id.equals(idCliente))).write(
          ClientesCompanion(
            eliminado: const Value(true),
            fechaModificacion: Value(ahora),
            pendienteSync: const Value(true),
          ),
        );
        // Paso 2: marcar TODAS sus líneas (cargos y abonos) como eliminadas
        await (update(detalleCuentas)
              ..where((l) => l.idCliente.equals(idCliente)))
            .write(
          DetalleCuentasCompanion(
            eliminado: const Value(true),
            fechaModificacion: Value(ahora),
            pendienteSync: const Value(true),
          ),
        );
      });

  // ════════════ CONSULTAS: DETALLE DE CUENTAS ════════════

  /// Líneas vivas de un cliente, de la más antigua a la más nueva
  /// (como se escribe en la página física del índice).
  Stream<List<LineaRow>> observarLineasDeCliente(String idCliente) =>
      (select(detalleCuentas)
            ..where((l) =>
                l.idCliente.equals(idCliente) & l.eliminado.equals(false))
            ..orderBy([(l) => OrderingTerm.asc(l.fecha)]))
          .watch();

  /// Insertar línea + recálculo, en una sola transacción
  Future<void> insertarLineaYRecalcular(
          DetalleCuentasCompanion datos, String idCliente) =>
      transaction(() async {
        await into(detalleCuentas).insert(datos);
        await _recalcularCliente(idCliente);
      });

  /// ★ CARGA RÁPIDA ★: inserta VARIAS líneas y recalcula UNA sola
  /// vez, todo dentro de una transacción (todo-o-nada). Así una
  /// factura de 20 ítems entra completa o no entra: jamás a medias.
  Future<void> insertarLoteYRecalcular(
          List<DetalleCuentasCompanion> lote, String idCliente) =>
      transaction(() async {
        for (final datos in lote) {
          await into(detalleCuentas).insert(datos);
        }
        await _recalcularCliente(idCliente);
      });

  /// ★ SINCRONIZACIÓN DE BAJADA ★
  /// Reemplaza TODOS los clientes y sus líneas con los datos que
  /// vienen de Google Sheets. Es una transacción completa:
  /// todo entra o nada entra, nunca queda a medias.
  ///
  /// 👶 POR QUÉ REEMPLAZA EN VEZ DE MEZCLAR: porque Sheets es la
  /// "fuente de verdad" en una bajada. Si mezcláramos, un cliente
  /// borrado en Sheets seguiría apareciendo en la app. Reemplazar
  /// asegura que la app quede idéntica a la nube. Los datos que
  /// había en la app se suben ANTES de bajar (el mensajero los subió
  /// en la ronda de 60s), así que nada se pierde.
  Future<void> reemplazarDesdNube({
    required List<Map<String, dynamic>> clientesJson,
    required List<Map<String, dynamic>> detallesJson,
  }) =>
      transaction(() async {
        // 1) Limpiar SOLO lo ya sincronizado (borrado físico en la bajada).
        //    🐛 FIX: antes esto borraba TODO sin condición, incluidos los
        //    clientes/cargos recién creados en el teléfono que aún no
        //    habían viajado a Sheets (pendienteSync = true). Si el ciclo
        //    de bajada (cada 40s) se disparaba antes de que el de subida
        //    terminara, el dato local se borraba y jamás llegaba a la
        //    nube: se perdía para siempre. Mismo blindaje que ya tenían
        //    reemplazarInventarioDesdeNube y reemplazarNotasDesdeNube.
        await (delete(clientes)..where((c) => c.pendienteSync.equals(false)))
            .go();
        await (delete(detalleCuentas)
              ..where((l) => l.pendienteSync.equals(false)))
            .go();

        // Los que sobrevivieron son los pendientes de subir: sus IDs no
        // deben ser pisados por la versión (más vieja) que trae Sheets.
        final idsClientesPendientes =
            (await select(clientes).get()).map((c) => c.id).toSet();
        final idsLineasPendientes =
            (await select(detalleCuentas).get()).map((l) => l.id).toSet();

        // 2) Cargar los clientes que vienen de Sheets
        for (final c in clientesJson) {
          // 👶 Sheets a veces entrega números sin comillas (ej: Cedula=12345678
          // como int, no como String). _str() convierte cualquier tipo a texto.
          String str(String col) => (c[col] ?? '').toString().trim();

          final idCli = str('ID_Cliente');
          if (idCli.isEmpty) continue; // fila sin ID → basura, ignorar
          if (idsClientesPendientes.contains(idCli)) continue; // local manda

          await into(clientes).insert(
            ClientesCompanion.insert(
              id: idCli,
              cedula: Value(str('Cedula').isEmpty ? null : str('Cedula')),
              nombreCliente: str('Nombre_Cliente'),
              telefono: Value(str('Telefono').isEmpty ? null : str('Telefono')),
              direccion:
                  Value(str('Direccion').isEmpty ? null : str('Direccion')),
              facturaN: Value(str('Factura_N').isEmpty ? null : str('Factura_N')),
              totalAdeudado: Value(
                  double.tryParse(str('Total_Adeudado')) ?? 0),
              eliminado: Value(
                  str('Eliminado').toUpperCase() == 'SI' ||
                      c['Eliminado'] == true),
              fechaUltimoAbono:
                  Value(_parsearFecha(c['Fecha_Ultimo_Abono'])),
              fechaCreacion:
                  _parsearFecha(c['Fecha_Creacion']) ?? DateTime.now(),
              fechaModificacion: _parsearFecha(c['Fecha_Modificacion']) ??
                  DateTime.now(),
              pendienteSync: const Value(false),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }

        // 3) Cargar las líneas de cuenta (cargos y abonos)
        //    ★ BLINDAJE ★: cada fila entra en su propio try. Si una
        //    columna viene en formato raro (un número donde iba texto,
        //    un booleano, un nulo, etc.) se SALTA esa fila y se sigue —
        //    jamás se revierte la descarga completa, como pasaba antes
        //    (una sola fila mala dejaba TODAS las cuentas en $0).
        for (final d in detallesJson) {
          // Convierte cualquier tipo a texto sin reventar.
          String s(String col) => (d[col] ?? '').toString().trim();

          final idLinea = s('ID_Linea');
          if (idLinea.isEmpty) continue; // fila sin ID → basura, ignorar
          if (idsLineasPendientes.contains(idLinea)) continue; // local manda

          try {
            await into(detalleCuentas).insert(
              DetalleCuentasCompanion.insert(
                id: idLinea,
                idCliente: s('ID_Cliente'),
                tipoLinea:
                    s('Tipo_Linea').isEmpty ? 'CARGO' : s('Tipo_Linea'),
                fecha: _parsearFecha(d['Fecha']) ?? DateTime.now(),
                cantidad: double.tryParse(s('Cantidad')) ?? 1,
                descripcion: s('Descripcion'),
                precioUnitario: Value(double.tryParse(s('Precio_Unitario'))),
                costoUnitario: Value(double.tryParse(s('Costo_Unitario'))),
                totalLinea: double.tryParse(s('Total_Linea')) ?? 0,
                eliminado: Value(
                    s('Eliminado').toUpperCase() == 'SI' ||
                        d['Eliminado'] == true),
                fechaCreacion:
                    _parsearFecha(d['Fecha_Creacion']) ?? DateTime.now(),
                fechaModificacion:
                    _parsearFecha(d['Fecha_Modificacion']) ?? DateTime.now(),
                pendienteSync: const Value(false),
              ),
              mode: InsertMode.insertOrReplace,
            );
          } catch (e) {
            // Una fila torcida no debe tumbar toda la bajada.
            // ignore: avoid_print
            print('Línea DETALLE_CUENTAS omitida ($idLinea): $e');
          }
        }

        // 4) ★ RECALCULAR EL SALDO DE CADA CLIENTE ★
        // La columna Total_Adeudado de Sheets no siempre está al día
        // (ej: cuando se cargan ítems directo en Sheets con "Procesar
        // carga", esa columna no se toca). Para que el Índice Maestro
        // muestre el saldo correcto SIEMPRE, lo recalculamos aquí con
        // las líneas reales recién descargadas — la misma cuenta
        // exacta que hace la app cuando cargas un ítem manualmente.
        final idsClientes = clientesJson
            .map((c) => (c['ID_Cliente'] ?? '').toString().trim())
            .where((id) => id.isNotEmpty)
            .toSet();
        for (final idCliente in idsClientes) {
          await _recalcularCliente(idCliente, marcarPendienteSync: false);
        }
      });

  /// ★ SINCRONIZACIÓN DE BAJADA DEL INVENTARIO (FASE 8) ★
  /// Reemplaza los productos locales con los que vienen de Sheets.
  ///
  /// 👶 TRES PROTECCIONES IMPORTANTES:
  ///  1. FOTOS: las fotos viven en el teléfono (Sheets solo guarda
  ///     links http). Antes de borrar, se anota qué foto tenía cada
  ///     producto; si Sheets llega sin foto para ese ID, se conserva
  ///     la foto local. Así una bajada JAMÁS borra las fotos.
  ///  2. PENDIENTES: los productos creados en la app que aún no
  ///     subieron a Sheets (pendienteSync = true) NO se borran ni se
  ///     pisan — la versión local más nueva siempre gana.
  ///  3. BLINDAJE POR FILA: cada producto entra en su propio try.
  ///     Una fila torcida se salta y se sigue; jamás se revierte la
  ///     descarga completa por un solo dato malo.
  Future<void> reemplazarInventarioDesdeNube(
          List<Map<String, dynamic>> productosJson) =>
      transaction(() async {
        // 1) Anotar las fotos locales (id → foto) antes de borrar nada
        final locales = await select(inventario).get();
        final fotosLocales = <String, String>{};
        for (final p in locales) {
          if (p.urlFoto != null && p.urlFoto!.isNotEmpty) {
            fotosLocales[p.id] = p.urlFoto!;
          }
        }

        // 2) Borrar SOLO lo ya sincronizado (lo pendiente se queda)
        await (delete(inventario)
              ..where((p) => p.pendienteSync.equals(false)))
            .go();

        // Los que sobrevivieron son los pendientes de subir: sus IDs
        // no deben ser pisados por la versión (más vieja) de Sheets.
        final idsPendientes =
            (await select(inventario).get()).map((p) => p.id).toSet();

        // 3) Cargar los productos que vienen de Sheets, uno por uno
        for (final j in productosJson) {
          // Convierte cualquier tipo a texto sin reventar.
          String s(String col) => (j[col] ?? '').toString().trim();

          final idProd = s('ID_Producto');
          if (idProd.isEmpty) continue; // fila sin ID → basura, ignorar
          if (idsPendientes.contains(idProd)) continue; // local manda

          try {
            final fotoNube = s('URL_Foto');
            // Sheets puede mandar "5" o "5.0": aceptar ambos formatos
            int enteroDe(String col) =>
                double.tryParse(s(col))?.round() ?? 0;

            await into(inventario).insert(
              InventarioCompanion.insert(
                id: idProd,
                nombreProducto: s('Nombre_Producto'),
                descripcion: Value(
                    s('Descripcion').isEmpty ? null : s('Descripcion')),
                categoriaTags: s('Categoria'),
                // Vacío en Sheets = compatible con todo (UNIVERSAL)
                compatibilidadVehiculos:
                    s('Compatibilidad_Vehiculos').isEmpty
                        ? 'UNIVERSAL'
                        : s('Compatibilidad_Vehiculos'),
                costo: Value(double.tryParse(s('Precio_Compra'))),
                pvp: Value(double.tryParse(s('Precio_Publico'))),
                stockActual: Value(enteroDe('Unidades_Disponibles')),
                stockMinimo: Value(enteroDe('Stock_Minimo')),
                // Si Sheets no trae foto, conservar la local (si había)
                urlFoto: Value(fotoNube.isNotEmpty
                    ? fotoNube
                    : fotosLocales[idProd]),
                eliminado: Value(s('Eliminado').toUpperCase() == 'SI' ||
                    j['Eliminado'] == true),
                fechaCreacion:
                    _parsearFecha(j['Fecha_Creacion']) ?? DateTime.now(),
                fechaModificacion:
                    _parsearFecha(j['Fecha_Modificacion']) ?? DateTime.now(),
                pendienteSync: const Value(false),
              ),
              mode: InsertMode.insertOrReplace,
            );
          } catch (e) {
            // Una fila torcida no debe tumbar toda la bajada.
            // ignore: avoid_print
            print('Producto INVENTARIO omitido ($idProd): $e');
          }
        }
      });

  /// Convierte el texto de fecha que viene de Sheets en DateTime.
  /// Acepta ISO 8601 y fechas simples. Devuelve null si no puede.
  DateTime? _parsearFecha(dynamic valor) {
    if (valor == null || valor.toString().trim().isEmpty) return null;
    try {
      return DateTime.parse(valor.toString().trim());
    } catch (_) {
      return null;
    }
  }



  /// Borrar línea (lógico) + recálculo, en una sola transacción
  Future<void> eliminarLineaYRecalcular(
          String idLinea, String idCliente) =>
      transaction(() async {
        await (update(detalleCuentas)..where((l) => l.id.equals(idLinea)))
            .write(
          DetalleCuentasCompanion(
            eliminado: const Value(true),
            fechaModificacion: Value(DateTime.now()),
            pendienteSync: const Value(true),
          ),
        );
        await _recalcularCliente(idCliente);
      });

  /// ★ VACIAR CUENTA COMPLETA ★ (FASE 10)
  /// 👶 Marca como eliminadas TODAS las líneas activas del cliente de
  /// un solo golpe (mismo borrado lógico que el tacho de una línea,
  /// pero masivo) y recalcula UNA sola vez. Cada línea queda
  /// pendienteSync=true, así el vaciado viaja a Sheets y se refleja en
  /// los demás dispositivos. La ficha del cliente NO se toca: solo su
  /// historial. Devuelve cuántos movimientos se vaciaron.
  Future<int> vaciarCuentaCliente(String idCliente) =>
      transaction(() async {
        final ahora = DateTime.now();
        final afectadas = await (update(detalleCuentas)
              ..where((l) =>
                  l.idCliente.equals(idCliente) &
                  l.eliminado.equals(false)))
            .write(
          DetalleCuentasCompanion(
            eliminado: const Value(true),
            fechaModificacion: Value(ahora),
            pendienteSync: const Value(true),
          ),
        );
        await _recalcularCliente(idCliente);
        return afectadas;
      });

  /// ★ EL CEREBRO MATEMÁTICO ★
  /// Después de CUALQUIER cambio en las líneas, este método vuelve a
  /// sumar todo desde cero y actualiza la ficha del cliente:
  ///   Total_Adeudado     = Σ CARGOS − Σ ABONOS
  ///   Fecha_Ultimo_Abono = fecha del abono más reciente (revive el semáforo)
  /// Gracias a las tuberías (Streams), el Índice Maestro y el TOTAL
  /// GENERAL se enteran y repintan SOLOS, sin código extra.
  Future<void> _recalcularCliente(String idCliente,
      {bool marcarPendienteSync = true}) async {
    final lineas = await (select(detalleCuentas)
          ..where((l) =>
              l.idCliente.equals(idCliente) & l.eliminado.equals(false)))
        .get();

    double cargos = 0, abonos = 0;
    DateTime? ultimoAbono;
    for (final l in lineas) {
      // Las líneas TITULO son separadores visuales (ej: nombre de un
      // vehículo en facturas con varios vehículos del mismo cliente).
      // No representan dinero, así que no se suman a nada.
      if (l.tipoLinea == 'TITULO') continue;
      if (l.tipoLinea == 'ABONO') {
        abonos += l.totalLinea;
        if (ultimoAbono == null || l.fecha.isAfter(ultimoAbono)) {
          ultimoAbono = l.fecha;
        }
      } else {
        cargos += l.totalLinea;
      }
    }

    await (update(clientes)..where((c) => c.id.equals(idCliente))).write(
      ClientesCompanion(
        totalAdeudado: Value(cargos - abonos),
        fechaUltimoAbono: Value(ultimoAbono),
        fechaModificacion: Value(DateTime.now()),
        // Al recalcular tras una BAJADA de Sheets, el dato YA está
        // sincronizado (acaba de venir de allá) — no marcar para
        // re-subir, o cada bajada generaría una subida innecesaria.
        pendienteSync: Value(marcarPendienteSync),
      ),
    );
  }


  // ════════════════ CONSULTAS: INVENTARIO ════════════════

  /// Productos vivos, alfabéticamente. El filtrado fino (búsqueda y
  /// doble filtro cruzado) se hace en memoria en los providers: con
  /// el tamaño de un inventario de taller es instantáneo y permite
  /// cruzar texto + categoría + vehículo a la vez sin SQL complejo.
  Stream<List<ProductoRow>> observarProductosActivos() =>
      (select(inventario)
            ..where((p) => p.eliminado.equals(false))
            ..orderBy([(p) => OrderingTerm.asc(p.nombreProducto)]))
          .watch();

  Future<void> insertarProducto(InventarioCompanion datos) =>
      into(inventario).insert(datos);

  Future<void> actualizarProductoPorId(
          String id, InventarioCompanion datos) =>
      (update(inventario)..where((p) => p.id.equals(id))).write(datos);

  Future<void> marcarProductoEliminado(String idProducto) =>
      (update(inventario)..where((p) => p.id.equals(idProducto))).write(
        InventarioCompanion(
          eliminado: const Value(true),
          fechaModificacion: Value(DateTime.now()),
          pendienteSync: const Value(true),
        ),
      );


  // ════════════ CONSULTAS: BUSINESS INTELLIGENCE ════════════

  /// La fecha del primer movimiento registrado en la historia de la
  /// app (para saber desde qué mes hay que generar cierres).
  Future<DateTime?> primeraFechaMovimiento() async {
    final minFecha = detalleCuentas.fecha.min();
    final consulta = selectOnly(detalleCuentas)..addColumns([minFecha]);
    final fila = await consulta.getSingleOrNull();
    return fila?.read(minFecha);
  }

  /// Líneas VIVAS dentro de un rango de fechas [desde, hasta)
  Future<List<LineaRow>> lineasDelRango(DateTime desde, DateTime hasta) =>
      (select(detalleCuentas)
            ..where((l) =>
                l.eliminado.equals(false) &
                l.fecha.isBiggerOrEqualValue(desde) &
                l.fecha.isSmallerThanValue(hasta)))
          .get();

  /// ¿Ya existe la fotografía de este mes? (el cierre es idempotente:
  /// jamás se duplica aunque la app revise mil veces)
  Future<bool> existeCierre(int anio, int mes) async {
    final fila = await (select(cierresMensuales)
          ..where((c) => c.anio.equals(anio) & c.mes.equals(mes)))
        .getSingleOrNull();
    return fila != null;
  }

  Future<void> insertarCierre(CierresMensualesCompanion datos) =>
      into(cierresMensuales).insert(datos);

  /// Todos los cierres, en vivo, en orden cronológico
  Stream<List<CierreRow>> observarCierres() =>
      (select(cierresMensuales)
            ..orderBy([
              (c) => OrderingTerm.asc(c.anio),
              (c) => OrderingTerm.asc(c.mes),
            ]))
          .watch();

  /// El total en la calle AHORA (Future, para la foto de cartera)
  Future<double> totalGeneralAhora() async {
    final suma = clientes.totalAdeudado.sum();
    final consulta = selectOnly(clientes)
      ..addColumns([suma])
      ..where(clientes.eliminado.equals(false));
    final fila = await consulta.getSingle();
    return fila.read(suma) ?? 0;
  }

  // ════════════ COLA DE SINCRONIZACIÓN (ESPEJO) ════════════

  Future<List<ClienteRow>> clientesPendientesDeSync() =>
      (select(clientes)..where((c) => c.pendienteSync.equals(true))).get();

  Future<List<UsuarioRow>> usuariosPendientesDeSync() =>
      (select(usuarios)..where((u) => u.pendienteSync.equals(true))).get();

  Future<List<LineaRow>> lineasPendientesDeSync() =>
      (select(detalleCuentas)..where((l) => l.pendienteSync.equals(true)))
          .get();

  Future<List<ProductoRow>> productosPendientesDeSync() =>
      (select(inventario)..where((p) => p.pendienteSync.equals(true))).get();

  Future<List<CierreRow>> cierresPendientesDeSync() =>
      (select(cierresMensuales)..where((c) => c.pendienteSync.equals(true)))
          .get();

  Stream<int> observarPendientesDeSync() {
    final cuenta = clientes.id.count();
    final consulta = selectOnly(clientes)
      ..addColumns([cuenta])
      ..where(clientes.pendienteSync.equals(true));
    return consulta.watchSingle().map((fila) => fila.read(cuenta) ?? 0);
  }

  Stream<int> observarPendientesInventario() {
    final cuenta = inventario.id.count();
    final consulta = selectOnly(inventario)
      ..addColumns([cuenta])
      ..where(inventario.pendienteSync.equals(true));
    return consulta.watchSingle().map((fila) => fila.read(cuenta) ?? 0);
  }

  Stream<int> observarPendientesDetalle() {
    final cuenta = detalleCuentas.id.count();
    final consulta = selectOnly(detalleCuentas)
      ..addColumns([cuenta])
      ..where(detalleCuentas.pendienteSync.equals(true));
    return consulta.watchSingle().map((fila) => fila.read(cuenta) ?? 0);
  }

  Future<void> marcarClientesSincronizados(List<String> ids) =>
      (update(clientes)..where((c) => c.id.isIn(ids)))
          .write(const ClientesCompanion(pendienteSync: Value(false)));

  Future<void> marcarUsuariosSincronizados(List<String> ids) =>
      (update(usuarios)..where((u) => u.id.isIn(ids)))
          .write(const UsuariosCompanion(pendienteSync: Value(false)));

  Future<void> marcarLineasSincronizadas(List<String> ids) =>
      (update(detalleCuentas)..where((l) => l.id.isIn(ids)))
          .write(const DetalleCuentasCompanion(pendienteSync: Value(false)));

  Future<void> marcarProductosSincronizados(List<String> ids) =>
      (update(inventario)..where((p) => p.id.isIn(ids)))
          .write(const InventarioCompanion(pendienteSync: Value(false)));

  Future<void> marcarCierresSincronizados(List<String> ids) =>
      (update(cierresMensuales)..where((c) => c.id.isIn(ids))).write(
          const CierresMensualesCompanion(pendienteSync: Value(false)));

  // ════════════════ CONSULTAS: NOTAS (FASE 9) ════════════════

  /// Notas vivas, de la más recién tocada a la más vieja
  /// (como una pizarra: lo último que escribiste queda arriba).
  Stream<List<NotaRow>> observarNotasActivas() =>
      (select(notas)
            ..where((n) => n.eliminado.equals(false))
            ..orderBy([(n) => OrderingTerm.desc(n.fechaModificacion)]))
          .watch();

  Future<void> insertarNota(NotasCompanion datos) =>
      into(notas).insert(datos);

  Future<void> actualizarNotaPorId(String id, NotasCompanion datos) =>
      (update(notas)..where((n) => n.id.equals(id))).write(datos);

  /// Borrado LÓGICO (igual que clientes y productos): la nota se marca
  /// eliminada y viaja así al espejo de Sheets, quedando auditable.
  Future<void> marcarNotaEliminada(String idNota) =>
      (update(notas)..where((n) => n.id.equals(idNota))).write(
        NotasCompanion(
          eliminado: const Value(true),
          fechaModificacion: Value(DateTime.now()),
          pendienteSync: const Value(true),
        ),
      );

  Future<List<NotaRow>> notasPendientesDeSync() =>
      (select(notas)..where((n) => n.pendienteSync.equals(true))).get();

  Future<void> marcarNotasSincronizadas(List<String> ids) =>
      (update(notas)..where((n) => n.id.isIn(ids)))
          .write(const NotasCompanion(pendienteSync: Value(false)));

  /// ★ BAJADA DE NOTAS (Sheets → app) — FASE 9 ★
  /// Mismas protecciones probadas del inventario:
  ///  1. PENDIENTES: las notas creadas/editadas en la app que aún no
  ///     subieron (pendienteSync = true) NO se borran ni se pisan.
  ///  2. BLINDAJE POR FILA: cada nota entra en su propio try; una
  ///     fila torcida se salta y jamás tumba la bajada completa.
  Future<void> reemplazarNotasDesdeNube(
          List<Map<String, dynamic>> notasJson) =>
      transaction(() async {
        // 1) Borrar SOLO lo ya sincronizado (lo pendiente se queda)
        await (delete(notas)..where((n) => n.pendienteSync.equals(false)))
            .go();

        // Los que sobrevivieron son los pendientes de subir: sus IDs
        // no deben ser pisados por la versión (más vieja) de Sheets.
        final idsPendientes =
            (await select(notas).get()).map((n) => n.id).toSet();

        // 2) Cargar las notas que vienen de Sheets, una por una
        for (final j in notasJson) {
          String s(String col) => (j[col] ?? '').toString().trim();

          final idNota = s('ID_Nota');
          if (idNota.isEmpty) continue; // fila sin ID → basura, ignorar
          if (idsPendientes.contains(idNota)) continue; // local manda

          try {
            await into(notas).insert(
              NotasCompanion.insert(
                id: idNota,
                titulo: Value(s('Titulo').isEmpty ? null : s('Titulo')),
                contenido:
                    Value(s('Contenido').isEmpty ? null : s('Contenido')),
                color: Value(s('Color').isEmpty ? 'NARANJA' : s('Color')),
                eliminado: Value(s('Eliminado').toUpperCase() == 'SI' ||
                    j['Eliminado'] == true),
                fechaCreacion:
                    _parsearFecha(j['Fecha_Creacion']) ?? DateTime.now(),
                fechaModificacion:
                    _parsearFecha(j['Fecha_Modificacion']) ?? DateTime.now(),
                pendienteSync: const Value(false),
              ),
              mode: InsertMode.insertOrReplace,
            );
          } catch (e) {
            // Una fila torcida no debe tumbar toda la bajada.
            // ignore: avoid_print
            print('Nota NOTAS omitida ($idNota): $e');
          }
        }
      });
}

/// 👶 EL MOTOR UNIVERSAL: drift_flutter es el "adaptador de corriente"
/// oficial de Drift. Detecta dónde está corriendo la app y elige solo:
///  · Android / Windows / iOS → SQLite nativo en un archivo del disco.
///  · NAVEGADOR (Chrome, etc.) → SQLite compilado a WASM, guardando
///    los datos en el almacén interno del navegador (IndexedDB/OPFS).
///    Para eso necesita 2 archivos en la carpeta web/ del proyecto:
///    sqlite3.wasm y drift_worker.js (instrucciones en el README).
QueryExecutor _abrirConexion() => driftDatabase(
      name: 'alexmar_local',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
