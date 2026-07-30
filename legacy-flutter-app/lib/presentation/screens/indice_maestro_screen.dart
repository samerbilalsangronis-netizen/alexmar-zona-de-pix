import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/fondo_chip.dart';
import '../../core/utils/formato.dart';
import '../../data/sync/sheets_api_client.dart';
import '../../data/sync/sincronizacion_bajada_service.dart';
import '../providers/clientes_providers.dart' show sincronizacionBajadaProvider;
import '../../domain/entities/cliente.dart';
import '../providers/auth_providers.dart';
import '../providers/clientes_providers.dart';

/// ─────────────────────────────────────────────────────────────────
/// ÍNDICE MAESTRO · Control General de cartera (solo ADMIN).
/// Protegida por el guard del router: vive bajo /admin/**.
///
/// Estructura de la pantalla (de arriba hacia abajo):
///  1. Casilla FIJA con el TOTAL GENERAL adeudado en la calle ($).
///  2. Leyenda interactiva del semáforo (se abre/cierra al tocarla).
///  3. Lista en vivo de clientes con su color de estatus.
/// ─────────────────────────────────────────────────────────────────
class IndiceMaestroScreen extends ConsumerWidget {
  const IndiceMaestroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientes = ref.watch(indiceClientesProvider);
    final clientesFiltrados = ref.watch(indiceClientesFiltradosProvider);
    final textoBusqueda = ref.watch(textoBusquedaProvider);
    final pendientesSync = ref.watch(pendientesSyncProvider);

    // Encender el motor de sincronización (si ya está encendido, no
    // pasa nada: el provider lo crea una sola vez).
    ref.watch(syncServiceProvider);


        return FondoChip(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ÍNDICE MAESTRO'),
        actions: [
          _IndicadorSync(pendientes: pendientesSync),
          // ☁️ BOTÓN DE SINCRONIZAR (solo ADMIN): baja los datos de
          // Sheets y los carga en esta app, reemplazando todo.
          if (ref.watch(esAdminProvider))
            IconButton(
              tooltip: 'Sincronizar desde la nube (bajar datos)',
              icon: const Icon(Icons.cloud_download_outlined,
                  color: AppColors.statusGreen),
              onPressed: () => _mostrarDialogoSync(context, ref),
            ),
          // 🔍 BOTÓN DE DIAGNÓSTICO (temporal)
          IconButton(
            tooltip: 'Ver diagnóstico de la nube',
            icon: const Icon(Icons.bug_report, color: AppColors.neonCyan),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.panelDark,
                title: const Text('🔍 Diagnóstico de la nube',
                    style:
                        TextStyle(color: AppColors.neonCyan, fontSize: 16)),
                content: SingleChildScrollView(
                  child: SelectableText(
                    SheetsApiClient.ultimoDiagnostico,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CERRAR'),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.power_settings_new,
                color: AppColors.racingOrange),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.racingOrange,
        foregroundColor: AppColors.carbonBlack,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('NUEVO CLIENTE'),
        onPressed: () => _abrirFormularioNuevoCliente(context, ref),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. CASILLA FIJA: TOTAL GENERAL EN LA CALLE ──
            const _PanelTotalGeneral(),

            // ── 2. LEYENDA INTERACTIVA (onboarding de empleados) ──
            const _LeyendaSemaforo(),

            // ── 2.5 BUSCADOR: por nombre, cédula o teléfono ──
            const _BarraBusqueda(),

            const Divider(),

            // ── 3. LISTA EN VIVO DE CLIENTES (ya filtrada) ──
            Expanded(
              child: clientesFiltrados.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('No se pudo leer la base local.\n$e',
                      textAlign: TextAlign.center),
                ),
                data: (lista) => lista.isEmpty
                    ? (textoBusqueda.isEmpty
                        ? const _IndiceVacio()
                        : const _SinResultadosBusqueda())
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: lista.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _FilaCliente(cliente: lista[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Formulario sencillo para dar de alta una cuenta del índice físico
  void _abrirFormularioNuevoCliente(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nombreCtrl = TextEditingController();
    final cedulaCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final direccionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogo) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.gridLine),
        ),
        title: Text('REGISTRAR CUENTA',
            style: Theme.of(context).textTheme.titleLarge),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nombreCtrl,
                    decoration:
                        const InputDecoration(labelText: 'NOMBRE CLIENTE *'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'El nombre es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: cedulaCtrl,
                    decoration: const InputDecoration(
                        labelText: 'CÉDULA (OPCIONAL)'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'TELÉFONO *',
                        hintText: 'Con código de país para WhatsApp'),
                    validator: null, // Teléfono opcional
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: direccionCtrl,
                    decoration: const InputDecoration(
                        labelText: 'DIRECCIÓN (OPCIONAL)'),
                  ),
                  const SizedBox(height: 16),
                  // ★ FOLIO AUTOMÁTICO ★ — el sistema lo asigna solo,
                  // como la siguiente página en blanco del índice físico.
                  FutureBuilder<String>(
                    future:
                        ref.read(clientesRepositoryProvider).proximoFolio(),
                    builder: (_, foto) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.neonCyan),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tag,
                              color: AppColors.neonCyan, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'FOLIO ASIGNADO: Nº ${foto.data ?? '...'}',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppColors.neonCyan),
                          ),
                          const Spacer(),
                          Text('AUTOMÁTICO',
                              style:
                                  Theme.of(context).textTheme.labelSmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(160, 48)),
            onPressed: () async {
              if (formKey.currentState?.validate() != true) return;
              await ref.read(clientesRepositoryProvider).agregarCliente(
                    nombre: nombreCtrl.text,
                    cedula: cedulaCtrl.text,
                    telefono: telefonoCtrl.text.trim().isEmpty ? null : telefonoCtrl.text.trim(),
                    direccion: direccionCtrl.text,
                  );
              if (dialogo.mounted) Navigator.of(dialogo).pop();
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }
}

/// ── Casilla fija superior: el número más importante del negocio ──
class _PanelTotalGeneral extends ConsumerWidget {
  const _PanelTotalGeneral();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(totalGeneralProvider);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.racingOrange, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.racingOrangeDim,
            blurRadius: 32,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department,
                  color: AppColors.racingOrange, size: 18),
              const SizedBox(width: 8),
              Text('TOTAL GENERAL EN LA CALLE',
                  style: textTheme.labelSmall
                      ?.copyWith(color: AppColors.racingOrange)),
            ],
          ),
          const SizedBox(height: 6),
          total.when(
            loading: () => Text('\$ ---', style: textTheme.displayLarge),
            error: (_, __) => Text('\$ ERROR', style: textTheme.displayLarge),
            data: (monto) => Text(
              formatoDolar(monto),
              // Cifra grande en tipografía monoespaciada digital
              style: textTheme.labelLarge?.copyWith(
                fontSize: 38,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Leyenda interactiva del semáforo (onboarding de empleados) ──
class _LeyendaSemaforo extends StatelessWidget {
  const _LeyendaSemaforo();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Card(
        child: ExpansionTile(
          shape: const Border(), // sin borde extra al expandir
          leading:
              const Icon(Icons.traffic, color: AppColors.neonCyan, size: 22),
          title: Text('LEYENDA DEL SEMÁFORO · TOCA PARA VER',
              style: textTheme.labelSmall
                  ?.copyWith(color: AppColors.neonCyan)),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: const [
            _FilaLeyenda(
              color: AppColors.statusGreen,
              titulo: 'VERDE · ACTIVO',
              detalle: 'El cliente abonó hace 8 días o menos. Cuenta sana.',
            ),
            SizedBox(height: 10),
            _FilaLeyenda(
              color: AppColors.statusYellow,
              titulo: 'AMARILLO · INACTIVO',
              detalle:
                  'Entre 9 y 15 días sin abonar. Conviene recordarle por WhatsApp.',
            ),
            SizedBox(height: 10),
            _FilaLeyenda(
              color: AppColors.statusRed,
              titulo: 'ROJO · MORA',
              detalle:
                  'Más de 15 días sin abonar. Requiere gestión de cobro inmediata.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaLeyenda extends StatelessWidget {
  final Color color;
  final String titulo;
  final String detalle;
  const _FilaLeyenda(
      {required this.color, required this.titulo, required this.detalle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: .6), blurRadius: 8)
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: textTheme.titleMedium?.copyWith(color: color)),
              Text(detalle, style: textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// ── Una fila del índice: Cédula | Nombre | Teléfono | Folio | Estatus | Deuda ──
class _FilaCliente extends ConsumerWidget {
  final Cliente cliente;
  const _FilaCliente({required this.cliente});

  Color get _colorEstatus => switch (cliente.estatus) {
        EstatusCartera.verde => AppColors.statusGreen,
        EstatusCartera.amarillo => AppColors.statusYellow,
        EstatusCartera.rojo => AppColors.statusRed,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        // Tocar la fila → abrir la Hoja Individual del cliente
        onTap: () => context.go('/admin/clientes/${cliente.id}'),
        onLongPress: () => _confirmarEliminar(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Barra lateral con el color del semáforo
              Container(
                width: 4,
                height: 64,
                decoration: BoxDecoration(
                  color: _colorEstatus,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                        color: _colorEstatus.withValues(alpha: .5),
                        blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Folio del índice físico, ej: Nº 007
                        Text('Nº ${cliente.facturaN}',
                            style: textTheme.labelLarge
                                ?.copyWith(color: AppColors.neonCyan)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(cliente.nombre,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (cliente.cedula != null) 'CI ${cliente.cedula}',
                        if (cliente.telefono != null) cliente.telefono!,
                      ].join('  ·  '),
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _ChipEstatus(
                            color: _colorEstatus,
                            texto: cliente.estatus.etiqueta),
                        const SizedBox(width: 8),
                        Text('${cliente.diasSinAbonar} días',
                            style: textTheme.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Deuda en dólares, tipografía digital
              Text(
                formatoDolar(cliente.totalAdeudado),
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 17,
                  color: _colorEstatus,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogo) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text('¿ELIMINAR CUENTA?'),
        content: Text(
            'Se eliminará a "${cliente.nombre}" (Folio Nº ${cliente.facturaN}) del índice '
            'junto con TODOS sus cargos y abonos (eliminación en cascada).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRed,
              minimumSize: const Size(140, 48),
            ),
            onPressed: () async {
              await ref
                  .read(clientesRepositoryProvider)
                  .eliminarCliente(cliente.id);
              if (dialogo.mounted) Navigator.of(dialogo).pop();
            },
            child: const Text('ELIMINAR'),
          ),
        ],
      ),
    );
  }
}

class _ChipEstatus extends StatelessWidget {
  final Color color;
  final String texto;
  const _ChipEstatus({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        texto,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: color, letterSpacing: 1.5),
      ),
    );
  }
}


  /// Diálogo de confirmación + ejecución de la sincronización desde nube
  Future<void> _mostrarDialogoSync(BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text('☁️ Sincronizar desde la nube',
            style: TextStyle(color: AppColors.neonCyan)),
        content: const Text(
          'Esto REEMPLAZARÁ todos los datos locales con los que '
          'están en Google Sheets.\n\n'
          'Úsalo para:\n'
          '• Cargar datos del Sheets antiguo.\n'
          '• Sincronizar este dispositivo con otro.\n\n'
          'Los datos que subiste desde este dispositivo ya están '
          'guardados en la nube. ¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('SINCRONIZAR'),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;

    // Mostrar spinner mientras descarga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: AppColors.panelDark,
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Descargando desde la nube...\nEspera un momento.')),
          ],
        ),
      ),
    );

    try {
      final servicio = ref.read(sincronizacionBajadaProvider);
      final resumen = await servicio.sincronizarDesdeNube();
      if (context.mounted) Navigator.of(context).pop(); // cierra spinner
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.panelDark,
            title: const Text('✅ ¡Sincronización completada!',
                style: TextStyle(color: AppColors.statusGreen)),
            content: Text(resumen.mensaje),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('PERFECTO'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // cierra spinner
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.panelDark,
            title: const Text('❌ Error al sincronizar',
                style: TextStyle(color: Colors.red)),
            content: Text('Detalle: $e\n\nRevisa tu conexión a internet y vuelve a intentar.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CERRAR'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// ── Indicador de la cola del espejo en la barra superior ──
class _IndicadorSync extends StatelessWidget {
  final int pendientes;
  const _IndicadorSync({required this.pendientes});

  @override
  Widget build(BuildContext context) {
    final alDia = pendientes == 0;
    return Tooltip(
      message: alDia
          ? 'Espejo al día'
          : '$pendientes dato(s) en cola para subir a Google Sheets',
      child: InkWell(
        // 🔍 TOCAR LA NUBE → muestra el diagnóstico del último intento
        // de subida (temporal, para cazar el error del teléfono).
        onTap: () => _mostrarDiagnostico(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(
                alDia
                    ? Icons.cloud_done_outlined
                    : Icons.cloud_upload_outlined,
                color: alDia ? AppColors.statusGreen : AppColors.statusYellow,
                size: 20,
              ),
              if (!alDia) ...[
                const SizedBox(width: 4),
                Text('$pendientes',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.statusYellow)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 🔍 Muestra en pantalla el detalle del último intento de subida.
  /// Es temporal, para diagnosticar por qué el teléfono no sube.
  void _mostrarDiagnostico(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.panelDark,
        title: const Text('🔍 Diagnóstico de la nube',
            style: TextStyle(color: AppColors.neonCyan, fontSize: 16)),
        content: SingleChildScrollView(
          child: SelectableText(
            SheetsApiClient.ultimoDiagnostico,
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CERRAR'),
          ),
        ],
      ),
    );
  }
}

/// ── Estado vacío: invitación a actuar ──
class _IndiceVacio extends StatelessWidget {
  const _IndiceVacio();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_open_outlined,
              size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('El índice está vacío', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Use el botón NUEVO CLIENTE para registrar la primera cuenta',
              style: textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// ── BARRA DE BÚSQUEDA: filtra por nombre, cédula o teléfono ──
/// Es un ConsumerStatefulWidget porque necesita un TextEditingController
/// propio (para poder mostrar la "X" de limpiar y mantener el cursor).
class _BarraBusqueda extends ConsumerStatefulWidget {
  const _BarraBusqueda();

  @override
  ConsumerState<_BarraBusqueda> createState() => _BarraBusquedaState();
}

class _BarraBusquedaState extends ConsumerState<_BarraBusqueda> {
  late final TextEditingController _controlador;

  @override
  void initState() {
    super.initState();
    _controlador = TextEditingController();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hayTexto = ref.watch(textoBusquedaProvider).isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: _controlador,
        // Cada letra escrita actualiza el provider, que filtra la
        // lista en vivo — sin botón "buscar", es instantáneo.
        onChanged: (texto) =>
            ref.read(textoBusquedaProvider.notifier).state = texto,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Buscar por nombre, cédula o teléfono...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: hayTexto
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Limpiar búsqueda',
                  onPressed: () {
                    _controlador.clear();
                    ref.read(textoBusquedaProvider.notifier).state = '';
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

/// ── Mensaje cuando la búsqueda no encuentra a nadie ──
class _SinResultadosBusqueda extends ConsumerWidget {
  const _SinResultadosBusqueda();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final texto = ref.watch(textoBusquedaProvider);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('Sin resultados para "$texto"', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Prueba con el nombre, cédula o teléfono completo o parcial',
              style: textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
