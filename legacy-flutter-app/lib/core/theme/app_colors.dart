import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────
/// ALEXMAR APP · PALETA "DASHBOARD DE COMBATE"
/// Estética: Cyberpunk / Racing avanzado. Todo color de la app
/// DEBE salir de aquí. Prohibido hardcodear colores en pantallas.
/// ─────────────────────────────────────────────────────────────────
abstract class AppColors {
  // ── Fondos ──
  /// Negro carbón profundo (fondo maestro aprobado por el negocio)
  static const Color carbonBlack = Color(0xFF0D0D0D);

  /// Superficie de paneles (un paso por encima del fondo)
  static const Color panelDark = Color(0xFF141619);

  /// Superficie elevada (cards, inputs)
  static const Color surfaceRaised = Color(0xFF1B1E23);

  // ── Acentos neón ──
  /// Cian eléctrico: color de SISTEMA (navegación, focos, datos)
  static const Color neonCyan = Color(0xFF00E5FF);

  /// Naranja racing de alta intensidad: color de ACCIÓN (botones, alertas de negocio)
  static const Color racingOrange = Color(0xFFFF6B00);

  // ── Semáforo de cartera (Módulo 2, definido desde ya) ──
  static const Color statusGreen = Color(0xFF00FF9C);   // Activo ≤ 15 días
  static const Color statusYellow = Color(0xFFFFD60A);  // Inactivo 16-30 días
  static const Color statusRed = Color(0xFFFF2D55);     // Mora > 30 días

  // ── Texto ──
  static const Color textPrimary = Color(0xFFEAF6F8);   // Blanco frío
  static const Color textSecondary = Color(0xFF8A949E); // Gris instrumental
  static const Color textDisabled = Color(0xFF4A5158);

  // ── Líneas de guía estilizadas ──
  static const Color gridLine = Color(0xFF22272D);      // Retícula sutil
  static const Color neonCyanDim = Color(0x3300E5FF);   // Cian al 20% (glow suave)
  static const Color racingOrangeDim = Color(0x33FF6B00);

  // ── Estados de error/éxito del sistema ──
  static const Color error = statusRed;
  static const Color success = statusGreen;
}
