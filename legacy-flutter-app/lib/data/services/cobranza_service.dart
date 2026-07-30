import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/formato.dart';
import '../../domain/entities/cliente.dart';
import '../../domain/entities/linea_cuenta.dart';
import '../pdf/factura_pdf.dart';

/// ─────────────────────────────────────────────────────────────────
/// MOTOR DE COBRANZA DIRECTA
///
/// 👶 EXPLICACIÓN HONESTA E IMPORTANTE: WhatsApp, por seguridad, NO
/// permite que una app le "inyecte" un archivo adjunto directo a un
/// chat mediante un enlace. Lo que SÍ permite (y es el estándar que
/// usan las apps profesionales) son dos caminos, y aquí van ambos:
///
///  CAMINO A (PDF + texto): generamos el PDF y abrimos la bandeja de
///  compartir del teléfono con el PDF y el mensaje ya montados. El
///  usuario toca WhatsApp → elige el chat del cliente → enviar.
///  Total: 2 toques. El PDF viaja adjunto con el mensaje.
///
///  CAMINO B (chat directo): abrimos DIRECTAMENTE el chat de WhatsApp
///  del cliente (usando su teléfono) con el mensaje de cobro ya
///  escrito, listo para enviar. Sin PDF, pero con cero búsqueda.
/// ─────────────────────────────────────────────────────────────────
class CobranzaService {
  /// El mensaje amigable de cobro, con los datos reales de la cuenta
  static String mensajeCobro(Cliente cliente, double saldo) =>
      'Hola ${cliente.nombre}! 👋 Le saludamos de *Autoperiquitos Alexmar* 🏁\n\n'
      'Le compartimos el estado de su cuenta Nº ${cliente.facturaN}:\n'
      '💵 Saldo pendiente: *${formatoDolar(saldo)}*\n\n'
      'Cuando guste puede pasar a realizar su abono. '
      '¡Gracias por su confianza y preferencia! 🔧🚗';

  /// CAMINO A: genera el PDF formal y lo entrega según la plataforma.
  /// 👶 Usamos el paquete `printing`, que es universal:
  ///  · CELULAR → abre la bandeja de compartir (tocar WhatsApp → chat).
  ///  · NAVEGADOR → descarga/comparte el PDF para adjuntarlo en
  ///    WhatsApp Web. (El navegador no puede inyectar archivos en
  ///    otras apps: esa es una regla de seguridad de la web misma.)
  static Future<void> enviarPdfPorWhatsApp({
    required Cliente cliente,
    required List<LineaCuenta> lineas,
    required ResumenCuenta resumen,
  }) async {
    final bytes = await FacturaPdf.generar(
      cliente: cliente,
      lineas: lineas,
      resumen: resumen,
    );
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Estado_Cuenta_${cliente.facturaN}.pdf',
      subject: 'Estado de cuenta Nº ${cliente.facturaN} · Alexmar',
      body: mensajeCobro(cliente, resumen.saldoPendiente),
    );
  }

  /// CAMINO B: abre el chat de WhatsApp del cliente con el mensaje
  /// de cobro ya redactado. Devuelve false si no se pudo abrir.
  static Future<bool> abrirChatWhatsApp({
    required Cliente cliente,
    required double saldo,
  }) async {
    // wa.me exige el número SOLO con dígitos (con código de país)
    // telefono puede ser null si el cliente no tiene número registrado
    final telefonoLimpio = cliente.telefono
        ?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    if (telefonoLimpio.isEmpty) {
      throw Exception(
          'Este cliente no tiene teléfono registrado. '
          'Agrégalo en su ficha para poder contactarlo por WhatsApp.');
    }
    final telefono = telefonoLimpio;
    final mensaje = Uri.encodeComponent(mensajeCobro(cliente, saldo));
    final uri = Uri.parse('https://wa.me/$telefono?text=$mensaje');

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
