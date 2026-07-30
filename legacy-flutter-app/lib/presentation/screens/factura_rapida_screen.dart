import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../data/pdf/factura_pdf.dart';
import '../../domain/entities/linea_cuenta.dart';

/// ─────────────────────────────────────────────────────────────────
/// ★ FASE 10 · FACTURA RÁPIDA DE MOSTRADOR ★
///
/// 👶 PARA QUÉ SIRVE: llega un cliente OCASIONAL (no está registrado
/// en la app), se lleva un producto y pide su factura. Aquí el jefe
/// escribe a mano el nombre, los ítems y listo: sale el MISMO PDF
/// formal azul marino de siempre, para imprimir o mandar por
/// WhatsApp.
///
/// MUY IMPORTANTE: esta pantalla NO guarda NADA en la base de datos
/// ni en Google Sheets. Es solo "escribir → imprimir → entregar".
/// El cliente ocasional no queda registrado (si algún día se vuelve
/// cliente fijo, se registra por el camino normal del Índice).
/// ─────────────────────────────────────────────────────────────────
class FacturaRapidaScreen extends StatefulWidget {
  const FacturaRapidaScreen({super.key});

  @override
  State<FacturaRapidaScreen> createState() => _FacturaRapidaScreenState();
}

class _FacturaRapidaScreenState extends State<FacturaRapidaScreen> {
  // ── Datos del cliente ocasional (solo el nombre es obligatorio) ──
  final _nombreCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _facturaNCtrl = TextEditingController();

  // ── Monto pagado (opcional): si el cliente paga algo o todo,
  //    se refleja como ABONO y el saldo pendiente baja solo ──
  final _pagadoCtrl = TextEditingController();

  // ── Las líneas de productos (empieza con 3 filas vacías) ──
  final List<_FilaItem> _filas = [];

  bool _generando = false;

  // ── Tipo de documento: false = FACTURA (venta), true = PROFORMA
  //    (presupuesto/cotización, sin pago). ──
  bool _esProforma = false;

  @override
  void initState() {
    super.initState();
    // Nº de factura sugerido: M-díames-hora (M de Mostrador).
    // El jefe puede borrarlo y escribir el que quiera.
    _facturaNCtrl.text = _numeroSugerido();
    for (var i = 0; i < 3; i++) {
      _filas.add(_FilaItem(alCambiar: _recalcular));
    }
  }

  /// Nº sugerido: prefijo F- para factura, P- para proforma, más la
  /// fecha/hora. El jefe puede borrarlo y escribir el que quiera.
  String _numeroSugerido() {
    final ahora = DateTime.now();
    final prefijo = _esProforma ? 'P-' : 'F-';
    return '$prefijo'
        '${ahora.day.toString().padLeft(2, '0')}'
        '${ahora.month.toString().padLeft(2, '0')}'
        '-${ahora.hour.toString().padLeft(2, '0')}'
        '${ahora.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cedulaCtrl.dispose();
    _telefonoCtrl.dispose();
    _facturaNCtrl.dispose();
    _pagadoCtrl.dispose();
    for (final f in _filas) {
      f.dispose();
    }
    super.dispose();
  }

  void _recalcular() => setState(() {});

  // ── La matemática del mostrador, calculada al vuelo ──
  double get _totalConsumido {
    var total = 0.0;
    for (final f in _filas) {
      total += f.totalLinea;
    }
    return total;
  }

  double get _montoPagado {
    // Una proforma es una cotización: nunca lleva pago.
    if (_esProforma) return 0.0;
    final v = double.tryParse(_pagadoCtrl.text.replaceAll(',', '.'));
    return (v == null || v <= 0) ? 0.0 : v;
  }

  double get _saldo => _totalConsumido - _montoPagado;

  int get _itemsCompletos => _filas.where((f) => f.estaCompleta).length;

  // ══════════════════════════════════════════════════════════════
  //  CONSTRUIR LAS LÍNEAS Y GENERAR EL PDF
  // ══════════════════════════════════════════════════════════════
  ({List<LineaCuenta> lineas, ResumenCuenta resumen})? _armarDatos() {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      _aviso('Escribe el NOMBRE del cliente para poder facturar.');
      return null;
    }
    if (_itemsCompletos == 0) {
      _aviso('Agrega al menos UN ítem completo '
          '(cantidad, producto y precio).');
      return null;
    }

    final ahora = DateTime.now();
    final base = ahora.microsecondsSinceEpoch;
    final lineas = <LineaCuenta>[];
    var i = 0;

    for (final f in _filas) {
      if (!f.estaCompleta) continue; // Filas a medias se ignoran
      lineas.add(LineaCuenta(
        id: 'manual-$base-$i',
        idCliente: 'manual',
        tipo: TipoLinea.cargo,
        fecha: ahora,
        cantidad: f.cantidad,
        descripcion: f.descripcion,
        precioUnitario: f.precioUnitario,
        totalLinea: f.totalLinea,
      ));
      i++;
    }

    final pagado = _montoPagado;
    if (pagado > 0) {
      lineas.add(LineaCuenta(
        id: 'manual-$base-pago',
        idCliente: 'manual',
        tipo: TipoLinea.abono,
        fecha: ahora,
        cantidad: 1,
        descripcion: 'Pago recibido en mostrador',
        precioUnitario: null,
        totalLinea: pagado,
      ));
    }

    final resumen = ResumenCuenta(
      totalConsumido: _totalConsumido,
      totalAbonado: pagado,
    );
    return (lineas: lineas, resumen: resumen);
  }

  Future<void> _generar({required bool imprimir}) async {
    final datos = _armarDatos();
    if (datos == null) return;

    setState(() => _generando = true);
    try {
      final bytes = await FacturaPdf.generarManual(
        nombre: _nombreCtrl.text.trim(),
        cedula: _cedulaCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        direccion: null,
        facturaN: _facturaNCtrl.text.trim().isEmpty
            ? 'MOSTRADOR'
            : _facturaNCtrl.text.trim(),
        lineas: datos.lineas,
        resumen: datos.resumen,
        // ── Aquí se decide si sale FACTURA o PROFORMA ──
        etiquetaDocumento:
            _esProforma ? 'PROFORMA / PRESUPUESTO' : 'FACTURA DE VENTA',
        etiquetaTotalFinal: _esProforma ? 'TOTAL A PAGAR' : 'SALDO PENDIENTE',
        mostrarAbonos: !_esProforma,
        notaPie: _esProforma
            ? 'Documento sin validez fiscal. Cotización sujeta a '
                'disponibilidad y a cambios de precio.'
            : null,
      );

      if (imprimir) {
        // 👶 Abre el diálogo de IMPRESIÓN del sistema (o del
        // navegador en la versión web) con el PDF ya montado.
        await Printing.layoutPdf(onLayout: (_) async => bytes);
      } else {
        // 👶 Bandeja de COMPARTIR en el teléfono (WhatsApp a 2
        // toques) o DESCARGA del PDF en el navegador.
        final tipo = _esProforma ? 'Proforma' : 'Factura';
        await Printing.sharePdf(
          bytes: bytes,
          filename: '${tipo}_${_facturaNCtrl.text.trim()}.pdf',
          subject: '$tipo · Autoperiquitos Alexmar',
        );
      }
    } catch (e) {
      _aviso('No se pudo generar el PDF: $e');
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  void _aviso(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.panelDark,
    ));
  }

  void _limpiarTodo() {
    setState(() {
      _nombreCtrl.clear();
      _cedulaCtrl.clear();
      _telefonoCtrl.clear();
      _pagadoCtrl.clear();
      for (final f in _filas) {
        f.dispose();
      }
      _filas
        ..clear()
        ..addAll(List.generate(3, (_) => _FilaItem(alCambiar: _recalcular)));
    });
  }

  // ══════════════════════════════════════════════════════════════
  //  INTERFAZ
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('🧾 FACTURA RÁPIDA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        actions: [
          IconButton(
            tooltip: 'Limpiar todo y empezar de nuevo',
            icon: const Icon(Icons.restart_alt,
                color: AppColors.textSecondary),
            onPressed: _limpiarTodo,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Aviso honesto: esto NO se guarda ──
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.panelDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gridLine),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: AppColors.neonCyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Para clientes OCASIONALES de mostrador. Esta '
                          'factura NO se guarda en cuentas ni en Sheets: '
                          'solo se imprime o se comparte.',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ══ TIPO DE DOCUMENTO: FACTURA / PROFORMA ══
                _tituloSeccion('TIPO DE DOCUMENTO', textTheme),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _botonTipo(
                        texto: 'FACTURA',
                        subtitulo: 'Venta hecha',
                        activo: !_esProforma,
                        onTap: () => setState(() {
                          _esProforma = false;
                          _facturaNCtrl.text = _numeroSugerido();
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _botonTipo(
                        texto: 'PROFORMA',
                        subtitulo: 'Presupuesto',
                        activo: _esProforma,
                        onTap: () => setState(() {
                          _esProforma = true;
                          _facturaNCtrl.text = _numeroSugerido();
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ══ DATOS DEL CLIENTE ══
                _tituloSeccion('DATOS DEL CLIENTE', textTheme),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _campo(
                        controlador: _nombreCtrl,
                        etiqueta: 'Nombre del cliente *',
                        icono: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _campo(
                        controlador: _facturaNCtrl,
                        etiqueta: 'Factura Nº',
                        icono: Icons.tag,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _campo(
                        controlador: _cedulaCtrl,
                        etiqueta: 'Cédula (opcional)',
                        icono: Icons.badge_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _campo(
                        controlador: _telefonoCtrl,
                        etiqueta: 'Teléfono (opcional)',
                        icono: Icons.phone_outlined,
                        teclado: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ══ ÍTEMS DE LA VENTA ══
                _tituloSeccion('ÍTEMS DE LA VENTA', textTheme),
                const SizedBox(height: 8),
                // Encabezados de la mini-tabla
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 70,
                          child: Text('CANT.',
                              style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.textDisabled))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text('PRODUCTO O SERVICIO',
                              style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.textDisabled))),
                      const SizedBox(width: 8),
                      SizedBox(
                          width: 90,
                          child: Text('P. UNIT.',
                              style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.textDisabled))),
                      const SizedBox(width: 8),
                      SizedBox(
                          width: 80,
                          child: Text('TOTAL',
                              textAlign: TextAlign.right,
                              style: textTheme.labelSmall?.copyWith(
                                  color: AppColors.textDisabled))),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                for (var i = 0; i < _filas.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          child: _campoNumero(_filas[i].cantCtrl, '1'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _campoTexto(
                              _filas[i].descCtrl, 'Ej: Filtro de aceite'),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 90,
                          child: _campoNumero(_filas[i].precioCtrl, '0.00'),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: Text(
                            _filas[i].estaCompleta
                                ? formatoDolar(_filas[i].totalLinea)
                                : '—',
                            textAlign: TextAlign.right,
                            style: textTheme.bodyMedium?.copyWith(
                              color: _filas[i].estaCompleta
                                  ? AppColors.textPrimary
                                  : AppColors.textDisabled,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 36,
                          child: _filas.length > 1
                              ? IconButton(
                                  padding: EdgeInsets.zero,
                                  tooltip: 'Quitar esta fila',
                                  icon: const Icon(Icons.close,
                                      size: 18,
                                      color: AppColors.textDisabled),
                                  onPressed: () => setState(() {
                                    _filas.removeAt(i).dispose();
                                  }),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _filas.add(_FilaItem(alCambiar: _recalcular));
                    }),
                    icon: const Icon(Icons.add,
                        size: 18, color: AppColors.neonCyan),
                    label: const Text('AGREGAR OTRA FILA',
                        style: TextStyle(color: AppColors.neonCyan)),
                  ),
                ),
                const SizedBox(height: 16),

                // ══ PAGO Y TOTALES ══
                _tituloSeccion(
                    _esProforma ? 'TOTALES' : 'PAGO Y TOTALES', textTheme),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.panelDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gridLine),
                  ),
                  child: Column(
                    children: [
                      // El campo de PAGO solo aparece en FACTURA. Una
                      // proforma es un presupuesto: no hay pago todavía.
                      if (!_esProforma) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _campo(
                                controlador: _pagadoCtrl,
                                etiqueta: 'Monto pagado ahora \$ (opcional)',
                                icono: Icons.payments_outlined,
                                teclado:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                alCambiar: (_) => _recalcular(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      _filaResumen('TOTAL CONSUMIDO',
                          formatoDolar(_totalConsumido), textTheme,
                          color: AppColors.textPrimary),
                      if (!_esProforma) ...[
                        const SizedBox(height: 4),
                        _filaResumen('(-) PAGADO',
                            '- ${formatoDolar(_montoPagado)}', textTheme,
                            color: AppColors.statusGreen),
                      ],
                      const Divider(color: AppColors.gridLine),
                      _filaResumen(
                          _esProforma ? 'TOTAL A PAGAR' : 'SALDO PENDIENTE',
                          formatoDolar(
                              _esProforma ? _totalConsumido : _saldo),
                          textTheme,
                          color: (!_esProforma && _saldo <= 0)
                              ? AppColors.statusGreen
                              : AppColors.racingOrange,
                          grande: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ══ BOTONES DE ACCIÓN ══
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.racingOrange,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed:
                            _generando ? null : () => _generar(imprimir: true),
                        icon: _generando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.print, color: Colors.white),
                        label: const Text('IMPRIMIR',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: AppColors.neonCyan),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _generando
                            ? null
                            : () => _generar(imprimir: false),
                        icon: const Icon(Icons.share,
                            color: AppColors.neonCyan),
                        label: const Text('PDF / WHATSAPP',
                            style: TextStyle(
                                color: AppColors.neonCyan,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '$_itemsCompletos ítem(s) listo(s) · las filas '
                    'incompletas no salen en ${_esProforma ? 'la proforma' : 'la factura'}',
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.textDisabled),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Botón grande para elegir FACTURA o PROFORMA ──
  Widget _botonTipo({
    required String texto,
    required String subtitulo,
    required bool activo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: activo
              ? AppColors.neonCyan.withValues(alpha: 0.12)
              : AppColors.panelDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: activo ? AppColors.neonCyan : AppColors.gridLine,
            width: activo ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  activo
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color:
                      activo ? AppColors.neonCyan : AppColors.textDisabled,
                ),
                const SizedBox(width: 8),
                Text(
                  texto,
                  style: TextStyle(
                    color: activo
                        ? AppColors.neonCyan
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: const TextStyle(
                  color: AppColors.textDisabled, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ── Piezas visuales reutilizables ──
  Widget _tituloSeccion(String texto, TextTheme t) => Text(
        texto,
        style: t.labelLarge?.copyWith(
          color: AppColors.neonCyan,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      );

  Widget _campo({
    required TextEditingController controlador,
    required String etiqueta,
    required IconData icono,
    TextInputType? teclado,
    void Function(String)? alCambiar,
  }) {
    return TextField(
      controller: controlador,
      keyboardType: teclado,
      onChanged: alCambiar,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: etiqueta,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icono, size: 18, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.panelDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gridLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gridLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neonCyan),
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController ctrl, String pista) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: _decoCompacta(pista),
    );
  }

  Widget _campoNumero(TextEditingController ctrl, String pista) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        // Solo números, punto o coma decimal
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: _decoCompacta(pista),
    );
  }

  InputDecoration _decoCompacta(String pista) => InputDecoration(
        hintText: pista,
        hintStyle:
            const TextStyle(color: AppColors.textDisabled, fontSize: 13),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        filled: true,
        fillColor: AppColors.panelDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.gridLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.gridLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.neonCyan),
        ),
      );

  Widget _filaResumen(String etiqueta, String valor, TextTheme t,
      {required Color color, bool grande = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(etiqueta,
            style: t.labelMedium?.copyWith(
                color: AppColors.textSecondary, letterSpacing: 1)),
        Text(valor,
            style: (grande ? t.titleLarge : t.titleSmall)
                ?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// 👶 Una fila editable de la venta: cantidad + producto + precio.
/// Guarda sus propios controladores de texto y avisa a la pantalla
/// (alCambiar) cada vez que se escribe algo, para refrescar totales.
class _FilaItem {
  final TextEditingController cantCtrl;
  final TextEditingController descCtrl;
  final TextEditingController precioCtrl;
  final VoidCallback alCambiar;

  _FilaItem({required this.alCambiar})
      : cantCtrl = TextEditingController(),
        descCtrl = TextEditingController(),
        precioCtrl = TextEditingController() {
    cantCtrl.addListener(alCambiar);
    descCtrl.addListener(alCambiar);
    precioCtrl.addListener(alCambiar);
  }

  double get cantidad =>
      double.tryParse(cantCtrl.text.replaceAll(',', '.')) ?? 0;
  String get descripcion => descCtrl.text.trim();
  double get precioUnitario =>
      double.tryParse(precioCtrl.text.replaceAll(',', '.')) ?? 0;
  double get totalLinea => cantidad * precioUnitario;

  bool get estaCompleta =>
      cantidad > 0 && descripcion.isNotEmpty && precioUnitario > 0;

  void dispose() {
    cantCtrl.dispose();
    descCtrl.dispose();
    precioCtrl.dispose();
  }
}
