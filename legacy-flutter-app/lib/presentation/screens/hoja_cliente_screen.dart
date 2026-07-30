import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../data/services/cobranza_service.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/entities/linea_cuenta.dart';
import '../providers/cuenta_providers.dart';

/// ─────────────────────────────────────────────────────────────────
/// HOJA INDIVIDUAL DEL CLIENTE · La página viva del índice físico.
///
/// Estructura (de arriba hacia abajo):
///  1. Encabezado heredado del índice: nombre, folio, teléfono,
///     dirección y semáforo.
///  2. SCROLL VERTICAL INFINITO: Cantidad | Producto-Servicio |
///     P. Unitario | P. Total. Los ABONOS se inyectan en la misma
///     lista como filas resaltadas COMPLETAMENTE EN VERDE.
///  3. Pie fijo con los 3 totales dinámicos y el saldo.
///  4. Botones: + CARGO (naranja), + ABONO (verde), COBRAR (cian).
/// ─────────────────────────────────────────────────────────────────
class HojaClienteScreen extends ConsumerWidget {
  final String idCliente;
  const HojaClienteScreen({super.key, required this.idCliente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cliente = ref.watch(clientePorIdProvider(idCliente)).value;
    final lineas = ref.watch(lineasClienteProvider(idCliente));
    final resumen = ref.watch(resumenCuentaProvider(idCliente)).value ??
        const ResumenCuenta(totalConsumido: 0, totalAbonado: 0);

    if (cliente == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('HOJA Nº ${cliente.facturaN}'),
        actions: [
          // ★ FASE 10 · VACIAR CUENTA — para el cliente recurrente que
          // cancela todo: borra (lógico) todos sus movimientos de una
          // vez, sin crear una hoja nueva. Pide confirmación.
          IconButton(
            tooltip: 'Vaciar cuenta (borrar todos los movimientos)',
            icon: const Icon(Icons.delete_sweep_outlined,
                color: AppColors.statusRed),
            onPressed: () =>
                _confirmarVaciarCuenta(context, ref, cliente),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. ENCABEZADO DEL CLIENTE ──
            _EncabezadoCliente(cliente: cliente),

            // ── Encabezados de columna (como la página del índice) ──
            const _EncabezadosColumna(),
            const Divider(),

            // ── 2. SCROLL VERTICAL INFINITO ──
            Expanded(
              child: lineas.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (lista) => lista.isEmpty
                    ? const _CuentaVacia()
                    : ListView.builder(
                        // 👶 ListView.builder solo "fabrica" las filas
                        // visibles en pantalla. Aunque la cuenta tenga
                        // 10,000 movimientos, la app vuela: eso ES el
                        // scroll infinito de alto rendimiento.
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                        itemCount: lista.length,
                        itemBuilder: (_, i) => _FilaLinea(
                          linea: lista[i],
                          onEliminar: () => _confirmarEliminarLinea(
                              context, ref, lista[i]),
                        ),
                      ),
              ),
            ),

            // ── 3. TOTALES DINÁMICOS + 4. BOTONERA ──
            _PieTotalesYAcciones(
              cliente: cliente,
              resumen: resumen,
              onAgregarCargo: () => _abrirFormularioCargo(context, ref),
              onRegistrarAbono: () => _abrirFormularioAbono(context, ref),
              onCobrar: () => _abrirMenuCobranza(context, ref, cliente,
                  lineas.value ?? const [], resumen),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════ FORMULARIO: AGREGAR PRODUCTO / SERVICIO ═══════════
  void _abrirFormularioCargo(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final cantCtrl = TextEditingController(text: '1');
    final descCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    final costoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogo) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.racingOrange),
        ),
        title: Text('AGREGAR PRODUCTO / SERVICIO',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.racingOrange)),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: 'PRODUCTO O SERVICIO *',
                      hintText: 'Ej: Cambio de aceite / Faro Ford Cargo'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'La descripción es obligatoria'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: cantCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'CANTIDAD *'),
                        validator: (v) {
                          final n =
                              double.tryParse((v ?? '').replaceAll(',', '.'));
                          return (n == null || n <= 0)
                              ? 'Cantidad inválida'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: precioCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: r'P. UNITARIO ($) *'),
                        validator: (v) {
                          final n =
                              double.tryParse((v ?? '').replaceAll(',', '.'));
                          return (n == null || n < 0)
                              ? 'Precio inválido'
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // 🔒 Costo del día (opcional): alimenta la GANANCIA NETA
                // del panel BI. Si se deja vacío (servicios como mano de
                // obra), esa venta cuenta como ganancia completa.
                TextFormField(
                  controller: costoCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: r'COSTO UNIT. ($) 🔒 OPCIONAL',
                      hintText: 'Para calcular la ganancia neta'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null; // opcional
                    return double.tryParse(v.replaceAll(',', '.')) == null
                        ? 'Solo números'
                        : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogo).pop(),
              child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(150, 48)),
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              final costoTxt = costoCtrl.text.replaceAll(',', '.').trim();
              await ref.read(cuentasRepositoryProvider).agregarCargo(
                    idCliente: idCliente,
                    cantidad:
                        double.parse(cantCtrl.text.replaceAll(',', '.')),
                    descripcion: descCtrl.text,
                    precioUnitario:
                        double.parse(precioCtrl.text.replaceAll(',', '.')),
                    costoUnitario:
                        costoTxt.isEmpty ? null : double.parse(costoTxt),
                  );
              if (dialogo.mounted) Navigator.of(dialogo).pop();
            },
            child: const Text('AGREGAR'),
          ),
        ],
      ),
    );
  }

  // ═══════════ FORMULARIO: REGISTRAR ABONO (FILA VERDE) ═══════════
  void _abrirFormularioAbono(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final descCtrl = TextEditingController(text: 'Abono a cuenta');
    final montoCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogo) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.statusGreen),
        ),
        title: Text('REGISTRAR ABONO',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.statusGreen)),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'DESCRIPCIÓN DEL ABONO',
                      hintText: 'Ej: Abono en efectivo / Pago móvil'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: montoCtrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: r'MONTO ($) *'),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                    return (n == null || n <= 0) ? 'Monto inválido' : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogo).pop(),
              child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusGreen,
              minimumSize: const Size(150, 48),
            ),
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              await ref.read(cuentasRepositoryProvider).registrarAbono(
                    idCliente: idCliente,
                    descripcion: descCtrl.text,
                    monto:
                        double.parse(montoCtrl.text.replaceAll(',', '.')),
                  );
              if (dialogo.mounted) Navigator.of(dialogo).pop();
            },
            child: const Text('GUARDAR ABONO'),
          ),
        ],
      ),
    );
  }

  // ═══════════ MENÚ DE COBRANZA (PDF + WHATSAPP) ═══════════
  void _abrirMenuCobranza(BuildContext context, WidgetRef ref,
      Cliente cliente, List<LineaCuenta> lineas, ResumenCuenta resumen) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panelDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        side: BorderSide(color: AppColors.neonCyan, width: 1),
      ),
      builder: (hoja) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('MOTOR DE COBRANZA',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Saldo a cobrar: ${formatoDolar(resumen.saldoPendiente)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('ENVIAR PDF POR WHATSAPP'),
                onPressed: () async {
                  Navigator.of(hoja).pop();
                  await CobranzaService.enviarPdfPorWhatsApp(
                    cliente: cliente,
                    lineas: lineas,
                    resumen: resumen,
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.chat_outlined),
                label: const Text('ABRIR CHAT CON MENSAJE DE COBRO'),
                onPressed: () async {
                  Navigator.of(hoja).pop();
                  final ok = await CobranzaService.abrirChatWhatsApp(
                    cliente: cliente,
                    saldo: resumen.saldoPendiente,
                  );
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'No se pudo abrir WhatsApp. Verifique el teléfono del cliente (debe incluir código de país).')));
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                'El PDF se adjunta desde la bandeja de compartir: toque WhatsApp y elija el chat del cliente (2 toques).',
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ★ FASE 10 · VACIAR CUENTA COMPLETA ★
  /// Confirma y borra (lógico) TODOS los movimientos del cliente. El
  /// saldo queda en $0 y el vaciado se sincroniza a Sheets. La ficha
  /// del cliente (nombre, cédula...) NO se toca: solo su historial.
  void _confirmarVaciarCuenta(
      BuildContext context, WidgetRef ref, Cliente cliente) {
    showDialog(
      context: context,
      builder: (dialogo) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text('¿VACIAR TODA LA CUENTA?'),
        content: Text(
          'Se borrarán TODOS los movimientos (cargos y abonos) de '
          '${cliente.nombre}. Su saldo quedará en \$0.\n\n'
          'La ficha del cliente se conserva; solo se vacía su hoja. '
          'Esto se reflejará también en los demás dispositivos en la '
          'próxima sincronización.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusRed,
                minimumSize: const Size(150, 48)),
            onPressed: () async {
              final cuantas = await ref
                  .read(cuentasRepositoryProvider)
                  .vaciarCuenta(idCliente);
              if (dialogo.mounted) Navigator.of(dialogo).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.panelDark,
                    content: Text(cuantas == 0
                        ? 'Esta cuenta ya estaba vacía.'
                        : 'Cuenta vaciada: $cuantas movimiento(s) '
                            'eliminado(s). Saldo en \$0.'),
                  ),
                );
              }
            },
            child: const Text('SÍ, VACIAR'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarLinea(
      BuildContext context, WidgetRef ref, LineaCuenta linea) {
    showDialog(
      context: context,
      builder: (dialogo) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text('¿BORRAR ESTA LÍNEA?'),
        content: Text(
            '"${linea.descripcion}" por ${formatoDolar(linea.totalLinea)}. '
            'El saldo se recalculará automáticamente.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogo).pop(),
              child: const Text('CANCELAR')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusRed,
                minimumSize: const Size(130, 48)),
            onPressed: () async {
              await ref
                  .read(cuentasRepositoryProvider)
                  .eliminarLinea(linea.id, idCliente);
              if (dialogo.mounted) Navigator.of(dialogo).pop();
            },
            child: const Text('BORRAR'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════ WIDGETS DE LA PANTALLA ═══════════════════

class _EncabezadoCliente extends StatelessWidget {
  final Cliente cliente;
  const _EncabezadoCliente({required this.cliente});

  Color get _colorEstatus => switch (cliente.estatus) {
        EstatusCartera.verde => AppColors.statusGreen,
        EstatusCartera.amarillo => AppColors.statusYellow,
        EstatusCartera.rojo => AppColors.statusRed,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gridLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(cliente.nombre.toUpperCase(),
                    style: textTheme.displayMedium?.copyWith(fontSize: 18)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: _colorEstatus),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(cliente.estatus.etiqueta,
                    style: textTheme.labelSmall
                        ?.copyWith(color: _colorEstatus)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            [
              if (cliente.cedula != null) 'CI ${cliente.cedula}',
              'Tel ${cliente.telefono}',
              if (cliente.direccion != null) cliente.direccion!,
            ].join('  ·  '),
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _EncabezadosColumna extends StatelessWidget {
  const _EncabezadosColumna();

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(color: AppColors.neonCyan);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 6),
      child: Row(
        children: [
          SizedBox(width: 44, child: Text('CANT.', style: estilo)),
          Expanded(child: Text('PRODUCTO - SERVICIO', style: estilo)),
          SizedBox(
              width: 80,
              child:
                  Text('P. UNIT.', style: estilo, textAlign: TextAlign.right)),
          SizedBox(
              width: 90,
              child:
                  Text('P. TOTAL', style: estilo, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

/// Una fila del scroll. Si es ABONO → fila COMPLETA resaltada en verde.
class _FilaLinea extends StatelessWidget {
  final LineaCuenta linea;
  final VoidCallback onEliminar;
  const _FilaLinea({required this.linea, required this.onEliminar});

  /// dd/mm/aaaa — formato venezolano de toda la vida
  String _formatoFecha(DateTime f) {
    final dd = f.day.toString().padLeft(2, '0');
    final mm = f.month.toString().padLeft(2, '0');
    return '$dd/$mm/${f.year}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final esAbono = linea.esAbono;

    final colorTexto = esAbono ? AppColors.statusGreen : AppColors.textPrimary;

    return InkWell(
      onLongPress: onEliminar, // Mantener presionado = borrar línea
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          // ★ LA FILA VERDE DEL ABONO ★
          color: esAbono
              ? AppColors.statusGreen.withValues(alpha: .12)
              : AppColors.panelDark,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: esAbono ? AppColors.statusGreen : AppColors.gridLine,
            width: esAbono ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            // CANTIDAD (abonos siempre 1)
            SizedBox(
              width: 44,
              child: Text(
                esAbono
                    ? '1'
                    : (linea.cantidad == linea.cantidad.roundToDouble()
                        ? linea.cantidad.toInt().toString()
                        : linea.cantidad.toString()),
                style: textTheme.labelLarge?.copyWith(color: colorTexto),
              ),
            ),
            // PRODUCTO - SERVICIO (o descripción del abono)
            Expanded(
              child: Row(
                children: [
                  if (esAbono) ...[
                    const Icon(Icons.arrow_downward,
                        size: 14, color: AppColors.statusGreen),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          linea.descripcion,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorTexto,
                            fontWeight:
                                esAbono ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        // ★ FECHA DE LA TRANSACCIÓN ★ (ajuste Fase 7,
                        // re-aplicado en Fase 8 tras recuperación de
                        // archivo desde backup viejo). El dato siempre
                        // se guardó bien; esto solo lo hace VISIBLE.
                        Text(
                          _formatoFecha(linea.fecha),
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // P. UNITARIO (vacío en abonos)
            SizedBox(
              width: 80,
              child: Text(
                esAbono ? '—' : formatoDolar(linea.precioUnitario ?? 0),
                textAlign: TextAlign.right,
                style: textTheme.labelLarge
                    ?.copyWith(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            // P. TOTAL (los abonos se muestran restando)
            SizedBox(
              width: 90,
              child: Text(
                esAbono
                    ? '- ${formatoDolar(linea.totalLinea)}'
                    : formatoDolar(linea.totalLinea),
                textAlign: TextAlign.right,
                style: textTheme.labelLarge?.copyWith(
                  color: colorTexto,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pie fijo: los 3 totales dinámicos + botonera de acciones
class _PieTotalesYAcciones extends StatelessWidget {
  final Cliente cliente;
  final ResumenCuenta resumen;
  final VoidCallback onAgregarCargo;
  final VoidCallback onRegistrarAbono;
  final VoidCallback onCobrar;

  const _PieTotalesYAcciones({
    required this.cliente,
    required this.resumen,
    required this.onAgregarCargo,
    required this.onRegistrarAbono,
    required this.onCobrar,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.panelDark,
        border: Border(top: BorderSide(color: AppColors.neonCyan, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Los 3 totales en vivo ──
          Row(
            children: [
              _CasillaTotal(
                etiqueta: 'TOTAL CONSUMIDO',
                valor: formatoDolar(resumen.totalConsumido),
                color: AppColors.textPrimary,
              ),
              _CasillaTotal(
                etiqueta: 'TOTAL ABONADO',
                valor: '- ${formatoDolar(resumen.totalAbonado)}',
                color: AppColors.statusGreen,
              ),
              _CasillaTotal(
                etiqueta: 'SALDO PENDIENTE',
                valor: formatoDolar(resumen.saldoPendiente),
                color: AppColors.racingOrange,
                destacada: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Botonera ──
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: const Text('CARGO'),
                  onPressed: onAgregarCargo,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusGreen),
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('ABONO'),
                  onPressed: onRegistrarAbono,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: const Text('COBRAR'),
                  onPressed: onCobrar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CasillaTotal extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color color;
  final bool destacada;

  const _CasillaTotal({
    required this.etiqueta,
    required this.valor,
    required this.color,
    this.destacada = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: destacada ? color : AppColors.gridLine,
            width: destacada ? 1.2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(etiqueta,
                style: textTheme.labelSmall?.copyWith(fontSize: 9),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(valor,
                  style: textTheme.labelLarge?.copyWith(
                      color: color, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CuentaVacia extends StatelessWidget {
  const _CuentaVacia();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('La cuenta está en blanco', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Use el botón CARGO para anotar el primer producto o servicio',
              style: textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
