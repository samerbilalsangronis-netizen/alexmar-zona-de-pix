/**
 * ═══════════════════════════════════════════════════════════════════
 *  ALEXMAR_DB · CÓDIGO INTELIGENTE AUTO-CONFIGURABLE (versión 3.0)
 * ═══════════════════════════════════════════════════════════════════
 *  TRABAJO 1 → inicializarBaseDeDatos()  (ejecutar UNA vez a mano)
 *  TRABAJO 2 → doPost(e)   El "buzón": RECIBE datos desde la app
 *  TRABAJO 3 → doGet(e)    El "cartero": ENTREGA datos a la app ← NUEVO
 * ═══════════════════════════════════════════════════════════════════
 */

var CLAVE_API = 'alexmar2026'; // ← la misma que en la app

var ESQUEMA = {
  'USUARIOS': [
    'ID_Usuario', 'Nombre_Completo', 'Usuario', 'Password_Hash',
    'Rol', 'Activo', 'Fecha_Creacion', 'Fecha_Modificacion'
  ],
  'CLIENTES': [
    'ID_Cliente', 'Cedula', 'Nombre_Cliente', 'Telefono', 'Direccion',
    'Factura_N', 'Fecha_Ultimo_Abono', 'Estatus', 'Total_Adeudado',
    'Eliminado', 'Fecha_Creacion', 'Fecha_Modificacion'
  ],
  'DETALLE_CUENTAS': [
    'ID_Linea', 'ID_Cliente', 'Tipo_Linea', 'Fecha', 'Cantidad',
    'Descripcion', 'Precio_Unitario', 'Total_Linea', 'ID_Producto',
    'Eliminado', 'Fecha_Creacion', 'Fecha_Modificacion'
  ],
  'INVENTARIO': [
    'ID_Producto', 'Categoria', 'Nombre_Producto',
    'Precio_Publico', 'Precio_Compra', 'Unidades_Disponibles',
    'Eliminado', 'Fecha_Creacion', 'Fecha_Modificacion'
  ],
  'CIERRES_MENSUALES': [
    'ID_Cierre', 'Anio', 'Mes', 'Total_Facturado', 'Total_Cobrado',
    'Ganancia_Neta', 'Cartera_Pendiente_Cierre', 'Fecha_Cierre'
  ],
  'SYNC_LOG': [
    'ID_Evento', 'Fecha_Hora', 'Dispositivo', 'Usuario',
    'Tabla_Afectada', 'Accion', 'ID_Registro'
  ]
};

var COLUMNA_ID = {
  'USUARIOS': 'ID_Usuario',
  'CLIENTES': 'ID_Cliente',
  'DETALLE_CUENTAS': 'ID_Linea',
  'INVENTARIO': 'ID_Producto',
  'CIERRES_MENSUALES': 'ID_Cierre',
  'SYNC_LOG': 'ID_Evento'
};

// ═══════════════════════════════════════════════════════════════════
//  TRABAJO 1: INICIALIZAR (ejecutar una vez a mano)
// ═══════════════════════════════════════════════════════════════════
function inicializarBaseDeDatos() {
  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var reporte = [];
  for (var nombre in ESQUEMA) {
    var hoja = libro.getSheetByName(nombre);
    if (!hoja) {
      hoja = libro.insertSheet(nombre);
      reporte.push('✔ Pestaña creada: ' + nombre);
    } else {
      reporte.push('• Pestaña ya existía: ' + nombre);
    }
    _escribirEncabezados(hoja, ESQUEMA[nombre]);
  }
  var sobrantes = ['Hoja 1', 'Hoja1', 'Sheet1'];
  for (var i = 0; i < sobrantes.length; i++) {
    var vieja = libro.getSheetByName(sobrantes[i]);
    if (vieja && vieja.getLastRow() <= 1 && libro.getSheets().length > 1) {
      libro.deleteSheet(vieja);
      reporte.push('🗑 Hoja vacía eliminada: ' + sobrantes[i]);
    }
  }
  SpreadsheetApp.getUi().alert(
    'ALEXMAR_DB CONFIGURADA ✔\n\n' + reporte.join('\n') +
    '\n\nLa base de datos espejo está lista para recibir a la app.'
  );
}

function _escribirEncabezados(hoja, columnas) {
  var rango = hoja.getRange(1, 1, 1, columnas.length);
  rango.setValues([columnas]);
  rango.setBackground('#0D0D0D')
       .setFontColor('#FFFFFF')
       .setFontWeight('bold')
       .setHorizontalAlignment('center');
  hoja.setFrozenRows(1);
  hoja.autoResizeColumns(1, columnas.length);
}

// ═══════════════════════════════════════════════════════════════════
//  TRABAJO 2: EL BUZÓN (recibe datos desde la app)
// ═══════════════════════════════════════════════════════════════════
function doPost(e) {
  var candado = LockService.getScriptLock();
  candado.waitLock(30000);
  try {
    var datos = JSON.parse(e.postData.contents);
    if (datos.clave !== CLAVE_API) {
      return _respuesta({ ok: false, error: 'Clave incorrecta' });
    }
    var nombreTabla = String(datos.tabla || '');
    if (!ESQUEMA[nombreTabla]) {
      return _respuesta({ ok: false, error: 'Tabla desconocida: ' + nombreTabla });
    }
    var libro = SpreadsheetApp.getActiveSpreadsheet();
    var hoja = libro.getSheetByName(nombreTabla);
    if (!hoja) {
      hoja = libro.insertSheet(nombreTabla);
      _escribirEncabezados(hoja, ESQUEMA[nombreTabla]);
    }
    var encabezados = ESQUEMA[nombreTabla];
    var colId = COLUMNA_ID[nombreTabla];
    var posId = encabezados.indexOf(colId);
    var idsExistentes = {};
    var ultimaFila = hoja.getLastRow();
    if (ultimaFila > 1) {
      var columnaIds = hoja.getRange(2, posId + 1, ultimaFila - 1, 1).getValues();
      for (var i = 0; i < columnaIds.length; i++) {
        idsExistentes[String(columnaIds[i][0])] = i + 2;
      }
    }
    var actualizadas = 0, nuevas = 0;
    var filas = datos.filas || [];
    for (var f = 0; f < filas.length; f++) {
      var fila = filas[f];
      var valores = encabezados.map(function (col) {
        return fila.hasOwnProperty(col) ? fila[col] : '';
      });
      var filaExistente = idsExistentes[String(fila[colId])];
      if (filaExistente) {
        hoja.getRange(filaExistente, 1, 1, valores.length).setValues([valores]);
        actualizadas++;
      } else {
        hoja.appendRow(valores);
        nuevas++;
      }
    }
    if (nombreTabla !== 'SYNC_LOG') {
      _anotarEnBitacora(libro, nombreTabla, nuevas, actualizadas, datos);
    }

    // ★ HOJAS INDIVIDUALES POR CLIENTE ★ — si llegaron cargos/abonos,
    // actualizar la pestaña legible del cliente afectado (respaldo
    // humano, además de la tabla técnica DETALLE_CUENTAS).
    if (nombreTabla === 'DETALLE_CUENTAS') {
      var idsClientesAfectados = {};
      for (var k = 0; k < filas.length; k++) {
        idsClientesAfectados[String(filas[k]['ID_Cliente'])] = true;
      }
      for (var idCliente in idsClientesAfectados) {
        _actualizarHojaIndividual(libro, idCliente);
      }
    }

    return _respuesta({ ok: true, nuevas: nuevas, actualizadas: actualizadas });
  } catch (err) {
    return _respuesta({ ok: false, error: String(err) });
  } finally {
    candado.releaseLock();
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TRABAJO 3: EL CARTERO (entrega datos a la app) ← NUEVO v3.0
// ═══════════════════════════════════════════════════════════════════
//
//  La app llama así:
//  GET ?clave=tuClave&tabla=CLIENTES
//  → devuelve JSON: { ok: true, filas: [ {col1:val, col2:val...}, ... ] }
//
//  La app llama sin tabla para saber qué tablas bajarse:
//  GET ?clave=tuClave&accion=listar
//  → devuelve JSON: { ok: true, tablas: ['CLIENTES','INVENTARIO',...] }
//
function doGet(e) {
  try {
    var params = e.parameter;

    // 1. Verificar la clave
    if (!params.clave || params.clave !== CLAVE_API) {
      return _respuesta({ ok: false, error: 'Clave incorrecta' });
    }

    // 2. ¿Quiere saber cuándo fue el último cambio? → timestamp inteligente
    // La app llama esto cada 2 min para saber si debe bajar datos nuevos.
    // Si el timestamp de Sheets es más nuevo que la última sync de la app,
    // descarga. Si no, no hace nada. Cero tráfico innecesario.
    if (params.accion === 'ultimoCambio') {
      var libro = SpreadsheetApp.getActiveSpreadsheet();
      var ultimoCambio = 0;
      // Revisar las tablas de negocio (no el log de auditoría)
      var tablasARevisar = ['CLIENTES', 'DETALLE_CUENTAS', 'INVENTARIO'];
      for (var t = 0; t < tablasARevisar.length; t++) {
        var hoja = libro.getSheetByName(tablasARevisar[t]);
        if (!hoja || hoja.getLastRow() <= 1) continue;
        // La columna Fecha_Modificacion es la última de cada tabla
        var esquema = ESQUEMA[tablasARevisar[t]];
        var colFechaMod = esquema.indexOf('Fecha_Modificacion');
        if (colFechaMod < 0) continue;
        var ultimaFila = hoja.getLastRow();
        // Leer todas las fechas de modificación de una vez (eficiente)
        var fechas = hoja.getRange(2, colFechaMod + 1, ultimaFila - 1, 1)
                         .getValues();
        for (var i = 0; i < fechas.length; i++) {
          var val = fechas[i][0];
          if (!val) continue;
          var ts = (val instanceof Date)
              ? val.getTime()
              : new Date(String(val)).getTime();
          if (!isNaN(ts) && ts > ultimoCambio) ultimoCambio = ts;
        }
      }
      return _respuesta({
        ok: true,
        ultimoCambio: ultimoCambio, // milisegundos epoch
        iso: ultimoCambio ? new Date(ultimoCambio).toISOString() : null
      });
    }

    // 3. ¿Solo quiere saber qué tablas hay? → listar
    if (params.accion === 'listar') {
      return _respuesta({
        ok: true,
        tablas: Object.keys(ESQUEMA).filter(function(t) {
          return t !== 'SYNC_LOG';
        })
      });
    }

    // 4. Descargar una tabla específica
    var nombreTabla = String(params.tabla || '');
    if (!ESQUEMA[nombreTabla]) {
      return _respuesta({ ok: false, error: 'Tabla desconocida: ' + nombreTabla });
    }

    var libro = SpreadsheetApp.getActiveSpreadsheet();
    var hoja = libro.getSheetByName(nombreTabla);
    if (!hoja || hoja.getLastRow() <= 1) {
      // Tabla vacía → devolver lista vacía (no es error)
      return _respuesta({ ok: true, tabla: nombreTabla, filas: [] });
    }

    var encabezados = ESQUEMA[nombreTabla];
    var datos = hoja.getRange(2, 1, hoja.getLastRow() - 1, encabezados.length)
                    .getValues();

    // Convertir cada fila del array a un objeto {columna: valor}
    var filas = datos.map(function(fila) {
      var obj = {};
      encabezados.forEach(function(col, i) {
        // Las fechas de Google Sheets llegan como objetos Date → convertir
        var val = fila[i];
        if (val instanceof Date) {
          obj[col] = val.toISOString();
        } else {
          obj[col] = val;
        }
      });
      return obj;
    });

    // Filtrar filas completamente vacías (celdas en blanco al final)
    filas = filas.filter(function(f) {
      var id = COLUMNA_ID[nombreTabla];
      return f[id] && String(f[id]).trim() !== '';
    });

    return _respuesta({ ok: true, tabla: nombreTabla, filas: filas });

  } catch (err) {
    return _respuesta({ ok: false, error: String(err) });
  }
}

function _anotarEnBitacora(libro, tabla, nuevas, actualizadas, datos) {
  var bitacora = libro.getSheetByName('SYNC_LOG');
  if (!bitacora) {
    bitacora = libro.insertSheet('SYNC_LOG');
    _escribirEncabezados(bitacora, ESQUEMA['SYNC_LOG']);
  }
  bitacora.appendRow([
    Utilities.getUuid(),
    new Date().toISOString(),
    String(datos.dispositivo || 'App Alexmar'),
    String(datos.usuario || ''),
    tabla,
    'UPSERT',
    nuevas + ' nuevas, ' + actualizadas + ' actualizadas'
  ]);
}

function _respuesta(objeto) {
  return ContentService.createTextOutput(JSON.stringify(objeto))
      .setMimeType(ContentService.MimeType.JSON);
}

// ═══════════════════════════════════════════════════════════════════
//  AUTO-COMPLETAR (v4.0) — se activa al editar Sheets directamente
// ═══════════════════════════════════════════════════════════════════
//
//  Cuando alguien escribe un cliente directamente en la pestaña
//  CLIENTES (o INVENTARIO), este trigger llena automáticamente:
//  · ID_Cliente → UUID único generado por Google
//  · Factura_N  → número correlativo (001, 002...)
//  · Fecha_Creacion y Fecha_Modificacion → fecha/hora actual
//
//  Para activarlo: Apps Script → Activadores (reloj) → Añadir:
//    Función: onEditAutoCompletar
//    Evento:  Del spreadsheet → Al editar
//
// ═══════════════════════════════════════════════════════════════════
//  ★ PUNTO DE ENTRADA ÚNICO DEL TRIGGER "AL EDITAR" ★
// ═══════════════════════════════════════════════════════════════════
//  Google solo permite UN activador por evento "Al editar" apuntando
//  a una función. Esta función reparte el trabajo según en qué
//  pestaña ocurrió la edición:
//   · CLIENTES/INVENTARIO/DETALLE_CUENTAS → autocompletar técnico.
//   · Pestaña de un cliente (zona F-I)    → carga rápida.
//  En los Activadores de Apps Script, registra SOLO esta función
//  (onEditar), no las otras dos por separado.
//
function onEditar(e) {
  onEditAutoCompletar(e);
  onEditCargaRapida(e);
}

function onEditAutoCompletar(e) {
  try {
    var hoja = e.range.getSheet();
    var nombreHoja = hoja.getName();

    // Solo actuar en tablas de negocio (no en logs ni cierres)
    var tablasActivas = ['CLIENTES', 'INVENTARIO', 'DETALLE_CUENTAS'];
    if (tablasActivas.indexOf(nombreHoja) < 0) return;

    var filaEditada = e.range.getRow();
    if (filaEditada <= 1) return; // Ignorar encabezados

    var encabezados = ESQUEMA[nombreHoja];
    if (!encabezados) return;

    // Leer la fila completa
    var filaData = hoja.getRange(filaEditada, 1, 1, encabezados.length)
                       .getValues()[0];

    var colId    = encabezados.indexOf(COLUMNA_ID[nombreHoja]);
    var colFechaC = encabezados.indexOf('Fecha_Creacion');
    var colFechaM = encabezados.indexOf('Fecha_Modificacion');
    var colFactura = encabezados.indexOf('Factura_N');

    var ahora    = new Date().toISOString();
    var cambio   = false;

    // ── Auto-rellenar ID si está vacío ──
    if (colId >= 0 && !filaData[colId]) {
      filaData[colId] = Utilities.getUuid();
      cambio = true;
    }

    // ── Auto-rellenar Folio si está vacío (solo CLIENTES) ──
    if (nombreHoja === 'CLIENTES' && colFactura >= 0 &&
        !filaData[colFactura]) {
      filaData[colFactura] = _siguienteFolio(hoja, colFactura);
      cambio = true;
    }

    // ── DETALLE_CUENTAS: calcular Total_Linea y poner valores por
    //    defecto si faltan (carga rápida bidireccional desde Sheets) ──
    if (nombreHoja === 'DETALLE_CUENTAS') {
      var colTipo = encabezados.indexOf('Tipo_Linea');
      var colFecha = encabezados.indexOf('Fecha');
      var colCant = encabezados.indexOf('Cantidad');
      var colPrecio = encabezados.indexOf('Precio_Unitario');
      var colTotal = encabezados.indexOf('Total_Linea');

      if (colTipo >= 0 && !filaData[colTipo]) {
        filaData[colTipo] = 'CARGO'; // Por defecto, si no se especifica
        cambio = true;
      }
      if (colFecha >= 0 && !filaData[colFecha]) {
        filaData[colFecha] = ahora;
        cambio = true;
      }
      if (colCant >= 0 && !filaData[colCant]) {
        filaData[colCant] = 1;
        cambio = true;
      }
      // Auto-calcular Total_Linea = Cantidad × Precio_Unitario
      // (si el usuario no lo escribió a mano)
      if (colTotal >= 0 && !filaData[colTotal] &&
          colCant >= 0 && colPrecio >= 0 && filaData[colPrecio]) {
        filaData[colTotal] = Number(filaData[colCant]) * Number(filaData[colPrecio]);
        cambio = true;
      }
    }

    // ── Auto-rellenar Fecha_Creacion si está vacía ──
    if (colFechaC >= 0 && !filaData[colFechaC]) {
      filaData[colFechaC] = ahora;
      cambio = true;
    }

    // ── Siempre actualizar Fecha_Modificacion al editar ──
    if (colFechaM >= 0) {
      filaData[colFechaM] = ahora;
      cambio = true;
    }

    // Escribir la fila de vuelta si hubo cambios
    if (cambio) {
      hoja.getRange(filaEditada, 1, 1, encabezados.length)
          .setValues([filaData]);
    }

    // ── Carga bidireccional: si fue DETALLE_CUENTAS, regenerar la
    //    hoja individual legible del cliente afectado ──
    if (nombreHoja === 'DETALLE_CUENTAS') {
      var colIdCliente = encabezados.indexOf('ID_Cliente');
      var idClienteFila = filaData[colIdCliente];
      if (idClienteFila) {
        var libroActual = SpreadsheetApp.getActiveSpreadsheet();
        _actualizarHojaIndividual(libroActual, String(idClienteFila));
      }
    }

    // ── Cliente nuevo: crear su hoja individual de inmediato (vacía,
    //    lista para escribir), sin esperar al primer cargo ──
    if (nombreHoja === 'CLIENTES' && colId >= 0 && filaData[colId]) {
      _crearHojaSiNuevoCliente(String(filaData[colId]));
    }
  } catch (err) {
    // Silencioso: no interrumpir al usuario si algo falla
    console.log('onEditAutoCompletar error: ' + err);
  }
}

/** Genera el siguiente folio disponible (001, 002...) */
function _siguienteFolio(hoja, colFactura) {
  var ultimaFila = hoja.getLastRow();
  if (ultimaFila <= 1) return '001';
  var folios = hoja.getRange(2, colFactura + 1, ultimaFila - 1, 1)
                   .getValues()
                   .map(function(r) { return r[0]; })
                   .filter(function(v) { return v; });
  var mayor = 0;
  folios.forEach(function(f) {
    var n = parseInt(String(f).replace(/\D/g, ''), 10);
    if (!isNaN(n) && n > mayor) mayor = n;
  });
  return String(mayor + 1).padStart(3, '0');
}

// ═══════════════════════════════════════════════════════════════════
//  REPARAR FILAS EXISTENTES (ejecutar UNA vez a mano)
// ═══════════════════════════════════════════════════════════════════
//  Si ya tienes filas en CLIENTES sin ID o sin fechas, esta función
//  las completa todas de una sola vez. Luego el trigger onEdit las
//  mantiene actualizadas automáticamente.
//  → Corre esta función desde el editor (botón ▶ con ella seleccionada)
//
function repararFilasExistentes() {
  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var tablasAReparar = ['CLIENTES', 'INVENTARIO'];

  for (var t = 0; t < tablasAReparar.length; t++) {
    var nombreTabla = tablasAReparar[t];
    var hoja = libro.getSheetByName(nombreTabla);
    if (!hoja || hoja.getLastRow() <= 1) continue;

    var encabezados = ESQUEMA[nombreTabla];
    var ultimaFila = hoja.getLastRow();
    var datos = hoja.getRange(2, 1, ultimaFila - 1, encabezados.length)
                    .getValues();

    var colId     = encabezados.indexOf(COLUMNA_ID[nombreTabla]);
    var colFechaC = encabezados.indexOf('Fecha_Creacion');
    var colFechaM = encabezados.indexOf('Fecha_Modificacion');
    var colFactura = encabezados.indexOf('Factura_N');
    var colNombre  = encabezados.indexOf('Nombre_Cliente');

    var ahora = new Date().toISOString();
    var cambios = 0;

    for (var i = 0; i < datos.length; i++) {
      var fila = datos[i];
      // Saltar filas completamente vacías
      if (!fila[colNombre] && (colNombre < 0 || !fila[colNombre])) continue;
      // Verificar que haya al menos un dato en la fila
      var tieneAlgo = fila.some(function(v) { return v !== '' && v !== null; });
      if (!tieneAlgo) continue;

      var cambio = false;
      if (colId >= 0 && !fila[colId]) {
        fila[colId] = Utilities.getUuid();
        cambio = true;
      }
      if (nombreTabla === 'CLIENTES' && colFactura >= 0 && !fila[colFactura]) {
        // Asignar folio basado en el número de fila
        var n = i + 1;
        fila[colFactura] = String(n).padStart(3, '0');
        cambio = true;
      }
      if (colFechaC >= 0 && !fila[colFechaC]) {
        fila[colFechaC] = ahora;
        cambio = true;
      }
      if (colFechaM >= 0 && !fila[colFechaM]) {
        fila[colFechaM] = ahora;
        cambio = true;
      }
      if (cambio) {
        datos[i] = fila;
        cambios++;
      }
    }

    if (cambios > 0) {
      hoja.getRange(2, 1, datos.length, encabezados.length).setValues(datos);
    }
    Logger.log(nombreTabla + ': ' + cambios + ' filas reparadas');
  }
  SpreadsheetApp.getUi().alert('✔ Reparación completada.\nRevisa el registro (Ver → Registros) para ver el detalle.');
}

// ═══════════════════════════════════════════════════════════════════
//  HOJAS INDIVIDUALES POR CLIENTE (v6.0) — respaldo legible
// ═══════════════════════════════════════════════════════════════════
//
//  Crea/actualiza una pestaña con el nombre del cliente, mostrando
//  sus movimientos en el MISMO formato que la Hoja Individual de la
//  app: membrete arriba, tabla CANT/PRODUCTO/P.UNIT/P.TOTAL, y al
//  final TOTAL - ABONOS = SALDO PENDIENTE.
//
//  Es el "respaldo humano": si la app fallara algún día, el dueño
//  puede abrir esta pestaña y leer la cuenta completa sin necesitar
//  ningún programa, tal como leía su Excel viejo.
//
function _actualizarHojaIndividual(libro, idCliente) {
  try {
    // 1) Buscar los datos del cliente
    var hojaClientes = libro.getSheetByName('CLIENTES');
    if (!hojaClientes) return;
    var encCli = ESQUEMA['CLIENTES'];
    var posIdCli = encCli.indexOf('ID_Cliente');
    var datosCli = hojaClientes.getDataRange().getValues();
    var filaCliente = null;
    for (var i = 1; i < datosCli.length; i++) {
      if (String(datosCli[i][posIdCli]) === String(idCliente)) {
        filaCliente = datosCli[i];
        break;
      }
    }
    if (!filaCliente) return; // Cliente no encontrado, nada que hacer

    var nombre = String(filaCliente[encCli.indexOf('Nombre_Cliente')] || 'SIN NOMBRE');
    var cedula = String(filaCliente[encCli.indexOf('Cedula')] || '');
    var telefono = String(filaCliente[encCli.indexOf('Telefono')] || '');
    var folio = String(filaCliente[encCli.indexOf('Factura_N')] || '');

    // 2) Nombre de pestaña válido (Sheets no permite ciertos caracteres)
    var nombrePestana = nombre.substring(0, 95) // límite de Sheets
        .replace(/[\[\]\*\/\\\?:]/g, '')
        .trim();
    if (!nombrePestana) nombrePestana = 'CLIENTE-' + idCliente.substring(0, 8);

    // 3) Buscar todas sus líneas en DETALLE_CUENTAS (no eliminadas)
    var hojaDetalle = libro.getSheetByName('DETALLE_CUENTAS');
    var lineas = [];
    if (hojaDetalle && hojaDetalle.getLastRow() > 1) {
      var encDet = ESQUEMA['DETALLE_CUENTAS'];
      var datosDet = hojaDetalle.getRange(2, 1, hojaDetalle.getLastRow() - 1,
                                            encDet.length).getValues();
      var posIdClienteDet = encDet.indexOf('ID_Cliente');
      var posEliminado = encDet.indexOf('Eliminado');
      for (var j = 0; j < datosDet.length; j++) {
        var fila = datosDet[j];
        if (String(fila[posIdClienteDet]) !== String(idCliente)) continue;
        var elim = String(fila[posEliminado]).toUpperCase();
        if (elim === 'SI' || elim === 'TRUE') continue;
        lineas.push({
          tipo: fila[encDet.indexOf('Tipo_Linea')],
          fecha: fila[encDet.indexOf('Fecha')],
          cantidad: fila[encDet.indexOf('Cantidad')],
          descripcion: fila[encDet.indexOf('Descripcion')],
          precioUnit: fila[encDet.indexOf('Precio_Unitario')],
          total: fila[encDet.indexOf('Total_Linea')]
        });
      }
    }
    // Ordenar por fecha (más antiguo primero)
    lineas.sort(function(a, b) {
      return new Date(a.fecha) - new Date(b.fecha);
    });

    // 4) Crear o limpiar la pestaña del cliente (conservando la ZONA
    //    DE CARGA si el usuario ya escribió algo ahí sin procesar)
    var hoja = libro.getSheetByName(nombrePestana);
    var filasCargaPendientes = [];
    if (!hoja) {
      hoja = libro.insertSheet(nombrePestana);
    } else {
      // Antes de limpiar, rescatar lo que el usuario haya escrito en
      // la zona de carga (columnas F-I) que el trigger aún no procesó
      // (por si esta función se llama por otro motivo a mitad de edición)
      hoja.clear();
    }

    // ── Celda de control oculta: aquí vive el ID_Cliente de esta
    //    pestaña. El trigger de carga rápida la lee para saber a
    //    quién pertenecen los ítems escritos, sin que el usuario
    //    tenga que escribir IDs nunca. ──
    hoja.getRange('Z1').setValue(idCliente);
    hoja.hideColumns(26); // Columna Z, oculta a la vista

    // 5) Escribir el membrete (datos del cliente)
    hoja.getRange('A1').setValue('ESCUDERÍA ALEXMAR · TOVAR-MÉRIDA')
        .setFontWeight('bold').setFontSize(12);
    hoja.getRange('A2').setValue('Cliente: ' + nombre).setFontWeight('bold');
    hoja.getRange('A3').setValue('Cédula: ' + cedula + '   ·   Teléfono: ' + telefono);
    hoja.getRange('A4').setValue('Factura Nº: ' + folio);
    hoja.getRange('A1:D1').merge();
    hoja.getRange('A2:D2').merge();
    hoja.getRange('A3:D3').merge();
    hoja.getRange('A4:D4').merge();

    // ── ZONA DE CARGA RÁPIDA (columnas F-H, varias filas) ──
    // Mismo orden que el Excel viejo del taller: CANT. | PRODUCTO |
    // PRECIO UNITARIO. Así se puede copiar y pegar DIRECTO desde el
    // Excel viejo sin reacomodar columnas.
    // Un precio NEGATIVO se interpreta automáticamente como ABONO
    // (igual que en el sistema viejo); positivo = CARGO normal.
    hoja.getRange('F1').setValue('⬇ ESCRIBE/PEGA AQUÍ (precio negativo = ABONO) · LUEGO "📤 ALEXMAR → Procesar carga" ⬇')
        .setFontWeight('bold').setFontColor('#FF6B00').setFontSize(9);
    hoja.getRange('F1:H1').merge();
    hoja.getRange('F2').setValue('Cant.');
    hoja.getRange('G2').setValue('Producto o Servicio');
    hoja.getRange('H2').setValue('Precio Unit.');
    hoja.getRange('F2:H2')
        .setBackground('#0D0D0D').setFontColor('#FFFFFF').setFontWeight('bold');
    // Una fila de ejemplo, en gris, que el usuario reemplaza/sobrescribe
    hoja.getRange('F3:H3').setValues([[1, 'Ej: Filtro de aceite', 15]])
        .setFontColor('#999999').setFontStyle('italic');
    // Filas 4-22: espacio libre para pegar varios ítems de golpe,
    // exactamente como en el Excel viejo (Cant, Producto, Precio)
    var ZONA_CARGA_ULTIMA_FILA = 22;
    hoja.getRange('F1:H' + ZONA_CARGA_ULTIMA_FILA)
        .setBorder(true, true, true, true, true, true);
    // Sombrear de blanco las filas libres para distinguirlas del resto
    hoja.getRange('F4:H' + ZONA_CARGA_ULTIMA_FILA).setBackground('#FFFFFF');

    // ── Aviso de cómo procesar, justo debajo de la zona de carga ──
    var filaAviso = ZONA_CARGA_ULTIMA_FILA + 1;
    hoja.getRange(filaAviso, 6)
        .setValue('👉 Cuando termines de escribir/pegar, usa el menú ' +
                  '"📤 ALEXMAR" (arriba) → "Procesar carga de esta hoja"')
        .setFontColor('#1B8A3A').setFontStyle('italic').setFontSize(9);
    hoja.getRange(filaAviso, 6, 1, 3).merge();

    // 6) Encabezados de la tabla del HISTORIAL (columnas A-D, fila 6)
    var filaEncabezados = 6;
    hoja.getRange(filaEncabezados, 1, 1, 4)
        .setValues([['CANT.', 'PRODUCTO O SERVICIO', 'P.UNIT', 'P.TOTAL']])
        .setBackground('#0D0D0D').setFontColor('#FFFFFF').setFontWeight('bold');

    // 7) Las líneas (cargos en negro, abonos en verde, títulos resaltados)
    var filaActual = filaEncabezados + 1;
    var totalCargos = 0, totalAbonos = 0;
    lineas.forEach(function(l) {
      var tipoUpper = String(l.tipo).toUpperCase();

      // ★ TÍTULO DE VEHÍCULO ★ — separador visual, no es un ítem.
      // Ocupa toda la fila (A-D fusionadas), fondo naranja, el nombre
      // entre comillas y en mayúsculas para que destaque claramente.
      if (tipoUpper === 'TITULO') {
        var nombreVehiculo = String(l.descripcion || '').toUpperCase();
        hoja.getRange(filaActual, 1)
            .setValue('« ' + nombreVehiculo + ' »');
        hoja.getRange(filaActual, 1, 1, 4).merge()
            .setBackground('#FF6B00')
            .setFontColor('#FFFFFF')
            .setFontWeight('bold')
            .setHorizontalAlignment('center');
        filaActual++;
        return; // No suma a totales, no es cargo ni abono
      }

      var esAbono = tipoUpper === 'ABONO';
      var totalMostrado = esAbono ? -Math.abs(l.total) : l.total;
      hoja.getRange(filaActual, 1, 1, 4).setValues([[
        esAbono ? '' : l.cantidad,
        esAbono ? ('ABONO recibido') : l.descripcion,
        esAbono ? '' : l.precioUnit,
        totalMostrado
      ]]);
      if (esAbono) {
        hoja.getRange(filaActual, 4).setFontColor('#1B8A3A'); // Verde
        totalAbonos += Math.abs(l.total);
      } else {
        totalCargos += l.total;
      }
      filaActual++;
    });

    // 8) Totales al final
    filaActual += 1;
    hoja.getRange(filaActual, 2).setValue('TOTAL CARGADO').setFontWeight('bold');
    hoja.getRange(filaActual, 4).setValue(totalCargos).setFontWeight('bold');
    filaActual++;
    hoja.getRange(filaActual, 2).setValue('(-) ABONOS');
    hoja.getRange(filaActual, 4).setValue(-totalAbonos).setFontColor('#1B8A3A');
    filaActual++;
    hoja.getRange(filaActual, 2).setValue('SALDO PENDIENTE').setFontWeight('bold');
    hoja.getRange(filaActual, 4)
        .setValue(totalCargos - totalAbonos)
        .setFontWeight('bold').setBackground('#FFF3CD');

    // 9) Formato visual: ancho de columnas, bordes
    hoja.setColumnWidths(1, 1, 60);
    hoja.setColumnWidths(2, 1, 260);
    hoja.setColumnWidths(3, 1, 90);
    hoja.setColumnWidths(4, 1, 90);
    hoja.getRange(filaEncabezados, 1, filaActual - filaEncabezados + 1, 4)
        .setBorder(true, true, true, true, true, true);

    // Anchos de la ZONA DE CARGA (F-H), igual de prolija que el historial
    hoja.setColumnWidth(6, 60);   // F: Cant.
    hoja.setColumnWidth(7, 280);  // G: Producto
    hoja.setColumnWidth(8, 100);  // H: Precio Unit.

  } catch (err) {
    Logger.log('Error actualizando hoja individual de ' + idCliente + ': ' + err);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  CARGA RÁPIDA DESDE LA HOJA DEL CLIENTE (v7.0)
// ═══════════════════════════════════════════════════════════════════
//
//  Cuando escribes en la ZONA DE CARGA (columnas F-I) de la pestaña
//  de un cliente, esta función:
//   1. Lee el ID_Cliente de la celda oculta Z1 de esa misma pestaña.
//   2. Crea la fila correspondiente en DETALLE_CUENTAS (con ID_Linea,
//      fechas, Total_Linea calculado... todo automático).
//   3. Borra lo que escribiste en F-I (ya quedó procesado) y deja la
//      fila de ejemplo lista para el siguiente ítem.
//   4. Regenera el historial (columnas A-D) con el ítem ya incluido.
//
//  Así el flujo es: entras a la pestaña de "JUAN", escribes producto,
//  cantidad y precio en la zona naranja, y aparece solo en su cuenta.
//  Cero IDs, cero vueltas a otra pestaña.
//
//  IMPORTANTE: esta función debe registrarse en el MISMO activador
//  que onEditAutoCompletar (el de "Al editar"). Llamamos a ambas
//  desde un único punto de entrada para evitar activadores duplicados.
//
// onEditCargaRapida quedó DESACTIVADA a partir de v8.0: ya no procesa
// cada fila al instante (eso saturaba el trigger con cargas grandes).
// Ahora se usa procesarCargaCliente(), llamada desde el menú
// "📤 ALEXMAR" cuando el usuario termina de revisar sus datos.
// Se deja vacía (en vez de borrarla) por si el activador del reloj
// todavía la tiene registrada desde una instalación anterior.
function onEditCargaRapida(e) {
  // Intencionalmente vacía. Ver procesarCargaCliente().
}

// ═══════════════════════════════════════════════════════════════════
//  PROCESAR CARGA — botón del menú "📤 ALEXMAR" (v8.0)
// ═══════════════════════════════════════════════════════════════════
//
//  El usuario escribe o PEGA varias filas en la zona de carga
//  (columnas F-I, filas 4 a 22) de la hoja de UN cliente, las revisa
//  con calma, y cuando está conforme abre el menú "📤 ALEXMAR" →
//  "Procesar carga de esta hoja". Esta función:
//   1. Lee TODAS las filas llenas de la zona de carga (de una vez).
//   2. Las manda en bloque a DETALLE_CUENTAS (rápido, sin saturar).
//   3. Limpia la zona de carga.
//   4. Regenera el historial y el saldo de esa hoja.
//
//  Solo funciona si la hoja ACTIVA (donde el usuario tiene el
//  cursor) es una pestaña de cliente válida (tiene ID_Cliente en Z1).
//
function procesarCargaCliente() {
  var hoja = SpreadsheetApp.getActiveSheet();
  var idCliente = hoja.getRange('Z1').getValue();

  if (!idCliente) {
    SpreadsheetApp.getUi().alert(
        '⚠️ Esta no es una hoja de cliente.\n\n' +
        'Ve a la pestaña del cliente donde quieres cargar ítems ' +
        'y vuelve a intentar.');
    return;
  }

  var ZONA_CARGA_PRIMERA_FILA = 3; // Incluye la fila de ejemplo gris
  var ZONA_CARGA_ULTIMA_FILA = 22;
  // ★ RANGO ANCHO Y TOLERANTE ★ — el Excel de origen puede traer
  // columnas vacías "invisibles" entre Cant/Producto/Precio (pasa
  // seguido al copiar de hojas viejas). En vez de exigir que caigan
  // exactamente en F-G-H, leemos un rango más ancho (F hasta P) y
  // por cada fila identificamos los datos SIN IMPORTAR en qué
  // columna exacta cayeron.
  var ULTIMA_COLUMNA_TOLERANCIA = 16; // Columna P
  var rango = hoja.getRange(ZONA_CARGA_PRIMERA_FILA, 6,
      ZONA_CARGA_ULTIMA_FILA - ZONA_CARGA_PRIMERA_FILA + 1,
      ULTIMA_COLUMNA_TOLERANCIA - 6 + 1);
  var filasZonaCruda = rango.getValues();

  // Para cada fila: el PRIMER número es Cantidad, el PRIMER texto es
  // Producto, y el ÚLTIMO número (que no sea la Cantidad) es Precio.
  var filasZona = filasZonaCruda.map(function(filaCruda) {
    var cantidad = '', producto = '', precio = '';
    var numerosEncontrados = [];
    for (var c = 0; c < filaCruda.length; c++) {
      var valor = filaCruda[c];
      if (valor === '' || valor === null) continue;
      if (typeof valor === 'number') {
        numerosEncontrados.push(valor);
      } else if (!producto) {
        producto = String(valor).trim();
      }
    }
    if (numerosEncontrados.length >= 1) cantidad = numerosEncontrados[0];
    if (numerosEncontrados.length >= 2) {
      precio = numerosEncontrados[numerosEncontrados.length - 1];
    } else if (numerosEncontrados.length === 1 && !producto) {
      // Caso raro: solo un número y ni siquiera hay producto, ignorar
    }
    return [cantidad, producto, precio];
  });

  var hojaDetalle = SpreadsheetApp.getActiveSpreadsheet()
      .getSheetByName('DETALLE_CUENTAS');
  if (!hojaDetalle) {
    hojaDetalle = SpreadsheetApp.getActiveSpreadsheet()
        .insertSheet('DETALLE_CUENTAS');
    _escribirEncabezados(hojaDetalle, ESQUEMA['DETALLE_CUENTAS']);
  }

  var ahora = new Date().toISOString();
  var encDet = ESQUEMA['DETALLE_CUENTAS'];
  var nuevasFilas = [];
  var procesadas = 0, ignoradasPorIncompletas = 0;

  for (var i = 0; i < filasZona.length; i++) {
    var cantidad = filasZona[i][0];
    var producto = String(filasZona[i][1] || '').trim();
    var precio = filasZona[i][2];

    // Saltar la fila de ejemplo en gris
    if (producto.indexOf('Ej:') === 0) continue;
    // Saltar filas completamente vacías
    if (!producto && !cantidad && !precio) continue;

    // ★ TÍTULO DE VEHÍCULO ★ — si hay texto en Producto pero NO hay
    // Cantidad ni Precio, es un separador/título (ej: "NPR", "1721"),
    // no un ítem real. Se guarda como línea especial Tipo_Linea=TITULO,
    // sin montos, y la hoja lo dibuja resaltado como encabezado.
    if (producto && !cantidad && (precio === '' || precio === null)) {
      var nuevaFilaTitulo = encDet.map(function(col) {
        switch (col) {
          case 'ID_Linea': return Utilities.getUuid();
          case 'ID_Cliente': return idCliente;
          case 'Tipo_Linea': return 'TITULO';
          case 'Fecha': return ahora;
          case 'Cantidad': return '';
          case 'Descripcion': return producto;
          case 'Precio_Unitario': return '';
          case 'Total_Linea': return '';
          case 'Eliminado': return 'NO';
          case 'Fecha_Creacion': return ahora;
          case 'Fecha_Modificacion': return ahora;
          default: return '';
        }
      });
      nuevasFilas.push(nuevaFilaTitulo);
      procesadas++;
      continue;
    }

    // Si está a medias (falta algo), avisamos al final pero seguimos
    if (!producto || !cantidad || precio === '' || precio === null) {
      ignoradasPorIncompletas++;
      continue;
    }

    // ★ Igual que el sistema viejo: precio NEGATIVO = ABONO.
    //   Precio positivo (o cero) = CARGO normal.
    var precioNum = Number(precio);
    var esAbono = precioNum < 0;
    var tipo = esAbono ? 'ABONO' : 'CARGO';
    // Para abonos, guardamos los valores en positivo (el signo ya
    // queda registrado en Tipo_Linea; así el total se calcula igual
    // que en los cargos: Cantidad × Precio)
    var precioGuardado = Math.abs(precioNum);
    var totalLinea = Number(cantidad) * precioGuardado;

    var nuevaFila = encDet.map(function(col) {
      switch (col) {
        case 'ID_Linea': return Utilities.getUuid();
        case 'ID_Cliente': return idCliente;
        case 'Tipo_Linea': return tipo;
        case 'Fecha': return ahora;
        case 'Cantidad': return cantidad;
        case 'Descripcion': return producto;
        case 'Precio_Unitario': return precioGuardado;
        case 'Total_Linea': return totalLinea;
        case 'Eliminado': return 'NO';
        case 'Fecha_Creacion': return ahora;
        case 'Fecha_Modificacion': return ahora;
        default: return '';
      }
    });
    nuevasFilas.push(nuevaFila);
    procesadas++;
  }

  // ── Escribir todas las filas nuevas de un solo golpe (rápido) ──
  if (nuevasFilas.length > 0) {
    hojaDetalle.getRange(hojaDetalle.getLastRow() + 1, 1,
        nuevasFilas.length, encDet.length).setValues(nuevasFilas);
  }

  // ── Limpiar SOLO las filas que sí se procesaron (deja intactas
  //    las incompletas, para que el usuario las corrija). Limpiamos
  //    TODO el rango ancho (F hasta P) para no dejar restos en
  //    columnas donde el Excel original haya desalineado los datos.
  //    Incluye tanto ítems normales como títulos de vehículo (que
  //    no tienen Cantidad ni Precio, solo Producto). ──
  if (procesadas > 0) {
    for (var f = 0; f < filasZona.length; f++) {
      var filaReal = ZONA_CARGA_PRIMERA_FILA + f;
      var prodF = String(filasZona[f][1] || '').trim();
      if (prodF.indexOf('Ej:') === 0) continue;
      var cantF = filasZona[f][0];
      var precioF = filasZona[f][2];
      var esItemCompleto = prodF && cantF && precioF !== '' && precioF !== null;
      var esTituloVehiculo = prodF && !cantF && (precioF === '' || precioF === null);
      if (esItemCompleto || esTituloVehiculo) {
        hoja.getRange(filaReal, 6, 1,
            ULTIMA_COLUMNA_TOLERANCIA - 6 + 1).clearContent();
      }
    }
  }

  // ── Regenerar el historial y el saldo de esta hoja ──
  if (procesadas > 0) {
    _actualizarHojaIndividual(SpreadsheetApp.getActiveSpreadsheet(),
                               String(idCliente));
  }

  // ── Mensaje de resultado ──
  var mensaje = '✔ ' + procesadas + ' ítem(s) cargado(s) correctamente.';
  if (ignoradasPorIncompletas > 0) {
    mensaje += '\n\n⚠️ ' + ignoradasPorIncompletas + ' fila(s) quedaron ' +
        'incompletas (les falta Cantidad, Producto o Precio) y ' +
        'NO se procesaron. Complétalas y vuelve a procesar.';
  }
  if (procesadas === 0 && ignoradasPorIncompletas === 0) {
    mensaje = 'No había ítems nuevos para procesar en esta hoja.';
  }
  SpreadsheetApp.getUi().alert(mensaje);
}

// ═══════════════════════════════════════════════════════════════════
//  MENÚ PERSONALIZADO "📤 ALEXMAR" — aparece al abrir el Sheets
// ═══════════════════════════════════════════════════════════════════
function onOpen() {
  SpreadsheetApp.getUi()
      .createMenu('📤 ALEXMAR')
      .addItem('Procesar carga de esta hoja (clientes)', 'procesarCargaCliente')
      .addItem('🗑️ Vaciar cuenta de este cliente', 'vaciarCuentaCliente')
      .addSeparator()
      .addItem('📦 Procesar inventario de esta hoja', 'procesarInventarioCliente')
      .addItem('📦 Nueva categoría de inventario', 'crearPestanaInventario')
      .addSeparator()
      .addItem('🔄 Actualizar formato de TODAS las hojas de cliente',
               'actualizarFormatoTodasLasHojas')
      .addToUi();
}

// ═══════════════════════════════════════════════════════════════════
//  CREAR HOJA INDIVIDUAL AL AGREGAR UN CLIENTE NUEVO (v7.0)
// ═══════════════════════════════════════════════════════════════════
//
//  Antes la hoja individual solo se creaba al llegar el primer cargo.
//  Ahora se crea EN EL MOMENTO en que el cliente se da de alta en la
//  pestaña CLIENTES (aunque su saldo sea $0), para que el dueño pueda
//  ir directo a "buscar la pestaña de Juan" y cargar sus ítems ahí,
//  sin tener que esperar ni crear nada manualmente primero.
//
function _crearHojaSiNuevoCliente(idCliente) {
  var libro = SpreadsheetApp.getActiveSpreadsheet();
  _actualizarHojaIndividual(libro, idCliente); // Sin movimientos = hoja vacía y lista
}

// ═══════════════════════════════════════════════════════════════════
//  CREAR HOJAS INDIVIDUALES PARA TODOS LOS CLIENTES YA EXISTENTES
//  (ejecutar UNA vez a mano, después de instalar el parche D6)
// ═══════════════════════════════════════════════════════════════════
//
//  Si ya cargaste clientes ANTES de tener la carga rápida por hoja
//  (ej: tus 56 clientes), esta función recorre la pestaña CLIENTES
//  y crea la pestaña individual de cada uno que aún no la tenga.
//  No borra ni toca nada existente — solo agrega las que faltan.
//
function crearHojasParaClientesExistentes() {
  var inicio = new Date().getTime();
  var limiteMs = 5 * 60 * 1000; // Cortar a los 5 min (deja margen al límite de 6)

  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var hojaClientes = libro.getSheetByName('CLIENTES');
  if (!hojaClientes || hojaClientes.getLastRow() <= 1) {
    SpreadsheetApp.getUi().alert('No hay clientes cargados todavía.');
    return;
  }

  var encCli = ESQUEMA['CLIENTES'];
  var posId = encCli.indexOf('ID_Cliente');
  var datos = hojaClientes.getRange(2, 1, hojaClientes.getLastRow() - 1,
                                      encCli.length).getValues();

  // ★ OPTIMIZACIÓN ★: construir el mapa de IDs ya existentes UNA
  // sola vez (antes se recorrían todas las hojas POR CADA cliente,
  // lo que se vuelve lentísimo con muchas pestañas ya creadas).
  var idsConHoja = {};
  var hojas = libro.getSheets();
  for (var h = 0; h < hojas.length; h++) {
    try {
      var idEnZ1 = hojas[h].getRange('Z1').getValue();
      if (idEnZ1) idsConHoja[String(idEnZ1)] = true;
    } catch (e) { /* hoja sin esa celda, seguir */ }
  }

  var creadas = 0, yaExistian = 0, saltadas = 0, cortado = false;
  for (var i = 0; i < datos.length; i++) {
    // Si nos acercamos al límite de tiempo, parar limpiamente
    if (new Date().getTime() - inicio > limiteMs) {
      cortado = true;
      break;
    }

    var idCliente = datos[i][posId];
    if (!idCliente) { saltadas++; continue; }

    if (idsConHoja[String(idCliente)]) {
      yaExistian++;
    } else {
      _actualizarHojaIndividual(libro, String(idCliente));
      idsConHoja[String(idCliente)] = true; // Marcar como ya hecha
      creadas++;
    }
  }

  var mensaje = '✔ ' + (cortado ? 'Avance parcial (se acabó el tiempo).' : 'Listo, terminado completo.') +
      '\n\nHojas creadas: ' + creadas +
      '\nYa existían: ' + yaExistian +
      '\nFilas sin ID (saltadas): ' + saltadas;
  if (cortado) {
    mensaje += '\n\n⚠️ Vuelve a ejecutar esta misma función para ' +
        'continuar con los que faltan (no repetirá los ya hechos).';
  }
  SpreadsheetApp.getUi().alert(mensaje);
}

// ═══════════════════════════════════════════════════════════════════
//  REFRESCAR TODAS LAS HOJAS DE CLIENTE (ejecutar UNA vez a mano)
// ═══════════════════════════════════════════════════════════════════
//
//  Si actualizaste el diseño de la zona de carga (por ejemplo, pasó
//  de 4 a 3 columnas) y tienes hojas de cliente creadas ANTES de ese
//  cambio, esta función las regenera TODAS de un golpe para que
//  tomen el formato nuevo. No borra ni pierde ningún cargo/abono
//  existente — solo redibuja el membrete, la zona de carga y el
//  historial desde cero usando los datos de DETALLE_CUENTAS.
//
function refrescarTodasLasHojasDeCliente() {
  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var hojaClientes = libro.getSheetByName('CLIENTES');
  if (!hojaClientes || hojaClientes.getLastRow() <= 1) {
    SpreadsheetApp.getUi().alert('No hay clientes cargados todavía.');
    return;
  }

  var inicio = new Date().getTime();
  var limiteMs = 5 * 60 * 1000; // Cortar a los 5 min, igual que antes

  var encCli = ESQUEMA['CLIENTES'];
  var posId = encCli.indexOf('ID_Cliente');
  var datos = hojaClientes.getRange(2, 1, hojaClientes.getLastRow() - 1,
                                      encCli.length).getValues();

  var refrescadas = 0, saltadas = 0, cortado = false;
  for (var i = 0; i < datos.length; i++) {
    if (new Date().getTime() - inicio > limiteMs) {
      cortado = true;
      break;
    }
    var idCliente = datos[i][posId];
    if (!idCliente) { saltadas++; continue; }
    _actualizarHojaIndividual(libro, String(idCliente));
    refrescadas++;
  }

  var mensaje = '✔ Refrescadas: ' + refrescadas + '\nSin ID (saltadas): ' + saltadas;
  if (cortado) {
    mensaje += '\n\n⚠️ Se cortó por tiempo. Ejecuta la función de nuevo ' +
        'para continuar con las que faltan (no repite las ya hechas ' +
        'en esta misma corrida, pero si la cierras y la corres de nuevo ' +
        'sí las repetirá — no hay problema, solo redibuja).';
  }
  SpreadsheetApp.getUi().alert(mensaje);
}

// ═══════════════════════════════════════════════════════════════════
//  FORZAR ACTUALIZACIÓN DE TODAS LAS HOJAS DE CLIENTE (ejecutar UNA
//  vez después de instalar el parche F2, para que las hojas creadas
//  ANTES de este parche tomen el nuevo formato de zona de carga)
// ═══════════════════════════════════════════════════════════════════
//
//  No borra ni toca el historial de nadie — solo vuelve a dibujar
//  cada hoja (membrete + zona de carga + historial) con el diseño
//  más reciente. Es exactamente lo mismo que pasa automáticamente
//  cuando llega un cargo nuevo, solo que aquí lo disparamos a mano
//  para TODAS las hojas de una vez.
//
function actualizarFormatoTodasLasHojas() {
  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var hojas = libro.getSheets();
  var actualizadas = 0, saltadas = 0;

  for (var h = 0; h < hojas.length; h++) {
    var idEnZ1;
    try {
      idEnZ1 = hojas[h].getRange('Z1').getValue();
    } catch (e) {
      idEnZ1 = null;
    }
    if (!idEnZ1) { saltadas++; continue; } // No es hoja de cliente

    _actualizarHojaIndividual(libro, String(idEnZ1));
    actualizadas++;
  }

  SpreadsheetApp.getUi().alert(
    '✔ Formato actualizado.\n\n' +
    'Hojas de cliente actualizadas: ' + actualizadas + '\n' +
    'Pestañas técnicas saltadas: ' + saltadas
  );
}

// ═══════════════════════════════════════════════════════════════════
//  VACIAR CUENTA DE UN CLIENTE (botón del menú "📤 ALEXMAR")
// ═══════════════════════════════════════════════════════════════════
//
//  Borra (marca como eliminadas) TODAS las líneas de DETALLE_CUENTAS
//  del cliente cuya hoja está activa en este momento. Útil cuando
//  una carga masiva salió mal (ej: error de suma del Excel viejo) y
//  el dueño prefiere empezar esa cuenta de cero en vez de corregir
//  línea por línea.
//
//  SEGURIDAD: no borra físicamente las filas — las marca con
//  Eliminado = SI (igual que el botón de papelera de la app), así
//  queda registro por si hace falta revisar después. El cliente y
//  su hoja individual NO se tocan, solo su historial de movimientos.
//
//  Pide confirmación explícita antes de actuar, porque es una acción
//  que afecta muchas líneas de una vez.
//
function vaciarCuentaCliente() {
  var hoja = SpreadsheetApp.getActiveSheet();
  var idCliente = hoja.getRange('Z1').getValue();

  if (!idCliente) {
    SpreadsheetApp.getUi().alert(
        '⚠️ Esta no es una hoja de cliente.\n\n' +
        'Ve a la pestaña del cliente cuya cuenta quieres vaciar ' +
        'y vuelve a intentar.');
    return;
  }

  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var hojaDetalle = libro.getSheetByName('DETALLE_CUENTAS');
  if (!hojaDetalle || hojaDetalle.getLastRow() <= 1) {
    SpreadsheetApp.getUi().alert('Este cliente no tiene movimientos cargados.');
    return;
  }

  var encDet = ESQUEMA['DETALLE_CUENTAS'];
  var posIdCliente = encDet.indexOf('ID_Cliente');
  var posEliminado = encDet.indexOf('Eliminado');
  var posFechaMod = encDet.indexOf('Fecha_Modificacion');
  var ultimaFila = hojaDetalle.getLastRow();
  var datos = hojaDetalle.getRange(2, 1, ultimaFila - 1, encDet.length).getValues();

  // Contar cuántas líneas activas tiene este cliente (para el aviso)
  var lineasDelCliente = 0;
  for (var i = 0; i < datos.length; i++) {
    if (String(datos[i][posIdCliente]) === String(idCliente)) {
      var elim = String(datos[i][posEliminado]).toUpperCase();
      if (elim !== 'SI' && elim !== 'TRUE') lineasDelCliente++;
    }
  }

  if (lineasDelCliente === 0) {
    SpreadsheetApp.getUi().alert('Este cliente no tiene movimientos activos para vaciar.');
    return;
  }

  // ── Confirmación explícita: acción que afecta muchas líneas ──
  var nombreCliente = hoja.getRange('A2').getValue(); // "Cliente: NOMBRE"
  var respuesta = SpreadsheetApp.getUi().alert(
      '⚠️ VACIAR CUENTA COMPLETA',
      'Vas a ELIMINAR los ' + lineasDelCliente + ' movimiento(s) de:\n\n' +
      nombreCliente + '\n\n' +
      'Esta acción se reflejará también en las apps (PC y teléfono) ' +
      'en su próximo ciclo de sincronización.\n\n' +
      '¿Confirmas que quieres vaciar esta cuenta?',
      SpreadsheetApp.getUi().ButtonSet.YES_NO);

  if (respuesta !== SpreadsheetApp.getUi().Button.YES) {
    return; // El usuario canceló, no se toca nada
  }

  // ── Marcar como eliminadas todas las líneas de este cliente ──
  var ahora = new Date().toISOString();
  var marcadas = 0;
  for (var j = 0; j < datos.length; j++) {
    if (String(datos[j][posIdCliente]) === String(idCliente)) {
      var elimActual = String(datos[j][posEliminado]).toUpperCase();
      if (elimActual !== 'SI' && elimActual !== 'TRUE') {
        datos[j][posEliminado] = 'SI';
        datos[j][posFechaMod] = ahora;
        marcadas++;
      }
    }
  }
  // Escribir todo de un solo golpe (rápido, sin importar cuántas filas)
  hojaDetalle.getRange(2, 1, datos.length, encDet.length).setValues(datos);

  // ── Regenerar la hoja individual: ahora debe verse en $0 ──
  _actualizarHojaIndividual(libro, String(idCliente));

  SpreadsheetApp.getUi().alert(
      '✔ Cuenta vaciada.\n\n' +
      marcadas + ' movimiento(s) eliminado(s).\n' +
      'El saldo de ' + nombreCliente + ' ahora está en $0.\n\n' +
      'Ya puedes recargar los ítems correctos en la zona naranja.');
}

// ═══════════════════════════════════════════════════════════════════
//  SISTEMA DE INVENTARIO POR MARCAS/CATEGORÍAS (v1.0)
// ═══════════════════════════════════════════════════════════════════
//
//  14 pestañas de inventario, cada una con:
//  · Zona de carga (A-D, misma lógica que clientes pero más simple):
//    PRODUCTO | PRECIO PÚBLICO | PRECIO COMPRA | UNIDADES
//  · Lectura tolerante: si al pegar viene una columna vacía en el
//    medio (como la columna C de tu Excel viejo), la ignora sola.
//  · Solo PRODUCTO y PRECIO PÚBLICO son obligatorios.
//  · Todo lo demás puede faltar sin error.
//
//  Al presionar "📤 ALEXMAR → Procesar inventario de esta hoja",
//  los ítems se mandan a la tabla técnica INVENTARIO con su
//  Categoria (Ford, Chevrolet, etc.) como campo adicional.
//
// ═══════════════════════════════════════════════════════════════════

// Lista maestra de todas las categorías/marcas del inventario.
// Para AGREGAR una categoría: ejecutar crearPestanaInventario('NUEVA')
// Para QUITAR una categoría: borrar la pestaña manualmente en Sheets
//   (los productos ya cargados en INVENTARIO se conservan intactos).
var CATEGORIAS_INVENTARIO = [
  'FORD',
  'CHEVROLET',
  'TOYOTA',
  'HYUNDAI',
  'RENAULT',
  'CHERY',
  'FIAT',
  'DONGFENG-JAC-FOTON',
  'MACK-IVECO-ENCAVA',
  'GENERICO-UNIVERSAL',
  'ILUMINACION AUTOMOTRIZ',
  'SISTEMA ELECTRICO',
  'CUIDADO Y ESTETICA',
  'ACCESORIOS INT-EXT'
];

// ───────────────────────────────────────────────────────────────────
//  CREAR/REGENERAR una pestaña de inventario individual
// ───────────────────────────────────────────────────────────────────
function _crearPestanaInventario(libro, categoria) {
  var nombrePestana = categoria.substring(0, 95).trim();

  // Buscar si ya existe (por nombre)
  var hoja = libro.getSheetByName(nombrePestana);
  if (!hoja) {
    hoja = libro.insertSheet(nombrePestana);
  }

  // ── Encabezado de la categoría ──
  hoja.getRange('A1').setValue('📦 INVENTARIO · ' + categoria)
      .setFontWeight('bold').setFontSize(12).setFontColor('#FF6B00');
  hoja.getRange('A1:D1').merge();

  // ── Zona de carga (igual a zona naranja de clientes pero sin Z1) ──
  hoja.getRange('A2').setValue(
      '⬇ ESCRIBE/PEGA AQUÍ (columna vacía al pegar = ignorada) · ' +
      'LUEGO "📤 ALEXMAR → Procesar inventario de esta hoja" ⬇')
      .setFontColor('#FF6B00').setFontWeight('bold').setFontSize(9);
  hoja.getRange('A2:D2').merge();

  // Encabezados de columna (zona de carga)
  hoja.getRange('A3').setValue('Producto o Servicio');
  hoja.getRange('B3').setValue('Precio Público ($)');
  hoja.getRange('C3').setValue('Precio Compra ($)');
  hoja.getRange('D3').setValue('Unidades Disponibles');
  hoja.getRange('A3:D3')
      .setBackground('#0D0D0D').setFontColor('#00E5FF').setFontWeight('bold');

  // Fila de ejemplo en gris (fila 4)
  hoja.getRange('A4:D4').setValues([['Ej: Filtro de aceite', 15, 8, 10]])
      .setFontColor('#999999').setFontStyle('italic');

  // Filas 5-34: zona libre para escribir/pegar (30 filas de espacio)
  var ZONA_ULTIMA = 34;
  hoja.getRange('A2:D' + ZONA_ULTIMA)
      .setBorder(true, true, true, true, true, true);
  hoja.getRange('A5:D' + ZONA_ULTIMA).setBackground('#FFFFFF');

  // Aviso debajo de la zona de carga
  var filaAviso = ZONA_ULTIMA + 1;
  hoja.getRange(filaAviso, 1)
      .setValue('👉 Cuando termines, usa el menú "📤 ALEXMAR" → ' +
                '"Procesar inventario de esta hoja"')
      .setFontColor('#1B8A3A').setFontStyle('italic').setFontSize(9);
  hoja.getRange(filaAviso, 1, 1, 4).merge();

  // Separador visual
  hoja.getRange(filaAviso + 2, 1).setValue('▼ PRODUCTOS YA CARGADOS ▼')
      .setFontWeight('bold').setFontColor('#FFFFFF')
      .setBackground('#0D0D0D');
  hoja.getRange(filaAviso + 2, 1, 1, 4).merge();

  // Encabezados del historial (lo que ya está en INVENTARIO)
  var filaHistorial = filaAviso + 3;
  hoja.getRange(filaHistorial, 1, 1, 5).setValues([[
    'ID_Producto', 'Producto', 'P.Público', 'P.Compra', 'Unidades'
  ]]).setBackground('#1A1A2E').setFontColor('#00E5FF').setFontWeight('bold');

  // Anchos de columna prolijos
  hoja.setColumnWidth(1, 300); // Producto
  hoja.setColumnWidth(2, 120); // Precio Público
  hoja.setColumnWidth(3, 120); // Precio Compra
  hoja.setColumnWidth(4, 130); // Unidades

  // Guardar la categoría en una celda de control (columna F, fila 1)
  // para que el procesador sepa a qué categoría pertenece esta hoja
  hoja.getRange('F1').setValue(categoria);
  hoja.hideColumns(6); // Ocultar columna F (control interno)

  return hoja;
}

// ───────────────────────────────────────────────────────────────────
//  INICIALIZAR TODAS las pestañas de inventario de una vez
//  (ejecutar UNA vez a mano, o cuando se añade una categoría nueva)
// ───────────────────────────────────────────────────────────────────
function inicializarPestanasInventario() {
  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var creadas = 0, yaExistian = 0;

  for (var i = 0; i < CATEGORIAS_INVENTARIO.length; i++) {
    var categoria = CATEGORIAS_INVENTARIO[i];
    var existe = libro.getSheetByName(categoria);
    _crearPestanaInventario(libro, categoria);
    if (existe) yaExistian++; else creadas++;
  }

  // Regenerar el historial de cada pestaña con lo que ya hay en INVENTARIO
  _refrescarHistorialesInventario(libro);

  SpreadsheetApp.getUi().alert(
    '✔ Pestañas de inventario listas.\n\n' +
    'Creadas: ' + creadas + '\n' +
    'Ya existían (actualizadas): ' + yaExistian + '\n\n' +
    'Ahora puedes pegar tus productos en cada pestaña y usar\n' +
    '"📤 ALEXMAR → Procesar inventario de esta hoja".'
  );
}

// ───────────────────────────────────────────────────────────────────
//  CREAR UNA NUEVA categoría de inventario manualmente
//  (cuando quieras añadir una marca que no estaba en la lista)
// ───────────────────────────────────────────────────────────────────
function crearPestanaInventario(nombreCategoria) {
  var libro = SpreadsheetApp.getActiveSpreadsheet();
  if (!nombreCategoria) {
    var ui = SpreadsheetApp.getUi();
    var resp = ui.prompt('Nueva categoría de inventario',
        'Escribe el nombre de la nueva marca o categoría:', ui.ButtonSet.OK_CANCEL);
    if (resp.getSelectedButton() !== ui.Button.OK) return;
    nombreCategoria = resp.getResponseText().trim().toUpperCase();
    if (!nombreCategoria) { ui.alert('⚠️ El nombre no puede estar vacío.'); return; }
  }
  _crearPestanaInventario(libro, nombreCategoria);
  SpreadsheetApp.getUi().alert(
    '✔ Pestaña "' + nombreCategoria + '" creada.\n\n' +
    'Ya puedes pegar tus productos ahí y usar\n' +
    '"📤 ALEXMAR → Procesar inventario de esta hoja".'
  );
}

// ───────────────────────────────────────────────────────────────────
//  PROCESAR INVENTARIO de la hoja activa → tabla técnica INVENTARIO
// ───────────────────────────────────────────────────────────────────
function procesarInventarioCliente() {
  var hoja = SpreadsheetApp.getActiveSheet();
  // Leer la categoría de la celda de control F1
  var categoria = String(hoja.getRange('F1').getValue()).trim();
  if (!categoria) {
    SpreadsheetApp.getUi().alert(
        '⚠️ Esta no es una pestaña de inventario.\n\n' +
        'Ve a la pestaña de la marca/categoría donde quieres ' +
        'procesar y vuelve a intentar.');
    return;
  }

  var ZONA_PRIMERA_FILA = 4; // Incluye la fila de ejemplo
  var ZONA_ULTIMA_FILA = 34;
  // Leer un rango ANCHO (A hasta M) para tolerancia de columnas vacías
  // (igual que en los clientes: si pegan con columna C vacía, la ignora)
  var ULTIMA_COL_TOLERANCIA = 13;
  var filasZonaCruda = hoja.getRange(ZONA_PRIMERA_FILA, 1,
      ZONA_ULTIMA_FILA - ZONA_PRIMERA_FILA + 1,
      ULTIMA_COL_TOLERANCIA).getValues();

  // ★ LECTURA TOLERANTE ★ — por cada fila, busca:
  // 1er texto → Producto, 1er número → Precio Público,
  // 2do número → Precio Compra, 3er número → Unidades.
  // Cualquier columna vacía en el medio se ignora automáticamente.
  var filasZona = filasZonaCruda.map(function(filaCruda) {
    var producto = '', numeros = [];
    for (var c = 0; c < filaCruda.length; c++) {
      var v = filaCruda[c];
      if (v === '' || v === null) continue;
      if (typeof v === 'number') {
        numeros.push(v);
      } else if (!producto) {
        producto = String(v).trim();
      }
    }
    return {
      producto: producto,
      precioPublico: numeros.length >= 1 ? numeros[0] : '',
      precioCompra: numeros.length >= 2 ? numeros[1] : '',
      unidades: numeros.length >= 3 ? numeros[2] : ''
    };
  });

  var libro = SpreadsheetApp.getActiveSpreadsheet();
  var hojaInv = libro.getSheetByName('INVENTARIO');
  if (!hojaInv) {
    hojaInv = libro.insertSheet('INVENTARIO');
    _escribirEncabezados(hojaInv, ESQUEMA['INVENTARIO']);
  }

  var ahora = new Date().toISOString();
  var encInv = ESQUEMA['INVENTARIO'];
  var nuevasFilas = [], procesadas = 0, incompletas = 0;

  for (var i = 0; i < filasZona.length; i++) {
    var f = filasZona[i];

    // Saltar la fila de ejemplo
    if (f.producto.indexOf('Ej:') === 0) continue;
    // Saltar filas vacías
    if (!f.producto && f.precioPublico === '' && f.precioCompra === '') continue;

    // Solo PRODUCTO y PRECIO PÚBLICO son obligatorios
    if (!f.producto || f.precioPublico === '' || f.precioPublico === null) {
      incompletas++;
      continue;
    }

    var nuevaFila = encInv.map(function(col) {
      switch (col) {
        case 'ID_Producto': return Utilities.getUuid();
        case 'Categoria': return categoria;
        case 'Nombre_Producto': return f.producto;
        case 'Precio_Publico': return f.precioPublico;
        case 'Precio_Compra': return f.precioCompra !== '' ? f.precioCompra : '';
        case 'Unidades_Disponibles': return f.unidades !== '' ? f.unidades : '';
        case 'Eliminado': return 'NO';
        case 'Fecha_Creacion': return ahora;
        case 'Fecha_Modificacion': return ahora;
        default: return '';
      }
    });
    nuevasFilas.push(nuevaFila);
    procesadas++;
  }

  // Escribir todo de un golpe
  if (nuevasFilas.length > 0) {
    hojaInv.getRange(hojaInv.getLastRow() + 1, 1,
        nuevasFilas.length, encInv.length).setValues(nuevasFilas);
  }

  // Limpiar la zona de carga (solo las filas procesadas)
  if (procesadas > 0) {
    for (var f2 = 0; f2 < filasZona.length; f2++) {
      var filaReal = ZONA_PRIMERA_FILA + f2;
      var item = filasZona[f2];
      if (item.producto.indexOf('Ej:') === 0) continue;
      if (item.producto && item.precioPublico !== '' && item.precioPublico !== null) {
        hoja.getRange(filaReal, 1, 1, ULTIMA_COL_TOLERANCIA).clearContent();
      }
    }
    // Regenerar el historial visible de esta pestaña
    _refrescarHistorialPestana(libro, hoja, categoria);
  }

  var mensaje = '✔ ' + procesadas + ' producto(s) cargado(s) en INVENTARIO.';
  if (incompletas > 0) {
    mensaje += '\n\n⚠️ ' + incompletas + ' fila(s) incompletas (les falta ' +
        'Producto o Precio Público) y NO se procesaron.';
  }
  if (procesadas === 0 && incompletas === 0) {
    mensaje = 'No había productos nuevos para procesar en esta hoja.';
  }
  SpreadsheetApp.getUi().alert(mensaje);
}

// ───────────────────────────────────────────────────────────────────
//  REFRESCAR el historial visible de UNA pestaña de inventario
// ───────────────────────────────────────────────────────────────────
function _refrescarHistorialPestana(libro, hoja, categoria) {
  var hojaInv = libro.getSheetByName('INVENTARIO');
  if (!hojaInv || hojaInv.getLastRow() <= 1) return;

  var encInv = ESQUEMA['INVENTARIO'];
  var posCat = encInv.indexOf('Categoria');
  var posId = encInv.indexOf('ID_Producto');
  var posNom = encInv.indexOf('Nombre_Producto');
  var posPvp = encInv.indexOf('Precio_Publico');
  var posCosto = encInv.indexOf('Precio_Compra');
  var posStock = encInv.indexOf('Unidades_Disponibles');
  var posElim = encInv.indexOf('Eliminado');

  var datos = hojaInv.getRange(2, 1, hojaInv.getLastRow() - 1,
      encInv.length).getValues();

  var productosCategoria = datos.filter(function(fila) {
    return String(fila[posCat]).toUpperCase() === categoria.toUpperCase() &&
           String(fila[posElim]).toUpperCase() !== 'SI';
  });

  // Borrar el historial viejo y redibujarlo
  // El historial empieza en la fila 38 (34 zona de carga + 4 de separador)
  var FILA_HISTORIAL_DATOS = 39;
  var ultimaFilaHoja = hoja.getLastRow();
  if (ultimaFilaHoja >= FILA_HISTORIAL_DATOS) {
    hoja.getRange(FILA_HISTORIAL_DATOS, 1,
        ultimaFilaHoja - FILA_HISTORIAL_DATOS + 1, 5).clearContent()
        .setBackground(null).setFontColor(null).setFontStyle(null);
  }

  if (productosCategoria.length === 0) return;

  var filas = productosCategoria.map(function(fila) {
    return [
      fila[posId],
      fila[posNom],
      fila[posPvp],
      fila[posCosto],
      fila[posStock]
    ];
  });
  hoja.getRange(FILA_HISTORIAL_DATOS, 1, filas.length, 5)
      .setValues(filas);
}

// ───────────────────────────────────────────────────────────────────
//  REFRESCAR los historiales de TODAS las pestañas de inventario
// ───────────────────────────────────────────────────────────────────
function _refrescarHistorialesInventario(libro) {
  var hojas = libro.getSheets();
  for (var h = 0; h < hojas.length; h++) {
    var cat;
    try { cat = String(hojas[h].getRange('F1').getValue()).trim(); }
    catch(e) { cat = ''; }
    if (!cat) continue;
    _refrescarHistorialPestana(libro, hojas[h], cat);
  }
}
