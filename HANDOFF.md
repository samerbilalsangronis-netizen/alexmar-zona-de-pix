# Handoff — Alexmar / Zona De Pix (app web) — contexto completo para retomar

Fecha de este resumen: **03-nov-2026**. Este archivo existe para que **cualquier
IA nueva** (Claude en otro chat, Codex, o quien sea) pueda entrar a este repo
sin haber visto ninguna conversación previa y: (1) entender el negocio y el
historial de decisiones, (2) entender cómo está armada la app técnicamente,
punto por punto, y (3) saber exactamente dónde quedó todo y qué sigue.

**Si estás por tocar código**: no asumas nada por tu cuenta — leé primero la
sección "Decisiones de diseño" (más abajo) para no revertir algo que ya se
decidió a propósito, y la sección "Cosas puntuales / gotchas" para no repetir
errores ya resueltos.

---

## 1. Quién es el usuario y qué es este proyecto

El usuario es **dueño de Escudería Alexmar / "Autoperiquitos y Rotulados
Alexmar" ("Zona De Pix")** — un negocio de accesorios/repuestos automotrices
y rotulados en **Tovar, Estado Mérida, Venezuela** (teléfono
+58 416-676-8393). Horario: Lunes a Viernes 7:30am-6pm (flexible si hay
trabajo pendiente), Sábados 8am-2pm, Domingos cerrado. Hace envíos a todo el
país por MRW, pago a destino.

Es **principiante en programación** — hay que darle pasos concretos y
explicados ("entrá acá, tocá este botón", con nombres exactos de botones si
hace falta guiarlo por una interfaz nueva), no dar por sentado que sabe usar
consolas, SQL, Git, etc. Prefiere confirmaciones rápidas antes de emprender
algo grande (usar preguntas de confirmación cuando haya una decisión de
diseño real — nombre de una categoría nueva, cómo agrupar productos, etc. —
pero no para trivialidades) y quiere **ver los cambios funcionando en
producción**, no solo "ya lo subí" — siempre hay que verificar el deploy real
antes de darlo por terminado.

### Historia (por qué existe este repo)

El negocio tenía un sistema viejo: **Google Sheets + Apps Script como
backend + una app Flutter** (Android nativo y web vía Netlify) con base de
datos local SQLite (paquete `drift`) que sincronizaba con Sheets cada 40
segundos en ambas direcciones. Había un bug de sincronización (datos cargados
desde Android que a veces no llegaban a la tabla) que **ya está corregido**
en `legacy-flutter-app/lib/data/local/app_database.dart` (la función que
bajaba datos de Sheets borraba clientes/cargos locales sin filtrar por
`pendienteSync`).

Con ese incendio apagado, el usuario pidió la **migración completa a una app
web** con Supabase como backend, para dejar de depender de Apps
Script/Sheets. Esa migración es este repo. **La app Flutter/Sheets vieja ya
no se usa** — se dejó `legacy-flutter-app/` solo como referencia/respaldo del
código fuente (sin assets binarios), no se toca salvo pedido puntual sobre el
sistema viejo.

---

## 2. Dónde vive todo

### Repo principal (la app web)
- **Repo**: `samerbilalsangronis-netizen/alexmar-zona-de-pix` (GitHub,
  **público**). Rama de producción: `main`.
- **Deploy**: Vercel, conectado al repo de GitHub, auto-deploy en cada push a
  `main`.
- **URL en producción**: https://alexmar-zona-de-pix.vercel.app

### Repo aparte: JARVIS (asistente de IA, Python — ver sección 10)
- **Repo**: `samerbilalsangronis-netizen/jarvis-alexmar` (GitHub,
  **privado**). Es un proyecto Python totalmente separado (no es parte de
  esta app web), pensado para correr en Replit. Consulta la misma base de
  Supabase en modo solo-lectura. Ver sección 10 para el detalle completo y el
  estado de avance.

### Base de datos — Supabase
- Proyecto ref `brnfxjzibiimijaawcvy`.
- URL: `https://brnfxjzibiimijaawcvy.supabase.co`
- anon key (pública por diseño, no es secreta, va embebida en el sitio y
  también se usa en JARVIS):
  `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJybmZ4anppYmlpbWlqYWF3Y3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUzNzU1NjYsImV4cCI6MjEwMDk1MTU2Nn0.SfE-QmciRyakIU02qzLwDSbGVxvYN76ouRzVWcHauho`
- **La `service_role` key NO está guardada en ningún lado** (ni en este
  handoff, ni en ningún repo, a propósito). Si hace falta para una tarea
  puntual de administración (migración masiva de datos, subir muchas fotos
  por script, etc.), pedírsela al usuario de nuevo: Supabase Dashboard →
  Project Settings → API → "service_role secret". Usarla solo para esa tarea
  puntual (en memoria/variable de entorno temporal) y **nunca** guardarla en
  un archivo del repo ni en un `.env` que se vaya a commitear.
- Variables de entorno en Vercel (Project Settings → Environment Variables):
  `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`.
- El usuario ya tiene su usuario de Auth creado y promovido a ADMIN.
- **No hay forma de ejecutar SQL arbitrario por API** con las claves
  disponibles en runtime (ni la anon key ni una service_role key temporal lo
  permiten para DDL vía REST) — **todo cambio de esquema se le da al usuario
  como bloque SQL para que lo pegue y corra él mismo en el SQL Editor del
  Dashboard de Supabase**. Esto se usó una y otra vez a lo largo de la
  sesión y es el flujo esperado — no intentar otra cosa.

### Storage buckets (Supabase)
Todos públicos para lectura; solo usuarios autenticados pueden
subir/editar/borrar (políticas en `supabase/schema.sql`):
- `productos` — fotos de productos del inventario (incluye las fotos
  recortadas del catálogo de PLAST INNOVA, ver sección 9).
- `facturas-proveedor` — fotos de facturas de proveedores.
- `fusibleras` — pensado para fotos de diagramas de caja de fusibles (ver
  sección 9.3) — bucket creado, prácticamente sin uso real todavía.
- `public-assets` — bucket que el usuario creó a mano para pasar el logo del
  negocio (no lo usa la app en runtime; el logo ya está copiado al repo como
  `public/logo-alexmar.png`).

---

## 3. Cómo continuar trabajando en una sesión nueva

1. Clonar/agregar el repo (`samerbilalsangronis-netizen/alexmar-zona-de-pix`).
2. **No hace falta rehacer nada de Supabase ni de Vercel** — el proyecto ya
   está provisionado, con datos reales de producción cargados, y el deploy ya
   está conectado.
3. **Instalar dependencias siempre al empezar** (`npm install`) — cada
   container/sesión nueva arranca sin `node_modules`, y sin esto `npm run
   build` falla con errores de tipos que parecen un bug pero no lo son
   (`Cannot find type definition file for 'vite/client'`).
4. Correr `npm run build` (que corre `tsc -b && vite build`) y `npx oxlint`
   **antes de cada push** — nunca pushear sin que esto pase limpio.
5. Después de cada push a `main`, **verificar el deploy real**, no asumir
   por tiempo transcurrido:
   ```bash
   until bash -c '
     html=$(curl -s https://alexmar-zona-de-pix.vercel.app/)
     js=$(echo "$html" | grep -oE "src=\"/assets/[^\"]+\.js\"" | head -1 | sed -E "s/src=\"(.*)\"/\1/")
     curl -s "https://alexmar-zona-de-pix.vercel.app${js}" | grep -q "<cadena nueva del cambio>"
   '; do sleep 5; done
   ```
   Correr esto en background (o con la tool `Monitor` si está disponible) y
   recién confirmarle al usuario "ya está en producción" cuando el loop
   realmente encuentre la cadena nueva en el bundle servido.
6. **Patrón de rama usado durante esta sesión de Claude Code**: hubo una rama
   de trabajo (`claude/alexmar-handoff-le87j4`) que se usó para cada cambio,
   y recién se fusionaba a `main` (fast-forward, sin squash) cuando el
   usuario decía "sí, fusioná". Esa rama es específica de esta sesión de
   Claude Code — **no es una convención que el usuario haya pedido
   explícitamente para siempre**. Lo que sí importa, venga de donde venga el
   cambio (otra rama, directo en `main`, Codex, etc.): build+lint limpios
   antes de tocar `main`, y verificación real del deploy después. Si Codex
   trabaja directo sobre `main` está bien, siempre que respete esos dos
   puntos.
7. Para cambios de esquema de base de datos: escribir el SQL, agregarlo a
   `supabase/schema.sql` en la sección MIGRACIONES (ver más abajo), y
   **dárselo al usuario como archivo/bloque de texto para que lo pegue en el
   SQL Editor de Supabase** — nunca asumir que se puede ejecutar solo.

---

## 4. Stack técnico

React 19 + TypeScript + Vite 8 + Tailwind CSS v4 + React Router v7
(`HashRouter`, por eso las rutas son `/#/algo`) + Supabase
(Postgres + Auth + Storage + Realtime) + jsPDF + jspdf-autotable, deploy en
Vercel. Mismo patrón de stack que otro proyecto del mismo usuario
(`hikman-prueba`), a pedido explícito de él. Linter: `oxlint`. No hay test
suite automatizada — la verificación es build + lint + revisión manual en
producción.

---

## 5. Estructura de carpetas (completa y actualizada)

### Raíz
- **`supabase/schema.sql`** — TODO el esquema de la base de datos. El
  esquema inicial (tablas base) es idempotente de punta a punta (`create
  table if not exists`, `drop policy if exists` antes de cada `create
  policy`, **y ahora también `drop trigger if exists` antes de cada `create
  trigger`** — esto se corrigió durante la sesión porque faltaba y rompía si
  se reintentaba correr el archivo completo sobre una base ya provisionada).
  Los cambios posteriores al esquema inicial están en la sección
  "MIGRACIONES" al final del archivo, **en orden cronológico** — cada vez
  que se agregue una columna/tabla/vista/bucket nueva, sumar el bloque SQL
  ahí (no editar el esquema inicial) y dárselo al usuario para correr en el
  SQL Editor.
- **`legacy-flutter-app/`** — código fuente de la app Flutter vieja (con el
  fix del bug de sync ya aplicado), sin binarios. Solo referencia/respaldo,
  no se toca salvo pedido puntual sobre el sistema viejo.
- **`HANDOFF.md`** — este archivo.

### `src/types.ts`
Todos los tipos + constantes compartidas:
- `Cliente`, `LineaCuenta` (CARGO|ABONO|TITULO), `METODOS_PAGO`.
- `Producto`, `CATEGORIAS_INVENTARIO` — **lista fija de 16 categorías**:
  FORD, CHEVROLET, TOYOTA, HYUNDAI, RENAULT, CHERY, FIAT,
  DONGFENG-JAC-FOTON, MACK-IVECO-ENCAVA, GENERICO-UNIVERSAL, ILUMINACION
  AUTOMOTRIZ, SISTEMA ELECTRICO, CUIDADO Y ESTETICA, ACCESORIOS INT-EXT,
  **PLAST INNOVA**, **SCORPION** (las dos últimas agregadas en esta sesión,
  ver sección 9). Importante: esta constante es **solo del frontend** — la
  columna `categoria_tags` en la base es texto libre, sin `check constraint`,
  así que agregar una categoría nueva nunca requiere tocar SQL, solo este
  archivo (+ el emoji en `categorias.ts`).
- `Nota`, `Proveedor`, `MovimientoProveedor` (COMPRA|PAGO), `Garantia`
  (ENVIADA|DEVUELTA|RECHAZADA).
- `Fusiblera`, `Fusible` — tipos del módulo de Fusibleras (ver sección 9.3).
- `calcularEstatus` (semáforo AL_DIA/REVISAR/MORA por días desde el último
  abono), `diasDesde`.

### `src/lib/`
- `supabaseClient.ts` — cliente de Supabase (lee `VITE_SUPABASE_URL`/`ANON_KEY`).
- `AuthContext.tsx` — sesión + perfil (tabla `perfiles`, rol ADMIN/VENDEDOR).
- `ThemeContext.tsx` — tema claro/oscuro (localStorage, atributo
  `data-theme` en `<html>`).
- `negocio.ts` — datos fijos del negocio (nombre, ubicación, teléfono,
  logoUrl, nota de pie) usados en las facturas.
- `imagenes.ts` — redimensiona una foto en el navegador (canvas, máx. 1280px,
  JPEG 0.82) y la sube a un bucket de Storage; expone `subirFotoProducto` y
  `subirFotoFacturaProveedor`.
- `generarPdf.ts` — arma el PDF de la factura/estado de cuenta con jsPDF +
  jspdf-autotable (header negro con logo, franja de datos del negocio, tabla
  con abonos resaltados y separadores de vehículo, totales, pie con "Página X
  de Y"). `compartirFacturaPdf()` genera el PDF y lo pasa a
  `navigator.share({files})` si el navegador soporta compartir archivos
  (celular); si no, lo descarga.
- `categorias.ts` — `ICONOS_CATEGORIA`: emoji por categoría de inventario
  (NO son los logos reales de las marcas — decisión consciente, ver sección
  8). `iconoCategoria()` hace fallback a 📦 si la categoría no está
  mapeada.
- `format.ts` — `money()`, `fecha()`.

### `src/components/`
- `Screen.tsx` — layout compartido de las subpáginas (header con back +
  título + acciones + ThemeToggle).
- `ProtectedRoute.tsx` — redirige a `/login` si no hay sesión.
- `ThemeToggle.tsx` — botón ☀️/🌙.
- `Badge.tsx` — `EstatusBadge` (AL_DIA/REVISAR/MORA).
- `GrillaItems.tsx` — grilla estilo planilla para cargar varios ítems a la
  vez, con navegación por flechas del teclado (↑↓ cambian de fila, ←→
  cambian de casilla al llegar al borde del texto, Enter baja de fila).
  Reusada en `HojaCliente` (carga de cargos) y en `FacturacionRapida`.
- `ImagenInput.tsx` — botón de foto. **Importante**: originalmente tenía
  `capture="environment"`, lo que en el celular saltaba directo a la cámara
  sin dar opción de elegir de la galería — esto **se sacó** durante la
  sesión porque el usuario lo reportó como bug; ahora abre el selector
  nativo con ambas opciones (cámara y galería/archivos). Recibe una prop
  `subir` opcional para elegir a qué bucket sube (por defecto productos).
- `Lightbox.tsx` — visor de imagen a pantalla completa. **Tiene zoom**:
  tocar la imagen hace zoom (2.5x) centrado, y con el zoom activo se puede
  arrastrar (pointer events) para recorrerla; tocar de nuevo vuelve al
  tamaño normal. Esto se agregó en la sesión porque antes era una imagen
  estática sin forma de ver detalle. Usado para "ampliar" fotos de
  productos y de facturas de proveedor.
- `ProductoDetalle.tsx` — modal de edición completa de un producto del
  inventario (nombre, categoría, vehículos compatibles, precios, stock
  actual y mínimo, foto con botón "🔍 Ampliar" que abre el Lightbox) + botón
  quitar (borrado suave).
- `LineaDetalle.tsx` — modal de edición de una línea de cuenta de cliente
  (cargo/abono/título) + eliminar.
- `ClienteDetalle.tsx` — **(nuevo)** modal para editar los datos básicos de
  un cliente ya cargado: nombre, cédula, teléfono, dirección, número de
  factura/hoja. Antes de esto no había forma de corregir esos datos sin
  borrar y recrear el cliente. Se abre desde el botón "✏️ Editar" en
  `HojaCliente`.
- `MovimientoProveedorDetalle.tsx` — igual que `LineaDetalle` pero para
  movimientos de proveedor (compra/pago + foto de factura, también con
  Lightbox/zoom).
- `FacturaLayout.tsx` — chrome visual de la factura/estado de
  cuenta/proforma/cotización (header negro+logo, franja de datos del
  negocio, pie de nota), con los botones "Compartir PDF" e "Imprimir".
  **Siempre** se ve en tema claro fijo (blanco/negro), sin importar el tema
  de la app — es un documento de negocio, no parte de la UI.
- `TablaFactura.tsx` — tabla de ítems reusada tanto en la vista HTML de la
  factura como en el PDF generado.

### `src/pages/`
- `Login.tsx` — email/password contra Supabase Auth.
- `Dashboard.tsx` — "Panel de control general", botones (array `ITEMS`):
  Índice Maestro, Catálogo e Inventario, Rendimiento (BI), Mis Notas,
  Facturación Rápida, Proveedores, **Fusibleras** (el último agregado, ver
  sección 9.3).
- `IndiceMaestro.tsx` — lista de clientes (`vista_saldos_clientes`),
  semáforo, buscador, alta, borrado rápido (suave) por fila.
- `HojaCliente.tsx` — detalle de un cliente: tarjeta de datos del cliente
  con botón **"✏️ Editar"** (abre `ClienteDetalle`) y botón "🗑 Quitar
  cliente"; libro de movimientos (cargos/abonos/separadores de vehículo) con
  editar/eliminar por línea; "Vaciar cuenta" (borra movimientos, conserva el
  cliente); carga de cargos en grilla (con campo opcional "Vehículo" que crea
  una línea TITULO separadora); registro de abono con método de pago; link a
  la factura.
- `FacturaCliente.tsx` — ruta `/clientes/:id/factura`.
- `Catalogo.tsx` — navegación en dos niveles: "carpetas" por categoría
  (ícono + conteo + alerta de stock) y, adentro, grilla de productos con
  miniatura, stock/agotado, precio. Buscador con alcance correcto: SIN
  entrar a una carpeta busca en TODO el inventario; DENTRO de una carpeta
  busca solo ahí. Click en un producto abre `ProductoDetalle`.
- `Notas.tsx` — pizarra con 4 colores, crear/editar/eliminar (borrado
  suave).
- `Rendimiento.tsx` — estadísticas simples (total facturado/cobrado/ganancia
  neta) calculadas en el cliente desde `detalle_cuentas`. Pendiente:
  gráficos por mes y cierre mensual automático.
- `FacturacionRapida.tsx` — generador de Factura/Preforma/Cotización para
  clientes ocasionales que NO están en la base de datos — no persiste nada.
- `Proveedores.tsx` — lista de proveedores (`vista_saldos_proveedores`),
  saldo = lo que se les debe, alta, borrado rápido, link a Garantías.
- `HojaProveedor.tsx` — detalle de un proveedor: movimientos de Compra (sube
  la deuda, con foto de factura opcional) y Pago (la baja).
- `Garantias.tsx` — registro de productos enviados a garantía.
- `Fusibleras.tsx` / `FusibleraDetalle.tsx` — **(nuevo, ver sección 9.3)**
  buscador de vehículo → diagrama de caja de fusibles con puntos tocables.
  Shippeado a producción pero **sin datos reales cargados** — ver por qué en
  la sección 9.3.

---

## 6. Esquema de datos (resumen — `supabase/schema.sql` es la fuente de
verdad, siempre leerlo si hace falta precisión exacta de columnas)

- `perfiles` — un perfil por usuario de Supabase Auth (nombre, rol
  ADMIN/VENDEDOR, activo). Se crea solo con un trigger al registrarse
  (`crear_perfil_nuevo_usuario`, `security definer`, con manejo de excepción
  para que un fallo ahí nunca bloquee la creación del usuario).
- `clientes` / `detalle_cuentas` (CARGO/ABONO/TITULO, `metodo_pago` solo
  para abonos) → vista `vista_saldos_clientes` (recalcula el saldo sumando
  líneas reales, nunca confía en un campo estático).
- `inventario` (categoría, vehículos compatibles, costo/pvp opcionales,
  stock actual/mínimo, url_foto, eliminado).
- `inventario_publico` — **(nuevo)** VISTA de solo lectura sobre
  `inventario` que excluye `costo` y solo muestra filas no eliminadas;
  tiene `grant select` para el rol `anon`. Se creó porque `inventario` exige
  sesión autenticada (RLS) y JARVIS (que usa la anon key, sin login) no
  podía leer nada — ver sección 9.4 para el detalle completo de este
  hallazgo, es importante si algo más necesita leer el inventario sin
  login.
- `notas`.
- `cierres_mensuales` — existe, sin UI todavía.
- `proveedores` / `movimientos_proveedor` (COMPRA/PAGO, `factura_url`
  opcional) → vista `vista_saldos_proveedores` (mismo patrón que clientes,
  en espejo).
- `garantias`.
- `fusibleras` (marca, modelo, año desde/hasta, ubicación, imagen_url) /
  `fusibles` (numero, función, amperaje, `pos_x`/`pos_y` en % para ubicar el
  punto tocable sobre la imagen) — ver sección 9.3.

**RLS**: todas las tablas de negocio (incluida `inventario`) usan la misma
política simple `auth.role() = 'authenticated'` para todo
(select/insert/update/delete) — es una herramienta interna de un solo
negocio, no multi-tenant. La distinción de rol (ADMIN ve costos, VENDEDOR
no) hoy es **solo a nivel de UI**, no está reforzada a nivel de base de
datos. La única excepción es `inventario_publico`, pensada específicamente
para acceso externo sin login (ver sección 9.4).

**Realtime**: `clientes`, `detalle_cuentas`, `inventario`, `notas`,
`proveedores`, `movimientos_proveedor`, `garantias`, `fusibleras`,
`fusibles` están en la publicación `supabase_realtime` — las páginas usan
`supabase.channel(...).on('postgres_changes', ...)` para refrescarse solas
cuando cambia algo desde otro dispositivo.

---

## 7. Migración de datos históricos (ya hecha, no repetir)

Se migraron los datos reales del Excel de respaldo de la base de datos vieja
(`Alexmarapp.xlsx`) con un script Python de un solo uso (no guardado en el
repo, usó la service_role key temporalmente vía REST de PostgREST con
`Prefer: resolution=merge-duplicates`, reusando los mismos UUID del sistema
viejo):

- 97 clientes, 639 productos de inventario, 2.632 líneas de cargos/abonos,
  16 notas, 4 cierres mensuales.
- 74 líneas de `DETALLE_CUENTAS` "huérfanas" se descartaron a propósito.
- Los `USUARIOS` del sistema viejo no se migraron (incompatibles con
  Supabase Auth).
- Se verificó cruzando montos contra capturas reales de la app vieja.

Si aparece más data histórica para cargar a mano (no vía la app), el patrón
es siempre el mismo: pedirle al usuario la `service_role` key (nunca
guardarla en archivos), escribir un script puntual, correrlo, avisar que se
descarta después. **Alternativa usada con éxito varias veces en esta
sesión para cargas chicas/medianas (ver sección 9)**: en vez de pedir la
service_role key, armar directamente el SQL `insert into ...` y dárselo al
usuario para pegar en el SQL Editor — más simple cuando son decenas de
filas, no miles.

---

## 8. Decisiones de diseño / trade-offs importantes (para no repreguntar ni
revertir sin querer)

- **Facturas: PDF real generado en el navegador**, no captura de pantalla ni
  depender del "Imprimir → Guardar PDF" del sistema operativo. Se usa
  jsPDF + jspdf-autotable (resuelve la paginación automática de la tabla).
  El botón "Imprimir" con CSS de impresión se dejó aparte, para quien
  prefiera imprimir en papel.
- **No hay lectura automática (OCR/IA) de facturas de proveedor.** Decisión
  consciente del usuario: la foto se sube redimensionada y el monto se
  escribe a mano.
- **Los "logos" de categoría del catálogo son emojis**, no los logos reales
  de Ford/Chevrolet/etc. (evita problemas de marca registrada de terceros).
  Si el usuario manda logos propios, van en `categorias.ts`.
- **`legacy-flutter-app/` no se toca ni se despliega** salvo pedido puntual.
- **Tema claro/oscuro**: toggle persistido en localStorage
  (`alexmar_tema`), variables CSS en `src/index.css`. Única excepción
  intencional: los componentes de factura siempre se ven en estilo claro
  fijo (son documentos de negocio, no pantallas de la app).
- **`GrillaItems` es un componente compartido**, reusado en `HojaCliente` y
  `FacturacionRapida`.
- **Todo el borrado es "suave"** (`eliminado = true`, nunca `DELETE` real).
  No hay pantalla de "papelera/recuperar" todavía; se recupera a mano por
  SQL si hace falta.
- **Categorías de inventario son texto libre sin constraint en la base** —
  agregar una categoría nueva (como pasó dos veces en esta sesión, PLAST
  INNOVA y SCORPION) es un cambio de **solo frontend**
  (`CATEGORIAS_INVENTARIO` en `types.ts` + emoji en `categorias.ts`), nunca
  hace falta tocar SQL para esto.
- **No se scrapea ni se copia contenido de catálogos/sitios de terceros con
  copyright** (se evaluó explícitamente para un sitio de diagramas de
  fusibleras de terceros y se descartó, ver sección 9.3). Sí es aceptable
  usar el catálogo PDF que el propio proveedor (ej. Plast Innova) le entrega
  al usuario como cliente mayorista — eso es material propio del negocio,
  no de un tercero ajeno — ver sección 9.2 para el criterio aplicado.
- **Para cargas masivas de productos desde catálogos de proveedor con fotos
  reales**: el patrón que funcionó fue recortar las imágenes del
  PDF/catálogo del proveedor (card completa: foto + nombre + specs, no una
  foto "limpia" aislada) y subirlas junto con los datos — ver sección 9.2
  para el detalle técnico completo (es un patrón reusable si aparece otro
  catálogo de otro proveedor).

---

## 9. Trabajo reciente de esta sesión (contexto importante, no son cambios
"triviales" — cada uno tuvo su propia decisión de diseño)

### 9.1 Edición de cliente + galería/zoom de fotos
Ya cubierto en las secciones de componentes arriba (`ClienteDetalle.tsx`,
cambios en `ImagenInput.tsx` y `Lightbox.tsx`). Resumen: antes no se podía
corregir nombre/cédula/teléfono de un cliente sin recrearlo, y las fotos no
tenían zoom ni opción de elegir de galería (forzaba cámara). Ambos corregidos
y en producción.

### 9.2 Categoría PLAST INNOVA — 74 productos cargados con fotos reales del catálogo
El usuario quería agregar al inventario parte del catálogo de su proveedor
"Plast Innova" (lámparas LED y accesorios cromados para camiones), con foto,
nombre y características — no solo texto.

**Proceso seguido** (reusable si aparece otro catálogo de otro proveedor):
1. El usuario mandó una **foto con códigos escritos a mano** (los productos
   que más usa) y el **catálogo completo en PDF** del proveedor.
2. Se renderizó el PDF página por página a imágenes de alta resolución
   (`pdftoppm`, hubo que instalar `poppler-utils` — no viene preinstalado).
3. Se cruzaron los códigos a mano contra el catálogo, confirmando con el
   usuario los casos dudosos (letra poco clara, códigos repetidos) antes de
   cargar nada — **nunca asumir una lectura ambigua de letra manuscrita**.
4. **Punto clave de diseño**: inicialmente se intentó recortar solo la
   fotografía "limpia" de cada producto (sin texto), pero calcular las
   coordenadas exactas a mano para ~75 productos en ~20 layouts de página
   distintos resultó muy lento y propenso a error. El usuario, puesto a
   elegir, prefirió esperar a que quedara bien recortado en vez de cargar
   todo sin foto — así que se persistió con el recorte, afinando el método:
   grillas de referencia con porcentaje exacto sobre la imagen renderizada,
   verificando cada recorte visualmente antes de seguir. El resultado final
   son recortes de la **tarjeta completa del catálogo** (foto + nombre +
   specs impresas), no solo la foto aislada — esto resultó ser mejor de
   todos modos porque el recorte ya muestra las especificaciones visualmente
   sin necesitar un campo de texto aparte.
5. Las imágenes se comprimieron a JPEG (~900px lado máximo, calidad 82) y se
   subieron al bucket `productos` vía un script Python puntual que usó la
   **service_role key** (pedida al usuario, usada una sola vez, descartada
   después) — necesario porque son ~75 archivos reales, demasiado para
   pegar como SQL con imágenes en base64.
6. **Nunca se copiaron textos ni imágenes de sitios de terceros no
   relacionados con el negocio** (ver el caso descartado de un sitio de
   diagramas de fusibleras en la sección 9.3) — la distinción aplicada fue:
   el catálogo de Plast Innova es material que el proveedor **le entrega
   directamente al usuario como cliente mayorista** para identificar sus
   propios productos en su propio inventario, uso interno, no reventa ni
   republicación pública — distinto de scrapear el sitio de un competidor
   sin relación comercial con el usuario.

Resultado: 74 productos bajo categoría `PLAST INNOVA`, con foto, sin
costo/PVP (el usuario los completa él mismo al ir comprando stock real).

### 9.3 Fusibleras — shippeado, pero deprioritizado (sin datos reales)
Se construyó un módulo completo (tablas `fusibleras`/`fusibles`, páginas
`Fusibleras.tsx`/`FusibleraDetalle.tsx`, botón en el Dashboard) para que el
usuario pudiera buscar un vehículo y ver el diagrama de su caja de fusibles
con puntos tocables que muestran qué hace cada uno (caso de uso real: un
auto llega con la corneta sin sonar, en vez de probar fusible por fusible se
busca directo cuál es).

**Por qué no tiene datos reales todavía**: el usuario quería cargar
diagramas reales de autos (ej. Ford Ka). La fuente obvia era un sitio
llamado StartMyCar, que tiene diagramas de casi todos los vehículos — **se
evaluó explícitamente y se descartó**: es contenido con copyright de un
tercero (Rewise Inc.) sin relación comercial con el usuario, su propio
`robots.txt` bloquea expresamente bots de IA/scraping, y aunque fuera para
uso interno/privado, reproducir su diagrama específico seguía siendo
redistribución de su material protegido. Se armó una alternativa (un
generador de diagrama propio, grilla simple con colores estándar de la
industria, no una copia visual de ningún sitio) y se probó con un Ford Ka
2005 de prueba — pero al verlo, **el usuario no quedó conforme con el
estilo visual** y pidió dejar esta sección para después. **No se llegó a
cargar ni siquiera ese dato de prueba** en la base — las tablas existen,
están vacías.

Si se retoma: el enfoque recomendado (ya conversado con el usuario) es que
él mismo vaya fotografiando la caja de fusibles real de los vehículos que
entran al taller — cero riesgo legal, datos 100% reales, y de paso evita
todo el problema de recortar imágenes de un catálogo/diagrama ajeno.

### 9.4 Categoría SCORPION — 13 productos agrupados desde una factura de proveedor
El usuario mandó una foto de una factura de "Duper Distribuciones C.A." con
~53 líneas de productos nuevos. Pidió una categoría nueva **"SCORPION"**
(confirmado el nombre exacto porque lo escribió de dos formas distintas en
el mismo mensaje — "Scorpio" y "Scorpion" — hubo que preguntar cuál era),
**sin costo ni PVP** (los va a completar él mismo), y dio instrucciones de
**agrupar varias líneas de la factura en una sola fila de inventario**,
sumando cantidades (ej. "cubre placa ahumado" en 3 tonos distintos → una
sola fila con la suma de las 3 cantidades; "alfombras" de 3/4/5 piezas con y
sin logo de marca → una sola fila). También pidió **omitir por completo**
ciertas líneas (cepillos limpiaparabrisas, bombillos LED, tope de goma para
puertas) — no se cargaron, ni agrupados ni individuales.

El proceso fue puramente conversacional/manual (leer la foto de la factura,
proponer el agrupamiento, el usuario corrigió el criterio dos veces antes de
confirmar) y terminó en un `insert into inventario (...)` con 13 filas,
corrido por el usuario en el SQL Editor. **Patrón a tener en cuenta**: con
cargas chicas (decenas de filas, sin fotos) conviene más dar el SQL directo
que pedir la service_role key — mucho más rápido y sin credenciales de por
medio.

### 9.5 Vista `inventario_publico` (hallazgo importante de RLS)
Al construir JARVIS (sección 10) se descubrió en la práctica (no por
suposición) que la tabla `inventario` **no se puede leer con la anon key
sola** — la política RLS exige `auth.role() = 'authenticated'`, y la app web
nunca lo nota porque el usuario siempre está logueado, pero cualquier
cliente externo sin login (un bot, un script, etc.) con la key pública
recibe **siempre cero filas**, sin error, lo cual es engañoso (parece que
"no hay resultados" cuando en realidad es un bloqueo de permisos). La
solución fue crear la vista `inventario_publico` (sección 6) con `grant
select` para `anon`, excluyendo `costo`. **Si en el futuro algo más necesita
leer datos del inventario sin que el usuario esté logueado en la app
(un bot, una integración, una página pública), usar este mismo patrón**:
una vista reducida con grant a `anon`, nunca abrir RLS de la tabla real.

---

## 10. JARVIS — asistente de IA para el negocio (repo aparte, subproyecto)

**Qué es**: un asistente conversacional en Python ("Alex Mar") pensado para
responder por WhatsApp/voz en el futuro, arrancando por una Fase 1 mucho más
chica: un bot de consola (CLI) con 3 capacidades — Ventas (consulta el
inventario real de Supabase), Soporte (horarios/envíos/ubicación, datos
fijos) y General (clima de Tovar vía OpenWeatherMap, tasa del dólar
Venezuela vía `ve.dolarapi.com`). Es un proyecto del mismo usuario pero
**totalmente separado de esta app web** — otro lenguaje (Python), otro
hosting (Replit), otro repo.

- **Repo**: `samerbilalsangronis-netizen/jarvis-alexmar` (privado). Tiene su
  propio README, GUIA_SETUP_REPLIT.md y troubleshooting.md — toda la
  documentación de cómo instalarlo y por qué se tomó cada decisión de diseño
  vive ahí, no en este handoff.
- Usa la arquitectura de "tool use" nativo de la API de Claude (no un
  clasificador de intención escrito a mano) para decidir cuándo consultar
  Supabase/clima/dólar.
- Consulta la vista `inventario_publico` descrita arriba (sección 9.5) — es
  justamente el proyecto que originó ese hallazgo de RLS.
- **No se usó "Hermes Agent" de Nous Research** como pedía el plan original
  del usuario (no existe un paquete real con ese nombre que sirva de
  harness) — se armó un harness propio simple. Documentado en el README de
  ese repo.
- **Estado al cierre de esta sesión**: el código de Phase 1 está completo,
  probado (compilación, búsqueda real contra Supabase, simulación del loop
  de tool-use) y pusheado al repo. El usuario estaba **a mitad de montar el
  proyecto en Replit**: ya importó el repo (vía GitHub, con el conector
  Replit↔Claude conectado desde claude.ai), ya creó su cuenta de Anthropic y
  tenía la clave API, y estaba por cargar los "Secrets" (ANTHROPIC_API_KEY,
  SUPABASE_URL, SUPABASE_ANON_KEY, OPENWEATHER_API_KEY) en Replit. **No está
  confirmado que haya terminado de correrlo ni que lo haya probado en
  vivo** — si se retoma, preguntar primero en qué quedó, no asumir que ya
  funciona.
- Replit tiene plan gratis suficiente para esta Fase 1 (probar a mano); el
  plan pago (~US$20-25/mes) recién hace falta cuando se necesite que corra
  24/7 sin dormirse, lo cual es relevante recién en una fase futura
  (WhatsApp).

---

## 11. Pendiente / próximos pasos (mencionados y explícitamente pospuestos)

- **Fusibleras**: retomar con fotos reales tomadas por el usuario en vez de
  diagramas generados — ver sección 9.3.
- **JARVIS**: confirmar si el usuario terminó de montarlo en Replit y
  probarlo; seguir con las fases siguientes del plan (Cobranza, Redes,
  Admin, voz, WhatsApp) solo si lo pide.
- **Cierre mensual automático** — la tabla `cierres_mensuales` existe, la UI
  de `Rendimiento.tsx` todavía no la usa.
- **Pantalla de administración de Usuarios y Seguridad** — hoy los usuarios
  se crean a mano desde el dashboard de Supabase.
- **Gráficos por mes** en Rendimiento (BI) — hoy son solo 3 números
  totales.
- **Productos SCORPION y PLAST INNOVA sin precio** — el usuario los va a
  completar él mismo desde la app a medida que define costos/márgenes; no
  es una tarea pendiente de código, es una tarea del usuario.
- Logos reales de categoría de inventario (si el usuario los manda).
- Posible restricción de RLS por rol (VENDEDOR no debería ver
  `costo`/`precio_compra` — hoy esa restricción NO existe, ni en RLS ni en
  la UI web, salvo en `inventario_publico` que la excluye para todos por
  igual).

---

## 12. Cosas puntuales / gotchas (para no perder tiempo re-descubriendo esto)

- **GitHub**: la cuenta `samerbilalsangronis-netizen` es la única con la que
  se puede trabajar en una sesión de Claude Code dada — no se puede mezclar
  con otra cuenta en la misma sesión. `create_repository` vía integración
  puede fallar con 403 la primera vez por permisos del lado de GitHub
  (pasó dos veces); si pasa, lo más rápido es que el usuario cree el repo a
  mano desde github.com/new.
- **Node/npm**: cada sesión/container nuevo necesita `npm install` antes de
  poder buildear — si el build falla con errores de "Cannot find type
  definition file", es casi siempre esto, no un bug real del código.
- **PDFs**: `poppler-utils` (para `pdftoppm`/`pdftotext`) no viene
  preinstalado, hay que `apt-get install poppler-utils` si hace falta
  rasterizar un PDF (pasó con el catálogo de Plast Innova).
- **Verificación de deploy**: siempre el patrón `curl` + `grep` de una
  cadena nueva del cambio recién pusheado, en loop `until` en background —
  nunca confirmar "ya está en producción" solo por tiempo transcurrido.
- **Archivos que manda el usuario**: llegan como adjuntos reales (rutas tipo
  `/root/.claude/uploads/.../nombre`, legibles del disco) o como imagen
  pegada directo en el chat (esto es visible pero no es un archivo en disco
  — si hace falta el archivo real, pedirle que lo adjunte o lo suba a algún
  storage público).
- **Decisiones de nombres/categorías ambiguas**: dos veces en esta sesión el
  usuario escribió el mismo nombre de categoría de dos formas distintas en
  el mismo mensaje — siempre confirmar el nombre exacto antes de crear algo
  que va a quedar permanente en la base, es mucho más barato preguntar una
  vez que corregir después.
- **Supabase SQL Editor**: ejecutar SQL ahí corre como rol con privilegios
  de superusuario/dueño del esquema — por eso una vista sin
  `security_invoker` creada desde ahí puede leer una tabla con RLS
  restrictivo aunque quien consulte la vista después sea anónimo (así
  funciona `inventario_publico`). Tenerlo en cuenta si se crean más vistas
  "puente" como esa.

---

## Nota para Codex (o cualquier IA que use este repo con permisos de
escritura directa)

- Este repo es la fuente de verdad de la app web en producción — un push a
  `main` se despliega solo (Vercel). Tratá cualquier cambio en `main` como
  si fuera a producción inmediatamente, porque lo es.
- Antes de tocar `main`: `npm install` (si hace falta), `npm run build`,
  `npx oxlint` — los tres limpios.
- Los cambios de base de datos (tablas, columnas, vistas, políticas) no se
  pueden aplicar solos desde el código — van como bloque SQL nuevo al final
  de `supabase/schema.sql` (sección MIGRACIONES) y el usuario los corre a
  mano en el SQL Editor de Supabase. No asumas que un cambio de esquema ya
  está aplicado en producción solo porque está en el repo — confirmá con el
  usuario si corrió el SQL.
- Si agregás una categoría de inventario nueva: es solo
  `CATEGORIAS_INVENTARIO` en `src/types.ts` + un emoji en
  `src/lib/categorias.ts` — no hace falta SQL.
- Después de pushear, verificá el deploy real contra
  `https://alexmar-zona-de-pix.vercel.app/` antes de decir que algo "ya
  está arriba".
- Leé la sección 8 (Decisiones de diseño) antes de "corregir" algo que
  parezca raro a primera vista — varias cosas que podrían verse como bugs
  (emojis en vez de logos, PDF en vez de captura, borrado suave en vez de
  DELETE, categorías sin constraint en la base) son decisiones a propósito,
  no descuidos.
