import 'dart:math';

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ─────────────────────────────────────────────────────────────────
/// FONDO ANIMADO UNIVERSAL · "CHIP VIVO"
///
/// 👶 QUÉ HACE: envuelve cualquier pantalla y le pone detrás:
///   1. La imagen del chip ALEXMAR (assets/images/fondo_chip.png).
///   2. Un VELO oscuro sutil encima, para que los datos en $ y los
///      textos siempre se lean perfecto (intensidad: sutil).
///   3. Un PULSO de resplandor cian que "respira" lentamente.
///   4. PARTÍCULAS de energía cian viajando, como corriente por el
///      circuito.
///
/// CÓMO SE USA: en cualquier pantalla, en vez de devolver el
/// Scaffold directamente, se envuelve así:
///     return FondoChip(child: Scaffold(...));
/// El Scaffold debe tener backgroundColor: Colors.transparent para
/// dejar ver el fondo (de eso se encarga cada pantalla).
///
/// RENDIMIENTO: las animaciones usan un solo "reloj" compartido y se
/// dibujan con CustomPainter (muy liviano). Sin video, sin calentar
/// el equipo. Funciona igual en navegador, Android y Windows.
/// ─────────────────────────────────────────────────────────────────
class FondoChip extends StatefulWidget {
  final Widget child;

  /// Intensidad del velo oscuro (0 = imagen plena, 1 = casi negro).
  /// Elegimos 0.62 = "sutil" según la decisión del negocio: el fondo
  /// se aprecia pero los datos mandan.
  final double opacidadVelo;

  const FondoChip({super.key, required this.child, this.opacidadVelo = 0.62});

  @override
  State<FondoChip> createState() => _FondoChipState();
}

class _FondoChipState extends State<FondoChip>
    with TickerProviderStateMixin {
  // Un reloj para el pulso (lento) y otro para las partículas (continuo)
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  late final AnimationController _particulas = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  // Las partículas se generan una sola vez con posiciones al azar
  late final List<_Particula> _semillas = _crearParticulas(26);

  @override
  void dispose() {
    _pulso.dispose();
    _particulas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Capa 1: la imagen del chip cubriendo todo ──
        Positioned.fill(
          child: Image.asset(
            'assets/images/fondo_chip.png',
            fit: BoxFit.cover,
            // Si la imagen no cargara, caemos al negro carbón de siempre
            errorBuilder: (_, __, ___) =>
                Container(color: AppColors.carbonBlack),
          ),
        ),

        // ── Capa 2: velo oscuro sutil (legibilidad de los datos) ──
        Positioned.fill(
          child: Container(
            color: AppColors.carbonBlack.withValues(alpha: widget.opacidadVelo),
          ),
        ),

        // ── Capa 3: pulso de resplandor cian (el chip "respira") ──
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _pulso,
              builder: (_, __) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.1),
                    radius: 1.1,
                    colors: [
                      AppColors.neonCyan.withValues(
                          alpha: 0.04 + (_pulso.value * 0.07)),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Capa 4: partículas de energía recorriendo el circuito ──
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _particulas,
              builder: (_, __) => CustomPaint(
                painter: _ParticulasPainter(
                  particulas: _semillas,
                  avance: _particulas.value,
                ),
              ),
            ),
          ),
        ),

        // ── Capa 5: la pantalla real (login, dashboard, etc.) ──
        widget.child,
      ],
    );
  }

  static List<_Particula> _crearParticulas(int cantidad) {
    final rng = Random(7); // Semilla fija: el patrón es estable y elegante
    return List.generate(cantidad, (_) {
      return _Particula(
        // Dirección: mezcla de horizontales y verticales (como pistas)
        horizontal: rng.nextBool(),
        // Carril (la "pista" del circuito por la que viaja)
        carril: rng.nextDouble(),
        // Punto de arranque desfasado para que no salgan todas juntas
        desfase: rng.nextDouble(),
        // Velocidad ligeramente distinta cada una
        velocidad: 0.5 + rng.nextDouble(),
        // Tamaño del punto de luz
        radio: 1.2 + rng.nextDouble() * 1.6,
      );
    });
  }
}

/// Una chispa de energía: viaja por un "carril" recto del circuito
class _Particula {
  final bool horizontal;
  final double carril;
  final double desfase;
  final double velocidad;
  final double radio;

  const _Particula({
    required this.horizontal,
    required this.carril,
    required this.desfase,
    required this.velocidad,
    required this.radio,
  });
}

class _ParticulasPainter extends CustomPainter {
  final List<_Particula> particulas;
  final double avance; // 0.0 → 1.0, el "reloj" continuo

  _ParticulasPainter({required this.particulas, required this.avance});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particulas) {
      // Posición a lo largo del carril (0 a 1), con rebote infinito
      var t = (avance * p.velocidad + p.desfase) % 1.0;

      late Offset centro;
      if (p.horizontal) {
        centro = Offset(t * size.width, p.carril * size.height);
      } else {
        centro = Offset(p.carril * size.width, t * size.height);
      }

      // La chispa se desvanece en los bordes del recorrido (entra y sale)
      final brillo = sin(t * pi); // 0 en extremos, 1 en el centro

      // Estela: una línea corta detrás de la chispa, como un cometa
      final estela = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: 0.18 * brillo)
        ..strokeWidth = p.radio * 0.8
        ..strokeCap = StrokeCap.round;
      final atras = p.horizontal
          ? Offset(centro.dx - 26, centro.dy)
          : Offset(centro.dx, centro.dy - 26);
      canvas.drawLine(atras, centro, estela);

      // El punto de luz brillante (con halo)
      final halo = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: 0.55 * brillo)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(centro, p.radio + 1.5, halo);

      final nucleo = Paint()
        ..color = AppColors.neonCyan.withValues(alpha: 0.9 * brillo);
      canvas.drawCircle(centro, p.radio, nucleo);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticulasPainter old) =>
      old.avance != avance;
}
