"""Carrusel 'Todo para tu Super Duty' (1080x1350).
Uso:
  python carrusel.py <dir_fuentes_logo> overlay <slide> <salida.png>   -> capa PNG para un video
  python carrusel.py <dir_fuentes_logo> cover <img_estudio> <salida.jpg>
  python carrusel.py <dir_fuentes_logo> final <img_fondo> <salida.jpg>
Solo especificaciones confirmadas por Samer o visibles en las fotos."""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
R, MODE = sys.argv[1], sys.argv[2]
ANTON = f"{R}/Anton.ttf"; M9 = f"{R}/Mont900.ttf"; M7 = f"{R}/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
W, H = 1080, 1350
LOGO = Image.open(f"{R}/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())

SLIDES = {
    "faro": ("FORD  SUPER  DUTY", ["FARO ORIGINAL"], ["Faro delantero original Ford", "El bombillo se cambia por detrás", "Luz blanca o amarilla, tú eliges"]),
    "volante": ("FORD  SUPER  DUTY", ["VOLANTE + TAPA"], ["Volante con mandos SETUP · INFO · RESET", "Tapa central con emblema Ford", "Textura original de fábrica"]),
    "fusilera": ("FORD  SUPER  DUTY", ["FUSILERA"], ["Caja de fusibles original FoMoCo", "Con sus fusibles y relés", "Lista para conectar"]),
    "parrillas": ("FORD  SUPER  DUTY  ·  TRITÓN", ["PARRILLAS"], ["Super Duty negra original", "Super Duty cromada", "Tritón cromada con panal"]),
    "exploradoras": ("FORD  SUPER  DUTY", ["EXPLORADORAS"], ["Par completo: izquierda y derecha", "Con su base de montaje", "Funcionan con bombillo"]),
}

def shadow(im, blur=12, op=200, off=(0, 5)):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad + off[0], pad + off[1]), blk)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)); base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad

def txt(cv, x, y, s, font, fill, sp=0, op=210, anchor="l"):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 40, int(font.size * 1.6)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 20
    for c in s: ld.text((xx, 10), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, 12, op)
    X = x - p if anchor == "l" else x - lay.width // 2
    cv.alpha_composite(lay, (int(X), int(y - p))); return y + lay.height - 2 * p

def grad(cv, y0, y1, a0, a1):
    g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
    for y in range(y0, y1):
        t = (y - y0) / max(1, y1 - y0 - 1); d.line((0, y, W, y), fill=(8, 8, 8, int(a0 + (a1 - a0) * t)))
    cv.alpha_composite(g)

def watermark(cv, op=11):
    t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, op))
    t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))

def logo(cv, w=118, x=None, y=30):
    lg = LOGO.resize((w, int(LOGO.height * w / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 10, 170)
    cv.alpha_composite(lg, ((W - w - 34 if x is None else x) - p, y - p))

def header(cv, kicker, lines, size=84, colors=None):
    y = txt(cv, 48, 38, kicker, ImageFont.truetype(M9, 24), LIGHT, sp=7, op=150) + 12
    ImageDraw.Draw(cv).line((48, y, 138, y), fill=TERRA + (255,), width=4); y += 20
    for i, l in enumerate(lines):
        c = (colors or [CREAM] * len(lines))[i]
        y = txt(cv, 46, y, l, ImageFont.truetype(ANTON, size), c, sp=2) + 6
    return y

def footer(cv, specs):
    y = H - 118 - 46 * len(specs) - 14
    f = ImageFont.truetype(M7, 30)
    for s in specs:
        ImageDraw.Draw(cv).rectangle((50, y + 13, 62, y + 25), fill=TERRA + (255,))
        txt(cv, 78, y, s, f, CREAM, op=230); y += 46
    dr = ImageDraw.Draw(cv); y = H - 104
    dr.line((48, y, W - 48, y), fill=(245, 240, 232, 80), width=2)
    dr.text((48, y + 14), "ALEXMAR", font=ImageFont.truetype(ANTON, 50), fill=TERRA)
    dr.text((50, y + 76), "AUTOPERIQUITOS Y ROTULADOS", font=ImageFont.truetype(M9, 14), fill=LIGHT)
    fp = ImageFont.truetype(ANTON, 46); s = "0416-676 83 93"; dr.text((W - 48 - dr.textlength(s, font=fp), y + 14), s, font=fp, fill=CREAM)
    fs = ImageFont.truetype(M7, 17); s = "Tovar · Pueblo Llano"; dr.text((W - 48 - dr.textlength(s, font=fs), y + 74), s, font=fs, fill=CREAM)

if MODE == "overlay":
    key, out = sys.argv[3], sys.argv[4]; k, lines, specs = SLIDES[key]
    cv = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    grad(cv, 0, 260, 200, 0); grad(cv, H - 330, H, 0, 235); watermark(cv); logo(cv)
    header(cv, k, lines); footer(cv, specs); cv.save(out)

elif MODE == "cover":
    src, out = sys.argv[3], sys.argv[4]
    cv = Image.open(src).convert("RGB").resize((W, H), Image.LANCZOS).convert("RGBA")
    grad(cv, 0, 360, 210, 0); grad(cv, H - 330, H, 0, 235); watermark(cv, 12); logo(cv, 130)
    header(cv, "REPUESTOS  FORD", ["TODO PARA TU", "SUPER DUTY"], size=96, colors=[CREAM, TERRA])
    footer(cv, ["Lo que necesites, lo manejamos", "Desliza y mira las piezas  →"])
    cv.convert("RGB").save(out, quality=95)

elif MODE == "final":
    src, out = sys.argv[3], sys.argv[4]
    bg = Image.open(src).convert("RGB").resize((W, H), Image.LANCZOS).filter(ImageFilter.GaussianBlur(18))
    cv = ImageEnhance.Brightness(bg).enhance(0.28).convert("RGBA"); watermark(cv, 10)
    lw = 250; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 14, 200)
    cv.alpha_composite(lg, ((W - lg.width) // 2, 50 - p)); y = 50 + int(LOGO.height * lw / LOGO.width) + 30
    y = txt(cv, W // 2, y, "LO  QUE  NECESITES", ImageFont.truetype(M9, 28), LIGHT, sp=8, anchor="c") + 10
    y = txt(cv, W // 2, y, "PARA TU SUPER DUTY", ImageFont.truetype(ANTON, 92), CREAM, sp=2, anchor="c") + 30
    items = ["Capós", "Parachoques", "Estribos", "Faros delanteros", "Faros traseros",
             "Cruces", "Espejos", "Exploradoras", "Cara de vaca", "Radiadores"]
    f = ImageFont.truetype(M7, 36); col = [150, 590]
    for i, it in enumerate(items):
        x = col[i % 2]; yy = y + (i // 2) * 60
        ImageDraw.Draw(cv).rectangle((x, yy + 15, x + 14, yy + 29), fill=TERRA + (255,))
        txt(cv, x + 30, yy, it, f, CREAM, op=230)
    y += 5 * 60 + 26
    y = txt(cv, W // 2, y, "¡Y mucho más! Si es de Super Duty, lo tenemos.", ImageFont.truetype(M9, 28), LIGHT, anchor="c") + 34
    ImageDraw.Draw(cv).line((W // 2 - 260, y, W // 2 + 260, y), fill=(245, 240, 232, 120), width=2); y += 26
    y = txt(cv, W // 2, y, "0416-676 83 93", ImageFont.truetype(ANTON, 96), TERRA, sp=3, anchor="c") + 18
    y = txt(cv, W // 2, y, "Tovar  ·  Pueblo Llano", ImageFont.truetype(M7, 36), CREAM, anchor="c") + 12
    y = txt(cv, W // 2, y, "Lunes a sábado 8 am a 6 pm  ·  Envíos por MRW y Zoom", ImageFont.truetype(M7, 26), CREAM, anchor="c")
    cv.convert("RGB").save(out, quality=95)
print("ok", MODE)
