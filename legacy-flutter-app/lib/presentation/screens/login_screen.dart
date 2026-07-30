import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/fondo_chip.dart';
import '../providers/auth_providers.dart';

/// ─────────────────────────────────────────────────────────────────
/// LOGIN · "RACING COCKPIT"
/// Fondo carbón #0D0D0D + retícula técnica, panel HUD con esquinas
/// marcadas en cian, acción primaria en naranja racing.
/// Responsive: panel fluido en móvil, tarjeta centrada máx. 460px en Web/PC.
/// ─────────────────────────────────────────────────────────────────
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _verPassword = false;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _intentarLogin() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;
    ref
        .read(authControllerProvider.notifier)
        .login(_usuarioCtrl.text.trim().toLowerCase(), _passwordCtrl.text);
    // El guard del router redirige solo según el rol al haber sesión.
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final cargando = auth is AuthVerificando;
    final textTheme = Theme.of(context).textTheme;

    // Errores de login → snackbar estilo alerta de pit
    ref.listen(authControllerProvider, (prev, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.racingOrange, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(next.mensaje)),
            ]),
          ));
      }
    });

    return FondoChip(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
        children: [
          // (La retícula original se retiró: ahora el fondo es el
          // chip ALEXMAR animado, aplicado por FondoChip a toda la app.)
          // Capa 2: resplandor cian ambiental superior
          Positioned(
            top: -160,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 320,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [AppColors.neonCyanDim, Colors.transparent],
                    radius: 0.9,
                  ),
                ),
              ),
            ),
          ),
          // Capa 3: contenido
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Encabezado(textTheme: textTheme),
                      const SizedBox(height: 36),
                      _PanelHud(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('AUTENTICACIÓN REQUERIDA',
                                  style: textTheme.labelSmall),
                              const SizedBox(height: 6),
                              Text('Acceso al sistema',
                                  style: textTheme.displayMedium
                                      ?.copyWith(fontSize: 20)),
                              const SizedBox(height: 28),

                              // ── USUARIO ──
                              TextFormField(
                                controller: _usuarioCtrl,
                                enabled: !cargando,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                style: textTheme.bodyLarge,
                                decoration: const InputDecoration(
                                  labelText: 'USUARIO',
                                  hintText: 'Nombre de operador',
                                  prefixIcon: Icon(Icons.badge_outlined,
                                      color: AppColors.neonCyan, size: 20),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Ingrese su usuario'
                                        : null,
                              ),
                              const SizedBox(height: 18),

                              // ── CONTRASEÑA ──
                              TextFormField(
                                controller: _passwordCtrl,
                                enabled: !cargando,
                                obscureText: !_verPassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _intentarLogin(),
                                style: textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  labelText: 'CONTRASEÑA',
                                  hintText: 'Clave de acceso',
                                  prefixIcon: const Icon(Icons.key_outlined,
                                      color: AppColors.neonCyan, size: 20),
                                  suffixIcon: IconButton(
                                    tooltip: _verPassword
                                        ? 'Ocultar contraseña'
                                        : 'Mostrar contraseña',
                                    icon: Icon(
                                      _verPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _verPassword = !_verPassword),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Ingrese su contraseña'
                                    : null,
                              ),
                              const SizedBox(height: 30),

                              // ── ACCIÓN: NARANJA RACING ──
                              ElevatedButton(
                                onPressed: cargando ? null : _intentarLogin,
                                child: cargando
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: AppColors.racingOrange,
                                        ),
                                      )
                                    : const Text('INICIAR SESIÓN'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'ALEXMAR · AUTOPERIQUITOS · ROTULADOS · SERVICIOS MECÁNICOS',
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.textDisabled),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

/// Marca + velocímetro de estado
class _Encabezado extends StatelessWidget {
  final TextTheme textTheme;
  const _Encabezado({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Línea de velocidad decorativa
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _segmento(AppColors.racingOrange, 42),
            _segmento(AppColors.racingOrange.withValues(alpha: .55), 22),
            _segmento(AppColors.racingOrange.withValues(alpha: .25), 12),
            const SizedBox(width: 14),
            Text('ALEXMAR', style: textTheme.displayLarge),
            const SizedBox(width: 14),
            _segmento(AppColors.neonCyan.withValues(alpha: .25), 12),
            _segmento(AppColors.neonCyan.withValues(alpha: .55), 22),
            _segmento(AppColors.neonCyan, 42),
          ],
        ),
        const SizedBox(height: 10),
        Text('SISTEMA DE CONTROL OPERATIVO · v1.0',
            style: textTheme.labelSmall?.copyWith(color: AppColors.neonCyan)),
      ],
    );
  }

  Widget _segmento(Color color, double ancho) => Container(
        width: ancho,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        color: color,
      );
}

/// Panel estilo HUD: fondo de instrumento + 4 esquinas marcadas en cian
class _PanelHud extends StatelessWidget {
  final Widget child;
  const _PanelHud({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.panelDark.withValues(alpha: .92),
            border: Border.all(color: AppColors.gridLine),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: AppColors.neonCyanDim,
                blurRadius: 40,
                spreadRadius: -12,
              ),
            ],
          ),
          child: child,
        ),
        // Esquinas de mira (corner brackets)
        for (final esquina in _Esquina.values)
          Positioned(
            top: esquina.arriba ? 0 : null,
            bottom: esquina.arriba ? null : 0,
            left: esquina.izquierda ? 0 : null,
            right: esquina.izquierda ? null : 0,
            child: _MarcaEsquina(esquina: esquina),
          ),
      ],
    );
  }
}

enum _Esquina {
  supIzq(true, true),
  supDer(true, false),
  infIzq(false, true),
  infDer(false, false);

  final bool arriba;
  final bool izquierda;
  const _Esquina(this.arriba, this.izquierda);
}

class _MarcaEsquina extends StatelessWidget {
  final _Esquina esquina;
  const _MarcaEsquina({required this.esquina});

  @override
  Widget build(BuildContext context) {
    const lado = BorderSide(color: AppColors.neonCyan, width: 2);
    return SizedBox(
      width: 18,
      height: 18,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: esquina.arriba ? lado : BorderSide.none,
            bottom: esquina.arriba ? BorderSide.none : lado,
            left: esquina.izquierda ? lado : BorderSide.none,
            right: esquina.izquierda ? BorderSide.none : lado,
          ),
        ),
      ),
    );
  }
}
