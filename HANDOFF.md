# Handoff — Alexmar / Zona De Pix (migración web) — para continuar en otro chat

Fecha de este resumen: 30-jul-2026. Si el contexto de este chat está por
llenarse, pegá este archivo completo en el chat nuevo (o pedile a Claude
que lo lea directo del repo) para que la sesión siga exactamente donde
quedó, sin perder nada de lo que ya se decidió o se construyó.

## Quién es el usuario y qué es este proyecto

El usuario es **dueño de Escudería Alexmar / "Zona De Pix"** — un negocio
de accesorios/repuestos automotrices y rotulados en **Tovar, Estado
Mérida, Venezuela** (teléfono +58 416-676-8393). Es **principiante en
programación** — hay que darle pasos concretos y explicados ("entrá acá,
tocá este botón"), no dar por sentado que sabe usar consolas, SQL, Git,
etc. Prefiere confirmaciones rápidas antes de emprender algo grande (usar
`AskUserQuestion` cuando haya una decisión de diseño real, no para
trivialidades) y quiere ver los cambios funcionando en producción, no solo
"ya lo subí".

### Historia (por qué existe este repo)

El negocio tenía un sistema viejo: **Google Sheets + Apps Script como
backend + una app Flutter** (Android nativo y web vía Netlify) con base de
datos local SQLite (paquete `drift`) que sincronizaba con Sheets cada 40
segundos en ambas direcciones. El usuario reportó que **los datos que
cargaba desde Android a veces no llegaban a la tabla**.

**Diagnóstico confirmado con el código real** (no una suposición): en
`lib/data/local/app_database.dart`, la función `reemplazarDesdNube` (la
que bajaba datos de Sheets al abrir la app) borraba **TODOS** los clientes
y líneas de cuenta locales sin filtrar por `pendienteSync`, mientras que
las funciones equivalentes de inventario y notas sí tenían esa protección.
Como el ciclo de bajada corre cada 40s de forma independiente del de
subida, un cliente o cargo recién creado en el teléfono podía borrarse
antes de llegar a subir a Sheets — se perdía para siempre. Ese bug **ya
está corregido** en `legacy-flutter-app/lib/data/local/app_database.dart`
de este repo (protege filas con `pendienteSync = true` igual que ya hacían
`reemplazarInventarioDesdeNube` y `reemplazarNotasDesdeNube`).

Con ese incendio apagado, el usuario pidió la **migración completa a una
app web** con Supabase como backend (mismo patrón que su otro proyecto,
`hikman-prueba`), para dejar de depender de Apps Script/Sheets. Esa
migración es este repo. **La app Flutter/Sheets vieja ya no se usa** — se
dejó `legacy-flutter-app/` solo como referencia/respaldo del código fuente
(sin assets binarios, para no inflar el repo).

## Dónde vive todo

- **Repo**: `samerbilalsangronis-netizen/alexmar-zona-de-pix` (GitHub,
  **público**). Rama única: `main`.
  - ⚠️ Esta cuenta de GitHub (`samerbilalsangronis-netizen`) es la única
    con la que esta sesión de Claude Code puede trabajar — no se puede
    mezclar con otra cuenta en la misma sesión (pasó una vez: el usuario
    creó el repo bajo otra cuenta, `osalpaca14-coder`, por error, y hubo
    que recrearlo bajo la cuenta correcta).
- **Deploy**: Vercel, conectado al repo de GitHub, auto-deploy en cada
  push a `main`.
- **URL en producción**: https://alexmar-zona-de-pix.vercel.app
- **Base de datos**: Supabase, proyecto ref `brnfxjzibiimijaawcvy`
  - URL: `https://brnfxjzibiimijaawcvy.supabase.co`
  - anon key (pública por diseño, no es secreta, va embebida en el
    sitio): `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJybmZ4anppYmlpbWlqYWF3Y3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUzNzU1NjYsImV4cCI6MjEwMDk1MTU2Nn0.SfE-QmciRyakIU02qzLwDSbGVxvYN76ouRzVWcHauho`
  - **La `service_role` key NO está guardada en ningún lado** (ni en este
    handoff, ni en el repo, a propósito). Si hace falta para una tarea
    puntual de administración (migración masiva, crear un bucket de
    Storage por SQL, etc.), pedírsela al usuario de nuevo: Supabase
    Dashboard → Project Settings → API → "service_role secret" (botón
    para revelarla). Usarla solo para esa tarea y no guardarla en
    archivos.
  - Variables de entorno en Vercel (Project Settings → Environment
    Variables): `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`.
  - El usuario **ya tiene su usuario de Auth creado y promovido a
    ADMIN** — no hace falta rehacer ese paso.
- **Storage buckets** (todos públicos para lectura, solo autenticados
  pueden subir/editar/borrar — políticas en `supabase/schema.sql`):
  - `productos` — fotos de productos del inventario.
  - `facturas-proveedor` — fotos de facturas de proveedores.
  - `public-assets` — bucket que el usuario creó a mano para pasarme el
    logo del negocio (no lo usa la app en runtime; el logo ya se copió al
    repo como `public/logo-alexmar.png`).

### Cómo continuar trabajando en una sesión nueva

1. Agregar el repo a la sesión (`add_repo` con owner
   `samerbilalsangronis-netizen`, repo `alexmar-zona-de-pix`), clonarlo,
   `register_repo_root`.
2. **No hace falta rehacer nada de Supabase ni de Vercel** — el proyecto
   ya está provisionado, con datos reales de producción cargados, y el
   deploy ya está conectado. Solo seguir hacienda cambios de código,
   commitear y pushear a `main`; Vercel redeploya solo.
3. Después de cada push, verificar el deploy con `curl` contra
   `https://alexmar-zona-de-pix.vercel.app/`, buscando el bundle JS
   (`grep -oE 'src="[^"]+\.js"'` sobre el `index.html` servido) y
   grepeando adentro del bundle por alguna cadena nueva del cambio que se
   acaba de pushear, en un loop `until` con `run_in_background: true` (o
   con la tool `Monitor`) — así se sabe con certeza cuándo terminó de
   desplegar, sin adivinar tiempos de espera.
4. Correr `npm run build` (que corre `tsc -b && vite build`) y
   `npx oxlint` antes de cada push para no romper producción.

## Stack técnico

React 19 + TypeScript + Vite 8 + Tailwind CSS v4 + React Router v7
(`HashRouter`, por eso las rutas son `/#/algo`) + Supabase
(Postgres + Auth + Storage + Realtime) + jsPDF + jspdf-autotable, deploy
en Vercel. Mismo patrón de stack que `hikman-prueba` (otro proyecto del
mismo usuario), a pedido explícito de él.

### Estructura de carpetas

- **`supabase/schema.sql`** — TODO el esquema de la base de datos. Es
  idempotente de punta a punta (`create table if not exists`,
  `drop policy if exists` antes de cada `create policy`, etc.) — se puede
  correr el archivo entero en un proyecto nuevo y queda todo armado. Los
  cambios posteriores al esquema inicial están en la sección
  "MIGRACIONES" al final del archivo, en orden cronológico — **cada vez
  que se agregue una columna/tabla/bucket nueva, sumar el bloque SQL ahí**
  (no editar el esquema inicial) y dárselo al usuario para que lo corra a
  mano en el SQL Editor de Supabase (no hay forma de ejecutar SQL
  arbitrario por API con las claves disponibles en runtime — ni la anon
  key ni una service_role key temporal lo permiten vía REST, hace falta
  el SQL Editor del dashboard).
- **`legacy-flutter-app/`** — código fuente de la app Flutter vieja (con
  el fix del bug de sync ya aplicado), sin binarios. Solo referencia/
  respaldo, no se toca salvo pedido puntual sobre el sistema viejo.

**`src/types.ts`** — todos los tipos + constantes compartidas: `Cliente`,
`LineaCuenta` (CARGO|ABONO|TITULO), `METODOS_PAGO`, `Producto`,
`CATEGORIAS_INVENTARIO` (14 categorías fijas), `Nota`, `Proveedor`,
`MovimientoProveedor` (COMPRA|PAGO), `Garantia` (ENVIADA|DEVUELTA|
RECHAZADA), `calcularEstatus` (semáforo AL_DIA/REVISAR/MORA por días
desde el último abono).

**`src/lib/`**
- `supabaseClient.ts` — cliente de Supabase (lee `VITE_SUPABASE_URL`/`ANON_KEY`).
- `AuthContext.tsx` — sesión + perfil (tabla `perfiles`, rol ADMIN/VENDEDOR).
- `ThemeContext.tsx` — tema claro/oscuro (localStorage, atributo `data-theme` en `<html>`).
- `negocio.ts` — datos fijos del negocio (nombre, ubicación, teléfono, logoUrl, nota de pie) usados en las facturas.
- `imagenes.ts` — redimensiona una foto en el navegador (canvas, máx. 1280px, JPEG 0.82) y la sube a un bucket de Storage; expone `subirFotoProducto` y `subirFotoFacturaProveedor`.
- `generarPdf.ts` — arma el PDF de la factura/estado de cuenta con jsPDF + jspdf-autotable (mismo diseño que la app Flutter vieja: header negro con logo, franja de datos del negocio, tabla con abonos resaltados y separadores de vehículo, totales, pie con "Página X de Y"). `compartirFacturaPdf()` genera el PDF y lo pasa a `navigator.share({files})` si el navegador soporta compartir archivos (celular); si no, lo descarga.
- `categorias.ts` — `ICONOS_CATEGORIA`: emoji por categoría de inventario (NO son los logos reales de las marcas — decisión consciente, ver más abajo).
- `format.ts` — `money()`, `fecha()`.

**`src/components/`**
- `Screen.tsx` — layout compartido de las subpáginas (header con back + título + acciones + ThemeToggle).
- `ProtectedRoute.tsx` — redirige a `/login` si no hay sesión.
- `ThemeToggle.tsx` — botón ☀️/🌙.
- `Badge.tsx` — `EstatusBadge` (AL_DIA/REVISAR/MORA).
- `GrillaItems.tsx` — grilla estilo planilla para cargar varios ítems a la vez, con navegación por flechas del teclado (↑↓ cambian de fila, ←→ cambian de casilla al llegar al borde del texto, Enter baja de fila). Reusada en HojaCliente (carga de cargos) y en FacturacionRapida.
- `ImagenInput.tsx` — botón de foto (abre cámara/galería nativa en el celular vía `capture="environment"`), recibe una prop `subir` opcional para elegir a qué bucket sube (por defecto productos).
- `Lightbox.tsx` — visor de imagen a pantalla completa (para "ampliar" fotos de productos y de facturas de proveedor).
- `ProductoDetalle.tsx` — modal de edición completa de un producto del inventario (nombre, categoría, vehículos compatibles, precios, stock actual y mínimo, foto) + botón quitar (borrado suave).
- `LineaDetalle.tsx` — modal de edición de una línea de cuenta de cliente (cargo/abono/título) + eliminar.
- `MovimientoProveedorDetalle.tsx` — igual que LineaDetalle pero para movimientos de proveedor (compra/pago + foto de factura).
- `FacturaLayout.tsx` — chrome visual de la factura/estado de cuenta/proforma/cotización (header negro+logo, franja de datos del negocio, pie de nota), con los botones "Compartir PDF" e "Imprimir". **Siempre** se ve en tema claro fijo (blanco/negro), sin importar el tema de la app — es un documento de negocio, no parte de la UI.
- `TablaFactura.tsx` — tabla de ítems reusada tanto en la vista HTML de la factura como en el PDF generado (misma lógica de filas CARGO/ABONO/TITULO).

**`src/pages/`**
- `Login.tsx` — email/password contra Supabase Auth.
- `Dashboard.tsx` — "Panel de control general", 6 botones: Índice Maestro, Catálogo e Inventario, Rendimiento (BI), Mis Notas, Facturación Rápida, Proveedores.
- `IndiceMaestro.tsx` — lista de clientes (`vista_saldos_clientes`), semáforo, buscador, alta, borrado rápido (suave) por fila.
- `HojaCliente.tsx` — detalle de un cliente: libro de movimientos (cargos/abonos/separadores de vehículo) con editar/eliminar por línea, "Vaciar cuenta" (borra movimientos, conserva el cliente — para clientes frecuentes que saldan pero siguen viniendo), "Quitar cliente", carga de cargos en grilla (con campo opcional "Vehículo" que crea una línea TITULO separadora en el historial — pensado para clientes que llevan varios vehículos y quieren la factura separada por vehículo), registro de abono con método de pago (Efectivo/Binance/Zelle/Bolívares/Pesos/Otro), link a la factura.
- `FacturaCliente.tsx` — ruta `/clientes/:id/factura`, arma los datos reales del cliente y se los pasa a FacturaLayout.
- `Catalogo.tsx` — navegación en dos niveles: "carpetas" por categoría (ícono + conteo + alerta de stock) y, adentro, grilla de productos de esa categoría con miniatura, stock/agotado, precio. Buscador con alcance correcto: SIN entrar a una carpeta busca en TODO el inventario; DENTRO de una carpeta busca solo ahí. Click en un producto abre ProductoDetalle.
- `Notas.tsx` — pizarra con 4 colores, crear/editar/eliminar (borrado suave).
- `Rendimiento.tsx` — estadísticas simples (total facturado/cobrado/ganancia neta) calculadas en el cliente desde `detalle_cuentas`. Pendiente: gráficos por mes y cierre mensual automático (la tabla `cierres_mensuales` ya existe pero la UI todavía no la usa).
- `FacturacionRapida.tsx` — generador de Factura/Preforma/Cotización para clientes ocasionales que NO están en la base de datos — no persiste nada, es puramente cliente → PDF/impresión.
- `Proveedores.tsx` — lista de proveedores (`vista_saldos_proveedores`), saldo = lo que se les debe, alta, borrado rápido, link a Garantías.
- `HojaProveedor.tsx` — detalle de un proveedor: movimientos de Compra (sube la deuda, con foto de factura opcional) y Pago (la baja), editar/eliminar por movimiento, totales.
- `Garantias.tsx` — registro de productos enviados a garantía (producto, proveedor opcional, fecha de envío/retorno, estado Enviada/Devuelta/Rechazada, notas), filtro Pendientes/Todas.

## Datos y esquema de la base (resumen — el detalle real está en
`supabase/schema.sql`, que es la fuente de verdad)

- `perfiles` — un perfil por usuario de Supabase Auth (nombre, rol
  ADMIN/VENDEDOR, activo). Se crea solo con un trigger al registrarse
  (`crear_perfil_nuevo_usuario`, `security definer`, con manejo de
  excepción para que un fallo ahí **nunca** bloquee la creación del
  usuario — esto pasó una vez y tiró "Database error creating new user"
  hasta que se hizo el trigger defensivo).
- `clientes` / `detalle_cuentas` (CARGO/ABONO/TITULO,
  `metodo_pago` solo para abonos) → vista `vista_saldos_clientes` (recalcula
  el saldo sumando líneas reales, nunca confía en un campo estático).
- `inventario` (categoría, vehículos compatibles, costo/pvp opcionales,
  stock actual/mínimo, url_foto).
- `notas`.
- `cierres_mensuales` — existe, sin UI todavía.
- `proveedores` / `movimientos_proveedor` (COMPRA/PAGO, `factura_url`
  opcional) → vista `vista_saldos_proveedores` (mismo patrón que
  clientes, en espejo: lo que LES debemos a ELLOS).
- `garantias`.

**RLS**: todas las tablas de negocio usan la misma política simple
`auth.role() = 'authenticated'` para todo (select/insert/update/delete) —
es una herramienta interna de un solo negocio, no multi-tenant. La
distinción de rol (ADMIN ve costos, VENDEDOR no) hoy es **solo a nivel de
UI**, no está reforzada a nivel de base de datos — si el usuario pide
"que un vendedor no pueda editar precios de compra", hay que agregarlo
como policy nueva (no existe todavía).

**Realtime**: `clientes`, `detalle_cuentas`, `inventario`, `notas`,
`proveedores`, `movimientos_proveedor`, `garantias` están en la
publicación `supabase_realtime` — las páginas usan
`supabase.channel(...).on('postgres_changes', ...)` para refrescarse
solas cuando cambia algo desde otro dispositivo (por eso funciona bien
que el usuario cargue datos desde el celular mientras se sigue
desarrollando: son cosas totalmente independientes, y los cambios se ven
en vivo).

## Migración de datos históricos (ya hecha, no repetir)

Se migraron los datos reales del Excel de respaldo de la base de datos
vieja (`Alexmarapp.xlsx`, export de Google Sheets) con un script Python
de un solo uso (no está guardado en el repo — usaba la service_role key
temporalmente vía REST de PostgREST con `Prefer: resolution=merge-duplicates`,
reusando los mismos UUID del sistema viejo para no romper las relaciones
cliente↔cuenta↔producto):

- 97 clientes, 639 productos de inventario, 2.632 líneas de
  cargos/abonos, 16 notas, 4 cierres mensuales.
- 74 líneas de `DETALLE_CUENTAS` "huérfanas" (referenciaban clientes que
  ya no existían) se descartaron a propósito.
- Los `USUARIOS` del sistema viejo (usuario+hash de contraseña) **no** se
  migraron — incompatibles con Supabase Auth (que usa email real). El
  usuario ya creó su usuario nuevo directo en Supabase.
- Se verificó cruzando montos contra capturas de pantalla reales de la
  app vieja (ej. cliente "CHACANTERO" con saldo $4,683.50, "ELEAZAR
  TOVAR" con $8,637.00) — coincidieron exacto.

Si en algún momento aparece más data histórica para cargar, el patrón a
seguir es el mismo: pedirle al usuario la `service_role` key (nunca
guardarla en archivos), escribir un script puntual, correrlo, y avisar
que se descarta después.

## Decisiones de diseño / trade-offs importantes (para no repreguntar ni revertir sin querer)

- **Facturas: PDF real generado en el navegador, no captura de pantalla
  ni depender del "Imprimir → Guardar PDF" del sistema operativo.** Se
  empezó con el enfoque de imprimir vía CSS `@media print` (deja que el
  navegador pagine solo, muy confiable para facturas largas de 90+
  ítems), pero el botón "Compartir" con eso solo mandaba texto plano a
  WhatsApp, no el documento — el usuario pidió explícitamente que
  comparta el archivo. Por eso se agregó `generarPdf.ts` con
  jsPDF + jspdf-autotable (esta librería resuelve la paginación
  automática de la tabla, por eso se eligió en vez de armar el PDF a
  mano con html2canvas o coordenadas manuales). El botón "Imprimir" con
  CSS de impresión se dejó aparte, para quien prefiera imprimir en papel.
- **No hay lectura automática (OCR/IA) de facturas de proveedor.** Se le
  preguntó explícitamente al usuario y eligió la opción simple: la foto
  de la factura se sube (redimensionada) y el monto se escribe a mano.
  OCR quedó descartado por ahora porque implica contratar una API paga y
  agregar una integración aparte — si el usuario lo pide más adelante,
  es un cambio de alcance grande, no un ajuste menor.
- **Los "logos" de categoría del catálogo son emojis, no los logos reales
  de Ford/Chevrolet/etc.** No hay archivos de esos logos y usar marcas
  registradas de terceros sin permiso trae problemas — se lo avisé al
  usuario y no pidió cambiarlo. Si manda logos propios después, van en
  `categorias.ts` (hoy `ICONOS_CATEGORIA` es un emoji por categoría, se
  puede migrar a URLs de imagen sin romper la interfaz).
- **`legacy-flutter-app/` no se toca ni se despliega** salvo pedido
  puntual — es solo respaldo/referencia. Los assets binarios (imágenes,
  `web/`, `android/build`, gradle caches) se excluyeron a propósito para
  no inflar el repo.
- **Tema claro/oscuro**: toggle persistido en localStorage
  (`alexmar_tema`), variables CSS en `src/index.css`
  (`:root[data-theme='dark']` es la paleta original "Modo Jefe", default;
  `:root[data-theme='light']` es la alternativa). Se auditaron TODOS los
  usos de `text-white`/`bg-black`/`text-black` sueltos (no ligados a un
  fondo de color fijo tipo botón naranja) y se reemplazaron por
  `text-[var(--text-primary)]` etc. La única excepción intencional son
  los componentes de factura (`FacturaLayout`, `TablaFactura`,
  `FacturaCliente`, `FacturacionRapida` en su sección imprimible) que
  **siempre** se ven en estilo claro fijo (blanco/negro), sin importar el
  tema de la app — son documentos de negocio, no pantallas de la app.
- **`GrillaItems` se extrajo como componente compartido** después de
  construirla primero adentro de `HojaCliente` — se reusa en
  `FacturacionRapida`. Si se necesita en un tercer lugar, ya está lista
  para reusar tal cual.
- **Todo el borrado es "suave"** (`eliminado = true`, nunca `DELETE`
  real) en clientes, líneas de cuenta, productos, notas, proveedores y
  movimientos de proveedor — consistente con el patrón que ya traía el
  sistema viejo. No hay pantalla de "papelera/recuperar" todavía; si algo
  se borra por error hoy, se recupera a mano por SQL
  (`update <tabla> set eliminado = false where id = '...'`).

## Pendiente / próximos pasos (mencionados y explícitamente pospuestos, no son ideas mías sueltas)

- **Cierre mensual automático** — la tabla `cierres_mensuales` existe,
  la UI de `Rendimiento.tsx` todavía no la usa ni tiene botón para
  generarlo.
- **Pantalla de administración de Usuarios y Seguridad** — hoy los
  usuarios se crean a mano desde el dashboard de Supabase
  (Authentication → Users → Add user, con "Auto Confirm User" tildado
  porque si no pide verificar el email y no hay cómo) y el rol se
  promueve por SQL. No hay una pantalla dentro de la app para esto.
- **Gráficos por mes** en Rendimiento (BI) — hoy son solo 3 números
  totales, sin desglose temporal.
- Logos reales de categoría de inventario (si el usuario los manda).
- Posible restricción de RLS por rol (VENDEDOR no debería ver
  `costo`/`precio_compra` según el diseño original de la app Flutter
  vieja — hoy esa restricción NO existe, ni en RLS ni en la UI web).

## Cosas puntuales de esta sesión de Claude Code que conviene saber

- El repo se creó con create_repository fallando la primera vez por
  permisos (403 "Resource not accessible by integration") — el usuario
  "habilitó el permiso" y funcionó a la segunda. Si vuelve a pasar algo
  similar, no es necesariamente un bug: puede requerir que el usuario
  ajuste permisos de la app de GitHub, o simplemente crear el repo a mano
  desde github.com/new (más rápido que debuggear permisos).
- `add_repo` no soporta mezclar owners de GitHub distintos en la misma
  sesión ("cross-tier adds are not supported") — todo debe ser bajo
  `samerbilalsangronis-netizen`.
- El workspace de esta sesión clona el repo en `/workspace/alexmar-zona-de-pix`.
- Patrón de verificación de deploy usado en toda la sesión: pushear,
  después lanzar un `until curl ... | grep -q "<cadena nueva>"; do sleep
  5; done` en background (o `Monitor`), y recién confirmarle al usuario
  "ya está en producción" cuando ese loop realmente encuentra la cadena
  nueva en el bundle servido — nunca asumir que terminó por el tiempo
  transcurrido.
- El usuario manda archivos de dos formas: adjuntos reales (aparecen
  como `@"/root/.claude/uploads/.../nombre"`, se pueden leer/copiar del
  disco) o pegados directo como imagen en el chat (esto **no** genera un
  archivo accesible — hay que pedirle explícitamente que lo adjunte como
  archivo, o que lo suba a algún storage público y pase el link; así se
  resolvió el logo del negocio, subiéndolo el usuario a un bucket público
  de Supabase Storage).
