import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fondo_chip.dart';
import '../../core/utils/formato.dart';
import '../../data/services/foto_service.dart';
import '../../domain/entities/producto.dart';
import '../providers/auth_providers.dart';
import '../providers/clientes_providers.dart';
import '../providers/inventario_providers.dart';

/// ─────────────────────────────────────────────────────────────────
/// CATÁLOGO DE INVENTARIO VISUAL · Pantalla COMPARTIDA.
///
/// EMPLEADO ve: buscador, doble filtro, tarjetas con foto,
///   compatibilidad, stock y PVP. (El costo no existe para él:
///   se descartó en la capa de datos.)
/// ADMIN ve además: chip de COSTO/GANANCIA, botón NUEVO PRODUCTO,
///   y el menú de cada tarjeta (DUPLICAR / EDITAR / ELIMINAR).
/// ─────────────────────────────────────────────────────────────────
class CatalogoScreen extends ConsumerWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(productosFiltradosProvider);
    final cargando = ref.watch(productosProvider).isLoading;
    final enAlerta = ref.watch(productosEnAlertaProvider);
    final usuario = ref.watch(usuarioActualProvider);
    final textTheme = Theme.of(context).textTheme;

    return FondoChip(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('CATÁLOGO'),
        actions: [
          // Contador de productos agotándose (visible para todos:
          // al empleado también le sirve saber qué se acaba)
          if (enAlerta > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _ChipParpadeante(
                color: AppColors.statusRed,
                child: Text('$enAlerta EN ALERTA',
                    style: textTheme.labelSmall
                        ?.copyWith(color: AppColors.statusRed)),
              ),
            ),
          // ★ FASE 10-A · Botón ☁️ SINCRONIZAR — baja lo último de
          // Sheets a mano, sin esperar el ciclo automático de 2 min.
          const _BotonSincronizarCatalogo(),
          // ★ FASE 10 · FACTURA RÁPIDA — venta de mostrador a cliente
          // ocasional: se llena a mano, se imprime y NO guarda nada.
          SoloAdmin(
            child: IconButton(
              tooltip: 'Factura rápida (cliente ocasional)',
              icon: const Icon(Icons.receipt_long,
                  color: AppColors.neonCyan),
              onPressed: () => context.go(AppRoutes.adminFactura),
            ),
          ),
          SoloAdmin(
            child: IconButton(
              tooltip: 'Volver al Modo JEFE',
              icon: const Icon(Icons.dashboard_customize_outlined),
              onPressed: () => context.go(AppRoutes.adminDashboard),
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
      // ── Botón NUEVO PRODUCTO: SOLO existe para el ADMIN ──
      floatingActionButton: SoloAdmin(
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.racingOrange,
          foregroundColor: AppColors.carbonBlack,
          icon: const Icon(Icons.add_box_outlined),
          label: const Text('NUEVO PRODUCTO'),
          onPressed: () => _abrirFormulario(context, ref),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                'OPERADOR: ${usuario?.nombreCompleto.toUpperCase() ?? '—'} · '
                'ROL: ${usuario?.rol.toDb() ?? '—'}',
                style:
                    textTheme.labelSmall?.copyWith(color: AppColors.neonCyan),
              ),
            ),

            // ── BUSCADOR INTELIGENTE + DOBLE FILTRO CRUZADO ──
            const _BarraBusquedaYFiltros(),
            const Divider(),

            // ── REJILLA DE TARJETAS VISUALES ──
            Expanded(
              child: cargando
                  ? const Center(child: CircularProgressIndicator())
                  : productos.isEmpty
                      ? const _CatalogoVacio()
                      : LayoutBuilder(
                          // 👶 LayoutBuilder mide el ancho disponible:
                          // móvil = 2 columnas, tablet/PC = más columnas.
                          builder: (_, medidas) {
                            final columnas =
                                (medidas.maxWidth / 230).floor().clamp(2, 6);
                            return GridView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 8, 12, 96),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columnas,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                // ★ FASE 10-A: altura FIJA de tarjeta.
                                // Antes era una proporción (.72) y al
                                // agregar más líneas de datos se podía
                                // desbordar; con altura fija, la foto
                                // se estira o encoge sola y el texto
                                // siempre cabe.
                                mainAxisExtent: 336,
                              ),
                              itemCount: productos.length,
                              itemBuilder: (_, i) => _TarjetaProducto(
                                producto: productos[i],
                                onMenu: (accion) => _accionDeMenu(
                                    context, ref, productos[i], accion),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _accionDeMenu(BuildContext context, WidgetRef ref, Producto producto,
      String accion) {
    switch (accion) {
      case 'duplicar':
        // ★ DUPLICADOR RÁPIDO: abre el formulario PRELLENADO con los
        // datos del original; solo cambias el detalle y guardas.
        _abrirFormulario(context, ref,
            inicial: producto, esDuplicado: true);
      case 'editar':
        _abrirFormulario(context, ref, inicial: producto);
      case 'eliminar':
        showDialog(
          context: context,
          builder: (dialogo) => AlertDialog(
            backgroundColor: AppColors.panelDark,
            title: const Text('¿ELIMINAR PRODUCTO?'),
            content: Text('"${producto.nombre}" saldrá del catálogo.'),
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
                      .read(inventarioRepositoryProvider)
                      .eliminarProducto(producto.id);
                  if (dialogo.mounted) Navigator.of(dialogo).pop();
                },
                child: const Text('ELIMINAR'),
              ),
            ],
          ),
        );
    }
  }

  void _abrirFormulario(BuildContext context, WidgetRef ref,
      {Producto? inicial, bool esDuplicado = false}) {
    showDialog(
      context: context,
      builder: (_) => _FormularioProducto(
          inicial: inicial, esDuplicado: esDuplicado),
    );
  }
}

// ═══════════════ BUSCADOR + DOBLE FILTRO CRUZADO ═══════════════

class _BarraBusquedaYFiltros extends ConsumerWidget {
  const _BarraBusquedaYFiltros();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorias = ref.watch(categoriasDisponiblesProvider);
    final vehiculos = ref.watch(vehiculosDisponiblesProvider);
    final categoriaSel = ref.watch(filtroCategoriaProvider);
    final vehiculoSel = ref.watch(filtroVehiculoProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        children: [
          // Barra de texto: cada letra repinta la rejilla al instante
          TextField(
            decoration: const InputDecoration(
              labelText: 'BUSCAR',
              hintText: 'Producto, etiqueta o vehículo (ej: faro cargo)',
              prefixIcon:
                  Icon(Icons.search, color: AppColors.neonCyan, size: 22),
            ),
            onChanged: (texto) =>
                ref.read(busquedaTextoProvider.notifier).state = texto,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // ── FILTRO A: CATEGORÍA (tipo de mercancía) ──
              Expanded(
                child: _Desplegable(
                  etiqueta: 'CATEGORÍA',
                  valor: categoriaSel,
                  opciones: categorias,
                  acento: AppColors.neonCyan,
                  onCambio: (v) =>
                      ref.read(filtroCategoriaProvider.notifier).state = v,
                ),
              ),
              const SizedBox(width: 10),
              // ── FILTRO B: VEHÍCULO (marca/modelo) ──
              Expanded(
                child: _Desplegable(
                  etiqueta: 'VEHÍCULO',
                  valor: vehiculoSel,
                  opciones: vehiculos,
                  acento: AppColors.racingOrange,
                  onCambio: (v) =>
                      ref.read(filtroVehiculoProvider.notifier).state = v,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Desplegable extends StatelessWidget {
  final String etiqueta;
  final String? valor;
  final List<String> opciones;
  final Color acento;
  final ValueChanged<String?> onCambio;

  const _Desplegable({
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.acento,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: valor == null ? AppColors.gridLine : acento,
          width: valor == null ? 1 : 1.4,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: valor,
          isExpanded: true,
          dropdownColor: AppColors.panelDark,
          icon: Icon(Icons.arrow_drop_down, color: acento),
          hint: Text(etiqueta,
              style: textTheme.labelSmall),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('TODAS', style: textTheme.bodyMedium),
            ),
            for (final op in opciones)
              DropdownMenuItem<String?>(
                value: op,
                child: Text(op,
                    style: textTheme.bodyLarge?.copyWith(color: acento)),
              ),
          ],
          onChanged: onCambio,
        ),
      ),
    );
  }
}

// ═══════════════ TARJETA VISUAL DEL PRODUCTO ═══════════════

class _TarjetaProducto extends ConsumerWidget {
  final Producto producto;
  final ValueChanged<String> onMenu;
  const _TarjetaProducto({required this.producto, required this.onMenu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    // ★ ALERTA DE STOCK: el borde de TODA la tarjeta cambia de color
    final colorAlerta = producto.agotado
        ? AppColors.statusRed
        : producto.stockBajo
            ? AppColors.racingOrange
            : AppColors.gridLine;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: colorAlerta, width: producto.enAlerta ? 1.6 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── FOTO + chips flotantes ──
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(5)),
                  child: _FotoProducto(ruta: producto.urlFoto),
                ),
                // Chip de stock (parpadea si está en alerta)
                Positioned(
                  top: 6,
                  left: 6,
                  child: producto.enAlerta
                      ? _ChipParpadeante(
                          color: colorAlerta,
                          child: Text(
                            producto.agotado
                                ? 'AGOTADO'
                                : 'STOCK ${producto.stockActual}',
                            style: textTheme.labelSmall
                                ?.copyWith(color: colorAlerta, fontSize: 10),
                          ),
                        )
                      : _ChipFijo(
                          color: AppColors.statusGreen,
                          texto: 'STOCK ${producto.stockActual}',
                        ),
                ),
                // Menú de 3 puntos: SOLO existe para el ADMIN
                Positioned(
                  top: 0,
                  right: 0,
                  child: SoloAdmin(
                    child: PopupMenuButton<String>(
                      color: AppColors.panelDark,
                      icon: const Icon(Icons.more_vert,
                          color: AppColors.textPrimary, size: 20),
                      onSelected: onMenu,
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'duplicar',
                            child: Row(children: [
                              Icon(Icons.copy_all_outlined,
                                  size: 18, color: AppColors.neonCyan),
                              SizedBox(width: 8),
                              Text('DUPLICAR'),
                            ])),
                        PopupMenuItem(
                            value: 'editar',
                            child: Row(children: [
                              Icon(Icons.edit_outlined,
                                  size: 18, color: AppColors.statusYellow),
                              SizedBox(width: 8),
                              Text('EDITAR'),
                            ])),
                        PopupMenuItem(
                            value: 'eliminar',
                            child: Row(children: [
                              Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.statusRed),
                              SizedBox(width: 8),
                              Text('ELIMINAR'),
                            ])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── DATOS ──
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                // ★ FASE 10-A · FICHA COMPLETA A LA VISTA ★
                // Todo lo necesario para identificar el producto de un
                // solo vistazo: categorías (filtros), vehículos
                // compatibles y especificaciones. El PRECIO DE COMPRA
                // ya NO se muestra aquí (solo vive dentro del
                // formulario de edición del ADMIN).
                // Categorías / filtros (ej: FILTROS, ELECTRICA)
                if (producto.categorias.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      '⬦ ${Producto.unirTags(producto.categorias)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall
                          ?.copyWith(color: AppColors.neonCyan, fontSize: 10),
                    ),
                  ),
                // Vehículos compatibles (ej: FORD, CARGO)
                Text(
                  '🚗 ${Producto.unirTags(producto.vehiculos)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall
                      ?.copyWith(color: AppColors.racingOrange, fontSize: 10),
                ),
                // Especificaciones del producto (descripción técnica)
                if (producto.descripcion != null &&
                    producto.descripcion!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      producto.descripcion!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                          fontSize: 9.5, color: AppColors.textSecondary),
                    ),
                  ),
                const SizedBox(height: 6),
                // PVP destacado + unidades disponibles, en una fila.
                // ★ Fase 8: si el precio está pendiente, se muestra
                // "SIN PRECIO" en naranja para que salte a la vista.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      producto.pvp == null
                          ? 'SIN PRECIO'
                          : formatoDolar(producto.pvp!),
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: producto.pvp == null ? 15 : 19,
                        color: producto.pvp == null
                            ? AppColors.racingOrange
                            : AppColors.neonCyan,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${producto.stockActual} UND',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: producto.agotado
                            ? AppColors.statusRed
                            : producto.stockBajo
                                ? AppColors.racingOrange
                                : AppColors.statusGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra la foto venga de donde venga: internet, archivo local o nada
class _FotoProducto extends StatelessWidget {
  final String? ruta;
  const _FotoProducto({required this.ruta});

  @override
  Widget build(BuildContext context) {
    if (ruta == null || ruta!.isEmpty) {
      return Container(
        color: AppColors.surfaceRaised,
        child: const Icon(Icons.no_photography_outlined,
            size: 40, color: AppColors.textDisabled),
      );
    }
    // Foto embebida (texto base64) → camino inverso: texto → imagen
    if (FotoService.esFotoEmbebida(ruta)) {
      return Image.memory(FotoService.bytesDeFoto(ruta!),
          fit: BoxFit.cover,
          gaplessPlayback: true, // Evita parpadeos al repintar la rejilla
          errorBuilder: (_, __, ___) => const _FotoProducto(ruta: null));
    }
    // Link de internet (cuando la nube esté activa)
    if (FotoService.esUrlDeInternet(ruta)) {
      return Image.network(ruta!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _FotoProducto(ruta: null));
    }
    // Ruta vieja de archivo u otro formato → ícono gris
    return const _FotoProducto(ruta: null);
  }
}

/// ★ EL CHIP PARPADEANTE ★ — late entre visible y tenue, como una
/// luz de advertencia del tablero de un auto.
class _ChipParpadeante extends StatefulWidget {
  final Color color;
  final Widget child;
  const _ChipParpadeante({required this.color, required this.child});

  @override
  State<_ChipParpadeante> createState() => _ChipParpadeanteState();
}

class _ChipParpadeanteState extends State<_ChipParpadeante>
    with SingleTickerProviderStateMixin {
  late final AnimationController _latido = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true); // 👶 va y viene: 1.0 → 0.35 → 1.0 → ...

  @override
  void dispose() {
    _latido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: .35).animate(
          CurvedAnimation(parent: _latido, curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.carbonBlack.withValues(alpha: .85),
          border: Border.all(color: widget.color, width: 1.2),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
                color: widget.color.withValues(alpha: .55), blurRadius: 10),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _ChipFijo extends StatelessWidget {
  final Color color;
  final String texto;
  const _ChipFijo({required this.color, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.carbonBlack.withValues(alpha: .85),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(texto,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: color, fontSize: 10)),
    );
  }
}

// ═══════════════ FORMULARIO DE REGISTRO RÁPIDO (ADMIN) ═══════════════

class _FormularioProducto extends ConsumerStatefulWidget {
  final Producto? inicial;     // null = producto nuevo desde cero
  final bool esDuplicado;      // true = vino del DUPLICADOR RÁPIDO

  const _FormularioProducto({this.inicial, this.esDuplicado = false});

  @override
  ConsumerState<_FormularioProducto> createState() =>
      _FormularioProductoState();
}

class _FormularioProductoState extends ConsumerState<_FormularioProducto> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _categorias;
  late final TextEditingController _vehiculos;
  late final TextEditingController _costo;
  late final TextEditingController _pvp;
  late final TextEditingController _stock;
  late final TextEditingController _stockMin;
  String? _rutaFoto;
  bool _guardando = false;

  bool get _esEdicion => widget.inicial != null && !widget.esDuplicado;

  @override
  void initState() {
    super.initState();
    final p = widget.inicial;
    _nombre = TextEditingController(
        text: p == null
            ? ''
            : widget.esDuplicado
                ? '${p.nombre} (COPIA)'
                : p.nombre);
    _descripcion = TextEditingController(text: p?.descripcion ?? '');
    _categorias = TextEditingController(
        text: p == null ? '' : Producto.unirTags(p.categorias));
    _vehiculos = TextEditingController(
        text: p == null ? '' : Producto.unirTags(p.vehiculos));
    _costo =
        TextEditingController(text: p?.costo?.toStringAsFixed(2) ?? '');
    _pvp = TextEditingController(text: p?.pvp?.toStringAsFixed(2) ?? '');
    _stock = TextEditingController(text: p?.stockActual.toString() ?? '');
    _stockMin = TextEditingController(text: p?.stockMinimo.toString() ?? '1');
    _rutaFoto = p?.urlFoto;
  }

  @override
  void dispose() {
    for (final c in [
      _nombre, _descripcion, _categorias, _vehiculos,
      _costo, _pvp, _stock, _stockMin,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// ★ Fase 8: campo vacío = null (precio pendiente). Si escriben
  /// algo, se convierte a número (acepta coma o punto decimal).
  double? _numOpcional(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  /// Para los stocks: vacío = 0 unidades / sin umbral de alerta.
  int _entero(TextEditingController c) =>
      int.tryParse(c.text.trim()) ?? 0;

  /// Valida SOLO el formato: vacío está permitido (es "pendiente"),
  /// pero si escriben algo tiene que ser un número válido.
  String? _validaNumOpcional(String? v, {bool entero = false}) {
    if (v == null || v.trim().isEmpty) return null; // vacío = OK
    final ok = entero
        ? int.tryParse(v.trim()) != null
        : double.tryParse(v.replaceAll(',', '.')) != null;
    return ok ? null : 'Solo números';
  }

  Future<void> _tomarOFotoGaleria() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.panelDark,
      builder: (hoja) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.photo_camera, color: AppColors.neonCyan),
              title: const Text('TOMAR FOTO CON LA CÁMARA'),
              onTap: () async {
                Navigator.of(hoja).pop();
                final ruta = await FotoService.tomarFoto();
                if (ruta != null) setState(() => _rutaFoto = ruta);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.racingOrange),
              title: const Text('ELEGIR DE LA GALERÍA'),
              onTap: () async {
                Navigator.of(hoja).pop();
                final ruta = await FotoService.elegirDeGaleria();
                if (ruta != null) setState(() => _rutaFoto = ruta);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _guardando = true);

    final repo = ref.read(inventarioRepositoryProvider);
    final categorias = Producto.parsearTags(_categorias.text);
    final vehiculos = Producto.parsearTags(_vehiculos.text);

    if (_esEdicion) {
      await repo.actualizarProducto(
        id: widget.inicial!.id,
        nombre: _nombre.text,
        descripcion: _descripcion.text,
        categorias: categorias,
        vehiculos: vehiculos.isEmpty ? ['UNIVERSAL'] : vehiculos,
        costo: _numOpcional(_costo),
        pvp: _numOpcional(_pvp),
        stockActual: _entero(_stock),
        stockMinimo: _entero(_stockMin),
        urlFoto: _rutaFoto,
      );
    } else {
      await repo.agregarProducto(
        nombre: _nombre.text,
        descripcion: _descripcion.text,
        categorias: categorias,
        vehiculos: vehiculos.isEmpty ? ['UNIVERSAL'] : vehiculos,
        costo: _numOpcional(_costo),
        pvp: _numOpcional(_pvp),
        stockActual: _entero(_stock),
        stockMinimo: _entero(_stockMin),
        urlFoto: _rutaFoto,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titulo = _esEdicion
        ? 'EDITAR PRODUCTO'
        : widget.esDuplicado
            ? 'DUPLICAR PRODUCTO'
            : 'NUEVO PRODUCTO';

    return AlertDialog(
      backgroundColor: AppColors.panelDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.neonCyan),
      ),
      title: Text(titulo, style: textTheme.titleLarge),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── BOTÓN DE LA CÁMARA + vista previa ──
                InkWell(
                  onTap: _tomarOFotoGaleria,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: _rutaFoto == null
                              ? AppColors.gridLine
                              : AppColors.neonCyan),
                    ),
                    child: _rutaFoto == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_outlined,
                                  color: AppColors.neonCyan, size: 32),
                              const SizedBox(height: 6),
                              Text('TOCAR PARA AGREGAR FOTO',
                                  style: textTheme.labelSmall),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: _FotoProducto(ruta: _rutaFoto),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nombre,
                  autofocus: !widget.esDuplicado,
                  decoration: const InputDecoration(
                      labelText: 'NOMBRE DEL PRODUCTO *'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcion,
                  decoration: const InputDecoration(
                      labelText: 'DESCRIPCIÓN (OPCIONAL)',
                      hintText: 'Detalle técnico, conector, color...'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categorias,
                  decoration: const InputDecoration(
                      labelText: 'CATEGORÍAS (separadas por coma) *',
                      hintText: 'Ej: SONIDO, ELECTRICA'),
                  validator: (v) =>
                      Producto.parsearTags(v ?? '').isEmpty
                          ? 'Al menos una categoría'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _vehiculos,
                  decoration: const InputDecoration(
                      labelText: 'COMPATIBILIDAD (separada por coma)',
                      hintText: 'Ej: FORD, CARGO · vacío = UNIVERSAL'),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costo,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                          labelText: r'COSTO ($) 🔒',
                          hintText: 'Vacío = pendiente · solo ADMIN'),
                      validator: _validaNumOpcional,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _pvp,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                          labelText: r'PVP ($)',
                          hintText: 'Vacío = SIN PRECIO'),
                      validator: _validaNumOpcional,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stock,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'STOCK ACTUAL',
                          hintText: 'Vacío = 0'),
                      validator: (v) => _validaNumOpcional(v, entero: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockMin,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'STOCK MÍNIMO',
                          hintText: 'Umbral de alerta · vacío = sin alerta'),
                      validator: (v) => _validaNumOpcional(v, entero: true),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _guardando ? null : () => Navigator.of(context).pop(),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4))
              : Text(_esEdicion ? 'GUARDAR CAMBIOS' : 'REGISTRAR'),
        ),
      ],
    );
  }
}

class _CatalogoVacio extends StatelessWidget {
  const _CatalogoVacio();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('Sin resultados en el catálogo', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Pruebe con otra búsqueda o quite los filtros.\n'
            'El ADMIN puede registrar mercancía con el botón NUEVO PRODUCTO.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


// ═══════════════ BOTÓN ☁️ SINCRONIZAR (FASE 10-A) ═══════════════
//
//  👶 Mismo motor de bajada que ya usa el resto de la app (el del
//  polling de 2 minutos), pero disparado a mano: baja clientes,
//  cuentas, inventario y notas de Sheets AHORA, sin esperar. Útil
//  cuando acabas de cargar productos o fotos desde otro aparato y
//  quieres verlos ya.
class _BotonSincronizarCatalogo extends ConsumerStatefulWidget {
  const _BotonSincronizarCatalogo();

  @override
  ConsumerState<_BotonSincronizarCatalogo> createState() =>
      _BotonSincronizarCatalogoState();
}

class _BotonSincronizarCatalogoState
    extends ConsumerState<_BotonSincronizarCatalogo> {
  bool _sincronizando = false;

  Future<void> _sincronizar() async {
    if (_sincronizando) return;
    setState(() => _sincronizando = true);
    try {
      final resumen = await ref
          .read(sincronizacionBajadaProvider)
          .sincronizarDesdeNube();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resumen.mensaje),
          backgroundColor: AppColors.panelDark,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo sincronizar: $e'),
          backgroundColor: AppColors.panelDark,
        ),
      );
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Sincronizar con la nube',
      onPressed: _sincronizando ? null : _sincronizar,
      icon: _sincronizando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2.2, color: AppColors.neonCyan),
            )
          : const Icon(Icons.cloud_sync_outlined, color: AppColors.neonCyan),
    );
  }
}
