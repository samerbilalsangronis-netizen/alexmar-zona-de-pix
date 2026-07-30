import 'package:intl/intl.dart';

/// 👶 El negocio trabaja EXCLUSIVAMENTE en dólares ($).
/// Esta función convierte 1234.5 en "$1,234.50" en toda la app,
/// desde un único lugar (si un día quieren quitar decimales,
/// se cambia aquí y listo).
final _formatoUsd = NumberFormat.currency(
  locale: 'en_US',
  symbol: r'$',
  decimalDigits: 2,
);

String formatoDolar(double monto) => _formatoUsd.format(monto);
