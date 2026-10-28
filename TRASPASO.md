# TRASPASO — Publicidad ALEXMAR (actualizado martes 20-oct-2026, 5:30 pm)

Leer esto al empezar un chat nuevo del proyecto. Las reglas generales (rol, paleta, formatos, textos) están en las instrucciones del proyecto y en la "ficha alexmar".

## 0. Al empezar el chat nuevo
1. Agregar el repositorio **samerbilalsangronis-netizen/alexmar-zona-de-pix** con permiso de escritura y clonar solo la rama **`publicidad`** (`git clone --depth 1 --branch publicidad --single-branch …`). No tocar main.
2. Revisar en Metricool (brand 7455167) qué hay programado del 21 al 31 de octubre y cuántas publicaciones quedan (sección 2).
3. **Jueves 22:** revisar el resultado del RETO de luces laterales (reel del miércoles 21): meta **30 me gusta + 15 compartidos**. Si llegó, pedirle a Samer los precios nuevos y armar la pieza de la promoción (precios más bajos en luces laterales LED para camiones).
4. Preguntar: qué ganó la votación del rotulado de la rifa (A o B), si Scorpion aceptó la colaboración, y si ya configuró las respuestas automáticas de Meta (sección 5).

## 1. Reglas acordadas (además de las instrucciones del proyecto)
- **Solo Instagram** (@autoalexmar_car). No hacer versiones de WhatsApp. Posts y carruseles en 1080x1350; historias y Reels en 1080x1920.
- **Videos:** se entregan **sin audio**. Samer pone la música (CapCut/TikTok), lo devuelve, y recién ahí se programa en Metricool con publicación automática. No usar música del catálogo de Instagram.
- **No inventar nada:** los Reels se arman **solo con sus fotos y videos reales**. No usar tomas de IA salvo que lo pida. Si se usan, marcar `isAiGenerated: true`.
- **Textos dentro del video:** cortos, con sentido y descriptivos (el nombre de lo que se instaló: "BARRA LED", "ANTENA PCTEL"...). Rechazó "Luces que se notan" por no tener sentido. Le gustan las frases elegantes/épicas al final ("No es solo una camioneta, es tu carta de presentación", "Los detalles hacen la diferencia").
- **Enfocar el trabajo hecho:** acercamientos (punch-in) a cada pieza instalada, con foco/viñeta alrededor; en fotos se puede realzar el brillo solo de las luces reales.
- **Historias nunca "secas":** video de 12 s con zoom suave y sin audio + imagen. Indicar sticker y 2–3 hashtags. Las sube Samer a mano.
- Antes de programar, **mostrarle el texto completo con hashtags**. Si Samer manda el video con música y dice "prográmalo", se puede programar directo y mostrar el texto después (puede pedir cambios).
- Clientes: "nuestro fiel cliente" + nombre en piezas normales. **En piezas de PROMOCIÓN no va el nombre del cliente.** No inventar el trabajo hecho.
- Horario en publicidad: **lunes a sábado, 8 am a 6 pm**.
- Direcciones: **Tovar:** Carrera 4ta, El Llano, diagonal a LM Market. **Pueblo Llano (sede):** C-9, sector La Curva de Los Luises. Envíos a todo el país por MRW y Zoom.
- Productos Scorpion: colaborador **@scorpions_vzla**.
- Pedirle los videos **como documento por WhatsApp o por Drive** (los normales llegan a 360x640).
- Cuando use Higgsfield, **informar los créditos gastados** de cada acción.
- **Rotulados:** primero propuestas sobre fotos reales; diseño por capas de color después de que Samer escoja.

## 2. Herramientas
- **Metricool:** brand id **7455167**, zona America/Caracas. Plan Free, **20 publicaciones al mes**. Octubre: **10 usadas, quedan 10** (para el 24–31). Hay un borrador viejo de historia (EXR, 17-oct) que Samer debe borrar desde la app (si Metricool lo cuenta, quedan 10).
- **Medios para Metricool:** subir al repo y usar el raw `https://raw.githubusercontent.com/samerbilalsangronis-netizen/alexmar-zona-de-pix/publicidad/<ruta>`.
- **Higgsfield:** plan **Plus** pagado el 18-oct (1.000 créditos/mes, 49 €). Saldo ≈ **991 créditos**. Referencia: voz ~1,2 cr; video IA Kling 3.0 Pro 5 s ~8,75 cr; clonar voz 40 cr (falló con notas de WhatsApp y se reembolsó). Limitación: desde el chat no se pueden subir archivos a Higgsfield ni bajar sus resultados; Samer tiene que subir el material con la ventanita de Higgsfield. Por eso la edición normal se hace aquí con ffmpeg/Pillow.
- **Edición:** ffmpeg + Pillow aquí; el video se manda directo al chat. Fuentes Anton/Montserrat (npm @fontsource).
- **Respuestas a DMs/comentarios:** Claude no tiene acceso. Metricool (con este conector) no lee ni responde. Claude en Chrome solo funciona con la PC de Samer encendida. Opción recomendada: **respuestas automáticas gratis de Meta Business Suite** (bienvenida, ausencia, 4 FAQ, 5 palabras clave, comentario→DM "LUCES" del reto). Los textos ya se le mandaron el 19-oct a las 9 pm. Alternativa con IA: ManyChat Pro (39 $/mes).
- **Alarmas:** herramienta del teléfono (Android), solo con la app de Claude abierta. Samer las borra a mano.

## 3. Reels de Metricool (feed) — octubre
| Fecha | Hora | Reel | Estado |
|---|---|---|---|
| Vie 16 | 10:00 am | Pisos 5D | Publicado |
| Sáb 17 | 10:00 am | F-250 Scorpion (@endersonfabianflorez), tomas IA, colaborador @scorpions_vzla | Publicado |
| Dom 18 | 12:00 pm | Aveo interior, tomas IA | Publicado |
| Lun 19 | 11:30 am | Ford Cargo 1721 de Nixon, iluminación LED | Publicado |
| Mar 20 | 1:00 pm | Alfombras tipo bandeja Scorpion, colaborador @scorpions_vzla | Programado |
| Mié 21 | 10:00 am | **RETO luces laterales**: Cargo 1721 luces LED (sin nombre de cliente). Meta 30 me gusta + 15 compartidos → bajamos precios de luces laterales LED para camiones. `reels/cargo1721_luces_led/` | Programado |
| Jue 22 | 10:00 am | **Toyota Merú**: luces de policía (rojo/azul en parrilla), panorámica LED morada, antena PCTEL, antena australiana, portaplacas ahumado, arreglo de placas. Sin nombre de cliente. `reels/meru_policia/` | Programado |
| Vie 23 | 10:00 am | **Pisos 5D Toyota Hembrita** (Land Cruiser pickup). `reels/bandejas5d_hembrita/` | Programado |
| Sáb 24 | 10:00 am | **Ford Sport Trac** (Tovar): pantalla Pioneer 9" Android (DAH-9250), cámara de retroceso, bombillos LED. Gancho "¿Tu camioneta ya tiene pantalla?", tomas del equipo trabajando. Sin nombres ni @ (Samer no quiere mencionar a nadie del equipo). `reels/sporttrac_pioneer/` | Programado |

Quedan **10 espacios** del 24 al 31. Ideas del plan anterior: Sáb 24 Reel rotulado rifa (segundo del día) · Dom 25 trabajos de la semana · Lun 26 carro de la rifa terminado · Mar 27 pisos 5D (listo en posts/) · Mié 28 educativo · Jue 29 rifa últimos tickets · Vie 30 Reel + promo · Sáb 31 lo mejor del mes · promo luces laterales si se cumple el reto. Mejor hora según Metricool: **10 am** (también 6 pm).

## 4. Historias (las sube Samer a mano)
- Mié 21, 10:15 am: compartir el Reel del RETO con avión de papel + "¡Ayúdanos a llegar a la meta!".
- Jue 22, 10:15 am: compartir Reel Merú. Vie 23, 10:15 am: compartir Reel Hembrita. Sáb 24, 10:15 am: compartir Reel Sport Trac.
- Las alarmas semanales viejas (dom/lun/mar 7:20 am, 11:35, 11:45, 1:05, 1:15, 7:20 pm) hay que borrarlas.

## 5. Pendientes
- **Reto luces laterales:** revisar el jueves 22; si se cumple, pieza de promo con precios que dé Samer (no inventar precios).
- **Respuestas automáticas de Meta:** confirmar si Samer las configuró con los textos del 19-oct.
- **Merú:** si el dueño tiene Instagram o se confirma la sede (parece Tovar), actualizar el post del jueves en Metricool.
- **Rifa (Rifas Prestigio):** Ford Fiesta azul, rotulado solo en vidrios, verde reflectivo + blanco, negro y tornasol. Propuestas A y B en `rotulados/rifa_prestigio/`. Falta que Samer escoja, los datos del cliente y el diseño por capas.
- **Reel "Rumbo a Pueblo Llano":** Samer nunca mandó los videos.
- Si el dueño del Aveo o Nixon tienen Instagram, agregarlos con @.

## 6. Archivos (repo alexmar-zona-de-pix, rama `publicidad`)
- `plantillas/`: `overlays_reel.py`, `cliente.py`, `historias_semana.py`, `rifa_votacion.py`, `make.py`, `cover.py`, `reel.py`, `fonts/`, `assets/logo_alexmar_sticker.png`.
- `reels/<trabajo>/`: versión sin audio, con audio y scripts. Carpetas: `scorpion_f250`, `aveo_interior`, `cargo1721_nixon`, `alfombras_scorpion`, `cargo1721_luces_led`, `meru_policia`, `bandejas5d_hembrita`.
- Plantilla de montaje más reciente: `reels/meru_policia/build_meru.py` + `ov_meru.py` (funciones `vid_punch` = acercamiento en video con centro y zoom; `photo_punch` = acercamiento en foto con foco; `still_full`; xfade encadenado; tarjetas de texto con banda oscura; logo, marca de agua, barra con ALEXMAR y teléfono abajo; cierre con logo grande, teléfono, horario y sedes).
- `rotulados/rifa_prestigio/`, `historias/`, `piezas/`.
- **Estilo de montaje que le gusta:** (desde el Sport Trac) más rítmico: frase gancho al inicio, cortes de 1,6–2,4 s, xfade rápidos 0.15–0.25 s (fadewhite, hlslice, radial, zoomin, smoothleft, hblur) y golpe de zoom al inicio de cada toma (`kick` en `vid_punch`); recortar tiempos muertos de los videos. Plantilla: `reels/sporttrac_pioneer/build_sporttrac.py`. Antes: cortes de 2–3 s, transiciones xfade 0.3–0.45 s (fadewhite como destello, zoomin, smoothleft, smoothup, circleopen, slideleft, fadeblack), color con contraste 1.10–1.12 y saturación 1.18–1.22, textos arriba (y=400) para no tapar el trabajo, frase épica abajo (y≈1250), duración 22–27 s.

## 7. Clientes mostrados
- Esteban Lolo: Chevrolet EXR (historia).
- Nixon, de Pueblo Llano: Ford Cargo 1721 (Reel del 19-oct; también el RETO del 21 pero sin su nombre).
- Enderson Fabián Flórez (@endersonfabianflorez): Ford F-250 Super Duty, luces Scorpion.
- Popular Man: Chevrolet NPR (sin detalle del trabajo).
- Dueño del Aveo azul: nombre pendiente (Tovar).
- Toyota Merú blanca (placa MDY 14H): dueño sin nombre (Reel del 22-oct).
- Toyota Hembrita marrón: pisos 5D (Reel del 23-oct).
- "Tufruta Mi Paquito": fiel cliente (camión de frutas, imagen del 15-oct).
- Rifas Prestigio: Ford Fiesta azul, rotulado en proceso.

## Carrusel piezas Ford Super Duty (en curso, 28-oct)
- Portada: `piezas/proshot_ford_superduty` variante A "Frente cromado" (Higgsfield media 499bb531-198d-4c52-8dc4-4548761255d7).
- Faro original: reel v2 (bombillo bien orientado) media 8d2191d5-275a-4ff3-b2a3-4e97988459c7. Keyframes jobs: frente fdc88d79, trasera corregida 40d02f1e, blanca 273d45b4, amarilla 484273bd.
- Volante + tapa: reel media 5b02905c-258b-4ea5-a063-4d2edacff8ea. Keyframes: armado 37adcce9, tapa fuera 2c4c9b2a, trasera c67698c8. Cierre = clip 1 en reversa.
- Método: gpt_image_2_5 keyframes 9:16 → minimax_h3 start/end 6 s → overlays.py + mk.sh (sandbox Higgsfield, carpetas faro/ y vol/).
- Pendiente: más piezas, música de Samer, unir todo en carrusel (máx. 10 láminas), marcar isAiGenerated.
- Fusilera: reel media 77261846-6032-42f4-b689-eaded9d0f086 (17 s). Keyframes: armada 72d53914 (sin tarjeta SecuriCode), fusibles fuera b45287dc. Clip + reversa. Ojo: la foto original trae el código de acceso del vehículo; en el repo quedó difuminado.
- Parrillas (Super Duty negra original / Super Duty cromada / Tritón): reel media 97d27dfc-90b1-4201-9080-4d8644159854 (17 s). Keyframes 7deefafd (armadas), 4e5cfb50 (emblemas fuera). La negra no trae emblema en la foto: no se le inventó.
- 28-oct 15:25 VERSIONES VIGENTES del carrusel Ford: faro v3 a65e91e1-3171-493a-ad0c-918a881c815b (sin frase 'por detrás, sin desarmar'), volante v2 73b15911-1602-4b56-b061-0effbdaaec64 (sin 'así vienen por detrás'), fusilera 77261846-6032-42f4-b689-eaded9d0f086, parrillas v2 b74ae3cc-1f21-4d99-ac70-bb784ab0f6c3 (3 parrillas sin reflejo, negra con emblema, keyframes 2b49e615 / 6f9ee241). Nota técnica: capas PNG vacías con ImageMagick → usar PNG32: o salen negras.
- Exploradoras (par; la izquierda es espejo de la derecha): reel media a4a5e76e-6c6e-40df-beb5-e8ff05a7d0ce (17 s). Keyframes a16241d5 (frente), ddafdd38 (trasera, bombillos fuera bien orientados).
- 28-oct: CARRUSEL 'Todo para tu Super Duty' programado en Metricool vie 30-oct 10:00 (id 409357121, IG POST, isAiGenerated). 7 láminas 4:5: portada (s1) + faro, volante, fusilera, parrillas, exploradoras (videos 4:5 con specs y música original sonilo_music job 80dde96e) + lámina contacto con lista de repuestos (s7). Script: piezas/carrusel_superduty/carrusel.py; composición en sandbox ~/car (comp.py, build.sh).
- 28-oct: Reel Ford Fiesta (estilo cine v2 + música de Samer; luces policiales, bombillos LED, panorámica) programado sáb 31-oct 10:00, Metricool id 409428250. Lección: la marca (logo + ALEXMAR + teléfono) debe ir GRANDE todo el video; Samer rechazó el estilo glitch/underground y las frases genéricas.
