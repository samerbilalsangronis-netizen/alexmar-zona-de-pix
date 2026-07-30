import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/cierre_mensual.dart';

/// ─────────────────────────────────────────────────────────────────
/// REPORTE EJECUTIVO ANUAL EN PDF · Para presentar al dueño.
/// Mismo lenguaje visual de la factura: papel blanco profesional con
/// la cabecera carbón/naranja de "Autoperiquitos Alexmar".
/// ─────────────────────────────────────────────────────────────────

const _carbon = PdfColor.fromInt(0xFF0D0D0D);
const _naranja = PdfColor.fromInt(0xFFFF6B00);
const _cian = PdfColor.fromInt(0xFF007C8F);
const _verde = PdfColor.fromInt(0xFF0B7A4B);
const _grisLinea = PdfColor.fromInt(0xFFDDDDDD);

String _fmt(double v) {
  final neg = v < 0;
  final s = v.abs().toStringAsFixed(2);
  final partes = s.split('.');
  final e = partes[0];
  final b = StringBuffer();
  for (var i = 0; i < e.length; i++) {
    final r = e.length - i;
    b.write(e[i]);
    if (r > 1 && (r - 1) % 3 == 0) b.write(',');
  }
  return '${neg ? '-' : ''}\$${b.toString()}.${partes[1]}';
}

class ReporteAnualPdf {
  /// Devuelve los BYTES del informe (compatible con navegador)
  static Future<Uint8List> generar(ResumenAnual resumen) async {
    final doc = pw.Document();
    final cierres = resumen.cierres;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          // ══ CABECERA ══
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(color: _carbon),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('AUTOPERIQUITOS ALEXMAR',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 3)),
                    pw.Text('INFORME EJECUTIVO ANUAL',
                        style: pw.TextStyle(
                            color: _naranja,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 2)),
                  ],
                ),
                pw.Text('${resumen.anio}',
                    style: pw.TextStyle(
                        color: _naranja,
                        fontSize: 34,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          pw.SizedBox(height: 18),

          // ══ KPIs DEL AÑO ══
          pw.Row(children: [
            _kpi('FACTURADO ANUAL', _fmt(resumen.facturadoAnual), _carbon),
            pw.SizedBox(width: 8),
            _kpi('COBRADO ANUAL', _fmt(resumen.cobradoAnual), _verde),
            pw.SizedBox(width: 8),
            _kpi('GANANCIA NETA', _fmt(resumen.gananciaAnual), _naranja),
            pw.SizedBox(width: 8),
            _kpi('EFECTIVIDAD',
                '${resumen.efectividadAnual.toStringAsFixed(1)}%', _cian),
          ]),
          pw.SizedBox(height: 18),

          // ══ DESTACADOS DEL AÑO ══
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _grisLinea),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('DESTACADOS DEL AÑO',
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 2,
                        color: PdfColors.grey700)),
                pw.SizedBox(height: 8),
                if (resumen.mesRecordVentas != null)
                  pw.Bullet(
                      text:
                          'MES RÉCORD EN VENTAS: ${resumen.mesRecordVentas!.nombreMes} '
                          'con ${_fmt(resumen.mesRecordVentas!.totalFacturado)} facturados.',
                      style: const pw.TextStyle(fontSize: 10)),
                if (resumen.mesRecordCobranza != null)
                  pw.Bullet(
                      text:
                          'MES RÉCORD EN COBRANZA: ${resumen.mesRecordCobranza!.nombreMes} '
                          'con ${_fmt(resumen.mesRecordCobranza!.totalCobrado)} recaudados.',
                      style: const pw.TextStyle(fontSize: 10)),
                pw.Bullet(
                    text: resumen.crecimientoPorcentual == null
                        ? 'CRECIMIENTO: se necesitan al menos 2 meses con ventas para medir la curva.'
                        : 'CURVA DE CRECIMIENTO: el taller ${resumen.crecimientoPorcentual! >= 0 ? 'creció' : 'decreció'} '
                            '${resumen.crecimientoPorcentual!.abs().toStringAsFixed(1)}% '
                            'entre el primer y el último mes con ventas.',
                    style: const pw.TextStyle(fontSize: 10)),
                pw.Bullet(
                    text:
                        'EFECTIVIDAD ANUAL DE COBRANZA: de cada \$100 facturados, '
                        'entraron \$${resumen.efectividadAnual.toStringAsFixed(0)} en caja.',
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
          pw.SizedBox(height: 18),

          // ══ TABLA MES A MES ══
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.symmetric(
                inside: const pw.BorderSide(color: _grisLinea, width: .5)),
            headerDecoration: const pw.BoxDecoration(color: _carbon),
            headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
            headers: [
              'MES', 'VENTAS TOTALES', 'ABONOS RECAUDADOS',
              'GANANCIA NETA', 'EFECTIVIDAD',
            ],
            data: [
              for (final c in cierres)
                [
                  c.nombreMes,
                  _fmt(c.totalFacturado),
                  _fmt(c.totalCobrado),
                  _fmt(c.gananciaNeta),
                  '${c.efectividadCobro.toStringAsFixed(1)}%',
                ],
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Informe generado automáticamente por Alexmar App. '
            'Todos los montos en dólares netos (USD \$). '
            'La ganancia neta de las líneas sin costo registrado (servicios) se computa al 100%.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    return doc.save(); // Los bytes del PDF, listos para compartir
  }

  static pw.Widget _kpi(String etiqueta, String valor, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: color, width: 1.2),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(etiqueta,
                  style: pw.TextStyle(
                      fontSize: 7,
                      color: PdfColors.grey700,
                      letterSpacing: 1.5)),
              pw.SizedBox(height: 3),
              pw.Text(valor,
                  style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      );
}
