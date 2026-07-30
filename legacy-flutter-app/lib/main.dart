import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// ─────────────────────────────────────────────────────────────────
/// ALEXMAR APP · Punto de entrada
/// Módulo 1: Login, Seguridad y Roles (ADMIN / EMPLEADO)
/// ─────────────────────────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AlexmarApp()));
}

class AlexmarApp extends ConsumerWidget {
  const AlexmarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Alexmar App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // La app vive SIEMPRE en modo cockpit
      routerConfig: router,
    );
  }
}
