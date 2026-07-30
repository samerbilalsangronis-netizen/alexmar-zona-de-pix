# Alexmar — app Flutter original (legado)

Código fuente de la app Flutter (Android + Web vía Netlify) que usaba
Google Sheets + Apps Script como backend. Se guarda acá como referencia y
respaldo mientras se termina de migrar todo a la app web nueva (raíz de
este repo, con Supabase).

Faltan a propósito los assets binarios (imágenes, `web/`, carpetas de
build de `android/`) para no inflar el repositorio — están en tu proyecto
local. Solo se subió el código fuente (`lib/`, `pubspec.yaml`, etc.) y el
backend (`apps_script/Code.gs`).

## El único cambio real vs. tu proyecto local

`lib/data/local/app_database.dart` — función `reemplazarDesdNube` — tenía
un bug que borraba clientes/cargos recién creados en el teléfono antes de
que llegaran a subir a Google Sheets (ver el README de la raíz del repo
para el detalle completo). Ya está corregido acá.

**Para aplicarlo a tu proyecto local:** copiá el archivo
`lib/data/local/app_database.dart` de esta carpeta sobre el mismo archivo
en tu proyecto de `C:\alexmar\alexmar_app\`, y volvé a compilar:

```bash
flutter pub get
flutter build apk        # para el Android
flutter build web        # para volver a publicar en Netlify
```
