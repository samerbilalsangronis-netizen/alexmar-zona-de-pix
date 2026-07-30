import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// ─────────────────────────────────────────────────────────────────
/// SERVICIO DE FOTOS DEL INVENTARIO · Versión UNIVERSAL (web + móvil)
///
/// 👶 EXPLICACIÓN DEL CAMBIO: Antes guardábamos la foto como un
/// archivo en una carpeta del teléfono. Pero un NAVEGADOR no tiene
/// carpetas accesibles (vive en una "caja de arena" de seguridad).
///
/// La nueva estrategia funciona en TODAS las plataformas por igual:
/// la foto se toma, se COMPRIME fuerte (máx. 800px) y se convierte a
/// "base64" — un truco clásico que transforma una imagen en un texto
/// largo (letras y números). Ese texto viaja dentro de la base de
/// datos local como un dato más. Para mostrarla, se hace el camino
/// inverso: texto → imagen. Cero archivos, cero carpetas.
///
/// El texto empieza con "data:image/jpeg;base64,..." — así la app
/// distingue 3 tipos de foto:
///   · "data:..."  → foto embebida (la nueva forma universal)
///   · "https://..." → link de internet (cuando activemos la nube)
///   · vacío        → sin foto (ícono gris)
/// Al espejo de Sheets solo viajarán los links https; las fotos
/// embebidas se quedan en la base local (no ensucian la hoja).
/// ─────────────────────────────────────────────────────────────────
class FotoService {
  static final _picker = ImagePicker();

  /// Abre la CÁMARA (en navegador de PC abre el selector de archivos;
  /// en el navegador del celular sí ofrece la cámara).
  static Future<String?> tomarFoto() => _capturar(ImageSource.camera);

  /// Abre la GALERÍA / selector de archivos.
  static Future<String?> elegirDeGaleria() => _capturar(ImageSource.gallery);

  static Future<String?> _capturar(ImageSource origen) async {
    final XFile? imagen = await _picker.pickImage(
      source: origen,
      maxWidth: 800,     // Compresión fuerte: nitidez de catálogo,
      imageQuality: 70,  // peso pequeño para no inflar la base local
    );
    if (imagen == null) return null; // El usuario canceló

    // Imagen → bytes → texto base64 con su etiqueta identificadora
    final Uint8List bytes = await imagen.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  /// ★ ESQUELETO PARA LA NUBE (etapa futura, sin cambios de plan) ★
  /// Recibirá la foto embebida, la subirá a un storage externo
  /// (Cloudinary/Firebase) y devolverá la URL https. Ese día, solo
  /// se rellena este método: el resto de la app no se toca.
  static Future<String?> subirANube(String fotoEmbebida) async {
    // TODO(Fase futura): POST multipart al storage y devolver secure_url
    return null;
  }

  // ── Detectores del tipo de foto ──

  static bool esUrlDeInternet(String? ruta) =>
      ruta != null && ruta.startsWith('http');

  static bool esFotoEmbebida(String? ruta) =>
      ruta != null && ruta.startsWith('data:');

  /// Camino inverso: texto base64 → bytes listos para Image.memory
  static Uint8List bytesDeFoto(String fotoEmbebida) =>
      base64Decode(fotoEmbebida.substring(fotoEmbebida.indexOf(',') + 1));
}
