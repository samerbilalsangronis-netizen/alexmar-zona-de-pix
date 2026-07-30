import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/cliente.dart';
import '../../domain/entities/linea_cuenta.dart';

/// ─────────────────────────────────────────────────────────────────
/// GENERADOR DE FACTURA PDF · "Autoperiquitos y Rotulados Alexmar"
///
/// 👶 EXPLICACIÓN: El paquete `pdf` nos deja "dibujar" un documento
/// con widgets parecidos a los de Flutter (pw.Column, pw.Text...).
/// El PDF es para el CLIENTE, así que aquí usamos una estética
/// FORMAL Y ELEGANTE: papel blanco profesional, cabecera en carbón
/// con "ALEXMAR" en blanco grande y centrado, azul marino como color
/// de acento (más serio que naranja), con el LOGO real del negocio.
/// El archivo se devuelve como bytes en memoria y el motor de
/// cobranza lo comparte por WhatsApp o lo descarga en el navegador.
///
/// ★ FASE 10 · FACTURA RÁPIDA ★
/// Ahora hay DOS puertas de entrada al MISMO diseño:
///  · generar(...)       → la de siempre: recibe un Cliente registrado.
///    (NADA cambió para el resto de la app: misma firma, mismo PDF.)
///  · generarManual(...) → recibe los datos escritos A MANO (cliente
///    ocasional de mostrador que no está en la base de datos).
/// Ambas llaman por dentro a _construir(), que es el dibujo único.
/// Así el formato es EXACTAMENTE el mismo en los dos casos.
/// ─────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════
// PALETA FORMAL (v2 · más elegante y menos escandalosa)
// ══════════════════════════════════════════════════════════════════
const _carbon = PdfColor.fromInt(0xFF0D0D0D);         // Membrete
const _azulMarino = PdfColor.fromInt(0xFF003366);     // Acento formal
const _grisLinea = PdfColor.fromInt(0xFFDDDDDD);      // Bordes suaves
const _grisFondo = PdfColor.fromInt(0xFFF8F9FA);      // Fondo contacto
const _grisTexto = PdfColor.fromInt(0xFF666666);      // Etiquetas
const _verdeAbono = PdfColor.fromInt(0xFFE6F9F0);     // Fondo abonos
const _verdeTexto = PdfColor.fromInt(0xFF0B6E3F);     // Texto abonos

String _fmt(double v) {
  // Formato $1,234.50 sin depender de intl dentro del PDF
  final negativo = v < 0;
  final s = v.abs().toStringAsFixed(2);
  final partes = s.split('.');
  final entero = partes[0];
  final buffer = StringBuffer();
  for (var i = 0; i < entero.length; i++) {
    final restantes = entero.length - i;
    buffer.write(entero[i]);
    if (restantes > 1 && (restantes - 1) % 3 == 0) buffer.write(',');
  }
  return '${negativo ? '-' : ''}\$${buffer.toString()}.${partes[1]}';
}

String _fecha(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

class FacturaPdf {
  /// 👶 CAMBIO PARA WEB: antes guardábamos el PDF en el disco y
  /// devolvíamos el archivo. Ahora devolvemos los BYTES (el contenido
  /// puro del PDF en memoria), porque el navegador no tiene disco.
  /// Quien lo recibe (el motor de cobranza) decide cómo entregarlo:
  /// bandeja de compartir en el celular, descarga en el navegador.
  static Future<Uint8List> generar({
    required Cliente cliente,
    required List<LineaCuenta> lineas,
    required ResumenCuenta resumen,
  }) {
    // La puerta de siempre: desarma el Cliente registrado y pasa
    // sus datos al dibujo único. Cero cambios para quien la llama.
    return _construir(
      nombre: cliente.nombre,
      cedula: cliente.cedula,
      telefono: cliente.telefono,
      direccion: cliente.direccion,
      facturaN: '${cliente.facturaN}',
      etiquetaDocumento: 'ESTADO DE CUENTA',
      lineas: lineas,
      resumen: resumen,
    );
  }

  /// ★ FASE 10 ★ — La puerta NUEVA para la FACTURA RÁPIDA de
  /// mostrador: recibe los datos tal como se escribieron a mano,
  /// sin necesitar un Cliente guardado en la base de datos.
  ///
  /// 👶 Sirve para DOS documentos con el MISMO diseño:
  ///  · FACTURA  → venta ya hecha. Puede mostrar lo pagado y el
  ///    saldo pendiente.
  ///  · PROFORMA → presupuesto/cotización. NO es una venta todavía:
  ///    no muestra "abonado", el total final se llama "TOTAL A PAGAR"
  ///    y lleva una nota de que es una cotización sin validez fiscal.
  /// La pantalla decide cuál mandar con estos parámetros; el dibujo
  /// interno es exactamente el mismo.
  static Future<Uint8List> generarManual({
    required String nombre,
    String? cedula,
    String? telefono,
    String? direccion,
    required String facturaN,
    required List<LineaCuenta> lineas,
    required ResumenCuenta resumen,
    String etiquetaDocumento = 'FACTURA DE VENTA',
    String etiquetaTotalFinal = 'SALDO PENDIENTE',
    bool mostrarAbonos = true,
    String? notaPie,
  }) {
    return _construir(
      nombre: nombre,
      cedula: (cedula != null && cedula.trim().isEmpty) ? null : cedula,
      telefono: (telefono != null && telefono.trim().isEmpty) ? null : telefono,
      direccion:
          (direccion != null && direccion.trim().isEmpty) ? null : direccion,
      facturaN: facturaN,
      etiquetaDocumento: etiquetaDocumento,
      etiquetaTotalFinal: etiquetaTotalFinal,
      mostrarAbonos: mostrarAbonos,
      notaPie: notaPie,
      lineas: lineas,
      resumen: resumen,
    );
  }

  /// El DIBUJO ÚNICO del documento. Aquí vive todo el diseño formal.
  /// Las dos puertas de arriba solo le entregan los datos.
  static Future<Uint8List> _construir({
    required String nombre,
    String? cedula,
    String? telefono,
    String? direccion,
    required String facturaN,
    required String etiquetaDocumento,
    required List<LineaCuenta> lineas,
    required ResumenCuenta resumen,
    String etiquetaTotalFinal = 'SALDO PENDIENTE',
    bool mostrarAbonos = true,
    String? notaPie,
  }) async {
    final doc = pw.Document();

    // ── Cargar el logo REAL del negocio desde assets ──
    // Está en assets/icon/app_icon.png (mismo que usa la app)
    pw.MemoryImage? logoNegocio;
    try {
      final logoData = await rootBundle.load('assets/icon/app_icon.png');
      logoNegocio = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {
      // Si por alguna razón no se puede cargar, seguimos sin logo
      logoNegocio = null;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            'AUTOPERIQUITOS Y ROTULADOS ALEXMAR · Página ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (ctx) => [
          // ══════════════════════════════════════════════════════════
          // MEMBRETE PROFESIONAL (logo + nombre centrado + factura)
          // ══════════════════════════════════════════════════════════
          pw.Container(
            padding: const pw.EdgeInsets.all(18),
            decoration: const pw.BoxDecoration(
              color: _carbon,
              border: pw.Border(
                bottom: pw.BorderSide(color: _azulMarino, width: 2.5),
              ),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ── Logo real del negocio ──
                pw.Container(
                  width: 72,
                  height: 72,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(color: _azulMarino, width: 1.5),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  padding: const pw.EdgeInsets.all(3),
                  child: logoNegocio != null
                      ? pw.Image(logoNegocio, fit: pw.BoxFit.contain)
                      : pw.Center(
                          child: pw.Text(
                            'A',
                            style: pw.TextStyle(
                              color: _azulMarino,
                              fontSize: 40,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                pw.SizedBox(width: 16),
                // ── Nombre del negocio (centrado) ──
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        'AUTOPERIQUITOS Y ROTULADOS',
                        style: pw.TextStyle(
                          color: PdfColors.grey300,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.normal,
                          letterSpacing: 2,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'ALEXMAR',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                // ── Recuadro de Factura Nº ──
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: _azulMarino, width: 1.5),
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            etiquetaDocumento,
                            style: pw.TextStyle(
                              color: PdfColors.grey400,
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'FACTURA Nº $facturaN',
                            style: pw.TextStyle(
                              color: _azulMarino,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Emitido: ${_fecha(DateTime.now())}',
                      style: const pw.TextStyle(
                        color: PdfColors.grey400,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ══════════════════════════════════════════════════════════
          // BANDA DE CONTACTO DEL NEGOCIO
          // ══════════════════════════════════════════════════════════
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            color: _grisFondo,
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'UBICACIÓN',
                        style: pw.TextStyle(
                          fontSize: 7,
                          color: _grisTexto,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Tovar, Edo. Mérida',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: _carbon,
                          fontWeight: pw.FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TELÉFONO',
                        style: pw.TextStyle(
                          fontSize: 7,
                          color: _grisTexto,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '+58 416-676-8393',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: _carbon,
                          fontWeight: pw.FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),

          // ══════════════════════════════════════════════════════════
          // DATOS DEL CLIENTE
          // ══════════════════════════════════════════════════════════
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _grisLinea),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CLIENTE',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: _grisTexto,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        nombre,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: _carbon,
                        ),
                      ),
                      if (cedula != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 3),
                          child: pw.Text(
                            'C.I.: $cedula',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: _grisTexto,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CONTACTO',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: _grisTexto,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Tel: ${telefono ?? '—'}',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: _carbon,
                        ),
                      ),
                      if (direccion != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 3),
                          child: pw.Text(
                            direccion,
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: _grisTexto,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),

          // ══════════════════════════════════════════════════════════
          // TABLA DE MOVIMIENTOS
          // ══════════════════════════════════════════════════════════
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.symmetric(
                inside: const pw.BorderSide(color: _grisLinea, width: .5)),
            headerDecoration: const pw.BoxDecoration(color: _carbon),
            headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1),
            headerAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
            cellStyle: const pw.TextStyle(fontSize: 9.5),
            rowDecoration: const pw.BoxDecoration(),
            headers: [
              'FECHA',
              'CANT.',
              'PRODUCTO / SERVICIO',
              'P. UNIT.',
              'P. TOTAL'
            ],
            data: [
              for (final l in lineas)
                if (l.esTitulo)
                  // ★ TÍTULO DE VEHÍCULO ★ — solo el nombre, centrado
                  // sobre el fondo azul marino, sin cantidad/precio
                  ['', '', '« ${l.descripcion.toUpperCase()} »', '', '']
                else
                  [
                    _fecha(l.fecha),
                    l.esAbono
                        ? '1'
                        : (l.cantidad == l.cantidad.roundToDouble()
                            ? l.cantidad.toInt().toString()
                            : l.cantidad.toString()),
                    l.esAbono ? 'ABONO — ${l.descripcion}' : l.descripcion,
                    l.esAbono ? '—' : _fmt(l.precioUnitario ?? 0),
                    l.esAbono ? '- ${_fmt(l.totalLinea)}' : _fmt(l.totalLinea),
                  ],
            ],
            cellDecoration: (columna, dato, numFila) {
              // numFila 0 = encabezado; los datos empiezan en la fila 1
              final i = numFila - 1;
              if (i >= 0 && i < lineas.length) {
                if (lineas[i].esTitulo) {
                  // Título de vehículo → fondo azul marino formal
                  return const pw.BoxDecoration(color: _azulMarino);
                }
                if (lineas[i].esAbono) {
                  return const pw.BoxDecoration(color: _verdeAbono);
                }
              }
              return const pw.BoxDecoration();
            },
          ),
          pw.SizedBox(height: 18),

          // ══════════════════════════════════════════════════════════
          // TOTALES (fondo azul marino formal)
          // ══════════════════════════════════════════════════════════
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                width: 260,
                child: pw.Column(
                  children: [
                    _filaTotal('TOTAL CONSUMIDO', _fmt(resumen.totalConsumido)),
                    // El "TOTAL ABONADO" solo aparece cuando corresponde
                    // (facturas). En una proforma no hay pago aún, así
                    // que esta fila se oculta para no confundir.
                    if (mostrarAbonos) ...[
                      pw.SizedBox(height: 4),
                      _filaTotal(
                          'TOTAL ABONADO', '- ${_fmt(resumen.totalAbonado)}',
                          color: _verdeTexto),
                    ],
                    pw.Divider(color: _grisLinea),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: const pw.BoxDecoration(color: _azulMarino),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            etiquetaTotalFinal,
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          pw.Text(
                            // En proforma no hay abonos: el "total a
                            // pagar" es simplemente lo consumido.
                            _fmt(mostrarAbonos
                                ? resumen.saldoPendiente
                                : resumen.totalConsumido),
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          // ══════════════════════════════════════════════════════════
          // PIE DE PÁGINA
          // ══════════════════════════════════════════════════════════
          pw.Text(
            'Gracias por su confianza. Todos los montos están expresados en dólares (USD \$).',
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey600),
          ),
          // Nota extra (ej: aviso de que la proforma es una cotización)
          if (notaPie != null && notaPie.trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Text(
                notaPie,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  color: _azulMarino,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );

    return doc.save(); // Los bytes del PDF, listos para compartir
  }

  static pw.Widget _filaTotal(String etiqueta, String valor,
      {PdfColor color = _carbon}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(etiqueta,
            style: pw.TextStyle(
                fontSize: 9, color: PdfColors.grey700, letterSpacing: 1)),
        pw.Text(valor,
            style: pw.TextStyle(
                fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
      ],
    );
  }
}
