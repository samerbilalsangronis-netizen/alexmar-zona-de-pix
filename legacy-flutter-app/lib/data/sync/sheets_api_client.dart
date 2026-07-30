import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// ─────────────────────────────────────────────────────────────────
/// 👶 EXPLICACIÓN: Google Sheets no se puede escribir "directo" de
/// forma segura desde una app. La solución profesional y GRATUITA:
/// dentro del propio Google Sheets vive un mini-programa llamado
/// "Apps Script" que publicamos como una dirección web (URL).
/// Nuestra app le manda paquetes de datos a esa URL, y el script
/// los escribe en las pestañas correctas (CLIENTES, USUARIOS...).
///
/// El archivo del script está en: apps_script/Code.gs (incluido).
/// Cuando lo publiques, pega la URL que te dé Google aquí abajo. ⬇
/// ─────────────────────────────────────────────────────────────────
class SheetsApiClient {
  /// ⚠️ PASO PENDIENTE DE CONFIGURACIÓN (instrucciones en el README):
  /// Pegar aquí la URL del Web App de Apps Script. Mientras esté
  /// vacía, el motor trabaja en "modo local": acumula la cola y no
  /// intenta subir nada (la app funciona perfectamente igual).
  static const String urlWebApp =
      'https://script.google.com/macros/s/AKfycbzC4ykQPbvKhdzn7GSoFfn2ao2tXjyz_IEyt6QlkxYwBgg7wGQe2EjISWgKdCE3irxh0w/exec';

  /// Clave compartida simple: el script rechaza paquetes que no la
  /// traigan. Debe coincidir con la del archivo Code.gs.
  static const String claveApi = 'alexmar2026';

  bool get configurado => urlWebApp.isNotEmpty;

  /// 🔍 CHIVATO DE DIAGNÓSTICO (temporal): guarda el detalle del
  /// último intento de subida, para poder mostrarlo en pantalla y
  /// ver POR QUÉ falla en el teléfono. Se quita cuando resolvamos.
  static String ultimoDiagnostico = 'aún no se ha intentado subir';

  /// Envía un lote de filas a una pestaña del espejo.
  /// Devuelve true si Google confirmó la escritura.
  Future<bool> subirLote({
    required String tabla, // 'CLIENTES' | 'USUARIOS' | ...
    required List<Map<String, dynamic>> filas,
  }) async {
    if (!configurado || filas.isEmpty) {
      ultimoDiagnostico = !configurado
          ? 'ERROR: no hay URL configurada'
          : 'sin filas para enviar';
      return false;
    }

    try {
      final cuerpoEnvio = jsonEncode({
        'clave': claveApi,
        'tabla': tabla,
        'filas': filas,
      });
      const cabeceras = {'Content-Type': 'text/plain;charset=utf-8'};

      // ── CAMINO WEB: el navegador sigue la redirección 302 solo ──
      // 👶 EL ARREGLO CLAVE DE LA WEB (bug del inventario/notas que no
      // subían): en el navegador NO debemos mandar el encabezado
      // Content-Type. Si lo mandamos, el navegador hace una
      // "verificación previa" (preflight CORS con el método OPTIONS)
      // que Google Apps Script NO sabe responder → el navegador
      // CANCELA el envío y el dato jamás sale de la web. Al NO poner
      // ese encabezado, el navegador trata el POST como "simple",
      // se salta la verificación, y el paquete llega perfecto.
      // Apps Script lee el cuerpo igual (JSON.parse(e.postData.contents)),
      // así que del lado del servidor no hay que cambiar NADA.
      // El teléfono/PC no tienen navegador → siguen usando su propio
      // camino de abajo, que ya funcionaba bien.
      if (kIsWeb) {
        final respuesta = await http
            .post(Uri.parse(urlWebApp), body: cuerpoEnvio)
            .timeout(const Duration(seconds: 25));
        final cuerpoCorto = respuesta.body.length > 200
            ? respuesta.body.substring(0, 200)
            : respuesta.body;
        ultimoDiagnostico =
            'WEB · Código ${respuesta.statusCode}: $cuerpoCorto';
        if (respuesta.statusCode != 200) return false;
        final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
        return cuerpo['ok'] == true;
      }

      // ── CAMINO MÓVIL/ESCRITORIO: seguir el 302 a mano ──
      // 👶 EL ARREGLO REAL (confirmado por el diagnóstico):
      // Google responde 302 "Moved Temporarily" con la dirección
      // final en la cabecera "location". Apps Script GUARDA el
      // resultado del POST y lo entrega en esa nueva dirección
      // mediante un GET. Así que: enviamos el POST, y cuando llega el
      // 302, hacemos un GET a la URL de "location" para recoger la
      // respuesta JSON. (El navegador hace esto solo; aquí lo
      // hacemos nosotros porque http.post en Android no lo completa.)
      final cliente = http.Client();
      try {
        // 1) El POST con los datos (sin seguir la redirección auto)
        final peticionPost = http.Request('POST', Uri.parse(urlWebApp))
          ..followRedirects = false
          ..headers.addAll(cabeceras)
          ..body = cuerpoEnvio;
        final flujoPost =
            await cliente.send(peticionPost).timeout(
                  const Duration(seconds: 25),
                );
        final respPost = await http.Response.fromStream(flujoPost);

        // 2) ¿Llegó el 302 con la dirección final? → GET allá
        if (respPost.statusCode >= 300 && respPost.statusCode < 400) {
          final destino = respPost.headers['location'];
          if (destino == null) {
            ultimoDiagnostico = 'MÓVIL · 302 sin location';
            return false;
          }
          final respGet = await cliente
              .get(Uri.parse(destino))
              .timeout(const Duration(seconds: 25));
          final cuerpoCorto = respGet.body.length > 200
              ? respGet.body.substring(0, 200)
              : respGet.body;
          ultimoDiagnostico =
              'MÓVIL · GET tras 302 · Código ${respGet.statusCode}: $cuerpoCorto';
          if (respGet.statusCode != 200) return false;
          final cuerpo = jsonDecode(respGet.body) as Map<String, dynamic>;
          return cuerpo['ok'] == true;
        }

        // 3) Sin redirección (raro): intentar leer la respuesta directa
        final cuerpoCorto = respPost.body.length > 200
            ? respPost.body.substring(0, 200)
            : respPost.body;
        ultimoDiagnostico =
            'MÓVIL · Código ${respPost.statusCode} (sin redirección): $cuerpoCorto';
        if (respPost.statusCode != 200) return false;
        final cuerpo = jsonDecode(respPost.body) as Map<String, dynamic>;
        return cuerpo['ok'] == true;
      } finally {
        cliente.close();
      }
    } catch (e) {
      ultimoDiagnostico = 'EXCEPCIÓN: ${e.runtimeType}\n$e';
      return false;
    }
  }
}
