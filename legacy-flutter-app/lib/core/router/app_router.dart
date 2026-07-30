import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/usuario.dart';
import '../../presentation/providers/auth_providers.dart';
import '../../presentation/screens/admin_dashboard_screen.dart';
import '../../presentation/screens/catalogo_screen.dart';
import '../../presentation/screens/factura_rapida_screen.dart';
import '../../presentation/screens/hoja_cliente_screen.dart';
import '../../presentation/screens/indice_maestro_screen.dart';
import '../../presentation/screens/notas_screen.dart';
import '../../presentation/screens/rendimiento_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/widgets/nota_rapida.dart';

/// ─────────────────────────────────────────────────────────────────
/// GUARD DE NAVEGACIÓN POR ROLES — Seguridad desde la RAÍZ.
///
/// Reglas (se evalúan en CADA navegación, sin excepciones):
///  1. Sin sesión        → /login. Punto.
///  2. EMPLEADO          → solo /catalogo. Cualquier intento de
///     entrar a rutas /admin/** (deudas, costos, clientes, reportes)
///     se redirige al catálogo. El bloqueo no depende de esconder
///     botones: aunque el empleado escriba la URL a mano en la
///     versión Web, el redirect lo expulsa.
///  3. ADMIN             → acceso total.
///  4. Con sesión activa → /login deja de ser accesible.
/// ─────────────────────────────────────────────────────────────────

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const catalogo = '/catalogo';        // Compartida (vista empleado)
  static const adminDashboard = '/admin';     // Raíz del Modo JEFE
  static const adminClientes = '/admin/clientes'; // Índice Maestro (Módulo 2)
  static const adminRendimiento = '/admin/rendimiento'; // Panel BI (Módulo 5)
  static const adminNotas = '/admin/notas'; // ★ FASE 9: Pizarra de notas
  static const adminFactura = '/admin/factura'; // ★ FASE 10: Factura rápida
  // Futuras rutas protegidas colgarán de /admin/**.
}

/// ★ FASE 9 — NOTA RÁPIDA EN TODA LA APP ★
/// 👶 Cada pantalla con sesión iniciada se envuelve en
/// NotaRapidaOverlay: eso le pega la pestañita naranja del borde
/// derecho SIN tocar ni una línea de la pantalla original. Así, estés
/// donde estés (cargando un cliente, viendo el catálogo...), tocas la
/// pestañita, escribes "pedir bombillos H4", guardas y sigues.
/// El splash y el login NO la llevan (todavía no hay sesión).

/// Adaptador: convierte el estado Riverpod en un Listenable
/// para que go_router re-evalúe el guard ante cada cambio de sesión.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, routerState) {
      final auth = ref.read(authControllerProvider);
      final destino = routerState.matchedLocation;

      // 0) Mientras se restaura la sesión, mantener el splash
      if (auth is AuthInicializando) return AppRoutes.splash;

      final usuario = auth is AuthConSesion ? auth.usuario : null;
      final enLogin =
          destino == AppRoutes.login || destino == AppRoutes.splash;

      // 1) SIN SESIÓN → todo va al login
      if (usuario == null) return enLogin ? AppRoutes.login : AppRoutes.login;

      // 2) CON SESIÓN intentando ver login/splash → a su pantalla de inicio
      if (enLogin) {
        return usuario.esAdmin ? AppRoutes.adminDashboard : AppRoutes.catalogo;
      }

      // 3) EMPLEADO intentando entrar a CUALQUIER ruta /admin/** → expulsado
      if (!usuario.esAdmin && destino.startsWith(AppRoutes.adminDashboard)) {
        return AppRoutes.catalogo;
      }

      return null; // Navegación permitida
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.catalogo,
        builder: (_, __) =>
            const NotaRapidaOverlay(child: CatalogoScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (_, __) =>
            const NotaRapidaOverlay(child: AdminDashboardScreen()),
        // Sub-rutas de /admin/**: protegidas automáticamente por la
        // regla 3 del redirect (el EMPLEADO jamás puede entrar aquí).
        routes: [
          GoRoute(
            path: 'clientes', // URL completa: /admin/clientes
            builder: (_, __) =>
                const NotaRapidaOverlay(child: IndiceMaestroScreen()),
            routes: [
              // URL completa: /admin/clientes/<id-del-cliente>
              // También protegida: el EMPLEADO jamás puede entrar.
              GoRoute(
                path: ':id',
                builder: (_, estado) => NotaRapidaOverlay(
                  child: HojaClienteScreen(
                    idCliente: estado.pathParameters['id']!,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'rendimiento', // URL: /admin/rendimiento (solo JEFE)
            builder: (_, __) =>
                const NotaRapidaOverlay(child: RendimientoScreen()),
          ),
          GoRoute(
            path: 'notas', // ★ FASE 9 · URL: /admin/notas (solo JEFE)
            builder: (_, __) => const NotasScreen(),
          ),
          GoRoute(
            // ★ FASE 10 · URL: /admin/factura (solo JEFE)
            // Factura rápida de mostrador: se llena a mano y se
            // imprime/comparte. NO guarda nada en la base de datos.
            path: 'factura',
            builder: (_, __) =>
                const NotaRapidaOverlay(child: FacturaRapidaScreen()),
          ),
        ],
      ),
    ],
  );
});

/// ─────────────────────────────────────────────────────────────────
/// SEGUNDA CAPA: guard a nivel de WIDGET.
/// Para datos sensibles incrustados en pantallas compartidas
/// (ej. la columna COSTO dentro del catálogo): si el usuario no es
/// ADMIN, el widget sensible NI SIQUIERA SE CONSTRUYE en el árbol.
/// No es "invisible": no existe.
/// ─────────────────────────────────────────────────────────────────
class SoloAdmin extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const SoloAdmin({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final esAdmin = ref.watch(esAdminProvider);
    return esAdmin ? child : (fallback ?? const SizedBox.shrink());
  }
}
