import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formato.dart';
import '../../domain/entities/linea_cuenta.dart';
import '../providers/cuenta_providers.dart';

/// ─────────────────────────────────────────────────────────────────
/// CARGA RÁPIDA · Rejilla estilo hoja de cálculo para cargar una
/// factura completa de un solo aliento.
///
/// 👶 EL TECLADO INTELIGENTE (lo que pidió el jefe):
///  · ENTER     → salta a la siguiente casilla; al terminar la fila,
///                baja a la primera casilla de la fila siguiente
///                (y si no existe, LA CREA sola: filas infinitas).
///  · FLECHA ↓↑ → baja/sube a la misma columna de otra fila.
///  · CLIC      → edita cualquier casilla, como en Sheets.
///  · TOTAL en vivo abajo, sumando mientras escribes.
///  · GUARDAR TODO → las filas entran juntas en UNA transacción
///                (todo-o-nada) con UN solo recálculo del saldo.
/// ─────────────────────────────────────────────────────────────────
class CargaRapidaDialog extends ConsumerStatefulWidget {
  final String idCliente;
  const CargaRapidaDialog({super.key, required this.idCliente});

  @override
  ConsumerState<CargaRapidaDialog> createState() => _CargaRapidaState();
}

/// Una fila de la rejilla: 4 casillas con sus controles y focos.
/// Columnas: 0=CANT · 1=PRODUCTO · 2=P.UNIT · 3=COSTO(opcional)
class _Fila {
  final controles = List.generate(4, (_) => TextEditingController());
  final focos = List.generate(4, (_) => FocusNode());

  _Fila() {
    controles[0].text = '1'; // Cantidad arranca en 1, como en el papel
  }

  void dispose() {
    for (final c in controles) {
      c.dispose();
    }
    for (final f in focos) {
      f.dispose();
    }
  }

  bool get estaVacia =>
      controles[1].text.trim().isEmpty &&
      controles[2].text.trim().isEmpty &&
      controles[3].text.trim().isEmpty;
}

class _CargaRapidaState extends ConsumerState<CargaRapidaDialog> {
  // Arrancamos con 3 filas en blanco, como una hoja lista para escribir
  final List<_Fila> _filas = [_Fila(), _Fila(), _Fila()];
  bool _guardando = false;

  @override
  void dispose() {
    for (final f in _filas) {
      f.dispose();
    }
    super.dispose();
  }

  double? _num(String texto) =>
      double.tryParse(texto.replaceAll(',', '.').trim());

  /// ── ENTER: el corazón del flujo tipo Sheets ──
  void _alDarEnter(int fila, int col) {
    if (col < 3) {
      // Siguiente casilla de la misma fila
      _filas[fila].focos[col + 1].requestFocus();
    } else {
      // Fin de la fila → bajar a la primera casilla de la siguiente,
      // creándola si hace falta (la hoja crece sola hacia abajo)
      if (fila == _filas.length - 1) {
        setState(() => _filas.add(_Fila()));
      }
      // Esperar un parpadeo a que la fila nueva exista en pantalla
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && fila + 1 < _filas.length) {
          _filas[fila + 1].focos[0].requestFocus();
        }
      });
    }
  }

  /// ── FLECHAS ↑↓: moverse entre filas en la misma columna ──
  /// 👶 REGLA DE ORO DE ESTE MÉTODO: tocar SOLO las flechas arriba y
  /// abajo. TODO lo demás (flechas ←→, letras, números, borrar,
  /// inicio/fin...) se deja pasar intacto al campo de texto. Por eso
  /// solo capturamos esas dos teclas concretas y para el resto
  /// devolvemos "ignored" de inmediato, sin tocar nada.
  KeyEventResult _alTocarFlechas(KeyEvent evento, int fila, int col) {
    // Las flechas laterales JAMÁS se interceptan: mueven el cursor
    // dentro del texto, como en cualquier casilla normal.
    final esArribaOAbajo =
        evento.logicalKey == LogicalKeyboardKey.arrowUp ||
            evento.logicalKey == LogicalKeyboardKey.arrowDown;
    if (!esArribaOAbajo) return KeyEventResult.ignored;

    // Solo actuamos al PRESIONAR (no al soltar ni al repetir)
    if (evento is! KeyDownEvent) return KeyEventResult.ignored;

    if (evento.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (fila < _filas.length - 1) {
        _filas[fila + 1].focos[col].requestFocus();
      }
      return KeyEventResult.handled;
    }
    // arrowUp
    if (fila > 0) {
      _filas[fila - 1].focos[col].requestFocus();
    }
    return KeyEventResult.handled;
  }

  /// Total en vivo: suma de cantidad × precio de las filas válidas
  double get _totalEnVivo {
    var total = 0.0;
    for (final f in _filas) {
      final cant = _num(f.controles[0].text);
      final precio = _num(f.controles[2].text);
      if (cant != null && precio != null) total += cant * precio;
    }
    return total;
  }

  Future<void> _guardarTodo() async {
    final cargos = <NuevoCargo>[];

    for (var i = 0; i < _filas.length; i++) {
      final f = _filas[i];
      if (f.estaVacia) continue; // Filas en blanco se ignoran en paz

      final descripcion = f.controles[1].text.trim();
      final cantidad = _num(f.controles[0].text);
      final precio = _num(f.controles[2].text);
      final costoTexto = f.controles[3].text.trim();
      final costo = costoTexto.isEmpty ? null : _num(costoTexto);

      // Validación con dedo en la fila exacta del problema
      String? problema;
      if (descripcion.isEmpty) {
        problema = 'falta el producto/servicio';
      } else if (cantidad == null || cantidad <= 0) {
        problema = 'cantidad inválida';
      } else if (precio == null || precio < 0) {
        problema = 'precio inválido';
      } else if (costoTexto.isNotEmpty && costo == null) {
        problema = 'costo inválido';
      }

      if (problema != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Revise la fila ${i + 1}: $problema')));
        f.focos[descripcion.isEmpty ? 1 : 0].requestFocus();
        return;
      }

      cargos.add(NuevoCargo(
        cantidad: cantidad!,
        descripcion: descripcion,
        precioUnitario: precio!,
        costoUnitario: costo,
      ));
    }

    if (cargos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No hay líneas para guardar todavía')));
      return;
    }

    setState(() => _guardando = true);
    await ref.read(cuentasRepositoryProvider).agregarCargos(
          idCliente: widget.idCliente,
          cargos: cargos,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // 👶 DETECTOR DE PANTALLA: si el ancho disponible es menor a 600px
    // estamos en un TELÉFONO → usamos tarjetas verticales apiladas.
    // Si es mayor (PC/tablet) → la rejilla horizontal de siempre.
    final esMovil = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: AppColors.panelDark,
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.racingOrange),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('CARGA RÁPIDA DE PRODUCTOS / SERVICIOS',
                  style: textTheme.titleLarge
                      ?.copyWith(color: AppColors.racingOrange)),
              const SizedBox(height: 4),
              Text(
                esMovil
                    ? 'Llena cada producto y toca GUARDAR TODO al final'
                    : 'ENTER avanza · FLECHAS ↑↓ cambian de fila · CLIC edita cualquier casilla',
                style: textTheme.labelSmall,
              ),
              const SizedBox(height: 14),

              // ── Encabezados (solo en PC; en móvil cada tarjeta los trae) ──
              if (!esMovil) ...[
                Row(
                  children: [
                    _encabezado('CANT.', 64),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _encabezadoFlexible('PRODUCTO - SERVICIO')),
                    const SizedBox(width: 8),
                    _encabezado(r'P. UNIT ($)', 104),
                    const SizedBox(width: 8),
                    _encabezado(r'COSTO ($) 🔒', 104),
                    const SizedBox(width: 32),
                  ],
                ),
                const SizedBox(height: 6),
              ],

              // ── Las filas (crecen sin límite) ──
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filas.length,
                  itemBuilder: (_, i) =>
                      esMovil ? _tarjetaMovil(i) : _filaPc(i),
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('AGREGAR FILA'),
                  onPressed: () => setState(() => _filas.add(_Fila())),
                ),
              ),
              const Divider(),

              // ── Total en vivo + acciones ──
              // En móvil van apilados (Columna) para que nada se corte.
              if (esMovil)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL DE LA CARGA:',
                            style: textTheme.labelSmall),
                        Text(
                          formatoDolar(_totalEnVivo),
                          style: textTheme.labelLarge?.copyWith(
                              fontSize: 20,
                              color: AppColors.racingOrange,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 52)),
                      onPressed: _guardando ? null : _guardarTodo,
                      icon: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.2))
                          : const Icon(Icons.playlist_add_check, size: 20),
                      label: const Text('GUARDAR TODO'),
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: _guardando
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('CANCELAR'),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Text('TOTAL DE LA CARGA: ',
                        style: textTheme.labelSmall),
                    Text(
                      formatoDolar(_totalEnVivo),
                      style: textTheme.labelLarge?.copyWith(
                          fontSize: 18,
                          color: AppColors.racingOrange,
                          fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _guardando
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('CANCELAR'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(190, 48)),
                      onPressed: _guardando ? null : _guardarTodo,
                      icon: _guardando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.2))
                          : const Icon(Icons.playlist_add_check, size: 20),
                      label: const Text('GUARDAR TODO'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Una fila en formato PC (rejilla horizontal, con teclado inteligente)
  Widget _filaPc(int i) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            _casilla(i, 0, ancho: 64),
            const SizedBox(width: 8),
            Expanded(
                child: _casilla(i, 1,
                    pista: i == 0 ? 'Ej: Faro Ford Cargo' : null)),
            const SizedBox(width: 8),
            _casilla(i, 2, ancho: 104),
            const SizedBox(width: 8),
            _casilla(i, 3, ancho: 104),
            ExcludeFocus(
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.close,
                    size: 16, color: AppColors.textDisabled),
                tooltip: 'Quitar fila',
                onPressed: _filas.length <= 1
                    ? null
                    : () => setState(() => _filas.removeAt(i).dispose()),
              ),
            ),
          ],
        ),
      );

  /// Una "tarjeta" en formato MÓVIL: campos apilados verticalmente,
  /// grandes y cómodos para el dedo. Cada uno con su etiqueta encima.
  Widget _tarjetaMovil(int i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PRODUCTO #${i + 1}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.neonCyan)),
                if (_filas.length > 1)
                  GestureDetector(
                    onTap: () =>
                        setState(() => _filas.removeAt(i).dispose()),
                    child: const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.textDisabled),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _campoMovil(i, 1, 'PRODUCTO / SERVICIO',
                pista: 'Ej: Faro Ford Cargo'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _campoMovil(i, 0, 'CANT.')),
                const SizedBox(width: 8),
                Expanded(child: _campoMovil(i, 2, r'P. UNIT ($)')),
              ],
            ),
            const SizedBox(height: 8),
            _campoMovil(i, 3, r'COSTO ($) 🔒 opcional'),
          ],
        ),
      );

  /// Un campo etiquetado para el formato móvil (sin teclado de flechas:
  /// en el teléfono se navega tocando, que es lo natural)
  Widget _campoMovil(int fila, int col, String etiqueta, {String? pista}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.neonCyan, fontSize: 10)),
        const SizedBox(height: 4),
        TextField(
          controller: _filas[fila].controles[col],
          focusNode: _filas[fila].focos[col],
          onChanged: (_) => setState(() {}),
          keyboardType: col == 0 || col == 2 || col == 3
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          textAlign: col == 0 || col == 2 || col == 3
              ? TextAlign.right
              : TextAlign.left,
          style:
              Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            hintText: pista,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _encabezado(String texto, double ancho) => SizedBox(
        width: ancho,
        child: Text(texto,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.neonCyan, fontSize: 10)),
      );

  Widget _encabezadoFlexible(String texto) => Text(texto,
      style: Theme.of(context)
          .textTheme
          .labelSmall
          ?.copyWith(color: AppColors.neonCyan, fontSize: 10));

  /// Una casilla de la rejilla con su teclado inteligente conectado.
  /// 👶 CLAVE DEL ARREGLO: ya NO envolvemos el campo en un Focus
  /// externo (eso interceptaba TODAS las teclas y bloqueaba el cursor
  /// con las flechas ←→). Ahora el TextField conserva el control
  /// total de su cursor, y solo añadimos un "oyente" que reacciona
  /// ÚNICAMENTE a ↑↓; el resto de teclas ni se tocan.
  Widget _casilla(int fila, int col, {double? ancho, String? pista}) {
    // Conectamos el oyente de ↑↓ directamente al FocusNode de esta
    // casilla. Es la vía limpia de Flutter: el nodo escucha la tecla
    // pero NO se interpone entre el teclado y el cursor del texto.
    _filas[fila].focos[col].onKeyEvent =
        (_, evento) => _alTocarFlechas(evento, fila, col);

    final campo = TextField(
      controller: _filas[fila].controles[col],
      focusNode: _filas[fila].focos[col],
      onChanged: (_) => setState(() {}), // Refresca el TOTAL en vivo
      // ENTER → la coreografía de saltos
      onEditingComplete: () => _alDarEnter(fila, col),
      textAlign: col == 0 || col == 2 || col == 3
          ? TextAlign.right
          : TextAlign.left,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13.5),
      decoration: InputDecoration(
        isDense: true,
        hintText: pista,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
    );
    return ancho == null ? campo : SizedBox(width: ancho, child: campo);
  }
}
