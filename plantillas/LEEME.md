# Plantillas ALEXMAR (Python + Pillow)

- `make.py`: plantilla base. Funciones: `LOGO` (logo recortado con borde), `watermark(W,H)`, `text_c`, `fit_font`, `build(item,W,H)` (post 1080x1350 / estado 1080x1920 sobre la foto del producto).
  Paleta: OR #D97757, ORL #F0A57E, BK #1A1A1A, CH #2B2B2B, CR #F5F0E8. Fuentes: Anton (títulos), Montserrat 700/900.
  Rutas a ajustar al nuevo entorno: carpeta de fuentes `S`, carpeta de fotos `U`, `LOGO_SRC`, `OUT`.
- `cover.py`: portada y cierre de carrusel (`bg_fit`, `bands`).
- `reel.py`: gancho y cierre 9:16 para Reels; el video se arma con ffmpeg (xfade slideleft, zoompan suave) — ver comando en el traspaso.
- `exr.py` / `nixon.py`: post de "cliente" sobre foto vertical / foto horizontal (foto centrada + fondo difuminado de la misma foto).
- `assets/logo_alexmar_sticker.png`: logo sin fondo con borde crema (listo para pegar).
