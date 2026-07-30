import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// ─────────────────────────────────────────────────────────────────
/// ALEXMAR APP · TEMA FUTURISTA "RACING COCKPIT"
///
/// Tipografías:
///  · Orbitron      → Display / títulos (digital, geométrica, racing)
///  · Rajdhani      → Texto general (condensada, técnica, alta legibilidad)
///  · Share Tech Mono → Datos, cifras en $, folios (monoespaciada digital)
/// ─────────────────────────────────────────────────────────────────
abstract class AppTheme {
  static ThemeData get dark {
    final baseText = GoogleFonts.rajdhaniTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.carbonBlack,
      canvasColor: AppColors.carbonBlack,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonCyan,
        onPrimary: AppColors.carbonBlack,
        secondary: AppColors.racingOrange,
        onSecondary: AppColors.carbonBlack,
        surface: AppColors.panelDark,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.carbonBlack,
        outline: AppColors.gridLine,
      ),

      // ── Tipografía ──
      textTheme: baseText.copyWith(
        // Títulos de pantalla / branding
        displayLarge: GoogleFonts.orbitron(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: 4,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
          color: AppColors.textPrimary,
        ),
        // Encabezados de sección / paneles
        titleLarge: GoogleFonts.orbitron(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.5,
          color: AppColors.neonCyan,
        ),
        titleMedium: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.textPrimary,
        ),
        // Cuerpo
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        // Etiquetas técnicas (eyebrows tipo HUD)
        labelSmall: GoogleFonts.shareTechMono(
          fontSize: 11,
          letterSpacing: 2,
          color: AppColors.textSecondary,
        ),
        // Cifras monetarias en $ y folios de factura
        labelLarge: GoogleFonts.shareTechMono(
          fontSize: 15,
          letterSpacing: 1,
          color: AppColors.textPrimary,
        ),
      ),

      // ── Inputs estilo consola ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceRaised,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: GoogleFonts.rajdhani(
          color: AppColors.textDisabled,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
        labelStyle: GoogleFonts.shareTechMono(
          color: AppColors.textSecondary,
          fontSize: 12,
          letterSpacing: 2,
        ),
        floatingLabelStyle: GoogleFonts.shareTechMono(
          color: AppColors.neonCyan,
          fontSize: 12,
          letterSpacing: 2,
        ),
        // Esquinas rectas: estética de instrumento, no de juguete
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: AppColors.gridLine, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: AppColors.neonCyan, width: 1.4),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: AppColors.error, width: 1.4),
        ),
        errorStyle: GoogleFonts.rajdhani(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── Botón primario: NARANJA RACING = acción ──
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.racingOrange,
          foregroundColor: AppColors.carbonBlack,
          disabledBackgroundColor: AppColors.surfaceRaised,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          textStyle: GoogleFonts.orbitron(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
      ),

      // ── Botón secundario: contorno CIAN = sistema ──
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.neonCyan,
          side: const BorderSide(color: AppColors.neonCyan, width: 1.2),
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          textStyle: GoogleFonts.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonCyan,
          textStyle: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),

      // ── Paneles / cards tipo HUD ──
      cardTheme: const CardThemeData(
        color: AppColors.panelDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          side: BorderSide(color: AppColors.gridLine, width: 1),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.carbonBlack,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.neonCyan),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceRaised,
        contentTextStyle: GoogleFonts.rajdhani(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          side: BorderSide(color: AppColors.racingOrange, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.neonCyan,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.gridLine,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
