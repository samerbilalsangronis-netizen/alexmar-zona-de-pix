# TRASPASO — Publicidad ALEXMAR (actualizado viernes 30-oct-2026, 4:00 pm)

Leer esto al empezar un chat nuevo del proyecto. Las reglas generales (rol, paleta, formatos, textos) están en las instrucciones del proyecto y en la "ficha alexmar".

## 0. Al empezar el chat nuevo
1. Agregar el repositorio **samerbilalsangronis-netizen/alexmar-zona-de-pix** con permiso de escritura y clonar solo la rama **`publicidad`** (`git clone --depth 1 --branch publicidad --single-branch …`). No tocar main. Si el push falla: `git pull --rebase origin publicidad` y volver a empujar.
2. Revisar en Metricool (brand 7455167) qué hay programado de noviembre (el plan Free da 20 publicaciones al mes; noviembre empieza en cero).
3. Preguntar a Samer por los pendientes de la sección 5.

## 1. Reglas acordadas (además de las instrucciones del proyecto)
- **Solo Instagram** (@autoalexmar_car). No hacer versiones de WhatsApp. Posts y carruseles en 1080x1350; historias y Reels en 1080x1920. Si no dice formato: post + historia.
- **Videos:** se entregan **sin audio**. Samer pone la música (CapCut), lo devuelve y dice "programa"; ahí se programa en Metricool con publicación automática. Si no da hora, usar 10:00 am (o 1:00 pm si ya hay algo ese día).
- **LA MARCA VA GRANDE (regla más importante, 28-oct):** en todo video, barra negra arriba con **logo grande + ALEXMAR en naranja + "Autoperiquitos y Rotulados"**, y barra abajo con **0416-676 83 93 grande** + "Tovar · Pueblo Llano · @autoalexmar_car", líneas naranjas separando las barras. Marca de agua ALEXMAR diagonal. Cierre con logo gigante. Samer se molestó ("todo chiquitico") cuando la marca iba pequeña.
- **Títulos dentro del video:** grandes (Anton 120–190 px) sobre franja oscura, con kicker pequeño espaciado arriba y rayita naranja. Deben decir **exactamente lo que se instaló o el producto** (LUCES POLICIALES, BOMBILLOS LED, PANORÁMICA, PISOS DELANTEROS…). Rechazó frases genéricas ("Sin filtro", "Manos a la obra", "Luces que se notan").
- **Estilos:** RECHAZÓ el estilo underground/glitch (destellos, RGB, temblor, grano fuerte, REC). APROBÓ el estilo "cine" (barras, color cálido suave, fundidos) y el de "llegando mercancía" (cortes rápidos ~2 s, títulos que cambian, lista de modelos saltando en cintas naranja/crema). Para antes/después: "ANTES · Así llegó" / "DESPUÉS · Bandejas 5D".
- **Mejorar calidad** cuando los videos vienen malos/quemados por el sol: hqdn3d + curves (bajar altas luces) + eq gamma 0.94 + unsharp; reescalar lanczos. Videos de WhatsApp llegan a 360x640 o 720x1280; algunos llegan acostados (rotar con transpose=1).
- **No inventar** especificaciones, precios ni disponibilidad. Las tomas de IA solo si las pide o en piezas de producto; si se usan, `isAiGenerated: true`.
- **Piezas con IA (Higgsfield):** Samer pidió "sorpréndeme" y le gustó la escena IA de la sede con billetes volando, PERO dijo que me pasé con montañas "mitológicas": mantener el entorno **realista** (montañas verdes reales de los Andes, cielo natural) y solo agregar el elemento creativo.
- Antes de programar, mostrar el texto completo con hashtags (si dice "prográmalo" se programa directo y se muestra después).
- Clientes: "nuestro fiel cliente" + nombre en piezas normales; **en promociones no va el nombre**. Preguntar si se difuminan placas.
- Horario: **lunes a sábado, 8 am a 6 pm**. Direcciones: **Tovar:** Carrera 4ta, El Llano, diagonal a LM Market. **Pueblo Llano (sede):** C-9, sector La Curva de Los Luises. Envíos por MRW y Zoom.
- Productos Scorpion: colaborador **@scorpions_vzla**.
- Informar siempre los **créditos de Higgsfield** gastados y el saldo.

## 2. Herramientas y flujo técnico
- **Metricool:** brand **7455167**, America/Caracas. Medios por raw de GitHub: `https://raw.githubusercontent.com/samerbilalsangronis-netizen/alexmar-zona-de-pix/<commit o publicidad>/<ruta>` (también acepta URLs cloudfront de Higgsfield). Carrusel = `instagramData.type POST` con varias medias (imágenes y videos); el audio de catálogo solo aplica a REEL.
- **Higgsfield (plan Plus):** saldo **≈641 créditos** (30-oct). Imagen gpt_image_2_5 2k ≈2,75–3 cr; video minimax_h3 6 s con start/end ≈12 cr; música sonilo_music 20 s ≈1,25 cr.
  - Subir fotos: push al repo → `media_import_url` con el raw.
  - Bajar resultados: el entorno local NO puede descargar de cloudfront (403); se trabaja en `sandbox_exec` (tiene ffmpeg, Pillow, ImageMagick) y para entregar se sube con `media_upload` + `curl PUT` + `media_confirm` y se le da el enlace `d2ol7oe51mr4n9.cloudfront.net/...`.
  - El sandbox a veces da error 502 en esperas largas: usar `background: true` y revisar el log.
  - ImageMagick: capas PNG vacías con `PNG32:` (si no salen negras).
- **Archivos al chat:** `SendUserFile`. Si a Samer no le descarga, mandar versión liviana (crf 23, maxrate 6M, ~19 MB) y el enlace raw de GitHub.
- **Fuentes:** `plantillas/fonts/` Anton, Mont700, Mont900, **Montserrat-VF** (variable: Regular/ExtraBold…), **GreatVibes** (firma manuscrita).
- **Skill /proshot** creada (foto de producto de estudio con IA + diseño ALEXMAR).

## 3. Publicaciones recientes en Metricool
| Fecha | Hora | Pieza | Estado |
|---|---|---|---|
| Lun 26 | 10:25 | Hilux 2025 bandejas 5D | Publicado |
| Mar 27 | 10:00 | Scorpion K150 Corolla (collab @scorpions_vzla) | Publicado |
| Mié 28 | 10:00 | Luces LED Super Duty | Publicado |
| Jue 29 | 10:00 | F-350 con animación (IA) | Publicado |
| Vie 30 | 10:00 | **Carrusel "Todo para tu Super Duty"** (7 láminas, IA) id 409357121 | Publicado |
| Vie 30 | 1:00 pm | **Reel "¡Llegaron las bandejas!"** id 411282406 | Publicado |
| Sáb 31 | 10:00 | **Reel Ford Fiesta estilo cine** (luces policiales, LED, panorámica) id 409428250 | Programado |

## 4. Piezas listas SIN programar (preguntar a Samer cuándo)
- **Toyota Meru bandejas 5D, antes/después** (`reels/meru_bandejas5d/`, script `build_meru.py`, liviano `alexmar_meru_5d_liviano.mp4`). Esperando que Samer le ponga música y lo devuelva. No había toma de la maletera con bandeja puesta (solo el antes).
- **"Hasta que nademos entre los verdes" – sede Pueblo Llano** (post + historia, escena IA realista con billetes volando): `piezas/sede_pueblo_llano_verdes/verdes_pro.py`. Versión vigente v3: post `c101d01a-1e69-4327-b0a6-c370b73eb24d`, historia `d65040f7-6ace-4d3d-b948-b59816a09bc4` (cloudfront d2ol7oe51mr4n9). Fondos IA jobs 0c4081d5 (4:5) y eb7d361f (9:16). Marcar isAiGenerated.
- **"Mente ocupada, manos trabajando"** (post + historia, sin el señor de franela azul, editada con IA): `piezas/mente_ocupada/`. Post `98113689-2220-41f5-9358-56fa3827e9a9`, historia `774937df-4776-4413-8c78-a981822e4d01`. Se ven placas (preguntó si difuminar: sin respuesta).
- **"¡Llegó mercancía!"** (camión descargando + forros Scorpions, plumillas, forros de volante): `reels/llegando_mercancia/alexmar_llegando_mercancia.mp4`, esperando música.
- Exploradoras, faro, volante, fusilera, parrillas Super Duty (reels individuales 9:16) ya usados en el carrusel; se pueden reutilizar como reels sueltos.

## 5. Pendientes / dudas abiertas
- Confirmar nombres de modelos de bandejas: **"Ekaizen"** (¿qué modelo?), **"Machito LS79"** (¿LC79?), **"Terios Vigo"**. Ya salieron así en el reel del 30-oct.
- Si tiene toma de la maletera de la Meru con la bandeja, meterla en el "después".
- Placas visibles en Fiesta, mente ocupada y Meru: Samer no ha dicho si difuminar.
- Viejos: voto rotulado rifa (A/B), respuestas automáticas de Meta, reel "Rumbo a Pueblo Llano" (nunca mandó videos), clonar la voz de Samer (30–60 s de audio limpio, ~40 cr).

## 6. Plantillas de montaje (repo, rama `publicidad`)
- **Plantilla vigente para reels con la marca grande:** `reels/llegando_mercancia/build_mercancia.py` y derivadas `reels/bandejas_llegando/build_bandejas.py` (lista de modelos en cintas que saltan) y `reels/meru_bandejas5d/build_meru.py` (antes/después + mejora de calidad + rotación). Uso: `python build_X.py <carpeta con clips> <salida.mp4>`; se edita la lista `SEG` (clip, inicio, duración, velocidad, "rot"/crop), los `card/title/caption` y la lista `ovl` (tiempos de cada título).
- Estilo cine: `reels/fiesta_underground/build_cine.py`.
- Productos con IA "desarmándose" (vista explosionada): keyframes gpt_image_2_5 9:16 → minimax_h3 start/end 6 s → overlays + ffmpeg en sandbox (ver carrusel Super Duty en `piezas/carrusel_superduty/` y `piezas/ford_*`). Ojo realismo mecánico: bombillo sale por detrás con el vidrio apuntando hacia adentro.
- Piezas foto: `piezas/<nombre>/` (npr_elegante, autobus_encava, pisos_hilux_kavak, mente_ocupada, sede_pueblo_llano_verdes…).
- Reels anteriores con `vid_punch`/xfade rítmico: `reels/sporttrac_pioneer/build_sporttrac.py`.

## 7. Clientes mostrados
- Nixon (Pueblo Llano): Ford Cargo 1721. Enderson Fabián Flórez (@endersonfabianflorez): F-250 Scorpion. Esteban Lolo: Chevrolet EXR. Popular Man: NPR. Rifas Prestigio: Ford Fiesta azul (rotulado en proceso). "Tufruta Mi Paquito".
- Toyota Merú blanca: luces policía (22-oct) y bandejas 5D (30-oct, sin nombre). Ford Fiesta plateado: luces policiales + LED + panorámica (31-oct, sin nombre).
- Rotulados entregados: Azcar (Los Araques), Virgen de la Candelaria 60x8 cm (Corel).
