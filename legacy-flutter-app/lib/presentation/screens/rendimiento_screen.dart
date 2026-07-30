import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/fondo_chip.dart';
import '../../core/utils/formato.dart';
import '../../data/pdf/reporte_anual_pdf.dart';
import '../../domain/entities/cierre_mensual.dart';
import '../providers/rendimiento_providers.dart';

/// ─────────────────────────────────────────────────────────────────
/// PANEL DE RENDIMIENTO GERENCIAL (BI) · SOLO MODO JEFE.
/// Vive bajo /admin/** → el guard del router expulsa al empleado.
///
/// Estructura (de arriba hacia abajo):
///  1. Selector de año + aviso de cierres recién generados.
///  2. KPIs del año (Facturado, Cobrado, Ganancia, Efectividad).
///  3. GRÁFICO de barras dinámico (painter personalizado).
///  4. Tabla histórica mes a mes.
///  5. Reporte Ejecutivo Anual + botón EXPORTAR PDF.
/// ─────────────────────────────────────────────────────────────────
class RendimientoScreen extends ConsumerWidget {
  const RendimientoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Al entrar, el contador nocturno revisa si hay meses por cerrar
    final verificacion = ref.watch(verificarCierresProvider);
    final resumen = ref.watch(resumenAnualProvider);
    final anios = ref.watch(aniosDisponiblesProvider);
    final anioSel = ref.watch(anioSeleccionadoProvider) ??
        (anios.isEmpty ? null : anios.last);
    final textTheme = Theme.of(context).textTheme;

    return FondoChip(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,title: const Text('RENDIMIENTO · BI')),
      body: SafeArea(
        child: resumen == null
            ? _SinHistoria(verificacion: verificacion)
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  // ── 1. SELECTOR DE AÑO ──
                  Row(
                    children: [
                      Text('PERIODO FISCAL',
                          style: textTheme.labelSmall
                              ?.copyWith(color: AppColors.neonCyan)),
                      const SizedBox(width: 12),
                      for (final a in anios)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('$a'),
                            selected: a == anioSel,
                            selectedColor:
                                AppColors.racingOrange.withValues(alpha: .25),
                            labelStyle: textTheme.labelLarge?.copyWith(
                                color: a == anioSel
                                    ? AppColors.racingOrange
                                    : AppColors.textSecondary),
                            side: BorderSide(
                                color: a == anioSel
                                    ? AppColors.racingOrange
                                    : AppColors.gridLine),
                            onSelected: (_) => ref
                                .read(anioSeleccionadoProvider.notifier)
                                .state = a,
                          ),
                        ),
                    ],
                  ),
                  // Aviso amistoso si el motor acaba de fotografiar meses
                  if ((verificacion.value ?? 0) > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '✓ Cierre automático: ${verificacion.value} mes(es) '
                        'fotografiado(s) y enviado(s) a la cola del espejo.',
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.statusGreen),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ── 2. KPIs DEL AÑO ──
                  _FilaKpis(resumen: resumen),
                  const SizedBox(height: 16),

                  // ── 3. GRÁFICO DINÁMICO ──
                  _PanelGrafico(cierres: resumen.cierres),
                  const SizedBox(height: 16),

                  // ── 4. TABLA HISTÓRICA MES A MES ──
                  _TablaHistorica(cierres: resumen.cierres),
                  const SizedBox(height: 16),

                  // ── 5. REPORTE EJECUTIVO + EXPORTAR PDF ──
                  _ReporteEjecutivo(resumen: resumen),
                ],
              ),
      ),
      ),
    );
  }
}

// ═══════════════════ 2. KPIs ═══════════════════

class _FilaKpis extends StatelessWidget {
  final ResumenAnual resumen;
  const _FilaKpis({required this.resumen});

  @override
  Widget build(BuildContext context) {
    // Wrap: en PC caben los 4 en fila; en móvil bajan en 2x2 solos
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _Kpi(
            etiqueta: 'FACTURADO ANUAL',
            valor: formatoDolar(resumen.facturadoAnual),
            color: AppColors.neonCyan,
            icono: Icons.point_of_sale_outlined),
        _Kpi(
            etiqueta: 'COBRADO ANUAL',
            valor: formatoDolar(resumen.cobradoAnual),
            color: AppColors.statusGreen,
            icono: Icons.payments_outlined),
        _Kpi(
            etiqueta: 'GANANCIA NETA',
            valor: formatoDolar(resumen.gananciaAnual),
            color: AppColors.racingOrange,
            icono: Icons.trending_up),
        _Kpi(
            etiqueta: 'EFECTIVIDAD DE COBRO',
            valor: '${resumen.efectividadAnual.toStringAsFixed(1)}%',
            color: AppColors.statusYellow,
            icono: Icons.track_changes_outlined),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color color;
  final IconData icono;
  const _Kpi(
      {required this.etiqueta,
      required this.valor,
      required this.color,
      required this.icono});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gridLine),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: .12),
              blurRadius: 24,
              spreadRadius: -6),
        ],
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiqueta,
                    style: textTheme.labelSmall?.copyWith(fontSize: 9.5)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(valor,
                      style: textTheme.labelLarge?.copyWith(
                          fontSize: 19,
                          color: color,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════ 3. GRÁFICO ═══════════════════

class _PanelGrafico extends StatelessWidget {
  final List<CierreMensual> cierres;
  const _PanelGrafico({required this.cierres});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gridLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURVA DE RENDIMIENTO MENSUAL', style: textTheme.titleLarge),
          const SizedBox(height: 4),
          // Leyenda del gráfico
          Wrap(
            spacing: 16,
            children: const [
              _LeyendaItem(color: AppColors.neonCyan, texto: 'FACTURADO'),
              _LeyendaItem(color: AppColors.statusGreen, texto: 'COBRADO'),
              _LeyendaItem(
                  color: AppColors.racingOrange, texto: 'GANANCIA (LÍNEA)'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _GraficoBarrasPainter(cierres: cierres),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeyendaItem extends StatelessWidget {
  final Color color;
  final String texto;
  const _LeyendaItem({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 5),
        Text(texto,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontSize: 9.5)),
      ],
    );
  }
}

/// ★ EL PINTOR DEL GRÁFICO ★
/// 👶 Un CustomPainter es un lienzo en blanco donde dibujamos con
/// coordenadas, como en papel milimetrado: (0,0) es la esquina
/// superior izquierda. Dibujamos: la retícula, 2 barras por mes
/// (facturado cian, cobrado verde) y la línea naranja de ganancia.
class _GraficoBarrasPainter extends CustomPainter {
  final List<CierreMensual> cierres;
  _GraficoBarrasPainter({required this.cierres});

  @override
  void paint(Canvas canvas, Size size) {
    const margenIzq = 8.0, margenInf = 22.0, margenSup = 10.0;
    final alto = size.height - margenInf - margenSup;
    final ancho = size.width - margenIzq;

    // 1) El "techo" del gráfico: el valor más alto manda la escala
    double maximo = 0;
    for (final c in cierres) {
      if (c.totalFacturado > maximo) maximo = c.totalFacturado;
      if (c.totalCobrado > maximo) maximo = c.totalCobrado;
      if (c.gananciaNeta > maximo) maximo = c.gananciaNeta;
    }
    if (maximo <= 0) maximo = 1; // Evitar división entre cero

    // 2) Retícula horizontal (4 líneas de guía)
    final guia = Paint()
      ..color = AppColors.gridLine
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = margenSup + alto - (alto * i / 4);
      canvas.drawLine(
          Offset(margenIzq, y), Offset(size.width, y), guia);
    }

    // 3) Las barras: cada mes ocupa una "celda" del ancho
    final celda = ancho / 12; // Siempre 12 espacios (enero..diciembre)
    final anchoBarra = (celda * .28).clamp(4.0, 18.0);
    final pincelFact = Paint()..color = AppColors.neonCyan;
    final pincelCobr = Paint()..color = AppColors.statusGreen;

    final puntosGanancia = <Offset>[];
    final estiloMes = TextStyle(
        color: AppColors.textSecondary,
        fontSize: 8.5,
        fontFamily: 'monospace');

    for (final c in cierres) {
      final xCelda = margenIzq + celda * (c.mes - 1);
      final centro = xCelda + celda / 2;

      double altura(double v) => alto * (v / maximo);

      // Barra FACTURADO (cian, a la izquierda del centro)
      canvas.drawRect(
        Rect.fromLTWH(
            centro - anchoBarra - 1,
            margenSup + alto - altura(c.totalFacturado),
            anchoBarra,
            altura(c.totalFacturado)),
        pincelFact,
      );
      // Barra COBRADO (verde, a la derecha del centro)
      canvas.drawRect(
        Rect.fromLTWH(
            centro + 1,
            margenSup + alto - altura(c.totalCobrado),
            anchoBarra,
            altura(c.totalCobrado)),
        pincelCobr,
      );
      // Punto de la línea de GANANCIA (naranja)
      puntosGanancia.add(Offset(
          centro, margenSup + alto - altura(c.gananciaNeta.clamp(0, maximo))));

      // Etiqueta del mes (3 letras) bajo su celda
      final tp = TextPainter(
        text: TextSpan(
            text: nombresMeses[c.mes - 1].substring(0, 3), style: estiloMes),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(centro - tp.width / 2, margenSup + alto + 6));
    }

    // 4) La línea de ganancia conectando los puntos + nodos brillantes
    if (puntosGanancia.length > 1) {
      final linea = Paint()
        ..color = AppColors.racingOrange
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final camino = Path()
        ..moveTo(puntosGanancia.first.dx, puntosGanancia.first.dy);
      for (final p in puntosGanancia.skip(1)) {
        camino.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(camino, linea);
    }
    final nodo = Paint()..color = AppColors.racingOrange;
    for (final p in puntosGanancia) {
      canvas.drawCircle(p, 3, nodo);
    }
  }

  @override
  bool shouldRepaint(covariant _GraficoBarrasPainter old) =>
      old.cierres != cierres;
}

// ═══════════════════ 4. TABLA HISTÓRICA ═══════════════════

class _TablaHistorica extends StatelessWidget {
  final List<CierreMensual> cierres;
  const _TablaHistorica({required this.cierres});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final encabezado =
        textTheme.labelSmall?.copyWith(color: AppColors.neonCyan);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gridLine),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('MES', style: encabezado)),
                Expanded(
                    flex: 3,
                    child: Text('VENTAS', style: encabezado,
                        textAlign: TextAlign.right)),
                Expanded(
                    flex: 3,
                    child: Text('ABONOS', style: encabezado,
                        textAlign: TextAlign.right)),
                Expanded(
                    flex: 3,
                    child: Text('GANANCIA', style: encabezado,
                        textAlign: TextAlign.right)),
                Expanded(
                    flex: 2,
                    child: Text('EFECT.', style: encabezado,
                        textAlign: TextAlign.right)),
              ],
            ),
          ),
          const Divider(),
          for (final c in cierres) _FilaMes(cierre: c),
        ],
      ),
    );
  }
}

class _FilaMes extends StatelessWidget {
  final CierreMensual cierre;
  const _FilaMes({required this.cierre});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cifra = textTheme.labelLarge?.copyWith(fontSize: 13);

    // El color de la efectividad usa el mismo lenguaje del semáforo
    final colorEfect = cierre.efectividadCobro >= 80
        ? AppColors.statusGreen
        : cierre.efectividadCobro >= 50
            ? AppColors.statusYellow
            : AppColors.statusRed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(cierre.nombreMes,
                  style: textTheme.titleMedium?.copyWith(fontSize: 13))),
          Expanded(
              flex: 3,
              child: Text(formatoDolar(cierre.totalFacturado),
                  style: cifra?.copyWith(color: AppColors.neonCyan),
                  textAlign: TextAlign.right)),
          Expanded(
              flex: 3,
              child: Text(formatoDolar(cierre.totalCobrado),
                  style: cifra?.copyWith(color: AppColors.statusGreen),
                  textAlign: TextAlign.right)),
          Expanded(
              flex: 3,
              child: Text(formatoDolar(cierre.gananciaNeta),
                  style: cifra?.copyWith(color: AppColors.racingOrange),
                  textAlign: TextAlign.right)),
          Expanded(
              flex: 2,
              child: Text('${cierre.efectividadCobro.toStringAsFixed(0)}%',
                  style: cifra?.copyWith(color: colorEfect),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

// ═══════════════════ 5. REPORTE EJECUTIVO ═══════════════════

class _ReporteEjecutivo extends ConsumerWidget {
  final ResumenAnual resumen;
  const _ReporteEjecutivo({required this.resumen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final crecimiento = resumen.crecimientoPorcentual;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.racingOrange, width: 1.2),
        boxShadow: const [
          BoxShadow(
              color: AppColors.racingOrangeDim,
              blurRadius: 32,
              spreadRadius: -8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('REPORTE EJECUTIVO ${resumen.anio}',
              style: textTheme.titleLarge
                  ?.copyWith(color: AppColors.racingOrange)),
          const SizedBox(height: 12),
          if (resumen.mesRecordVentas != null)
            _Destacado(
              icono: Icons.emoji_events_outlined,
              color: AppColors.neonCyan,
              texto: 'MES RÉCORD EN VENTAS: ${resumen.mesRecordVentas!.nombreMes} '
                  '(${formatoDolar(resumen.mesRecordVentas!.totalFacturado)})',
            ),
          if (resumen.mesRecordCobranza != null)
            _Destacado(
              icono: Icons.workspace_premium_outlined,
              color: AppColors.statusGreen,
              texto:
                  'MES RÉCORD EN COBRANZA: ${resumen.mesRecordCobranza!.nombreMes} '
                  '(${formatoDolar(resumen.mesRecordCobranza!.totalCobrado)})',
            ),
          _Destacado(
            icono: crecimiento == null
                ? Icons.hourglass_empty
                : crecimiento >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
            color: crecimiento == null
                ? AppColors.textSecondary
                : crecimiento >= 0
                    ? AppColors.statusGreen
                    : AppColors.statusRed,
            texto: crecimiento == null
                ? 'CRECIMIENTO: se necesitan 2+ meses con ventas para medir la curva'
                : 'CRECIMIENTO DEL TALLER: ${crecimiento >= 0 ? '+' : ''}${crecimiento.toStringAsFixed(1)}% '
                    'entre el primer y el último mes con ventas',
          ),
          _Destacado(
            icono: Icons.track_changes_outlined,
            color: AppColors.statusYellow,
            texto:
                'EFECTIVIDAD ANUAL: de cada \$100 facturados entraron '
                '\$${resumen.efectividadAnual.toStringAsFixed(0)} en caja',
          ),
          const SizedBox(height: 16),
          // ── EL BOTÓN FUTURISTA DE EXPORTACIÓN ──
          ElevatedButton.icon(
            icon: const Icon(Icons.rocket_launch_outlined),
            label: Text('EXPORTAR INFORME ANUAL ${resumen.anio} EN PDF'),
            onPressed: () async {
              final bytes = await ReporteAnualPdf.generar(resumen);
              // En celular abre la bandeja de compartir; en navegador
              // descarga/comparte el archivo. Mismo botón, todas partes.
              await Printing.sharePdf(
                bytes: bytes,
                filename: 'Informe_Ejecutivo_Alexmar_${resumen.anio}.pdf',
                subject: 'Informe Ejecutivo Alexmar ${resumen.anio}',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Destacado extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;
  const _Destacado(
      {required this.icono, required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(texto,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _SinHistoria extends StatelessWidget {
  final AsyncValue<int> verificacion;
  const _SinHistoria({required this.verificacion});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (verificacion.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insights_outlined,
                size: 56, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text('Aún no hay meses cerrados', style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'El primer cierre se generará automáticamente cuando termine '
              'el mes en curso y se abra la app. Las fotografías financieras '
              'aparecerán aquí mes a mes.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
