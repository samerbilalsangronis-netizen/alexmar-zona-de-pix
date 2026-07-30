# Alexmar / Zona De Pix

App web (React + TypeScript + Vite + Tailwind + Supabase) que reemplaza el
esquema anterior (Flutter + Google Sheets + Apps Script). Mismo negocio,
misma lógica de clientes/cuentas/inventario/notas, pero con una base de
datos real (Postgres en Supabase) en vez de un Sheet, y sin depender de
Apps Script.

- `legacy-flutter-app/` — la app Flutter original (con **un bug de
  sincronización ya corregido**, ver más abajo). Se deja como referencia y
  como respaldo mientras la web se termina de probar.
- `supabase/schema.sql` — el esquema completo de la base de datos nueva.
- `src/` — la app web nueva.

## 🚨 Paso 1 — Crear el proyecto de Supabase (gratis, 5 minutos)

1. Entrá a [supabase.com](https://supabase.com) → "New project".
2. Elegí un nombre (ej. `alexmar`) y una contraseña de base de datos
   (guardala, no hace falta para la app pero sí para entrar a la consola).
3. Cuando el proyecto esté listo: **SQL Editor → New query**, pegá **todo**
   el contenido de `supabase/schema.sql` de este repo, y ejecutalo (▶ Run).
   Eso crea las tablas `clientes`, `detalle_cuentas`, `inventario`, `notas`,
   `cierres_mensuales` y `perfiles`, con seguridad (RLS) y tiempo real ya
   configurados.
4. **Project Settings → API**: copiá el `Project URL` y el `anon public key`.
5. **Authentication → Users → Add user**: creá tu primer usuario (email +
   contraseña) — con eso vas a entrar a la app. El primer usuario entra
   como `VENDEDOR`; para que sea `ADMIN` corré en el SQL Editor:
   ```sql
   update perfiles set rol = 'ADMIN' where id =
     (select id from auth.users where email = 'tu-correo@ejemplo.com');
   ```

## Paso 2 — Configurar y correr la app localmente

```bash
npm install
cp .env.example .env.local
# completá VITE_SUPABASE_URL y VITE_SUPABASE_ANON_KEY en .env.local
npm run dev
```

## Paso 3 — Publicarla en internet (Vercel, gratis)

1. Entrá a [vercel.com](https://vercel.com) con tu cuenta de GitHub.
2. "Add New… → Project" → elegí este repositorio (`alexmar-zona-de-pix`).
3. Vercel detecta Vite solo. Antes de darle "Deploy", en
   **Environment Variables** agregá `VITE_SUPABASE_URL` y
   `VITE_SUPABASE_ANON_KEY` con los mismos valores del paso 1.
4. "Deploy". En ~1 minuto tenés una URL pública (`algo.vercel.app`) que
   funciona desde el teléfono, tablet o PC — no hace falta instalar nada,
   y como es la misma base de datos para todos los dispositivos, se
   sincroniza sola (tiempo real de Supabase, no hay que esperar ciclos
   de 40 segundos como en la app vieja).

## Qué ya funciona en la web nueva

- **Índice Maestro**: alta de clientes, saldo recalculado desde las
  líneas reales, semáforo (al día / revisar / mora), búsqueda.
- **Hoja de cliente**: historial de cargos/abonos, carga rápida.
- **Catálogo / Inventario**: alta de productos, categorías, alerta de
  stock bajo.
- **Mis Notas**: pizarra con colores.
- **Rendimiento (BI)**: totales de facturado/cobrado/ganancia (versión
  simple; gráficos por mes quedan para el siguiente paso).

## Qué falta (próximos pasos, no crítico para arrancar hoy)

- Facturas en PDF y reporte anual (la app Flutter los generaba local).
- Cierre mensual automático.
- Pantalla de administración de Usuarios y Seguridad (hoy los usuarios
  se crean a mano desde el panel de Supabase).

## El bug que tenía la app Flutter (ya corregido en este repo)

`lib/data/local/app_database.dart`, función `reemplazarDesdNube`: al bajar
datos de Google Sheets, borraba **todos** los clientes y cuentas locales
sin importar si tenían cambios pendientes de subir. Si el ciclo de bajada
(cada 40s) se disparaba antes de que un cliente/cargo recién creado en el
teléfono terminara de subir, ese dato se borraba del teléfono sin haber
llegado nunca a Sheets — se perdía para siempre. Es la causa más probable
de "agrego datos desde Android y no aparecen en mi tabla". El fix ya está
aplicado en `legacy-flutter-app/lib/data/local/app_database.dart` de este
repo: solo falta que reemplaces ese archivo en tu proyecto local, corras
`flutter pub get` y vuelvas a compilar/publicar el APK y la web de
Netlify. Mientras se termina de migrar todo a Supabase, ese fix evita que
sigas perdiendo datos con el sistema viejo.
