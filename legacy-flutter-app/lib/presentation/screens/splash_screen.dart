import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Pantalla de arranque mientras se restaura la sesión persistida.
/// El guard del router decide automáticamente a dónde redirigir.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ALEXMAR',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            const SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                color: AppColors.racingOrange,
                backgroundColor: AppColors.surfaceRaised,
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 12),
            Text('INICIANDO SISTEMA...',
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
