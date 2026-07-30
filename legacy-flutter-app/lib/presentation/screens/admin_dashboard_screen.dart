import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/fondo_chip.dart';
import '../providers/auth_providers.dart';
import '../providers/clientes_providers.dart';

/// ─────────────────────────────────────────────────────────────────
/// MODO JEFE · Dashboard raíz del ADMIN.
/// ─────────────────────────────────────────────────────────────────
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActualProvider);
    final textTheme = Theme.of(context).textTheme;

    // ── Arrancar el polling de bajada desde el DASHBOARD ──
    // Al entrar al área admin, el proveedor se crea con keepAlive=true
    // y el timer de 2 minutos comienza. Navegar a otras pantallas
    // (Índice, Catálogo, etc.) NO lo destruye porque tiene keepAlive.
    // Así el polling corre en todo momento que el usuario esté logueado.
    ref.watch(sincronizacionBajadaProvider);

    return FondoChip(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MODO JEFE'),
        actions: [
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('OPERADOR: ${usuario?.nombreCompleto.toUpperCase() ?? '—'}',
                style: textTheme.labelSmall
                    ?.copyWith(color: AppColors.neonCyan)),
            const SizedBox(height: 4),
            Text('Panel de control general', style: textTheme.displayMedium),
            const SizedBox(height: 24),
            _AccesoModulo(
              icono: Icons.account_balance_wallet_outlined,
              titulo: 'ÍNDICE MAESTRO',
              descripcion: 'Clientes, deudas y total en la calle (\$)',
              acento: AppColors.statusGreen,
              onTap: () => context.go(AppRoutes.adminClientes),
            ),
            _AccesoModulo(
              icono: Icons.inventory_2_outlined,
              titulo: 'CATÁLOGO E INVENTARIO',
              descripcion: 'Productos, costos, PVP y stock',
              acento: AppColors.neonCyan,
              onTap: () => context.go(AppRoutes.catalogo),
            ),
            _AccesoModulo(
              icono: Icons.insights_outlined,
              titulo: 'RENDIMIENTO (BI)',
              descripcion: 'Facturado, cobrado y ganancia neta (\$)',
              acento: AppColors.racingOrange,
              onTap: () => context.go(AppRoutes.adminRendimiento),
            ),
            // ★ FASE 9 — La pizarra del jefe: pendientes y compras.
            _AccesoModulo(
              icono: Icons.sticky_note_2_outlined,
              titulo: 'MIS NOTAS',
              descripcion: 'Pizarra de pendientes, compras y recordatorios',
              acento: AppColors.racingOrange,
              onTap: () => context.go(AppRoutes.adminNotas),
            ),
            _AccesoModulo(
              icono: Icons.manage_accounts_outlined,
              titulo: 'USUARIOS Y SEGURIDAD',
              descripcion: 'Gestión de operadores y roles',
              acento: AppColors.statusYellow,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _AccesoModulo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color acento;
  final VoidCallback? onTap; // null = módulo aún no disponible

  const _AccesoModulo({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.acento,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        child: InkWell(
          onTap: onTap ??
              () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('$titulo: disponible en el próximo módulo')),
                  ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 44,
                  color: acento, // Barra de acento lateral tipo HUD
                ),
                const SizedBox(width: 16),
                Icon(icono, color: acento, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: textTheme.titleLarge
                              ?.copyWith(color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(descripcion, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textDisabled),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
