// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsuariosTable extends Usuarios
    with TableInfo<$UsuariosTable, UsuarioRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nombreCompletoMeta =
      const VerificationMeta('nombreCompleto');
  @override
  late final GeneratedColumn<String> nombreCompleto = GeneratedColumn<String>(
      'nombre_completo', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usuarioMeta =
      const VerificationMeta('usuario');
  @override
  late final GeneratedColumn<String> usuario = GeneratedColumn<String>(
      'usuario', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
      'salt', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rolMeta = const VerificationMeta('rol');
  @override
  late final GeneratedColumn<String> rol = GeneratedColumn<String>(
      'rol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
      'activo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("activo" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _fechaCreacionMeta =
      const VerificationMeta('fechaCreacion');
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>('fecha_creacion', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fechaModificacionMeta =
      const VerificationMeta('fechaModificacion');
  @override
  late final GeneratedColumn<DateTime> fechaModificacion =
      GeneratedColumn<DateTime>('fecha_modificacion', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pendienteSyncMeta =
      const VerificationMeta('pendienteSync');
  @override
  late final GeneratedColumn<bool> pendienteSync = GeneratedColumn<bool>(
      'pendiente_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pendiente_sync" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nombreCompleto,
        usuario,
        passwordHash,
        salt,
        rol,
        activo,
        fechaCreacion,
        fechaModificacion,
        pendienteSync
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios';
  @override
  VerificationContext validateIntegrity(Insertable<UsuarioRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre_completo')) {
      context.handle(
          _nombreCompletoMeta,
          nombreCompleto.isAcceptableOrUnknown(
              data['nombre_completo']!, _nombreCompletoMeta));
    } else if (isInserting) {
      context.missing(_nombreCompletoMeta);
    }
    if (data.containsKey('usuario')) {
      context.handle(_usuarioMeta,
          usuario.isAcceptableOrUnknown(data['usuario']!, _usuarioMeta));
    } else if (isInserting) {
      context.missing(_usuarioMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
          _saltMeta, salt.isAcceptableOrUnknown(data['salt']!, _saltMeta));
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('rol')) {
      context.handle(
          _rolMeta, rol.isAcceptableOrUnknown(data['rol']!, _rolMeta));
    } else if (isInserting) {
      context.missing(_rolMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(_activoMeta,
          activo.isAcceptableOrUnknown(data['activo']!, _activoMeta));
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
          _fechaCreacionMeta,
          fechaCreacion.isAcceptableOrUnknown(
              data['fecha_creacion']!, _fechaCreacionMeta));
    } else if (isInserting) {
      context.missing(_fechaCreacionMeta);
    }
    if (data.containsKey('fecha_modificacion')) {
      context.handle(
          _fechaModificacionMeta,
          fechaModificacion.isAcceptableOrUnknown(
              data['fecha_modificacion']!, _fechaModificacionMeta));
    } else if (isInserting) {
      context.missing(_fechaModificacionMeta);
    }
    if (data.containsKey('pendiente_sync')) {
      context.handle(
          _pendienteSyncMeta,
          pendienteSync.isAcceptableOrUnknown(
              data['pendiente_sync']!, _pendienteSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsuarioRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsuarioRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nombreCompleto: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nombre_completo'])!,
      usuario: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}usuario'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      salt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}salt'])!,
      rol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rol'])!,
      activo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}activo'])!,
      fechaCreacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_creacion'])!,
      fechaModificacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_modificacion'])!,
      pendienteSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pendiente_sync'])!,
    );
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }
}

class UsuarioRow extends DataClass implements Insertable<UsuarioRow> {
  final String id;
  final String nombreCompleto;
  final String usuario;
  final String passwordHash;
  final String salt;
  final String rol;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;
  final bool pendienteSync;
  const UsuarioRow(
      {required this.id,
      required this.nombreCompleto,
      required this.usuario,
      required this.passwordHash,
      required this.salt,
      required this.rol,
      required this.activo,
      required this.fechaCreacion,
      required this.fechaModificacion,
      required this.pendienteSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre_completo'] = Variable<String>(nombreCompleto);
    map['usuario'] = Variable<String>(usuario);
    map['password_hash'] = Variable<String>(passwordHash);
    map['salt'] = Variable<String>(salt);
    map['rol'] = Variable<String>(rol);
    map['activo'] = Variable<bool>(activo);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    map['fecha_modificacion'] = Variable<DateTime>(fechaModificacion);
    map['pendiente_sync'] = Variable<bool>(pendienteSync);
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(
      id: Value(id),
      nombreCompleto: Value(nombreCompleto),
      usuario: Value(usuario),
      passwordHash: Value(passwordHash),
      salt: Value(salt),
      rol: Value(rol),
      activo: Value(activo),
      fechaCreacion: Value(fechaCreacion),
      fechaModificacion: Value(fechaModificacion),
      pendienteSync: Value(pendienteSync),
    );
  }

  factory UsuarioRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsuarioRow(
      id: serializer.fromJson<String>(json['id']),
      nombreCompleto: serializer.fromJson<String>(json['nombreCompleto']),
      usuario: serializer.fromJson<String>(json['usuario']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      salt: serializer.fromJson<String>(json['salt']),
      rol: serializer.fromJson<String>(json['rol']),
      activo: serializer.fromJson<bool>(json['activo']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
      fechaModificacion:
          serializer.fromJson<DateTime>(json['fechaModificacion']),
      pendienteSync: serializer.fromJson<bool>(json['pendienteSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombreCompleto': serializer.toJson<String>(nombreCompleto),
      'usuario': serializer.toJson<String>(usuario),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'salt': serializer.toJson<String>(salt),
      'rol': serializer.toJson<String>(rol),
      'activo': serializer.toJson<bool>(activo),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
      'fechaModificacion': serializer.toJson<DateTime>(fechaModificacion),
      'pendienteSync': serializer.toJson<bool>(pendienteSync),
    };
  }

  UsuarioRow copyWith(
          {String? id,
          String? nombreCompleto,
          String? usuario,
          String? passwordHash,
          String? salt,
          String? rol,
          bool? activo,
          DateTime? fechaCreacion,
          DateTime? fechaModificacion,
          bool? pendienteSync}) =>
      UsuarioRow(
        id: id ?? this.id,
        nombreCompleto: nombreCompleto ?? this.nombreCompleto,
        usuario: usuario ?? this.usuario,
        passwordHash: passwordHash ?? this.passwordHash,
        salt: salt ?? this.salt,
        rol: rol ?? this.rol,
        activo: activo ?? this.activo,
        fechaCreacion: fechaCreacion ?? this.fechaCreacion,
        fechaModificacion: fechaModificacion ?? this.fechaModificacion,
        pendienteSync: pendienteSync ?? this.pendienteSync,
      );
  UsuarioRow copyWithCompanion(UsuariosCompanion data) {
    return UsuarioRow(
      id: data.id.present ? data.id.value : this.id,
      nombreCompleto: data.nombreCompleto.present
          ? data.nombreCompleto.value
          : this.nombreCompleto,
      usuario: data.usuario.present ? data.usuario.value : this.usuario,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      salt: data.salt.present ? data.salt.value : this.salt,
      rol: data.rol.present ? data.rol.value : this.rol,
      activo: data.activo.present ? data.activo.value : this.activo,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
      fechaModificacion: data.fechaModificacion.present
          ? data.fechaModificacion.value
          : this.fechaModificacion,
      pendienteSync: data.pendienteSync.present
          ? data.pendienteSync.value
          : this.pendienteSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsuarioRow(')
          ..write('id: $id, ')
          ..write('nombreCompleto: $nombreCompleto, ')
          ..write('usuario: $usuario, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('rol: $rol, ')
          ..write('activo: $activo, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaModificacion: $fechaModificacion, ')
          ..write('pendienteSync: $pendienteSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombreCompleto, usuario, passwordHash,
      salt, rol, activo, fechaCreacion, fechaModificacion, pendienteSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsuarioRow &&
          other.id == this.id &&
          other.nombreCompleto == this.nombreCompleto &&
          other.usuario == this.usuario &&
          other.passwordHash == this.passwordHash &&
          other.salt == this.salt &&
          other.rol == this.rol &&
          other.activo == this.activo &&
          other.fechaCreacion == this.fechaCreacion &&
          other.fechaModificacion == this.fechaModificacion &&
          other.pendienteSync == this.pendienteSync);
}

class UsuariosCompanion extends UpdateCompanion<UsuarioRow> {
  final Value<String> id;
  final Value<String> nombreCompleto;
  final Value<String> usuario;
  final Value<String> passwordHash;
  final Value<String> salt;
  final Value<String> rol;
  final Value<bool> activo;
  final Value<DateTime> fechaCreacion;
  final Value<DateTime> fechaModificacion;
  final Value<bool> pendienteSync;
  final Value<int> rowid;
  const UsuariosCompanion({
    this.id = const Value.absent(),
    this.nombreCompleto = const Value.absent(),
    this.usuario = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.salt = const Value.absent(),
    this.rol = const Value.absent(),
    this.activo = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaModificacion = const Value.absent(),
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsuariosCompanion.insert({
    required String id,
    required String nombreCompleto,
    required String usuario,
    required String passwordHash,
    required String salt,
    required String rol,
    this.activo = const Value.absent(),
    required DateTime fechaCreacion,
    required DateTime fechaModificacion,
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nombreCompleto = Value(nombreCompleto),
        usuario = Value(usuario),
        passwordHash = Value(passwordHash),
        salt = Value(salt),
        rol = Value(rol),
        fechaCreacion = Value(fechaCreacion),
        fechaModificacion = Value(fechaModificacion);
  static Insertable<UsuarioRow> custom({
    Expression<String>? id,
    Expression<String>? nombreCompleto,
    Expression<String>? usuario,
    Expression<String>? passwordHash,
    Expression<String>? salt,
    Expression<String>? rol,
    Expression<bool>? activo,
    Expression<DateTime>? fechaCreacion,
    Expression<DateTime>? fechaModificacion,
    Expression<bool>? pendienteSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombreCompleto != null) 'nombre_completo': nombreCompleto,
      if (usuario != null) 'usuario': usuario,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (salt != null) 'salt': salt,
      if (rol != null) 'rol': rol,
      if (activo != null) 'activo': activo,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      if (fechaModificacion != null) 'fecha_modificacion': fechaModificacion,
      if (pendienteSync != null) 'pendiente_sync': pendienteSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsuariosCompanion copyWith(
      {Value<String>? id,
      Value<String>? nombreCompleto,
      Value<String>? usuario,
      Value<String>? passwordHash,
      Value<String>? salt,
      Value<String>? rol,
      Value<bool>? activo,
      Value<DateTime>? fechaCreacion,
      Value<DateTime>? fechaModificacion,
      Value<bool>? pendienteSync,
      Value<int>? rowid}) {
    return UsuariosCompanion(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      usuario: usuario ?? this.usuario,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      pendienteSync: pendienteSync ?? this.pendienteSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombreCompleto.present) {
      map['nombre_completo'] = Variable<String>(nombreCompleto.value);
    }
    if (usuario.present) {
      map['usuario'] = Variable<String>(usuario.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (rol.present) {
      map['rol'] = Variable<String>(rol.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    if (fechaModificacion.present) {
      map['fecha_modificacion'] = Variable<DateTime>(fechaModificacion.value);
    }
    if (pendienteSync.present) {
      map['pendiente_sync'] = Variable<bool>(pendienteSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')
          ..write('id: $id, ')
          ..write('nombreCompleto: $nombreCompleto, ')
          ..write('usuario: $usuario, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('rol: $rol, ')
          ..write('activo: $activo, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaModificacion: $fechaModificacion, ')
          ..write('pendienteSync: $pendienteSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientesTable extends Clientes
    with TableInfo<$ClientesTable, ClienteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cedulaMeta = const VerificationMeta('cedula');
  @override
  late final GeneratedColumn<String> cedula = GeneratedColumn<String>(
      'cedula', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nombreClienteMeta =
      const VerificationMeta('nombreCliente');
  @override
  late final GeneratedColumn<String> nombreCliente = GeneratedColumn<String>(
      'nombre_cliente', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _telefonoMeta =
      const VerificationMeta('telefono');
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
      'telefono', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _direccionMeta =
      const VerificationMeta('direccion');
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
      'direccion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _facturaNMeta =
      const VerificationMeta('facturaN');
  @override
  late final GeneratedColumn<String> facturaN = GeneratedColumn<String>(
      'factura_n', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fechaUltimoAbonoMeta =
      const VerificationMeta('fechaUltimoAbono');
  @override
  late final GeneratedColumn<DateTime> fechaUltimoAbono =
      GeneratedColumn<DateTime>('fecha_ultimo_abono', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _totalAdeudadoMeta =
      const VerificationMeta('totalAdeudado');
  @override
  late final GeneratedColumn<double> totalAdeudado = GeneratedColumn<double>(
      'total_adeudado', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _eliminadoMeta =
      const VerificationMeta('eliminado');
  @override
  late final GeneratedColumn<bool> eliminado = GeneratedColumn<bool>(
      'eliminado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("eliminado" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fechaCreacionMeta =
      const VerificationMeta('fechaCreacion');
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>('fecha_creacion', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fechaModificacionMeta =
      const VerificationMeta('fechaModificacion');
  @override
  late final GeneratedColumn<DateTime> fechaModificacion =
      GeneratedColumn<DateTime>('fecha_modificacion', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pendienteSyncMeta =
      const VerificationMeta('pendienteSync');
  @override
  late final GeneratedColumn<bool> pendienteSync = GeneratedColumn<bool>(
      'pendiente_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pendiente_sync" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cedula,
        nombreCliente,
        telefono,
        direccion,
        facturaN,
        fechaUltimoAbono,
        totalAdeudado,
        eliminado,
        fechaCreacion,
        fechaModificacion,
        pendienteSync
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(Insertable<ClienteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cedula')) {
      context.handle(_cedulaMeta,
          cedula.isAcceptableOrUnknown(data['cedula']!, _cedulaMeta));
    }
    if (data.containsKey('nombre_cliente')) {
      context.handle(
          _nombreClienteMeta,
          nombreCliente.isAcceptableOrUnknown(
              data['nombre_cliente']!, _nombreClienteMeta));
    } else if (isInserting) {
      context.missing(_nombreClienteMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(_telefonoMeta,
          telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta));
    }
    if (data.containsKey('direccion')) {
      context.handle(_direccionMeta,
          direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta));
    }
    if (data.containsKey('factura_n')) {
      context.handle(_facturaNMeta,
          facturaN.isAcceptableOrUnknown(data['factura_n']!, _facturaNMeta));
    }
    if (data.containsKey('fecha_ultimo_abono')) {
      context.handle(
          _fechaUltimoAbonoMeta,
          fechaUltimoAbono.isAcceptableOrUnknown(
              data['fecha_ultimo_abono']!, _fechaUltimoAbonoMeta));
    }
    if (data.containsKey('total_adeudado')) {
      context.handle(
          _totalAdeudadoMeta,
          totalAdeudado.isAcceptableOrUnknown(
              data['total_adeudado']!, _totalAdeudadoMeta));
    }
    if (data.containsKey('eliminado')) {
      context.handle(_eliminadoMeta,
          eliminado.isAcceptableOrUnknown(data['eliminado']!, _eliminadoMeta));
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
          _fechaCreacionMeta,
          fechaCreacion.isAcceptableOrUnknown(
              data['fecha_creacion']!, _fechaCreacionMeta));
    } else if (isInserting) {
      context.missing(_fechaCreacionMeta);
    }
    if (data.containsKey('fecha_modificacion')) {
      context.handle(
          _fechaModificacionMeta,
          fechaModificacion.isAcceptableOrUnknown(
              data['fecha_modificacion']!, _fechaModificacionMeta));
    } else if (isInserting) {
      context.missing(_fechaModificacionMeta);
    }
    if (data.containsKey('pendiente_sync')) {
      context.handle(
          _pendienteSyncMeta,
          pendienteSync.isAcceptableOrUnknown(
              data['pendiente_sync']!, _pendienteSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClienteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClienteRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cedula: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cedula']),
      nombreCliente: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nombre_cliente'])!,
      telefono: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}telefono']),
      direccion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direccion']),
      facturaN: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}factura_n']),
      fechaUltimoAbono: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_ultimo_abono']),
      totalAdeudado: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_adeudado'])!,
      eliminado: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}eliminado'])!,
      fechaCreacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_creacion'])!,
      fechaModificacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_modificacion'])!,
      pendienteSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pendiente_sync'])!,
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class ClienteRow extends DataClass implements Insertable<ClienteRow> {
  final String id;
  final String? cedula;
  final String nombreCliente;
  final String? telefono;
  final String? direccion;
  final String? facturaN;
  final DateTime? fechaUltimoAbono;
  final double totalAdeudado;
  final bool eliminado;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;
  final bool pendienteSync;
  const ClienteRow(
      {required this.id,
      this.cedula,
      required this.nombreCliente,
      this.telefono,
      this.direccion,
      this.facturaN,
      this.fechaUltimoAbono,
      required this.totalAdeudado,
      required this.eliminado,
      required this.fechaCreacion,
      required this.fechaModificacion,
      required this.pendienteSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || cedula != null) {
      map['cedula'] = Variable<String>(cedula);
    }
    map['nombre_cliente'] = Variable<String>(nombreCliente);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    if (!nullToAbsent || facturaN != null) {
      map['factura_n'] = Variable<String>(facturaN);
    }
    if (!nullToAbsent || fechaUltimoAbono != null) {
      map['fecha_ultimo_abono'] = Variable<DateTime>(fechaUltimoAbono);
    }
    map['total_adeudado'] = Variable<double>(totalAdeudado);
    map['eliminado'] = Variable<bool>(eliminado);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    map['fecha_modificacion'] = Variable<DateTime>(fechaModificacion);
    map['pendiente_sync'] = Variable<bool>(pendienteSync);
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      cedula:
          cedula == null && nullToAbsent ? const Value.absent() : Value(cedula),
      nombreCliente: Value(nombreCliente),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      facturaN: facturaN == null && nullToAbsent
          ? const Value.absent()
          : Value(facturaN),
      fechaUltimoAbono: fechaUltimoAbono == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaUltimoAbono),
      totalAdeudado: Value(totalAdeudado),
      eliminado: Value(eliminado),
      fechaCreacion: Value(fechaCreacion),
      fechaModificacion: Value(fechaModificacion),
      pendienteSync: Value(pendienteSync),
    );
  }

  factory ClienteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClienteRow(
      id: serializer.fromJson<String>(json['id']),
      cedula: serializer.fromJson<String?>(json['cedula']),
      nombreCliente: serializer.fromJson<String>(json['nombreCliente']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      facturaN: serializer.fromJson<String?>(json['facturaN']),
      fechaUltimoAbono:
          serializer.fromJson<DateTime?>(json['fechaUltimoAbono']),
      totalAdeudado: serializer.fromJson<double>(json['totalAdeudado']),
      eliminado: serializer.fromJson<bool>(json['eliminado']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
      fechaModificacion:
          serializer.fromJson<DateTime>(json['fechaModificacion']),
      pendienteSync: serializer.fromJson<bool>(json['pendienteSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cedula': serializer.toJson<String?>(cedula),
      'nombreCliente': serializer.toJson<String>(nombreCliente),
      'telefono': serializer.toJson<String?>(telefono),
      'direccion': serializer.toJson<String?>(direccion),
      'facturaN': serializer.toJson<String?>(facturaN),
      'fechaUltimoAbono': serializer.toJson<DateTime?>(fechaUltimoAbono),
      'totalAdeudado': serializer.toJson<double>(totalAdeudado),
      'eliminado': serializer.toJson<bool>(eliminado),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
      'fechaModificacion': serializer.toJson<DateTime>(fechaModificacion),
      'pendienteSync': serializer.toJson<bool>(pendienteSync),
    };
  }

  ClienteRow copyWith(
          {String? id,
          Value<String?> cedula = const Value.absent(),
          String? nombreCliente,
          Value<String?> telefono = const Value.absent(),
          Value<String?> direccion = const Value.absent(),
          Value<String?> facturaN = const Value.absent(),
          Value<DateTime?> fechaUltimoAbono = const Value.absent(),
          double? totalAdeudado,
          bool? eliminado,
          DateTime? fechaCreacion,
          DateTime? fechaModificacion,
          bool? pendienteSync}) =>
      ClienteRow(
        id: id ?? this.id,
        cedula: cedula.present ? cedula.value : this.cedula,
        nombreCliente: nombreCliente ?? this.nombreCliente,
        telefono: telefono.present ? telefono.value : this.telefono,
        direccion: direccion.present ? direccion.value : this.direccion,
        facturaN: facturaN.present ? facturaN.value : this.facturaN,
        fechaUltimoAbono: fechaUltimoAbono.present
            ? fechaUltimoAbono.value
            : this.fechaUltimoAbono,
        totalAdeudado: totalAdeudado ?? this.totalAdeudado,
        eliminado: eliminado ?? this.eliminado,
        fechaCreacion: fechaCreacion ?? this.fechaCreacion,
        fechaModificacion: fechaModificacion ?? this.fechaModificacion,
        pendienteSync: pendienteSync ?? this.pendienteSync,
      );
  ClienteRow copyWithCompanion(ClientesCompanion data) {
    return ClienteRow(
      id: data.id.present ? data.id.value : this.id,
      cedula: data.cedula.present ? data.cedula.value : this.cedula,
      nombreCliente: data.nombreCliente.present
          ? data.nombreCliente.value
          : this.nombreCliente,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      facturaN: data.facturaN.present ? data.facturaN.value : this.facturaN,
      fechaUltimoAbono: data.fechaUltimoAbono.present
          ? data.fechaUltimoAbono.value
          : this.fechaUltimoAbono,
      totalAdeudado: data.totalAdeudado.present
          ? data.totalAdeudado.value
          : this.totalAdeudado,
      eliminado: data.eliminado.present ? data.eliminado.value : this.eliminado,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
      fechaModificacion: data.fechaModificacion.present
          ? data.fechaModificacion.value
          : this.fechaModificacion,
      pendienteSync: data.pendienteSync.present
          ? data.pendienteSync.value
          : this.pendienteSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClienteRow(')
          ..write('id: $id, ')
          ..write('cedula: $cedula, ')
          ..write('nombreCliente: $nombreCliente, ')
          ..write('telefono: $telefono, ')
          ..write('direccion: $direccion, ')
          ..write('facturaN: $facturaN, ')
          ..write('fechaUltimoAbono: $fechaUltimoAbono, ')
          ..write('totalAdeudado: $totalAdeudado, ')
          ..write('eliminado: $eliminado, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaModificacion: $fechaModificacion, ')
          ..write('pendienteSync: $pendienteSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cedula,
      nombreCliente,
      telefono,
      direccion,
      facturaN,
      fechaUltimoAbono,
      totalAdeudado,
      eliminado,
      fechaCreacion,
      fechaModificacion,
      pendienteSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClienteRow &&
          other.id == this.id &&
          other.cedula == this.cedula &&
          other.nombreCliente == this.nombreCliente &&
          other.telefono == this.telefono &&
          other.direccion == this.direccion &&
          other.facturaN == this.facturaN &&
          other.fechaUltimoAbono == this.fechaUltimoAbono &&
          other.totalAdeudado == this.totalAdeudado &&
          other.eliminado == this.eliminado &&
          other.fechaCreacion == this.fechaCreacion &&
          other.fechaModificacion == this.fechaModificacion &&
          other.pendienteSync == this.pendienteSync);
}

class ClientesCompanion extends UpdateCompanion<ClienteRow> {
  final Value<String> id;
  final Value<String?> cedula;
  final Value<String> nombreCliente;
  final Value<String?> telefono;
  final Value<String?> direccion;
  final Value<String?> facturaN;
  final Value<DateTime?> fechaUltimoAbono;
  final Value<double> totalAdeudado;
  final Value<bool> eliminado;
  final Value<DateTime> fechaCreacion;
  final Value<DateTime> fechaModificacion;
  final Value<bool> pendienteSync;
  final Value<int> rowid;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.cedula = const Value.absent(),
    this.nombreCliente = const Value.absent(),
    this.telefono = const Value.absent(),
    this.direccion = const Value.absent(),
    this.facturaN = const Value.absent(),
    this.fechaUltimoAbono = const Value.absent(),
    this.totalAdeudado = const Value.absent(),
    this.eliminado = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaModificacion = const Value.absent(),
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientesCompanion.insert({
    required String id,
    this.cedula = const Value.absent(),
    required String nombreCliente,
    this.telefono = const Value.absent(),
    this.direccion = const Value.absent(),
    this.facturaN = const Value.absent(),
    this.fechaUltimoAbono = const Value.absent(),
    this.totalAdeudado = const Value.absent(),
    this.eliminado = const Value.absent(),
    required DateTime fechaCreacion,
    required DateTime fechaModificacion,
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nombreCliente = Value(nombreCliente),
        fechaCreacion = Value(fechaCreacion),
        fechaModificacion = Value(fechaModificacion);
  static Insertable<ClienteRow> custom({
    Expression<String>? id,
    Expression<String>? cedula,
    Expression<String>? nombreCliente,
    Expression<String>? telefono,
    Expression<String>? direccion,
    Expression<String>? facturaN,
    Expression<DateTime>? fechaUltimoAbono,
    Expression<double>? totalAdeudado,
    Expression<bool>? eliminado,
    Expression<DateTime>? fechaCreacion,
    Expression<DateTime>? fechaModificacion,
    Expression<bool>? pendienteSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cedula != null) 'cedula': cedula,
      if (nombreCliente != null) 'nombre_cliente': nombreCliente,
      if (telefono != null) 'telefono': telefono,
      if (direccion != null) 'direccion': direccion,
      if (facturaN != null) 'factura_n': facturaN,
      if (fechaUltimoAbono != null) 'fecha_ultimo_abono': fechaUltimoAbono,
      if (totalAdeudado != null) 'total_adeudado': totalAdeudado,
      if (eliminado != null) 'eliminado': eliminado,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      if (fechaModificacion != null) 'fecha_modificacion': fechaModificacion,
      if (pendienteSync != null) 'pendiente_sync': pendienteSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? cedula,
      Value<String>? nombreCliente,
      Value<String?>? telefono,
      Value<String?>? direccion,
      Value<String?>? facturaN,
      Value<DateTime?>? fechaUltimoAbono,
      Value<double>? totalAdeudado,
      Value<bool>? eliminado,
      Value<DateTime>? fechaCreacion,
      Value<DateTime>? fechaModificacion,
      Value<bool>? pendienteSync,
      Value<int>? rowid}) {
    return ClientesCompanion(
      id: id ?? this.id,
      cedula: cedula ?? this.cedula,
      nombreCliente: nombreCliente ?? this.nombreCliente,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      facturaN: facturaN ?? this.facturaN,
      fechaUltimoAbono: fechaUltimoAbono ?? this.fechaUltimoAbono,
      totalAdeudado: totalAdeudado ?? this.totalAdeudado,
      eliminado: eliminado ?? this.eliminado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      pendienteSync: pendienteSync ?? this.pendienteSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cedula.present) {
      map['cedula'] = Variable<String>(cedula.value);
    }
    if (nombreCliente.present) {
      map['nombre_cliente'] = Variable<String>(nombreCliente.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (facturaN.present) {
      map['factura_n'] = Variable<String>(facturaN.value);
    }
    if (fechaUltimoAbono.present) {
      map['fecha_ultimo_abono'] = Variable<DateTime>(fechaUltimoAbono.value);
    }
    if (totalAdeudado.present) {
      map['total_adeudado'] = Variable<double>(totalAdeudado.value);
    }
    if (eliminado.present) {
      map['eliminado'] = Variable<bool>(eliminado.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    if (fechaModificacion.present) {
      map['fecha_modificacion'] = Variable<DateTime>(fechaModificacion.value);
    }
    if (pendienteSync.present) {
      map['pendiente_sync'] = Variable<bool>(pendienteSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('cedula: $cedula, ')
          ..write('nombreCliente: $nombreCliente, ')
          ..write('telefono: $telefono, ')
          ..write('direccion: $direccion, ')
          ..write('facturaN: $facturaN, ')
          ..write('fechaUltimoAbono: $fechaUltimoAbono, ')
          ..write('totalAdeudado: $totalAdeudado, ')
          ..write('eliminado: $eliminado, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaModificacion: $fechaModificacion, ')
          ..write('pendienteSync: $pendienteSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DetalleCuentasTable extends DetalleCuentas
    with TableInfo<$DetalleCuentasTable, LineaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetalleCuentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _idClienteMeta =
      const VerificationMeta('idCliente');
  @override
  late final GeneratedColumn<String> idCliente = GeneratedColumn<String>(
      'id_cliente', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tipoLineaMeta =
      const VerificationMeta('tipoLinea');
  @override
  late final GeneratedColumn<String> tipoLinea = GeneratedColumn<String>(
      'tipo_linea', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
      'fecha', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cantidadMeta =
      const VerificationMeta('cantidad');
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
      'cantidad', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _precioUnitarioMeta =
      const VerificationMeta('precioUnitario');
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
      'precio_unitario', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _totalLineaMeta =
      const VerificationMeta('totalLinea');
  @override
  late final GeneratedColumn<double> totalLinea = GeneratedColumn<double>(
      'total_linea', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _costoUnitarioMeta =
      const VerificationMeta('costoUnitario');
  @override
  late final GeneratedColumn<double> costoUnitario = GeneratedColumn<double>(
      'costo_unitario', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _idProductoMeta =
      const VerificationMeta('idProducto');
  @override
  late final GeneratedColumn<String> idProducto = GeneratedColumn<String>(
      'id_producto', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _eliminadoMeta =
      const VerificationMeta('eliminado');
  @override
  late final GeneratedColumn<bool> eliminado = GeneratedColumn<bool>(
      'eliminado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("eliminado" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fechaCreacionMeta =
      const VerificationMeta('fechaCreacion');
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>('fecha_creacion', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fechaModificacionMeta =
      const VerificationMeta('fechaModificacion');
  @override
  late final GeneratedColumn<DateTime> fechaModificacion =
      GeneratedColumn<DateTime>('fecha_modificacion', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pendienteSyncMeta =
      const VerificationMeta('pendienteSync');
  @override
  late final GeneratedColumn<bool> pendienteSync = GeneratedColumn<bool>(
      'pendiente_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pendiente_sync" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        idCliente,
        tipoLinea,
        fecha,
        cantidad,
        descripcion,
        precioUnitario,
        totalLinea,
        costoUnitario,
        idProducto,
        eliminado,
        fechaCreacion,
        fechaModificacion,
        pendienteSync
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detalle_cuentas';
  @override
  VerificationContext validateIntegrity(Insertable<LineaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('id_cliente')) {
      context.handle(_idClienteMeta,
          idCliente.isAcceptableOrUnknown(data['id_cliente']!, _idClienteMeta));
    } else if (isInserting) {
      context.missing(_idClienteMeta);
    }
    if (data.containsKey('tipo_linea')) {
      context.handle(_tipoLineaMeta,
          tipoLinea.isAcceptableOrUnknown(data['tipo_linea']!, _tipoLineaMeta));
    } else if (isInserting) {
      context.missing(_tipoLineaMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
          _fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(_cantidadMeta,
          cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta));
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    } else if (isInserting) {
      context.missing(_descripcionMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
          _precioUnitarioMeta,
          precioUnitario.isAcceptableOrUnknown(
              data['precio_unitario']!, _precioUnitarioMeta));
    }
    if (data.containsKey('total_linea')) {
      context.handle(
          _totalLineaMeta,
          totalLinea.isAcceptableOrUnknown(
              data['total_linea']!, _totalLineaMeta));
    } else if (isInserting) {
      context.missing(_totalLineaMeta);
    }
    if (data.containsKey('costo_unitario')) {
      context.handle(
          _costoUnitarioMeta,
          costoUnitario.isAcceptableOrUnknown(
              data['costo_unitario']!, _costoUnitarioMeta));
    }
    if (data.containsKey('id_producto')) {
      context.handle(
          _idProductoMeta,
          idProducto.isAcceptableOrUnknown(
              data['id_producto']!, _idProductoMeta));
    }
    if (data.containsKey('eliminado')) {
      context.handle(_eliminadoMeta,
          eliminado.isAcceptableOrUnknown(data['eliminado']!, _eliminadoMeta));
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
          _fechaCreacionMeta,
          fechaCreacion.isAcceptableOrUnknown(
              data['fecha_creacion']!, _fechaCreacionMeta));
    } else if (isInserting) {
      context.missing(_fechaCreacionMeta);
    }
    if (data.containsKey('fecha_modificacion')) {
      context.handle(
          _fechaModificacionMeta,
          fechaModificacion.isAcceptableOrUnknown(
              data['fecha_modificacion']!, _fechaModificacionMeta));
    } else if (isInserting) {
      context.missing(_fechaModificacionMeta);
    }
    if (data.containsKey('pendiente_sync')) {
      context.handle(
          _pendienteSyncMeta,
          pendienteSync.isAcceptableOrUnknown(
              data['pendiente_sync']!, _pendienteSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LineaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineaRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      idCliente: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_cliente'])!,
      tipoLinea: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipo_linea'])!,
      fecha: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha'])!,
      cantidad: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cantidad'])!,
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion'])!,
      precioUnitario: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}precio_unitario']),
      totalLinea: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_linea'])!,
      costoUnitario: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}costo_unitario']),
      idProducto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id_producto']),
      eliminado: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}eliminado'])!,
      fechaCreacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_creacion'])!,
      fechaModificacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_modificacion'])!,
      pendienteSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pendiente_sync'])!,
    );
  }

  @override
  $DetalleCuentasTable createAlias(String alias) {
    return $DetalleCuentasTable(attachedDatabase, alias);
  }
}

class LineaRow extends DataClass implements Insertable<LineaRow> {
  final String id;
  final String idCliente;
  final String tipoLinea;
  final DateTime fecha;
  final double cantidad;
  final String descripcion;
  final double? precioUnitario;
  final double totalLinea;

  /// 🔒 FOTO DEL COSTO al momento de vender (solo cargos, opcional).
  /// 👶 ¿Por qué guardarlo aquí y no mirar el inventario? Porque los
  /// costos cambian con el tiempo: si en marzo el faro costó $10 y
  /// en julio cuesta $14, la ganancia de marzo debe calcularse con
  /// los \$10 de ESE día. Por eso congelamos el costo en la línea.
  final double? costoUnitario;
  final String? idProducto;
  final bool eliminado;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;
  final bool pendienteSync;
  const LineaRow(
      {required this.id,
      required this.idCliente,
      required this.tipoLinea,
      required this.fecha,
      required this.cantidad,
      required this.descripcion,
      this.precioUnitario,
      required this.totalLinea,
      this.costoUnitario,
      this.idProducto,
      required this.eliminado,
      required this.fechaCreacion,
      required this.fechaModificacion,
      required this.pendienteSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['id_cliente'] = Variable<String>(idCliente);
    map['tipo_linea'] = Variable<String>(tipoLinea);
    map['fecha'] = Variable<DateTime>(fecha);
    map['cantidad'] = Variable<double>(cantidad);
    map['descripcion'] = Variable<String>(descripcion);
    if (!nullToAbsent || precioUnitario != null) {
      map['precio_unitario'] = Variable<double>(precioUnitario);
    }
    map['total_linea'] = Variable<double>(totalLinea);
    if (!nullToAbsent || costoUnitario != null) {
      map['costo_unitario'] = Variable<double>(costoUnitario);
    }
    if (!nullToAbsent || idProducto != null) {
      map['id_producto'] = Variable<String>(idProducto);
    }
    map['eliminado'] = Variable<bool>(eliminado);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    map['fecha_modificacion'] = Variable<DateTime>(fechaModificacion);
    map['pendiente_sync'] = Variable<bool>(pendienteSync);
    return map;
  }

  DetalleCuentasCompanion toCompanion(bool nullToAbsent) {
    return DetalleCuentasCompanion(
      id: Value(id),
      idCliente: Value(idCliente),
      tipoLinea: Value(tipoLinea),
      fecha: Value(fecha),
      cantidad: Value(cantidad),
      descripcion: Value(descripcion),
      precioUnitario: precioUnitario == null && nullToAbsent
          ? const Value.absent()
          : Value(precioUnitario),
      totalLinea: Value(totalLinea),
      costoUnitario: costoUnitario == null && nullToAbsent
          ? const Value.absent()
          : Value(costoUnitario),
      idProducto: idProducto == null && nullToAbsent
          ? const Value.absent()
          : Value(idProducto),
      eliminado: Value(eliminado),
      fechaCreacion: Value(fechaCreacion),
      fechaModificacion: Value(fechaModificacion),
      pendienteSync: Value(pendienteSync),
    );
  }

  factory LineaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineaRow(
      id: serializer.fromJson<String>(json['id']),
      idCliente: serializer.fromJson<String>(json['idCliente']),
      tipoLinea: serializer.fromJson<String>(json['tipoLinea']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      precioUnitario: serializer.fromJson<double?>(json['precioUnitario']),
      totalLinea: serializer.fromJson<double>(json['totalLinea']),
      costoUnitario: serializer.fromJson<double?>(json['costoUnitario']),
      idProducto: serializer.fromJson<String?>(json['idProducto']),
      eliminado: serializer.fromJson<bool>(json['eliminado']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
      fechaModificacion:
          serializer.fromJson<DateTime>(json['fechaModificacion']),
      pendienteSync: serializer.fromJson<bool>(json['pendienteSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'idCliente': serializer.toJson<String>(idCliente),
      'tipoLinea': serializer.toJson<String>(tipoLinea),
      'fecha': serializer.toJson<DateTime>(fecha),
      'cantidad': serializer.toJson<double>(cantidad),
      'descripcion': serializer.toJson<String>(descripcion),
      'precioUnitario': serializer.toJson<double?>(precioUnitario),
      'totalLinea': serializer.toJson<double>(totalLinea),
      'costoUnitario': serializer.toJson<double?>(costoUnitario),
      'idProducto': serializer.toJson<String?>(idProducto),
      'eliminado': serializer.toJson<bool>(eliminado),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
      'fechaModificacion': serializer.toJson<DateTime>(fechaModificacion),
      'pendienteSync': serializer.toJson<bool>(pendienteSync),
    };
  }

  LineaRow copyWith(
          {String? id,
          String? idCliente,
          String? tipoLinea,
          DateTime? fecha,
          double? cantidad,
          String? descripcion,
          Value<double?> precioUnitario = const Value.absent(),
          double? totalLinea,
          Value<double?> costoUnitario = const Value.absent(),
          Value<String?> idProducto = const Value.absent(),
          bool? eliminado,
          DateTime? fechaCreacion,
          DateTime? fechaModificacion,
          bool? pendienteSync}) =>
      LineaRow(
        id: id ?? this.id,
        idCliente: idCliente ?? this.idCliente,
        tipoLinea: tipoLinea ?? this.tipoLinea,
        fecha: fecha ?? this.fecha,
        cantidad: cantidad ?? this.cantidad,
        descripcion: descripcion ?? this.descripcion,
        precioUnitario:
            precioUnitario.present ? precioUnitario.value : this.precioUnitario,
        totalLinea: totalLinea ?? this.totalLinea,
        costoUnitario:
            costoUnitario.present ? costoUnitario.value : this.costoUnitario,
        idProducto: idProducto.present ? idProducto.value : this.idProducto,
        eliminado: eliminado ?? this.eliminado,
        fechaCreacion: fechaCreacion ?? this.fechaCreacion,
        fechaModificacion: fechaModificacion ?? this.fechaModificacion,
        pendienteSync: pendienteSync ?? this.pendienteSync,
      );
  LineaRow copyWithCompanion(DetalleCuentasCompanion data) {
    return LineaRow(
      id: data.id.present ? data.id.value : this.id,
      idCliente: data.idCliente.present ? data.idCliente.value : this.idCliente,
      tipoLinea: data.tipoLinea.present ? data.tipoLinea.value : this.tipoLinea,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      totalLinea:
          data.totalLinea.present ? data.totalLinea.value : this.totalLinea,
      costoUnitario: data.costoUnitario.present
          ? data.costoUnitario.value
          : this.costoUnitario,
      idProducto:
          data.idProducto.present ? data.idProducto.value : this.idProducto,
      eliminado: data.eliminado.present ? data.eliminado.value : this.eliminado,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
      fechaModificacion: data.fechaModificacion.present
          ? data.fechaModificacion.value
          : this.fechaModificacion,
      pendienteSync: data.pendienteSync.present
          ? data.pendienteSync.value
          : this.pendienteSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineaRow(')
          ..write('id: $id, ')
          ..write('idCliente: $idCliente, ')
          ..write('tipoLinea: $tipoLinea, ')
          ..write('fecha: $fecha, ')
          ..write('cantidad: $cantidad, ')
          ..write('descripcion: $descripcion, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('totalLinea: $totalLinea, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('idProducto: $idProducto, ')
          ..write('eliminado: $eliminado, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaModificacion: $fechaModificacion, ')
          ..write('pendienteSync: $pendienteSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      idCliente,
      tipoLinea,
      fecha,
      cantidad,
      descripcion,
      precioUnitario,
      totalLinea,
      costoUnitario,
      idProducto,
      eliminado,
      fechaCreacion,
      fechaModificacion,
      pendienteSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineaRow &&
          other.id == this.id &&
          other.idCliente == this.idCliente &&
          other.tipoLinea == this.tipoLinea &&
          other.fecha == this.fecha &&
          other.cantidad == this.cantidad &&
          other.descripcion == this.descripcion &&
          other.precioUnitario == this.precioUnitario &&
          other.totalLinea == this.totalLinea &&
          other.costoUnitario == this.costoUnitario &&
          other.idProducto == this.idProducto &&
          other.eliminado == this.eliminado &&
          other.fechaCreacion == this.fechaCreacion &&
          other.fechaModificacion == this.fechaModificacion &&
          other.pendienteSync == this.pendienteSync);
}

class DetalleCuentasCompanion extends UpdateCompanion<LineaRow> {
  final Value<String> id;
  final Value<String> idCliente;
  final Value<String> tipoLinea;
  final Value<DateTime> fecha;
  final Value<double> cantidad;
  final Value<String> descripcion;
  final Value<double?> precioUnitario;
  final Value<double> totalLinea;
  final Value<double?> costoUnitario;
  final Value<String?> idProducto;
  final Value<bool> eliminado;
  final Value<DateTime> fechaCreacion;
  final Value<DateTime> fechaModificacion;
  final Value<bool> pendienteSync;
  final Value<int> rowid;
  const DetalleCuentasCompanion({
    this.id = const Value.absent(),
    this.idCliente = const Value.absent(),
    this.tipoLinea = const Value.absent(),
    this.fecha = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.totalLinea = const Value.absent(),
    this.costoUnitario = const Value.absent(),
    this.idProducto = const Value.absent(),
    this.eliminado = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaModificacion = const Value.absent(),
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DetalleCuentasCompanion.insert({
    required String id,
    required String idCliente,
    required String tipoLinea,
    required DateTime fecha,
    required double cantidad,
    required String descripcion,
    this.precioUnitario = const Value.absent(),
    required double totalLinea,
    this.costoUnitario = const Value.absent(),
    this.idProducto = const Value.absent(),
    this.eliminado = const Value.absent(),
    required DateTime fechaCreacion,
    required DateTime fechaModificacion,
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        idCliente = Value(idCliente),
        tipoLinea = Value(tipoLinea),
        fecha = Value(fecha),
        cantidad = Value(cantidad),
        descripcion = Value(descripcion),
        totalLinea = Value(totalLinea),
        fechaCreacion = Value(fechaCreacion),
        fechaModificacion = Value(fechaModificacion);
  static Insertable<LineaRow> custom({
    Expression<String>? id,
    Expression<String>? idCliente,
    Expression<String>? tipoLinea,
    Expression<DateTime>? fecha,
    Expression<double>? cantidad,
    Expression<String>? descripcion,
    Expression<double>? precioUnitario,
    Expression<double>? totalLinea,
    Expression<double>? costoUnitario,
    Expression<String>? idProducto,
    Expression<bool>? eliminado,
    Expression<DateTime>? fechaCreacion,
    Expression<DateTime>? fechaModificacion,
    Expression<bool>? pendienteSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idCliente != null) 'id_cliente': idCliente,
      if (tipoLinea != null) 'tipo_linea': tipoLinea,
      if (fecha != null) 'fecha': fecha,
      if (cantidad != null) 'cantidad': cantidad,
      if (descripcion != null) 'descripcion': descripcion,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (totalLinea != null) 'total_linea': totalLinea,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
      if (idProducto != null) 'id_producto': idProducto,
      if (eliminado != null) 'eliminado': eliminado,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      if (fechaModificacion != null) 'fecha_modificacion': fechaModificacion,
      if (pendienteSync != null) 'pendiente_sync': pendienteSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DetalleCuentasCompanion copyWith(
      {Value<String>? id,
      Value<String>? idCliente,
      Value<String>? tipoLinea,
      Value<DateTime>? fecha,
      Value<double>? cantidad,
      Value<String>? descripcion,
      Value<double?>? precioUnitario,
      Value<double>? totalLinea,
      Value<double?>? costoUnitario,
      Value<String?>? idProducto,
      Value<bool>? eliminado,
      Value<DateTime>? fechaCreacion,
      Value<DateTime>? fechaModificacion,
      Value<bool>? pendienteSync,
      Value<int>? rowid}) {
    return DetalleCuentasCompanion(
      id: id ?? this.id,
      idCliente: idCliente ?? this.idCliente,
      tipoLinea: tipoLinea ?? this.tipoLinea,
      fecha: fecha ?? this.fecha,
      cantidad: cantidad ?? this.cantidad,
      descripcion: descripcion ?? this.descripcion,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      totalLinea: totalLinea ?? this.totalLinea,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      idProducto: idProducto ?? this.idProducto,
      eliminado: eliminado ?? this.eliminado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      pendienteSync: pendienteSync ?? this.pendienteSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (idCliente.present) {
      map['id_cliente'] = Variable<String>(idCliente.value);
    }
    if (tipoLinea.present) {
      map['tipo_linea'] = Variable<String>(tipoLinea.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (totalLinea.present) {
      map['total_linea'] = Variable<double>(totalLinea.value);
    }
    if (costoUnitario.present) {
      map['costo_unitario'] = Variable<double>(costoUnitario.value);
    }
    if (idProducto.present) {
      map['id_producto'] = Variable<String>(idProducto.value);
    }
    if (eliminado.present) {
      map['eliminado'] = Variable<bool>(eliminado.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    if (fechaModificacion.present) {
      map['fecha_modificacion'] = Variable<DateTime>(fechaModificacion.value);
    }
    if (pendienteSync.present) {
      map['pendiente_sync'] = Variable<bool>(pendienteSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetalleCuentasCompanion(')
          ..write('id: $id, ')
          ..write('idCliente: $idCliente, ')
          ..write('tipoLinea: $tipoLinea, ')
          ..write('fecha: $fecha, ')
          ..write('cantidad: $cantidad, ')
          ..write('descripcion: $descripcion, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('totalLinea: $totalLinea, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('idProducto: $idProducto, ')
          ..write('eliminado: $eliminado, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaModificacion: $fechaModificacion, ')
          ..write('pendienteSync: $pendienteSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventarioTable extends Inventario
    with TableInfo<$InventarioTable, ProductoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventarioTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nombreProductoMeta =
      const VerificationMeta('nombreProducto');
  @override
  late final GeneratedColumn<String> nombreProducto = GeneratedColumn<String>(
      'nombre_producto', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descripcionMeta =
      const VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
      'descripcion', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoriaTagsMeta =
      const VerificationMeta('categoriaTags');
  @override
  late final GeneratedColumn<String> categoriaTags = GeneratedColumn<String>(
      'categoria_tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _compatibilidadVehiculosMeta =
      const VerificationMeta('compatibilidadVehiculos');
  @override
  late final GeneratedColumn<String> compatibilidadVehiculos =
      GeneratedColumn<String>('compatibilidad_vehiculos', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _costoMeta = const VerificationMeta('costo');
  @override
  late final GeneratedColumn<double> costo = GeneratedColumn<double>(
      'costo', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _pvpMeta = const VerificationMeta('pvp');
  @override
  late final GeneratedColumn<double> pvp = GeneratedColumn<double>(
      'pvp', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _stockActualMeta =
      const VerificationMeta('stockActual');
  @override
  late final GeneratedColumn<int> stockActual = GeneratedColumn<int>(
      'stock_actual', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stockMinimoMeta =
      const VerificationMeta('stockMinimo');
  @override
  late final GeneratedColumn<int> stockMinimo = GeneratedColumn<int>(
      'stock_minimo', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _urlFotoMeta =
      const VerificationMeta('urlFoto');
  @override
  late final GeneratedColumn<String> urlFoto = GeneratedColumn<String>(
      'url_foto', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _eliminadoMeta =
      const VerificationMeta('eliminado');
  @override
  late final GeneratedColumn<bool> eliminado = GeneratedColumn<bool>(
      'eliminado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("eliminado" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fechaCreacionMeta =
      const VerificationMeta('fechaCreacion');
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>('fecha_creacion', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fechaModificacionMeta =
      const VerificationMeta('fechaModificacion');
  @override
  late final GeneratedColumn<DateTime> fechaModificacion =
      GeneratedColumn<DateTime>('fecha_modificacion', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pendienteSyncMeta =
      const VerificationMeta('pendienteSync');
  @override
  late final GeneratedColumn<bool> pendienteSync = GeneratedColumn<bool>(
      'pendiente_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pendiente_sync" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        nombreProducto,
        descripcion,
        categoriaTags,
        compatibilidadVehiculos,
        costo,
        pvp,
        stockActual,
        stockMinimo,
        urlFoto,
        eliminado,
        fechaCreacion,
        fechaModificacion,
        pendienteSync
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventario';
  @override
  VerificationContext validateIntegrity(Insertable<ProductoRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nombre_producto')) {
      context.handle(
          _nombreProductoMeta,
          nombreProducto.isAcceptableOrUnknown(
              data['nombre_producto']!, _nombreProductoMeta));
    } else if (isInserting) {
      context.missing(_nombreProductoMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
          _descripcionMeta,
          descripcion.isAcceptableOrUnknown(
              data['descripcion']!, _descripcionMeta));
    }
    if (data.containsKey('categoria_tags')) {
      context.handle(
          _categoriaTagsMeta,
          categoriaTags.isAcceptableOrUnknown(
              data['categoria_tags']!, _categoriaTagsMeta));
    } else if (isInserting) {
      context.missing(_categoriaTagsMeta);
    }
    if (data.containsKey('compatibilidad_vehiculos')) {
      context.handle(
          _compatibilidadVehiculosMeta,
          compatibilidadVehiculos.isAcceptableOrUnknown(
              data['compatibilidad_vehiculos']!, _compatibilidadVehiculosMeta));
    } else if (isInserting) {
      context.missing(_compatibilidadVehiculosMeta);
    }
    if (data.containsKey('costo')) {
      context.handle(
          _costoMeta, costo.isAcceptableOrUnknown(data['costo']!, _costoMeta));
    }
    if (data.containsKey('pvp')) {
      context.handle(
          _pvpMeta, pvp.isAcceptableOrUnknown(data['pvp']!, _pvpMeta));
    }
    if (data.containsKey('stock_actual')) {
      context.handle(
          _stockActualMeta,
          stockActual.isAcceptableOrUnknown(
              data['stock_actual']!, _stockActualMeta));
    }
    if (data.containsKey('stock_minimo')) {
      context.handle(
          _stockMinimoMeta,
          stockMinimo.isAcceptableOrUnknown(
              data['stock_minimo']!, _stockMinimoMeta));
    }
    if (data.containsKey('url_foto')) {
      context.handle(_urlFotoMeta,
          urlFoto.isAcceptableOrUnknown(data['url_foto']!, _urlFotoMeta));
    }
    if (data.containsKey('eliminado')) {
      context.handle(_eliminadoMeta,
          eliminado.isAcceptableOrUnknown(data['eliminado']!, _eliminadoMeta));
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
          _fechaCreacionMeta,
          fechaCreacion.isAcceptableOrUnknown(
              data['fecha_creacion']!, _fechaCreacionMeta));
    } else if (isInserting) {
      context.missing(_fechaCreacionMeta);
    }
    if (data.containsKey('fecha_modificacion')) {
      context.handle(
          _fechaModificacionMeta,
          fechaModificacion.isAcceptableOrUnknown(
              data['fecha_modificacion']!, _fechaModificacionMeta));
    } else if (isInserting) {
      context.missing(_fechaModificacionMeta);
    }
    if (data.containsKey('pendiente_sync')) {
      context.handle(
          _pendienteSyncMeta,
          pendienteSync.isAcceptableOrUnknown(
              data['pendiente_sync']!, _pendienteSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductoRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      nombreProducto: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}nombre_producto'])!,
      descripcion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}descripcion']),
      categoriaTags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}categoria_tags'])!,
      compatibilidadVehiculos: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}compatibilidad_vehiculos'])!,
      costo: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}costo']),
      pvp: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pvp']),
      stockActual: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_actual'])!,
      stockMinimo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stock_minimo'])!,
      urlFoto: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url_foto']),
      eliminado: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}eliminado'])!,
      fechaCreacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_creacion'])!,
      fechaModificacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_modificacion'])!,
      pendienteSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pendiente_sync'])!,
    );
  }

  @override
  $InventarioTable createAlias(String alias) {
    return $InventarioTable(attachedDatabase, alias);
  }
}

class ProductoRow extends DataClass implements Insertable<ProductoRow> {
  final String id;
  final String nombreProducto;
  final String? descripcion;
  final String categoriaTags;
  final String compatibilidadVehiculos;
  final double? costo;
  final double? pvp;
  final int stockActual;
  final int stockMinimo;
  final String? urlFoto;
  final bool eliminado;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;
  final bool pendienteSync;
  const ProductoRow(
      {required this.id,
      required this.nombreProducto,
      this.descripcion,
      required this.categoriaTags,
      required this.compatibilidadVehiculos,
      this.costo,
      this.pvp,
      required this.stockActual,
      required this.stockMinimo,
      this.urlFoto,
      required this.eliminado,
      required this.fechaCreacion,
      required this.fechaModificacion,
      required this.pendienteSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nombre_producto'] = Variable<String>(nombreProducto);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['categoria_tags'] = Variable<String>(categoriaTags);
    map['compatibilidad_vehiculos'] = Variable<String>(compatibilidadVehiculos);
    if (!nullToAbsent || costo != null) {
      map['costo'] = Variable<double>(costo);
    }
    if (!nullToAbsent || pvp != null) {
      map['pvp'] = Variable<double>(pvp);
    }
    map['stock_actual'] = Variable<int>(stockActual);
    map['stock_minimo'] = Variable<int>(stockMinimo);
    if (!nullToAbsent || urlFoto != null) {
      map['url_foto'] = Variable<String>(urlFoto);
    }
    map['eliminado'] = Variable<bool>(eliminado);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    map['fecha_modificacion'] = Variable<DateTime>(fechaModificacion);
    map['pendiente_sync'] = Variable<bool>(pendienteSync);
    return map;
  }

  InventarioCompanion toCompanion(bool nullToAbsent) {
    return InventarioCompanion(
      id: Value(id),
      nombreProducto: Value(nombreProducto),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      categoriaTags: Value(categoriaTags),
      compatibilidadVehiculos: Value(compatibilidadVehiculos),
      costo:
          costo == null && nullToAbsent ? const Value.absent() : Value(costo),
      pvp: pvp == null && nullToAbsent ? const Value.absent() : Value(pvp),
      stockActual: Value(stockActual),
      stockMinimo: Value(stockMinimo),
      urlFoto: urlFoto == null && nullToAbsent
          ? const Value.absent()
          : Value(urlFoto),
      eliminado: Value(eliminado),
      fechaCreacion: Value(fechaCreacion),
      fechaModificacion: Value(fechaModificacion),
      pendienteSync: Value(pendienteSync),
    );
  }

  factory ProductoRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductoRow(
      id: serializer.fromJson<String>(json['id']),
      nombreProducto: serializer.fromJson<String>(json['nombreProducto']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      categoriaTags: serializer.fromJson<String>(json['categoriaTags']),
      compatibilidadVehiculos:
          serializer.fromJson<String>(json['compatibilidadVehiculos']),
      costo: serializer.fromJson<double?>(json['costo']),
      pvp: serializer.fromJson<double?>(json['pvp']),
      stockActual: serializer.fromJson<int>(json['stockActual']),
      stockMinimo: serializer.fromJson<int>(json['stockMinimo']),
      urlFoto: serializer.fromJson<String?>(json['urlFoto']),
      eliminado: serializer.fromJson<bool>(json['eliminado']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
      fechaModificacion:
          serializer.fromJson<DateTime>(json['fechaModificacion']),
      pendienteSync: serializer.fromJson<bool>(json['pendienteSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nombreProducto': serializer.toJson<String>(nombreProducto),
      'descripcion': serializer.toJson<String?>(descripcion),
      'categoriaTags': serializer.toJson<String>(categoriaTags),
      'compatibilidadVehiculos':
          serializer.toJson<String>(compatibilidadVehiculos),
      'costo': serializer.toJson<double?>(costo),
      'pvp': serializer.toJson<double?>(pvp),
      'stockActual': serializer.toJson<int>(stockActual),
      'stockMinimo': serializer.toJson<int>(stockMinimo),
      'urlFoto': serializer.toJson<String?>(urlFoto),
      'eliminado': serializer.toJson<bool>(eliminado),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
      'fechaModificacion': serializer.toJson<DateTime>(fechaModificacion),
      'pendienteSync': serializer.toJson<bool>(pendienteSync),
    };
  }

  ProductoRow copyWith(
          {String? id,
          String? nombreProducto,
          Value<String?> descripcion = const Value.absent(),
          String? categoriaTags,
          String? compatibilidadVehiculos,
          Value<double?> costo = const Value.absent(),
          Value<double?> pvp = const Value.absent(),
          int? stockActual,
          int? stockMinimo,
          Value<String?> urlFoto = const Value.absent(),
          bool? eliminado,
          DateTime? fechaCreacion,
          DateTime? fechaModificacion,
          bool? pendienteSync}) =>
      ProductoRow(
        id: id ?? this.id,
        nombreProducto: nombreProducto ?? this.nombreProducto,
        descripcion: descripcion.present ? descripcion.value : this.descripcion,
        categoriaTags: categoriaTags ?? this.categoriaTags,
        compatibilidadVehiculos:
            compatibilidadVehiculos ?? this.compatibilidadVehiculos,
        costo: costo.present ? costo.value : this.costo,
        pvp: pvp.present ? pvp.value : this.pvp,
        stockActual: stockActual ?? this.stockActual,
        stockMinimo: stockMinimo ?? this.stockMinimo,
        urlFoto: urlFoto.present ? urlFoto.value : this.urlFoto,
        eliminado: eliminado ?? this.eliminado,
        fechaCreacion: fechaCreacion ?? this.fechaCreacion,
        fechaModificacion: fechaModificacion ?? this.fechaModificacion,
        pendienteSync: pendienteSync ?? this.pendienteSync,
      );
  ProductoRow copyWithCompanion(InventarioCompanion data) {
    return ProductoRow(
      id: data.id.present ? data.id.value : this.id,
      nombreProducto: data.nombreProducto.present
          ? data.nombreProducto.value
          : this.nombreProducto,
      descripcion:
          data.descripcion.present ? data.descripcion.value : this.descripcion,
      categoriaTags: data.categoriaTags.present
          ? data.categoriaTags.value
          : this.categoriaTags,
      compatibilidadVehiculos: data.compatibilidadVehiculos.present
          ? data.compatibilidadVehiculos.value
          : this.compatibilidadVehiculos,
      costo: data.costo.present ? data.costo.value : this.costo,
      pvp: data.pvp.present ? data.pvp.value : this.pvp,
      stockActual:
          data.stockActual.present ? data.stockActual.value : this.stockActual,
      stockMinimo:
          data.stockMinimo.present ? data.stockMinimo.value : this.stockMinimo,
      urlFoto: data.urlFoto.present ? data.urlFoto.value : this.urlFoto,
      eliminado: data.eliminado.present ? data.eliminado.value : this.eliminado,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
      fechaModificacion: data.fechaModificacion.present
          ? data.fechaModificacion.value
          : this.fechaModificacion,
      pendienteSync: data.pendienteSync.present
          ? data.pendienteSync.value
          : this.pendienteSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductoRow(')
          ..write('id: $id, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoriaTags: $categoriaTags, ')
          ..write('compatibilidadVehiculos: $compatibilidadVehiculos, ')
          ..write('costo: $costo, ')
          ..write('pvp: $pvp, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('urlFoto: $urlFoto, ')
          ..write('eliminado: $eliminado, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaModificacion: $fechaModificacion, ')
          ..write('pendienteSync: $pendienteSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      nombreProducto,
      descripcion,
      categoriaTags,
      compatibilidadVehiculos,
      costo,
      pvp,
      stockActual,
      stockMinimo,
      urlFoto,
      eliminado,
      fechaCreacion,
      fechaModificacion,
      pendienteSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductoRow &&
          other.id == this.id &&
          other.nombreProducto == this.nombreProducto &&
          other.descripcion == this.descripcion &&
          other.categoriaTags == this.categoriaTags &&
          other.compatibilidadVehiculos == this.compatibilidadVehiculos &&
          other.costo == this.costo &&
          other.pvp == this.pvp &&
          other.stockActual == this.stockActual &&
          other.stockMinimo == this.stockMinimo &&
          other.urlFoto == this.urlFoto &&
          other.eliminado == this.eliminado &&
          other.fechaCreacion == this.fechaCreacion &&
          other.fechaModificacion == this.fechaModificacion &&
          other.pendienteSync == this.pendienteSync);
}

class InventarioCompanion extends UpdateCompanion<ProductoRow> {
  final Value<String> id;
  final Value<String> nombreProducto;
  final Value<String?> descripcion;
  final Value<String> categoriaTags;
  final Value<String> compatibilidadVehiculos;
  final Value<double?> costo;
  final Value<double?> pvp;
  final Value<int> stockActual;
  final Value<int> stockMinimo;
  final Value<String?> urlFoto;
  final Value<bool> eliminado;
  final Value<DateTime> fechaCreacion;
  final Value<DateTime> fechaModificacion;
  final Value<bool> pendienteSync;
  final Value<int> rowid;
  const InventarioCompanion({
    this.id = const Value.absent(),
    this.nombreProducto = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.categoriaTags = const Value.absent(),
    this.compatibilidadVehiculos = const Value.absent(),
    this.costo = const Value.absent(),
    this.pvp = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.urlFoto = const Value.absent(),
    this.eliminado = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaModificacion = const Value.absent(),
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventarioCompanion.insert({
    required String id,
    required String nombreProducto,
    this.descripcion = const Value.absent(),
    required String categoriaTags,
    required String compatibilidadVehiculos,
    this.costo = const Value.absent(),
    this.pvp = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.urlFoto = const Value.absent(),
    this.eliminado = const Value.absent(),
    required DateTime fechaCreacion,
    required DateTime fechaModificacion,
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        nombreProducto = Value(nombreProducto),
        categoriaTags = Value(categoriaTags),
        compatibilidadVehiculos = Value(compatibilidadVehiculos),
        fechaCreacion = Value(fechaCreacion),
        fechaModificacion = Value(fechaModificacion);
  static Insertable<ProductoRow> custom({
    Expression<String>? id,
    Expression<String>? nombreProducto,
    Expression<String>? descripcion,
    Expression<String>? categoriaTags,
    Expression<String>? compatibilidadVehiculos,
    Expression<double>? costo,
    Expression<double>? pvp,
    Expression<int>? stockActual,
    Expression<int>? stockMinimo,
    Expression<String>? urlFoto,
    Expression<bool>? eliminado,
    Expression<DateTime>? fechaCreacion,
    Expression<DateTime>? fechaModificacion,
    Expression<bool>? pendienteSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombreProducto != null) 'nombre_producto': nombreProducto,
      if (descripcion != null) 'descripcion': descripcion,
      if (categoriaTags != null) 'categoria_tags': categoriaTags,
      if (compatibilidadVehiculos != null)
        'compatibilidad_vehiculos': compatibilidadVehiculos,
      if (costo != null) 'costo': costo,
      if (pvp != null) 'pvp': pvp,
      if (stockActual != null) 'stock_actual': stockActual,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (urlFoto != null) 'url_foto': urlFoto,
      if (eliminado != null) 'eliminado': eliminado,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      if (fechaModificacion != null) 'fecha_modificacion': fechaModificacion,
      if (pendienteSync != null) 'pendiente_sync': pendienteSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventarioCompanion copyWith(
      {Value<String>? id,
      Value<String>? nombreProducto,
      Value<String?>? descripcion,
      Value<String>? categoriaTags,
      Value<String>? compatibilidadVehiculos,
      Value<double?>? costo,
      Value<double?>? pvp,
      Value<int>? stockActual,
      Value<int>? stockMinimo,
      Value<String?>? urlFoto,
      Value<bool>? eliminado,
      Value<DateTime>? fechaCreacion,
      Value<DateTime>? fechaModificacion,
      Value<bool>? pendienteSync,
      Value<int>? rowid}) {
    return InventarioCompanion(
      id: id ?? this.id,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      descripcion: descripcion ?? this.descripcion,
      categoriaTags: categoriaTags ?? this.categoriaTags,
      compatibilidadVehiculos:
          compatibilidadVehiculos ?? this.compatibilidadVehiculos,
      costo: costo ?? this.costo,
      pvp: pvp ?? this.pvp,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      urlFoto: urlFoto ?? this.urlFoto,
      eliminado: eliminado ?? this.eliminado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      pendienteSync: pendienteSync ?? this.pendienteSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nombreProducto.present) {
      map['nombre_producto'] = Variable<String>(nombreProducto.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (categoriaTags.present) {
      map['categoria_tags'] = Variable<String>(categoriaTags.value);
    }
    if (compatibilidadVehiculos.present) {
      map['compatibilidad_vehiculos'] =
          Variable<String>(compatibilidadVehiculos.value);
    }
    if (costo.present) {
      map['costo'] = Variable<double>(costo.value);
    }
    if (pvp.present) {
      map['pvp'] = Variable<double>(pvp.value);
    }
    if (stockActual.present) {
      map['stock_actual'] = Variable<int>(stockActual.value);
    }
    if (stockMinimo.present) {
      map['stock_minimo'] = Variable<int>(stockMinimo.value);
    }
    if (urlFoto.present) {
      map['url_foto'] = Variable<String>(urlFoto.value);
    }
    if (eliminado.present) {
      map['eliminado'] = Variable<bool>(eliminado.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    if (fechaModificacion.present) {
      map['fecha_modificacion'] = Variable<DateTime>(fechaModificacion.value);
    }
    if (pendienteSync.present) {
      map['pendiente_sync'] = Variable<bool>(pendienteSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventarioCompanion(')
          ..write('id: $id, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('descripcion: $descripcion, ')
          ..write('categoriaTags: $categoriaTags, ')
          ..write('compatibilidadVehiculos: $compatibilidadVehiculos, ')
          ..write('costo: $costo, ')
          ..write('pvp: $pvp, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('urlFoto: $urlFoto, ')
          ..write('eliminado: $eliminado, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaModificacion: $fechaModificacion, ')
          ..write('pendienteSync: $pendienteSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CierresMensualesTable extends CierresMensuales
    with TableInfo<$CierresMensualesTable, CierreRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CierresMensualesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _anioMeta = const VerificationMeta('anio');
  @override
  late final GeneratedColumn<int> anio = GeneratedColumn<int>(
      'anio', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _mesMeta = const VerificationMeta('mes');
  @override
  late final GeneratedColumn<int> mes = GeneratedColumn<int>(
      'mes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalFacturadoMeta =
      const VerificationMeta('totalFacturado');
  @override
  late final GeneratedColumn<double> totalFacturado = GeneratedColumn<double>(
      'total_facturado', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalCobradoMeta =
      const VerificationMeta('totalCobrado');
  @override
  late final GeneratedColumn<double> totalCobrado = GeneratedColumn<double>(
      'total_cobrado', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _gananciaNetaMeta =
      const VerificationMeta('gananciaNeta');
  @override
  late final GeneratedColumn<double> gananciaNeta = GeneratedColumn<double>(
      'ganancia_neta', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _carteraPendienteCierreMeta =
      const VerificationMeta('carteraPendienteCierre');
  @override
  late final GeneratedColumn<double> carteraPendienteCierre =
      GeneratedColumn<double>('cartera_pendiente_cierre', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fechaCierreMeta =
      const VerificationMeta('fechaCierre');
  @override
  late final GeneratedColumn<DateTime> fechaCierre = GeneratedColumn<DateTime>(
      'fecha_cierre', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pendienteSyncMeta =
      const VerificationMeta('pendienteSync');
  @override
  late final GeneratedColumn<bool> pendienteSync = GeneratedColumn<bool>(
      'pendiente_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pendiente_sync" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        anio,
        mes,
        totalFacturado,
        totalCobrado,
        gananciaNeta,
        carteraPendienteCierre,
        fechaCierre,
        pendienteSync
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cierres_mensuales';
  @override
  VerificationContext validateIntegrity(Insertable<CierreRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('anio')) {
      context.handle(
          _anioMeta, anio.isAcceptableOrUnknown(data['anio']!, _anioMeta));
    } else if (isInserting) {
      context.missing(_anioMeta);
    }
    if (data.containsKey('mes')) {
      context.handle(
          _mesMeta, mes.isAcceptableOrUnknown(data['mes']!, _mesMeta));
    } else if (isInserting) {
      context.missing(_mesMeta);
    }
    if (data.containsKey('total_facturado')) {
      context.handle(
          _totalFacturadoMeta,
          totalFacturado.isAcceptableOrUnknown(
              data['total_facturado']!, _totalFacturadoMeta));
    } else if (isInserting) {
      context.missing(_totalFacturadoMeta);
    }
    if (data.containsKey('total_cobrado')) {
      context.handle(
          _totalCobradoMeta,
          totalCobrado.isAcceptableOrUnknown(
              data['total_cobrado']!, _totalCobradoMeta));
    } else if (isInserting) {
      context.missing(_totalCobradoMeta);
    }
    if (data.containsKey('ganancia_neta')) {
      context.handle(
          _gananciaNetaMeta,
          gananciaNeta.isAcceptableOrUnknown(
              data['ganancia_neta']!, _gananciaNetaMeta));
    } else if (isInserting) {
      context.missing(_gananciaNetaMeta);
    }
    if (data.containsKey('cartera_pendiente_cierre')) {
      context.handle(
          _carteraPendienteCierreMeta,
          carteraPendienteCierre.isAcceptableOrUnknown(
              data['cartera_pendiente_cierre']!, _carteraPendienteCierreMeta));
    } else if (isInserting) {
      context.missing(_carteraPendienteCierreMeta);
    }
    if (data.containsKey('fecha_cierre')) {
      context.handle(
          _fechaCierreMeta,
          fechaCierre.isAcceptableOrUnknown(
              data['fecha_cierre']!, _fechaCierreMeta));
    } else if (isInserting) {
      context.missing(_fechaCierreMeta);
    }
    if (data.containsKey('pendiente_sync')) {
      context.handle(
          _pendienteSyncMeta,
          pendienteSync.isAcceptableOrUnknown(
              data['pendiente_sync']!, _pendienteSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CierreRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CierreRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      anio: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}anio'])!,
      mes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mes'])!,
      totalFacturado: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_facturado'])!,
      totalCobrado: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_cobrado'])!,
      gananciaNeta: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ganancia_neta'])!,
      carteraPendienteCierre: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}cartera_pendiente_cierre'])!,
      fechaCierre: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fecha_cierre'])!,
      pendienteSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pendiente_sync'])!,
    );
  }

  @override
  $CierresMensualesTable createAlias(String alias) {
    return $CierresMensualesTable(attachedDatabase, alias);
  }
}

class CierreRow extends DataClass implements Insertable<CierreRow> {
  final String id;
  final int anio;
  final int mes;
  final double totalFacturado;
  final double totalCobrado;
  final double gananciaNeta;
  final double carteraPendienteCierre;
  final DateTime fechaCierre;
  final bool pendienteSync;
  const CierreRow(
      {required this.id,
      required this.anio,
      required this.mes,
      required this.totalFacturado,
      required this.totalCobrado,
      required this.gananciaNeta,
      required this.carteraPendienteCierre,
      required this.fechaCierre,
      required this.pendienteSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['anio'] = Variable<int>(anio);
    map['mes'] = Variable<int>(mes);
    map['total_facturado'] = Variable<double>(totalFacturado);
    map['total_cobrado'] = Variable<double>(totalCobrado);
    map['ganancia_neta'] = Variable<double>(gananciaNeta);
    map['cartera_pendiente_cierre'] = Variable<double>(carteraPendienteCierre);
    map['fecha_cierre'] = Variable<DateTime>(fechaCierre);
    map['pendiente_sync'] = Variable<bool>(pendienteSync);
    return map;
  }

  CierresMensualesCompanion toCompanion(bool nullToAbsent) {
    return CierresMensualesCompanion(
      id: Value(id),
      anio: Value(anio),
      mes: Value(mes),
      totalFacturado: Value(totalFacturado),
      totalCobrado: Value(totalCobrado),
      gananciaNeta: Value(gananciaNeta),
      carteraPendienteCierre: Value(carteraPendienteCierre),
      fechaCierre: Value(fechaCierre),
      pendienteSync: Value(pendienteSync),
    );
  }

  factory CierreRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CierreRow(
      id: serializer.fromJson<String>(json['id']),
      anio: serializer.fromJson<int>(json['anio']),
      mes: serializer.fromJson<int>(json['mes']),
      totalFacturado: serializer.fromJson<double>(json['totalFacturado']),
      totalCobrado: serializer.fromJson<double>(json['totalCobrado']),
      gananciaNeta: serializer.fromJson<double>(json['gananciaNeta']),
      carteraPendienteCierre:
          serializer.fromJson<double>(json['carteraPendienteCierre']),
      fechaCierre: serializer.fromJson<DateTime>(json['fechaCierre']),
      pendienteSync: serializer.fromJson<bool>(json['pendienteSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'anio': serializer.toJson<int>(anio),
      'mes': serializer.toJson<int>(mes),
      'totalFacturado': serializer.toJson<double>(totalFacturado),
      'totalCobrado': serializer.toJson<double>(totalCobrado),
      'gananciaNeta': serializer.toJson<double>(gananciaNeta),
      'carteraPendienteCierre':
          serializer.toJson<double>(carteraPendienteCierre),
      'fechaCierre': serializer.toJson<DateTime>(fechaCierre),
      'pendienteSync': serializer.toJson<bool>(pendienteSync),
    };
  }

  CierreRow copyWith(
          {String? id,
          int? anio,
          int? mes,
          double? totalFacturado,
          double? totalCobrado,
          double? gananciaNeta,
          double? carteraPendienteCierre,
          DateTime? fechaCierre,
          bool? pendienteSync}) =>
      CierreRow(
        id: id ?? this.id,
        anio: anio ?? this.anio,
        mes: mes ?? this.mes,
        totalFacturado: totalFacturado ?? this.totalFacturado,
        totalCobrado: totalCobrado ?? this.totalCobrado,
        gananciaNeta: gananciaNeta ?? this.gananciaNeta,
        carteraPendienteCierre:
            carteraPendienteCierre ?? this.carteraPendienteCierre,
        fechaCierre: fechaCierre ?? this.fechaCierre,
        pendienteSync: pendienteSync ?? this.pendienteSync,
      );
  CierreRow copyWithCompanion(CierresMensualesCompanion data) {
    return CierreRow(
      id: data.id.present ? data.id.value : this.id,
      anio: data.anio.present ? data.anio.value : this.anio,
      mes: data.mes.present ? data.mes.value : this.mes,
      totalFacturado: data.totalFacturado.present
          ? data.totalFacturado.value
          : this.totalFacturado,
      totalCobrado: data.totalCobrado.present
          ? data.totalCobrado.value
          : this.totalCobrado,
      gananciaNeta: data.gananciaNeta.present
          ? data.gananciaNeta.value
          : this.gananciaNeta,
      carteraPendienteCierre: data.carteraPendienteCierre.present
          ? data.carteraPendienteCierre.value
          : this.carteraPendienteCierre,
      fechaCierre:
          data.fechaCierre.present ? data.fechaCierre.value : this.fechaCierre,
      pendienteSync: data.pendienteSync.present
          ? data.pendienteSync.value
          : this.pendienteSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CierreRow(')
          ..write('id: $id, ')
          ..write('anio: $anio, ')
          ..write('mes: $mes, ')
          ..write('totalFacturado: $totalFacturado, ')
          ..write('totalCobrado: $totalCobrado, ')
          ..write('gananciaNeta: $gananciaNeta, ')
          ..write('carteraPendienteCierre: $carteraPendienteCierre, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('pendienteSync: $pendienteSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, anio, mes, totalFacturado, totalCobrado,
      gananciaNeta, carteraPendienteCierre, fechaCierre, pendienteSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CierreRow &&
          other.id == this.id &&
          other.anio == this.anio &&
          other.mes == this.mes &&
          other.totalFacturado == this.totalFacturado &&
          other.totalCobrado == this.totalCobrado &&
          other.gananciaNeta == this.gananciaNeta &&
          other.carteraPendienteCierre == this.carteraPendienteCierre &&
          other.fechaCierre == this.fechaCierre &&
          other.pendienteSync == this.pendienteSync);
}

class CierresMensualesCompanion extends UpdateCompanion<CierreRow> {
  final Value<String> id;
  final Value<int> anio;
  final Value<int> mes;
  final Value<double> totalFacturado;
  final Value<double> totalCobrado;
  final Value<double> gananciaNeta;
  final Value<double> carteraPendienteCierre;
  final Value<DateTime> fechaCierre;
  final Value<bool> pendienteSync;
  final Value<int> rowid;
  const CierresMensualesCompanion({
    this.id = const Value.absent(),
    this.anio = const Value.absent(),
    this.mes = const Value.absent(),
    this.totalFacturado = const Value.absent(),
    this.totalCobrado = const Value.absent(),
    this.gananciaNeta = const Value.absent(),
    this.carteraPendienteCierre = const Value.absent(),
    this.fechaCierre = const Value.absent(),
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CierresMensualesCompanion.insert({
    required String id,
    required int anio,
    required int mes,
    required double totalFacturado,
    required double totalCobrado,
    required double gananciaNeta,
    required double carteraPendienteCierre,
    required DateTime fechaCierre,
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        anio = Value(anio),
        mes = Value(mes),
        totalFacturado = Value(totalFacturado),
        totalCobrado = Value(totalCobrado),
        gananciaNeta = Value(gananciaNeta),
        carteraPendienteCierre = Value(carteraPendienteCierre),
        fechaCierre = Value(fechaCierre);
  static Insertable<CierreRow> custom({
    Expression<String>? id,
    Expression<int>? anio,
    Expression<int>? mes,
    Expression<double>? totalFacturado,
    Expression<double>? totalCobrado,
    Expression<double>? gananciaNeta,
    Expression<double>? carteraPendienteCierre,
    Expression<DateTime>? fechaCierre,
    Expression<bool>? pendienteSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (anio != null) 'anio': anio,
      if (mes != null) 'mes': mes,
      if (totalFacturado != null) 'total_facturado': totalFacturado,
      if (totalCobrado != null) 'total_cobrado': totalCobrado,
      if (gananciaNeta != null) 'ganancia_neta': gananciaNeta,
      if (carteraPendienteCierre != null)
        'cartera_pendiente_cierre': carteraPendienteCierre,
      if (fechaCierre != null) 'fecha_cierre': fechaCierre,
      if (pendienteSync != null) 'pendiente_sync': pendienteSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CierresMensualesCompanion copyWith(
      {Value<String>? id,
      Value<int>? anio,
      Value<int>? mes,
      Value<double>? totalFacturado,
      Value<double>? totalCobrado,
      Value<double>? gananciaNeta,
      Value<double>? carteraPendienteCierre,
      Value<DateTime>? fechaCierre,
      Value<bool>? pendienteSync,
      Value<int>? rowid}) {
    return CierresMensualesCompanion(
      id: id ?? this.id,
      anio: anio ?? this.anio,
      mes: mes ?? this.mes,
      totalFacturado: totalFacturado ?? this.totalFacturado,
      totalCobrado: totalCobrado ?? this.totalCobrado,
      gananciaNeta: gananciaNeta ?? this.gananciaNeta,
      carteraPendienteCierre:
          carteraPendienteCierre ?? this.carteraPendienteCierre,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      pendienteSync: pendienteSync ?? this.pendienteSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (anio.present) {
      map['anio'] = Variable<int>(anio.value);
    }
    if (mes.present) {
      map['mes'] = Variable<int>(mes.value);
    }
    if (totalFacturado.present) {
      map['total_facturado'] = Variable<double>(totalFacturado.value);
    }
    if (totalCobrado.present) {
      map['total_cobrado'] = Variable<double>(totalCobrado.value);
    }
    if (gananciaNeta.present) {
      map['ganancia_neta'] = Variable<double>(gananciaNeta.value);
    }
    if (carteraPendienteCierre.present) {
      map['cartera_pendiente_cierre'] =
          Variable<double>(carteraPendienteCierre.value);
    }
    if (fechaCierre.present) {
      map['fecha_cierre'] = Variable<DateTime>(fechaCierre.value);
    }
    if (pendienteSync.present) {
      map['pendiente_sync'] = Variable<bool>(pendienteSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CierresMensualesCompanion(')
          ..write('id: $id, ')
          ..write('anio: $anio, ')
          ..write('mes: $mes, ')
          ..write('totalFacturado: $totalFacturado, ')
          ..write('totalCobrado: $totalCobrado, ')
          ..write('gananciaNeta: $gananciaNeta, ')
          ..write('carteraPendienteCierre: $carteraPendienteCierre, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('pendienteSync: $pendienteSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotasTable extends Notas with TableInfo<$NotasTable, NotaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
      'titulo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contenidoMeta =
      const VerificationMeta('contenido');
  @override
  late final GeneratedColumn<String> contenido = GeneratedColumn<String>(
      'contenido', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('NARANJA'));
  static const VerificationMeta _eliminadoMeta =
      const VerificationMeta('eliminado');
  @override
  late final GeneratedColumn<bool> eliminado = GeneratedColumn<bool>(
      'eliminado', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("eliminado" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fechaCreacionMeta =
      const VerificationMeta('fechaCreacion');
  @override
  late final GeneratedColumn<DateTime> fechaCreacion =
      GeneratedColumn<DateTime>('fecha_creacion', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fechaModificacionMeta =
      const VerificationMeta('fechaModificacion');
  @override
  late final GeneratedColumn<DateTime> fechaModificacion =
      GeneratedColumn<DateTime>('fecha_modificacion', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _pendienteSyncMeta =
      const VerificationMeta('pendienteSync');
  @override
  late final GeneratedColumn<bool> pendienteSync = GeneratedColumn<bool>(
      'pendiente_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pendiente_sync" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        titulo,
        contenido,
        color,
        eliminado,
        fechaCreacion,
        fechaModificacion,
        pendienteSync
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notas';
  @override
  VerificationContext validateIntegrity(Insertable<NotaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(_tituloMeta,
          titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta));
    }
    if (data.containsKey('contenido')) {
      context.handle(_contenidoMeta,
          contenido.isAcceptableOrUnknown(data['contenido']!, _contenidoMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('eliminado')) {
      context.handle(_eliminadoMeta,
          eliminado.isAcceptableOrUnknown(data['eliminado']!, _eliminadoMeta));
    }
    if (data.containsKey('fecha_creacion')) {
      context.handle(
          _fechaCreacionMeta,
          fechaCreacion.isAcceptableOrUnknown(
              data['fecha_creacion']!, _fechaCreacionMeta));
    } else if (isInserting) {
      context.missing(_fechaCreacionMeta);
    }
    if (data.containsKey('fecha_modificacion')) {
      context.handle(
          _fechaModificacionMeta,
          fechaModificacion.isAcceptableOrUnknown(
              data['fecha_modificacion']!, _fechaModificacionMeta));
    } else if (isInserting) {
      context.missing(_fechaModificacionMeta);
    }
    if (data.containsKey('pendiente_sync')) {
      context.handle(
          _pendienteSyncMeta,
          pendienteSync.isAcceptableOrUnknown(
              data['pendiente_sync']!, _pendienteSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotaRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      titulo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}titulo']),
      contenido: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contenido']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      eliminado: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}eliminado'])!,
      fechaCreacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_creacion'])!,
      fechaModificacion: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fecha_modificacion'])!,
      pendienteSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pendiente_sync'])!,
    );
  }

  @override
  $NotasTable createAlias(String alias) {
    return $NotasTable(attachedDatabase, alias);
  }
}

class NotaRow extends DataClass implements Insertable<NotaRow> {
  final String id;
  final String? titulo;
  final String? contenido;
  final String color;
  final bool eliminado;
  final DateTime fechaCreacion;
  final DateTime fechaModificacion;
  final bool pendienteSync;
  const NotaRow(
      {required this.id,
      this.titulo,
      this.contenido,
      required this.color,
      required this.eliminado,
      required this.fechaCreacion,
      required this.fechaModificacion,
      required this.pendienteSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || titulo != null) {
      map['titulo'] = Variable<String>(titulo);
    }
    if (!nullToAbsent || contenido != null) {
      map['contenido'] = Variable<String>(contenido);
    }
    map['color'] = Variable<String>(color);
    map['eliminado'] = Variable<bool>(eliminado);
    map['fecha_creacion'] = Variable<DateTime>(fechaCreacion);
    map['fecha_modificacion'] = Variable<DateTime>(fechaModificacion);
    map['pendiente_sync'] = Variable<bool>(pendienteSync);
    return map;
  }

  NotasCompanion toCompanion(bool nullToAbsent) {
    return NotasCompanion(
      id: Value(id),
      titulo:
          titulo == null && nullToAbsent ? const Value.absent() : Value(titulo),
      contenido: contenido == null && nullToAbsent
          ? const Value.absent()
          : Value(contenido),
      color: Value(color),
      eliminado: Value(eliminado),
      fechaCreacion: Value(fechaCreacion),
      fechaModificacion: Value(fechaModificacion),
      pendienteSync: Value(pendienteSync),
    );
  }

  factory NotaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotaRow(
      id: serializer.fromJson<String>(json['id']),
      titulo: serializer.fromJson<String?>(json['titulo']),
      contenido: serializer.fromJson<String?>(json['contenido']),
      color: serializer.fromJson<String>(json['color']),
      eliminado: serializer.fromJson<bool>(json['eliminado']),
      fechaCreacion: serializer.fromJson<DateTime>(json['fechaCreacion']),
      fechaModificacion:
          serializer.fromJson<DateTime>(json['fechaModificacion']),
      pendienteSync: serializer.fromJson<bool>(json['pendienteSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'titulo': serializer.toJson<String?>(titulo),
      'contenido': serializer.toJson<String?>(contenido),
      'color': serializer.toJson<String>(color),
      'eliminado': serializer.toJson<bool>(eliminado),
      'fechaCreacion': serializer.toJson<DateTime>(fechaCreacion),
      'fechaModificacion': serializer.toJson<DateTime>(fechaModificacion),
      'pendienteSync': serializer.toJson<bool>(pendienteSync),
    };
  }

  NotaRow copyWith(
          {String? id,
          Value<String?> titulo = const Value.absent(),
          Value<String?> contenido = const Value.absent(),
          String? color,
          bool? eliminado,
          DateTime? fechaCreacion,
          DateTime? fechaModificacion,
          bool? pendienteSync}) =>
      NotaRow(
        id: id ?? this.id,
        titulo: titulo.present ? titulo.value : this.titulo,
        contenido: contenido.present ? contenido.value : this.contenido,
        color: color ?? this.color,
        eliminado: eliminado ?? this.eliminado,
        fechaCreacion: fechaCreacion ?? this.fechaCreacion,
        fechaModificacion: fechaModificacion ?? this.fechaModificacion,
        pendienteSync: pendienteSync ?? this.pendienteSync,
      );
  NotaRow copyWithCompanion(NotasCompanion data) {
    return NotaRow(
      id: data.id.present ? data.id.value : this.id,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      contenido: data.contenido.present ? data.contenido.value : this.contenido,
      color: data.color.present ? data.color.value : this.color,
      eliminado: data.eliminado.present ? data.eliminado.value : this.eliminado,
      fechaCreacion: data.fechaCreacion.present
          ? data.fechaCreacion.value
          : this.fechaCreacion,
      fechaModificacion: data.fechaModificacion.present
          ? data.fechaModificacion.value
          : this.fechaModificacion,
      pendienteSync: data.pendienteSync.present
          ? data.pendienteSync.value
          : this.pendienteSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotaRow(')
          ..write('id: $id, ')
          ..write('titulo: $titulo, ')
          ..write('contenido: $contenido, ')
          ..write('color: $color, ')
          ..write('eliminado: $eliminado, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaModificacion: $fechaModificacion, ')
          ..write('pendienteSync: $pendienteSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, titulo, contenido, color, eliminado,
      fechaCreacion, fechaModificacion, pendienteSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotaRow &&
          other.id == this.id &&
          other.titulo == this.titulo &&
          other.contenido == this.contenido &&
          other.color == this.color &&
          other.eliminado == this.eliminado &&
          other.fechaCreacion == this.fechaCreacion &&
          other.fechaModificacion == this.fechaModificacion &&
          other.pendienteSync == this.pendienteSync);
}

class NotasCompanion extends UpdateCompanion<NotaRow> {
  final Value<String> id;
  final Value<String?> titulo;
  final Value<String?> contenido;
  final Value<String> color;
  final Value<bool> eliminado;
  final Value<DateTime> fechaCreacion;
  final Value<DateTime> fechaModificacion;
  final Value<bool> pendienteSync;
  final Value<int> rowid;
  const NotasCompanion({
    this.id = const Value.absent(),
    this.titulo = const Value.absent(),
    this.contenido = const Value.absent(),
    this.color = const Value.absent(),
    this.eliminado = const Value.absent(),
    this.fechaCreacion = const Value.absent(),
    this.fechaModificacion = const Value.absent(),
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotasCompanion.insert({
    required String id,
    this.titulo = const Value.absent(),
    this.contenido = const Value.absent(),
    this.color = const Value.absent(),
    this.eliminado = const Value.absent(),
    required DateTime fechaCreacion,
    required DateTime fechaModificacion,
    this.pendienteSync = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fechaCreacion = Value(fechaCreacion),
        fechaModificacion = Value(fechaModificacion);
  static Insertable<NotaRow> custom({
    Expression<String>? id,
    Expression<String>? titulo,
    Expression<String>? contenido,
    Expression<String>? color,
    Expression<bool>? eliminado,
    Expression<DateTime>? fechaCreacion,
    Expression<DateTime>? fechaModificacion,
    Expression<bool>? pendienteSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titulo != null) 'titulo': titulo,
      if (contenido != null) 'contenido': contenido,
      if (color != null) 'color': color,
      if (eliminado != null) 'eliminado': eliminado,
      if (fechaCreacion != null) 'fecha_creacion': fechaCreacion,
      if (fechaModificacion != null) 'fecha_modificacion': fechaModificacion,
      if (pendienteSync != null) 'pendiente_sync': pendienteSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotasCompanion copyWith(
      {Value<String>? id,
      Value<String?>? titulo,
      Value<String?>? contenido,
      Value<String>? color,
      Value<bool>? eliminado,
      Value<DateTime>? fechaCreacion,
      Value<DateTime>? fechaModificacion,
      Value<bool>? pendienteSync,
      Value<int>? rowid}) {
    return NotasCompanion(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      color: color ?? this.color,
      eliminado: eliminado ?? this.eliminado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      pendienteSync: pendienteSync ?? this.pendienteSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (contenido.present) {
      map['contenido'] = Variable<String>(contenido.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (eliminado.present) {
      map['eliminado'] = Variable<bool>(eliminado.value);
    }
    if (fechaCreacion.present) {
      map['fecha_creacion'] = Variable<DateTime>(fechaCreacion.value);
    }
    if (fechaModificacion.present) {
      map['fecha_modificacion'] = Variable<DateTime>(fechaModificacion.value);
    }
    if (pendienteSync.present) {
      map['pendiente_sync'] = Variable<bool>(pendienteSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotasCompanion(')
          ..write('id: $id, ')
          ..write('titulo: $titulo, ')
          ..write('contenido: $contenido, ')
          ..write('color: $color, ')
          ..write('eliminado: $eliminado, ')
          ..write('fechaCreacion: $fechaCreacion, ')
          ..write('fechaModificacion: $fechaModificacion, ')
          ..write('pendienteSync: $pendienteSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $DetalleCuentasTable detalleCuentas = $DetalleCuentasTable(this);
  late final $InventarioTable inventario = $InventarioTable(this);
  late final $CierresMensualesTable cierresMensuales =
      $CierresMensualesTable(this);
  late final $NotasTable notas = $NotasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [usuarios, clientes, detalleCuentas, inventario, cierresMensuales, notas];
}

typedef $$UsuariosTableCreateCompanionBuilder = UsuariosCompanion Function({
  required String id,
  required String nombreCompleto,
  required String usuario,
  required String passwordHash,
  required String salt,
  required String rol,
  Value<bool> activo,
  required DateTime fechaCreacion,
  required DateTime fechaModificacion,
  Value<bool> pendienteSync,
  Value<int> rowid,
});
typedef $$UsuariosTableUpdateCompanionBuilder = UsuariosCompanion Function({
  Value<String> id,
  Value<String> nombreCompleto,
  Value<String> usuario,
  Value<String> passwordHash,
  Value<String> salt,
  Value<String> rol,
  Value<bool> activo,
  Value<DateTime> fechaCreacion,
  Value<DateTime> fechaModificacion,
  Value<bool> pendienteSync,
  Value<int> rowid,
});

class $$UsuariosTableFilterComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreCompleto => $composableBuilder(
      column: $table.nombreCompleto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get usuario => $composableBuilder(
      column: $table.usuario, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rol => $composableBuilder(
      column: $table.rol, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => ColumnFilters(column));
}

class $$UsuariosTableOrderingComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreCompleto => $composableBuilder(
      column: $table.nombreCompleto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get usuario => $composableBuilder(
      column: $table.usuario, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rol => $composableBuilder(
      column: $table.rol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get activo => $composableBuilder(
      column: $table.activo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync,
      builder: (column) => ColumnOrderings(column));
}

class $$UsuariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombreCompleto => $composableBuilder(
      column: $table.nombreCompleto, builder: (column) => column);

  GeneratedColumn<String> get usuario =>
      $composableBuilder(column: $table.usuario, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<String> get rol =>
      $composableBuilder(column: $table.rol, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion, builder: (column) => column);

  GeneratedColumn<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => column);
}

class $$UsuariosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsuariosTable,
    UsuarioRow,
    $$UsuariosTableFilterComposer,
    $$UsuariosTableOrderingComposer,
    $$UsuariosTableAnnotationComposer,
    $$UsuariosTableCreateCompanionBuilder,
    $$UsuariosTableUpdateCompanionBuilder,
    (UsuarioRow, BaseReferences<_$AppDatabase, $UsuariosTable, UsuarioRow>),
    UsuarioRow,
    PrefetchHooks Function()> {
  $$UsuariosTableTableManager(_$AppDatabase db, $UsuariosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> nombreCompleto = const Value.absent(),
            Value<String> usuario = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String> salt = const Value.absent(),
            Value<String> rol = const Value.absent(),
            Value<bool> activo = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<DateTime> fechaModificacion = const Value.absent(),
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsuariosCompanion(
            id: id,
            nombreCompleto: nombreCompleto,
            usuario: usuario,
            passwordHash: passwordHash,
            salt: salt,
            rol: rol,
            activo: activo,
            fechaCreacion: fechaCreacion,
            fechaModificacion: fechaModificacion,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String nombreCompleto,
            required String usuario,
            required String passwordHash,
            required String salt,
            required String rol,
            Value<bool> activo = const Value.absent(),
            required DateTime fechaCreacion,
            required DateTime fechaModificacion,
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsuariosCompanion.insert(
            id: id,
            nombreCompleto: nombreCompleto,
            usuario: usuario,
            passwordHash: passwordHash,
            salt: salt,
            rol: rol,
            activo: activo,
            fechaCreacion: fechaCreacion,
            fechaModificacion: fechaModificacion,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsuariosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsuariosTable,
    UsuarioRow,
    $$UsuariosTableFilterComposer,
    $$UsuariosTableOrderingComposer,
    $$UsuariosTableAnnotationComposer,
    $$UsuariosTableCreateCompanionBuilder,
    $$UsuariosTableUpdateCompanionBuilder,
    (UsuarioRow, BaseReferences<_$AppDatabase, $UsuariosTable, UsuarioRow>),
    UsuarioRow,
    PrefetchHooks Function()>;
typedef $$ClientesTableCreateCompanionBuilder = ClientesCompanion Function({
  required String id,
  Value<String?> cedula,
  required String nombreCliente,
  Value<String?> telefono,
  Value<String?> direccion,
  Value<String?> facturaN,
  Value<DateTime?> fechaUltimoAbono,
  Value<double> totalAdeudado,
  Value<bool> eliminado,
  required DateTime fechaCreacion,
  required DateTime fechaModificacion,
  Value<bool> pendienteSync,
  Value<int> rowid,
});
typedef $$ClientesTableUpdateCompanionBuilder = ClientesCompanion Function({
  Value<String> id,
  Value<String?> cedula,
  Value<String> nombreCliente,
  Value<String?> telefono,
  Value<String?> direccion,
  Value<String?> facturaN,
  Value<DateTime?> fechaUltimoAbono,
  Value<double> totalAdeudado,
  Value<bool> eliminado,
  Value<DateTime> fechaCreacion,
  Value<DateTime> fechaModificacion,
  Value<bool> pendienteSync,
  Value<int> rowid,
});

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cedula => $composableBuilder(
      column: $table.cedula, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreCliente => $composableBuilder(
      column: $table.nombreCliente, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get facturaN => $composableBuilder(
      column: $table.facturaN, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaUltimoAbono => $composableBuilder(
      column: $table.fechaUltimoAbono,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAdeudado => $composableBuilder(
      column: $table.totalAdeudado, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get eliminado => $composableBuilder(
      column: $table.eliminado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => ColumnFilters(column));
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cedula => $composableBuilder(
      column: $table.cedula, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreCliente => $composableBuilder(
      column: $table.nombreCliente,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get telefono => $composableBuilder(
      column: $table.telefono, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direccion => $composableBuilder(
      column: $table.direccion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get facturaN => $composableBuilder(
      column: $table.facturaN, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaUltimoAbono => $composableBuilder(
      column: $table.fechaUltimoAbono,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAdeudado => $composableBuilder(
      column: $table.totalAdeudado,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get eliminado => $composableBuilder(
      column: $table.eliminado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync,
      builder: (column) => ColumnOrderings(column));
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cedula =>
      $composableBuilder(column: $table.cedula, builder: (column) => column);

  GeneratedColumn<String> get nombreCliente => $composableBuilder(
      column: $table.nombreCliente, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get facturaN =>
      $composableBuilder(column: $table.facturaN, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaUltimoAbono => $composableBuilder(
      column: $table.fechaUltimoAbono, builder: (column) => column);

  GeneratedColumn<double> get totalAdeudado => $composableBuilder(
      column: $table.totalAdeudado, builder: (column) => column);

  GeneratedColumn<bool> get eliminado =>
      $composableBuilder(column: $table.eliminado, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion, builder: (column) => column);

  GeneratedColumn<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => column);
}

class $$ClientesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientesTable,
    ClienteRow,
    $$ClientesTableFilterComposer,
    $$ClientesTableOrderingComposer,
    $$ClientesTableAnnotationComposer,
    $$ClientesTableCreateCompanionBuilder,
    $$ClientesTableUpdateCompanionBuilder,
    (ClienteRow, BaseReferences<_$AppDatabase, $ClientesTable, ClienteRow>),
    ClienteRow,
    PrefetchHooks Function()> {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> cedula = const Value.absent(),
            Value<String> nombreCliente = const Value.absent(),
            Value<String?> telefono = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            Value<String?> facturaN = const Value.absent(),
            Value<DateTime?> fechaUltimoAbono = const Value.absent(),
            Value<double> totalAdeudado = const Value.absent(),
            Value<bool> eliminado = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<DateTime> fechaModificacion = const Value.absent(),
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientesCompanion(
            id: id,
            cedula: cedula,
            nombreCliente: nombreCliente,
            telefono: telefono,
            direccion: direccion,
            facturaN: facturaN,
            fechaUltimoAbono: fechaUltimoAbono,
            totalAdeudado: totalAdeudado,
            eliminado: eliminado,
            fechaCreacion: fechaCreacion,
            fechaModificacion: fechaModificacion,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> cedula = const Value.absent(),
            required String nombreCliente,
            Value<String?> telefono = const Value.absent(),
            Value<String?> direccion = const Value.absent(),
            Value<String?> facturaN = const Value.absent(),
            Value<DateTime?> fechaUltimoAbono = const Value.absent(),
            Value<double> totalAdeudado = const Value.absent(),
            Value<bool> eliminado = const Value.absent(),
            required DateTime fechaCreacion,
            required DateTime fechaModificacion,
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientesCompanion.insert(
            id: id,
            cedula: cedula,
            nombreCliente: nombreCliente,
            telefono: telefono,
            direccion: direccion,
            facturaN: facturaN,
            fechaUltimoAbono: fechaUltimoAbono,
            totalAdeudado: totalAdeudado,
            eliminado: eliminado,
            fechaCreacion: fechaCreacion,
            fechaModificacion: fechaModificacion,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClientesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientesTable,
    ClienteRow,
    $$ClientesTableFilterComposer,
    $$ClientesTableOrderingComposer,
    $$ClientesTableAnnotationComposer,
    $$ClientesTableCreateCompanionBuilder,
    $$ClientesTableUpdateCompanionBuilder,
    (ClienteRow, BaseReferences<_$AppDatabase, $ClientesTable, ClienteRow>),
    ClienteRow,
    PrefetchHooks Function()>;
typedef $$DetalleCuentasTableCreateCompanionBuilder = DetalleCuentasCompanion
    Function({
  required String id,
  required String idCliente,
  required String tipoLinea,
  required DateTime fecha,
  required double cantidad,
  required String descripcion,
  Value<double?> precioUnitario,
  required double totalLinea,
  Value<double?> costoUnitario,
  Value<String?> idProducto,
  Value<bool> eliminado,
  required DateTime fechaCreacion,
  required DateTime fechaModificacion,
  Value<bool> pendienteSync,
  Value<int> rowid,
});
typedef $$DetalleCuentasTableUpdateCompanionBuilder = DetalleCuentasCompanion
    Function({
  Value<String> id,
  Value<String> idCliente,
  Value<String> tipoLinea,
  Value<DateTime> fecha,
  Value<double> cantidad,
  Value<String> descripcion,
  Value<double?> precioUnitario,
  Value<double> totalLinea,
  Value<double?> costoUnitario,
  Value<String?> idProducto,
  Value<bool> eliminado,
  Value<DateTime> fechaCreacion,
  Value<DateTime> fechaModificacion,
  Value<bool> pendienteSync,
  Value<int> rowid,
});

class $$DetalleCuentasTableFilterComposer
    extends Composer<_$AppDatabase, $DetalleCuentasTable> {
  $$DetalleCuentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idCliente => $composableBuilder(
      column: $table.idCliente, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipoLinea => $composableBuilder(
      column: $table.tipoLinea, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalLinea => $composableBuilder(
      column: $table.totalLinea, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costoUnitario => $composableBuilder(
      column: $table.costoUnitario, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idProducto => $composableBuilder(
      column: $table.idProducto, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get eliminado => $composableBuilder(
      column: $table.eliminado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => ColumnFilters(column));
}

class $$DetalleCuentasTableOrderingComposer
    extends Composer<_$AppDatabase, $DetalleCuentasTable> {
  $$DetalleCuentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idCliente => $composableBuilder(
      column: $table.idCliente, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipoLinea => $composableBuilder(
      column: $table.tipoLinea, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
      column: $table.fecha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cantidad => $composableBuilder(
      column: $table.cantidad, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalLinea => $composableBuilder(
      column: $table.totalLinea, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costoUnitario => $composableBuilder(
      column: $table.costoUnitario,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idProducto => $composableBuilder(
      column: $table.idProducto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get eliminado => $composableBuilder(
      column: $table.eliminado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync,
      builder: (column) => ColumnOrderings(column));
}

class $$DetalleCuentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetalleCuentasTable> {
  $$DetalleCuentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get idCliente =>
      $composableBuilder(column: $table.idCliente, builder: (column) => column);

  GeneratedColumn<String> get tipoLinea =>
      $composableBuilder(column: $table.tipoLinea, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
      column: $table.precioUnitario, builder: (column) => column);

  GeneratedColumn<double> get totalLinea => $composableBuilder(
      column: $table.totalLinea, builder: (column) => column);

  GeneratedColumn<double> get costoUnitario => $composableBuilder(
      column: $table.costoUnitario, builder: (column) => column);

  GeneratedColumn<String> get idProducto => $composableBuilder(
      column: $table.idProducto, builder: (column) => column);

  GeneratedColumn<bool> get eliminado =>
      $composableBuilder(column: $table.eliminado, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion, builder: (column) => column);

  GeneratedColumn<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => column);
}

class $$DetalleCuentasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DetalleCuentasTable,
    LineaRow,
    $$DetalleCuentasTableFilterComposer,
    $$DetalleCuentasTableOrderingComposer,
    $$DetalleCuentasTableAnnotationComposer,
    $$DetalleCuentasTableCreateCompanionBuilder,
    $$DetalleCuentasTableUpdateCompanionBuilder,
    (LineaRow, BaseReferences<_$AppDatabase, $DetalleCuentasTable, LineaRow>),
    LineaRow,
    PrefetchHooks Function()> {
  $$DetalleCuentasTableTableManager(
      _$AppDatabase db, $DetalleCuentasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetalleCuentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetalleCuentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetalleCuentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> idCliente = const Value.absent(),
            Value<String> tipoLinea = const Value.absent(),
            Value<DateTime> fecha = const Value.absent(),
            Value<double> cantidad = const Value.absent(),
            Value<String> descripcion = const Value.absent(),
            Value<double?> precioUnitario = const Value.absent(),
            Value<double> totalLinea = const Value.absent(),
            Value<double?> costoUnitario = const Value.absent(),
            Value<String?> idProducto = const Value.absent(),
            Value<bool> eliminado = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<DateTime> fechaModificacion = const Value.absent(),
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DetalleCuentasCompanion(
            id: id,
            idCliente: idCliente,
            tipoLinea: tipoLinea,
            fecha: fecha,
            cantidad: cantidad,
            descripcion: descripcion,
            precioUnitario: precioUnitario,
            totalLinea: totalLinea,
            costoUnitario: costoUnitario,
            idProducto: idProducto,
            eliminado: eliminado,
            fechaCreacion: fechaCreacion,
            fechaModificacion: fechaModificacion,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String idCliente,
            required String tipoLinea,
            required DateTime fecha,
            required double cantidad,
            required String descripcion,
            Value<double?> precioUnitario = const Value.absent(),
            required double totalLinea,
            Value<double?> costoUnitario = const Value.absent(),
            Value<String?> idProducto = const Value.absent(),
            Value<bool> eliminado = const Value.absent(),
            required DateTime fechaCreacion,
            required DateTime fechaModificacion,
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DetalleCuentasCompanion.insert(
            id: id,
            idCliente: idCliente,
            tipoLinea: tipoLinea,
            fecha: fecha,
            cantidad: cantidad,
            descripcion: descripcion,
            precioUnitario: precioUnitario,
            totalLinea: totalLinea,
            costoUnitario: costoUnitario,
            idProducto: idProducto,
            eliminado: eliminado,
            fechaCreacion: fechaCreacion,
            fechaModificacion: fechaModificacion,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DetalleCuentasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DetalleCuentasTable,
    LineaRow,
    $$DetalleCuentasTableFilterComposer,
    $$DetalleCuentasTableOrderingComposer,
    $$DetalleCuentasTableAnnotationComposer,
    $$DetalleCuentasTableCreateCompanionBuilder,
    $$DetalleCuentasTableUpdateCompanionBuilder,
    (LineaRow, BaseReferences<_$AppDatabase, $DetalleCuentasTable, LineaRow>),
    LineaRow,
    PrefetchHooks Function()>;
typedef $$InventarioTableCreateCompanionBuilder = InventarioCompanion Function({
  required String id,
  required String nombreProducto,
  Value<String?> descripcion,
  required String categoriaTags,
  required String compatibilidadVehiculos,
  Value<double?> costo,
  Value<double?> pvp,
  Value<int> stockActual,
  Value<int> stockMinimo,
  Value<String?> urlFoto,
  Value<bool> eliminado,
  required DateTime fechaCreacion,
  required DateTime fechaModificacion,
  Value<bool> pendienteSync,
  Value<int> rowid,
});
typedef $$InventarioTableUpdateCompanionBuilder = InventarioCompanion Function({
  Value<String> id,
  Value<String> nombreProducto,
  Value<String?> descripcion,
  Value<String> categoriaTags,
  Value<String> compatibilidadVehiculos,
  Value<double?> costo,
  Value<double?> pvp,
  Value<int> stockActual,
  Value<int> stockMinimo,
  Value<String?> urlFoto,
  Value<bool> eliminado,
  Value<DateTime> fechaCreacion,
  Value<DateTime> fechaModificacion,
  Value<bool> pendienteSync,
  Value<int> rowid,
});

class $$InventarioTableFilterComposer
    extends Composer<_$AppDatabase, $InventarioTable> {
  $$InventarioTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nombreProducto => $composableBuilder(
      column: $table.nombreProducto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoriaTags => $composableBuilder(
      column: $table.categoriaTags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get compatibilidadVehiculos => $composableBuilder(
      column: $table.compatibilidadVehiculos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costo => $composableBuilder(
      column: $table.costo, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pvp => $composableBuilder(
      column: $table.pvp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockActual => $composableBuilder(
      column: $table.stockActual, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stockMinimo => $composableBuilder(
      column: $table.stockMinimo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get urlFoto => $composableBuilder(
      column: $table.urlFoto, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get eliminado => $composableBuilder(
      column: $table.eliminado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => ColumnFilters(column));
}

class $$InventarioTableOrderingComposer
    extends Composer<_$AppDatabase, $InventarioTable> {
  $$InventarioTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nombreProducto => $composableBuilder(
      column: $table.nombreProducto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoriaTags => $composableBuilder(
      column: $table.categoriaTags,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get compatibilidadVehiculos => $composableBuilder(
      column: $table.compatibilidadVehiculos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costo => $composableBuilder(
      column: $table.costo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pvp => $composableBuilder(
      column: $table.pvp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockActual => $composableBuilder(
      column: $table.stockActual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stockMinimo => $composableBuilder(
      column: $table.stockMinimo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get urlFoto => $composableBuilder(
      column: $table.urlFoto, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get eliminado => $composableBuilder(
      column: $table.eliminado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync,
      builder: (column) => ColumnOrderings(column));
}

class $$InventarioTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventarioTable> {
  $$InventarioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombreProducto => $composableBuilder(
      column: $table.nombreProducto, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
      column: $table.descripcion, builder: (column) => column);

  GeneratedColumn<String> get categoriaTags => $composableBuilder(
      column: $table.categoriaTags, builder: (column) => column);

  GeneratedColumn<String> get compatibilidadVehiculos => $composableBuilder(
      column: $table.compatibilidadVehiculos, builder: (column) => column);

  GeneratedColumn<double> get costo =>
      $composableBuilder(column: $table.costo, builder: (column) => column);

  GeneratedColumn<double> get pvp =>
      $composableBuilder(column: $table.pvp, builder: (column) => column);

  GeneratedColumn<int> get stockActual => $composableBuilder(
      column: $table.stockActual, builder: (column) => column);

  GeneratedColumn<int> get stockMinimo => $composableBuilder(
      column: $table.stockMinimo, builder: (column) => column);

  GeneratedColumn<String> get urlFoto =>
      $composableBuilder(column: $table.urlFoto, builder: (column) => column);

  GeneratedColumn<bool> get eliminado =>
      $composableBuilder(column: $table.eliminado, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion, builder: (column) => column);

  GeneratedColumn<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => column);
}

class $$InventarioTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InventarioTable,
    ProductoRow,
    $$InventarioTableFilterComposer,
    $$InventarioTableOrderingComposer,
    $$InventarioTableAnnotationComposer,
    $$InventarioTableCreateCompanionBuilder,
    $$InventarioTableUpdateCompanionBuilder,
    (ProductoRow, BaseReferences<_$AppDatabase, $InventarioTable, ProductoRow>),
    ProductoRow,
    PrefetchHooks Function()> {
  $$InventarioTableTableManager(_$AppDatabase db, $InventarioTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventarioTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventarioTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventarioTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> nombreProducto = const Value.absent(),
            Value<String?> descripcion = const Value.absent(),
            Value<String> categoriaTags = const Value.absent(),
            Value<String> compatibilidadVehiculos = const Value.absent(),
            Value<double?> costo = const Value.absent(),
            Value<double?> pvp = const Value.absent(),
            Value<int> stockActual = const Value.absent(),
            Value<int> stockMinimo = const Value.absent(),
            Value<String?> urlFoto = const Value.absent(),
            Value<bool> eliminado = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<DateTime> fechaModificacion = const Value.absent(),
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventarioCompanion(
            id: id,
            nombreProducto: nombreProducto,
            descripcion: descripcion,
            categoriaTags: categoriaTags,
            compatibilidadVehiculos: compatibilidadVehiculos,
            costo: costo,
            pvp: pvp,
            stockActual: stockActual,
            stockMinimo: stockMinimo,
            urlFoto: urlFoto,
            eliminado: eliminado,
            fechaCreacion: fechaCreacion,
            fechaModificacion: fechaModificacion,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String nombreProducto,
            Value<String?> descripcion = const Value.absent(),
            required String categoriaTags,
            required String compatibilidadVehiculos,
            Value<double?> costo = const Value.absent(),
            Value<double?> pvp = const Value.absent(),
            Value<int> stockActual = const Value.absent(),
            Value<int> stockMinimo = const Value.absent(),
            Value<String?> urlFoto = const Value.absent(),
            Value<bool> eliminado = const Value.absent(),
            required DateTime fechaCreacion,
            required DateTime fechaModificacion,
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventarioCompanion.insert(
            id: id,
            nombreProducto: nombreProducto,
            descripcion: descripcion,
            categoriaTags: categoriaTags,
            compatibilidadVehiculos: compatibilidadVehiculos,
            costo: costo,
            pvp: pvp,
            stockActual: stockActual,
            stockMinimo: stockMinimo,
            urlFoto: urlFoto,
            eliminado: eliminado,
            fechaCreacion: fechaCreacion,
            fechaModificacion: fechaModificacion,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InventarioTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InventarioTable,
    ProductoRow,
    $$InventarioTableFilterComposer,
    $$InventarioTableOrderingComposer,
    $$InventarioTableAnnotationComposer,
    $$InventarioTableCreateCompanionBuilder,
    $$InventarioTableUpdateCompanionBuilder,
    (ProductoRow, BaseReferences<_$AppDatabase, $InventarioTable, ProductoRow>),
    ProductoRow,
    PrefetchHooks Function()>;
typedef $$CierresMensualesTableCreateCompanionBuilder
    = CierresMensualesCompanion Function({
  required String id,
  required int anio,
  required int mes,
  required double totalFacturado,
  required double totalCobrado,
  required double gananciaNeta,
  required double carteraPendienteCierre,
  required DateTime fechaCierre,
  Value<bool> pendienteSync,
  Value<int> rowid,
});
typedef $$CierresMensualesTableUpdateCompanionBuilder
    = CierresMensualesCompanion Function({
  Value<String> id,
  Value<int> anio,
  Value<int> mes,
  Value<double> totalFacturado,
  Value<double> totalCobrado,
  Value<double> gananciaNeta,
  Value<double> carteraPendienteCierre,
  Value<DateTime> fechaCierre,
  Value<bool> pendienteSync,
  Value<int> rowid,
});

class $$CierresMensualesTableFilterComposer
    extends Composer<_$AppDatabase, $CierresMensualesTable> {
  $$CierresMensualesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get anio => $composableBuilder(
      column: $table.anio, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mes => $composableBuilder(
      column: $table.mes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalFacturado => $composableBuilder(
      column: $table.totalFacturado,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalCobrado => $composableBuilder(
      column: $table.totalCobrado, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get gananciaNeta => $composableBuilder(
      column: $table.gananciaNeta, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carteraPendienteCierre => $composableBuilder(
      column: $table.carteraPendienteCierre,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaCierre => $composableBuilder(
      column: $table.fechaCierre, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => ColumnFilters(column));
}

class $$CierresMensualesTableOrderingComposer
    extends Composer<_$AppDatabase, $CierresMensualesTable> {
  $$CierresMensualesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get anio => $composableBuilder(
      column: $table.anio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mes => $composableBuilder(
      column: $table.mes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalFacturado => $composableBuilder(
      column: $table.totalFacturado,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalCobrado => $composableBuilder(
      column: $table.totalCobrado,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get gananciaNeta => $composableBuilder(
      column: $table.gananciaNeta,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carteraPendienteCierre => $composableBuilder(
      column: $table.carteraPendienteCierre,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaCierre => $composableBuilder(
      column: $table.fechaCierre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync,
      builder: (column) => ColumnOrderings(column));
}

class $$CierresMensualesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CierresMensualesTable> {
  $$CierresMensualesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get anio =>
      $composableBuilder(column: $table.anio, builder: (column) => column);

  GeneratedColumn<int> get mes =>
      $composableBuilder(column: $table.mes, builder: (column) => column);

  GeneratedColumn<double> get totalFacturado => $composableBuilder(
      column: $table.totalFacturado, builder: (column) => column);

  GeneratedColumn<double> get totalCobrado => $composableBuilder(
      column: $table.totalCobrado, builder: (column) => column);

  GeneratedColumn<double> get gananciaNeta => $composableBuilder(
      column: $table.gananciaNeta, builder: (column) => column);

  GeneratedColumn<double> get carteraPendienteCierre => $composableBuilder(
      column: $table.carteraPendienteCierre, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCierre => $composableBuilder(
      column: $table.fechaCierre, builder: (column) => column);

  GeneratedColumn<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => column);
}

class $$CierresMensualesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CierresMensualesTable,
    CierreRow,
    $$CierresMensualesTableFilterComposer,
    $$CierresMensualesTableOrderingComposer,
    $$CierresMensualesTableAnnotationComposer,
    $$CierresMensualesTableCreateCompanionBuilder,
    $$CierresMensualesTableUpdateCompanionBuilder,
    (
      CierreRow,
      BaseReferences<_$AppDatabase, $CierresMensualesTable, CierreRow>
    ),
    CierreRow,
    PrefetchHooks Function()> {
  $$CierresMensualesTableTableManager(
      _$AppDatabase db, $CierresMensualesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CierresMensualesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CierresMensualesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CierresMensualesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> anio = const Value.absent(),
            Value<int> mes = const Value.absent(),
            Value<double> totalFacturado = const Value.absent(),
            Value<double> totalCobrado = const Value.absent(),
            Value<double> gananciaNeta = const Value.absent(),
            Value<double> carteraPendienteCierre = const Value.absent(),
            Value<DateTime> fechaCierre = const Value.absent(),
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CierresMensualesCompanion(
            id: id,
            anio: anio,
            mes: mes,
            totalFacturado: totalFacturado,
            totalCobrado: totalCobrado,
            gananciaNeta: gananciaNeta,
            carteraPendienteCierre: carteraPendienteCierre,
            fechaCierre: fechaCierre,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int anio,
            required int mes,
            required double totalFacturado,
            required double totalCobrado,
            required double gananciaNeta,
            required double carteraPendienteCierre,
            required DateTime fechaCierre,
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CierresMensualesCompanion.insert(
            id: id,
            anio: anio,
            mes: mes,
            totalFacturado: totalFacturado,
            totalCobrado: totalCobrado,
            gananciaNeta: gananciaNeta,
            carteraPendienteCierre: carteraPendienteCierre,
            fechaCierre: fechaCierre,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CierresMensualesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CierresMensualesTable,
    CierreRow,
    $$CierresMensualesTableFilterComposer,
    $$CierresMensualesTableOrderingComposer,
    $$CierresMensualesTableAnnotationComposer,
    $$CierresMensualesTableCreateCompanionBuilder,
    $$CierresMensualesTableUpdateCompanionBuilder,
    (
      CierreRow,
      BaseReferences<_$AppDatabase, $CierresMensualesTable, CierreRow>
    ),
    CierreRow,
    PrefetchHooks Function()>;
typedef $$NotasTableCreateCompanionBuilder = NotasCompanion Function({
  required String id,
  Value<String?> titulo,
  Value<String?> contenido,
  Value<String> color,
  Value<bool> eliminado,
  required DateTime fechaCreacion,
  required DateTime fechaModificacion,
  Value<bool> pendienteSync,
  Value<int> rowid,
});
typedef $$NotasTableUpdateCompanionBuilder = NotasCompanion Function({
  Value<String> id,
  Value<String?> titulo,
  Value<String?> contenido,
  Value<String> color,
  Value<bool> eliminado,
  Value<DateTime> fechaCreacion,
  Value<DateTime> fechaModificacion,
  Value<bool> pendienteSync,
  Value<int> rowid,
});

class $$NotasTableFilterComposer extends Composer<_$AppDatabase, $NotasTable> {
  $$NotasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contenido => $composableBuilder(
      column: $table.contenido, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get eliminado => $composableBuilder(
      column: $table.eliminado, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => ColumnFilters(column));
}

class $$NotasTableOrderingComposer
    extends Composer<_$AppDatabase, $NotasTable> {
  $$NotasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titulo => $composableBuilder(
      column: $table.titulo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contenido => $composableBuilder(
      column: $table.contenido, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get eliminado => $composableBuilder(
      column: $table.eliminado, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync,
      builder: (column) => ColumnOrderings(column));
}

class $$NotasTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotasTable> {
  $$NotasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get contenido =>
      $composableBuilder(column: $table.contenido, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get eliminado =>
      $composableBuilder(column: $table.eliminado, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaCreacion => $composableBuilder(
      column: $table.fechaCreacion, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaModificacion => $composableBuilder(
      column: $table.fechaModificacion, builder: (column) => column);

  GeneratedColumn<bool> get pendienteSync => $composableBuilder(
      column: $table.pendienteSync, builder: (column) => column);
}

class $$NotasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotasTable,
    NotaRow,
    $$NotasTableFilterComposer,
    $$NotasTableOrderingComposer,
    $$NotasTableAnnotationComposer,
    $$NotasTableCreateCompanionBuilder,
    $$NotasTableUpdateCompanionBuilder,
    (NotaRow, BaseReferences<_$AppDatabase, $NotasTable, NotaRow>),
    NotaRow,
    PrefetchHooks Function()> {
  $$NotasTableTableManager(_$AppDatabase db, $NotasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> titulo = const Value.absent(),
            Value<String?> contenido = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<bool> eliminado = const Value.absent(),
            Value<DateTime> fechaCreacion = const Value.absent(),
            Value<DateTime> fechaModificacion = const Value.absent(),
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotasCompanion(
            id: id,
            titulo: titulo,
            contenido: contenido,
            color: color,
            eliminado: eliminado,
            fechaCreacion: fechaCreacion,
            fechaModificacion: fechaModificacion,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> titulo = const Value.absent(),
            Value<String?> contenido = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<bool> eliminado = const Value.absent(),
            required DateTime fechaCreacion,
            required DateTime fechaModificacion,
            Value<bool> pendienteSync = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotasCompanion.insert(
            id: id,
            titulo: titulo,
            contenido: contenido,
            color: color,
            eliminado: eliminado,
            fechaCreacion: fechaCreacion,
            fechaModificacion: fechaModificacion,
            pendienteSync: pendienteSync,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotasTable,
    NotaRow,
    $$NotasTableFilterComposer,
    $$NotasTableOrderingComposer,
    $$NotasTableAnnotationComposer,
    $$NotasTableCreateCompanionBuilder,
    $$NotasTableUpdateCompanionBuilder,
    (NotaRow, BaseReferences<_$AppDatabase, $NotasTable, NotaRow>),
    NotaRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db, _db.usuarios);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$DetalleCuentasTableTableManager get detalleCuentas =>
      $$DetalleCuentasTableTableManager(_db, _db.detalleCuentas);
  $$InventarioTableTableManager get inventario =>
      $$InventarioTableTableManager(_db, _db.inventario);
  $$CierresMensualesTableTableManager get cierresMensuales =>
      $$CierresMensualesTableTableManager(_db, _db.cierresMensuales);
  $$NotasTableTableManager get notas =>
      $$NotasTableTableManager(_db, _db.notas);
}
