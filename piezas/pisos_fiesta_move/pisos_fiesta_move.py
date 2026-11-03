"""/proshot — Pisos Ford Fiesta Move: foto de estudio IA + diseño ALEXMAR (post 1080x1350).
Uso: python pisos_fortuner.py <foto_ia.png> <dir_plantillas> <salida.jpg>"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
SRC, P, OUT = sys.argv[1:4]
ANTON = f"{P}/fonts/Anton.ttf"; VF = f"{P}/fonts/Montserrat-VF.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); BLACK = (26, 26, 26)
LOGO = Image.open(f"{P}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
W, H = 1080, 1350


def mont(size, weight):
    f = ImageFont.truetype(VF, size); f.set_variation_by_name(weight); return f


def shadow(im, blur=12, op=200, off=(0, 4)):
    pad = blur * 3; b = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); k = Image.new("RGBA", im.size, (0, 0, 0, 255)); k.putalpha(a)
    s = Image.new("RGBA", b.size, (0, 0, 0, 0)); s.paste(k, (pad + off[0], pad + off[1]), k)
    s = s.filter(ImageFilter.GaussianBlur(blur)); b.alpha_composite(s); b.alpha_composite(im, (pad, pad)); return b, pad


def put(cv, x, y, s, font, fill, sp=0, op=200, blur=12, anchor="c"):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 60, int(font.size * 1.8)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 30
    for c in s: ld.text((xx, 14), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, blur, op)
    X = x - lay.width // 2 if anchor == "c" else x - p
    cv.alpha_composite(lay, (int(X), int(y - p))); return y + lay.height - 2 * p, lay.width - 2 * p


# fondo: tono del estudio de la foto IA
ia = Image.open(SRC).convert("RGB")
a = np.asarray(ia, np.float32)
corner = np.concatenate([a[:60, :60].reshape(-1, 3), a[:60, -60:].reshape(-1, 3), a[-60:, :60].reshape(-1, 3), a[-60:, -60:].reshape(-1, 3)]).mean(0)
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
d = np.sqrt(((xx - W / 2) / W) ** 2 + ((yy - H * 0.52) / H) ** 2)
bg = np.clip(corner[None, None, :] * (1.35 - 0.9 * d[..., None]), 0, 255)
cv = Image.fromarray(bg.astype(np.uint8)).convert("RGBA")

# producto: recorte de los pisos con bordes difuminados hacia el fondo
lum = a.mean(2); m = lum > corner.mean() + 18
ys, xs = np.nonzero(m[40:-40, 40:-40]); ys += 40; xs += 40
x0, x1 = np.percentile(xs, [0.3, 99.7]).astype(int); y0, y1 = np.percentile(ys, [0.3, 99.7]).astype(int)
pad = 40; crop = ia.crop((max(0, x0 - pad), max(0, y0 - pad), min(ia.width, x1 + pad), min(ia.height, y1 + pad)))
TOP, BOT = 300, 1080                                     # zona del producto
s = min((BOT - TOP) / crop.height, 960 / crop.width)
crop = crop.resize((round(crop.width * s), round(crop.height * s)), Image.LANCZOS).convert("RGBA")
fm = Image.new("L", crop.size, 0); ImageDraw.Draw(fm).rectangle((26, 26, crop.width - 26, crop.height - 26), fill=255)
crop.putalpha(fm.filter(ImageFilter.GaussianBlur(20)))
cv.alpha_composite(crop, ((W - crop.width) // 2, TOP + (BOT - TOP - crop.height) // 2))

# arriba: logo + kicker + nombre
dr = ImageDraw.Draw(cv)
lg = LOGO.resize((int(LOGO.width * 118 / LOGO.height), 118), Image.LANCZOS); lgs, p = shadow(lg, 8, 180)
cv.alpha_composite(lgs, (W - lg.width - 40 - p, 34 - p))
put(cv, 52, 52, "FORD  FIESTA  MOVE", mont(27, "ExtraBold"), LIGHT, sp=4, op=0, anchor="l")
ImageDraw.Draw(cv).rectangle((52, 100, 152, 105), fill=TERRA + (255,))
y, _ = put(cv, 48, 118, "PISOS", ImageFont.truetype(ANTON, 104), CREAM, sp=3, op=200, anchor="l")
put(cv, 48, y + 2, "PARA FIESTA MOVE", ImageFont.truetype(ANTON, 60), TERRA, sp=3, op=200, anchor="l")

# especificaciones (solo lo confirmado / visible)
specs = ["Juego completo: 2 delanteros + trasero", "Bordes altos que protegen la alfombra"]
yb = 1092; f = mont(28, "SemiBold")
for i, t in enumerate(specs):
    tw = ImageDraw.Draw(cv).textlength(t, font=f); x = (W - tw - 40) // 2; yy_ = yb + i * 56
    ImageDraw.Draw(cv).rounded_rectangle((x, yy_, x + tw + 40, yy_ + 46), radius=23, fill=(30, 30, 30, 230), outline=TERRA + (255,), width=2)
    ImageDraw.Draw(cv).text((x + 20, yy_ + 7), t, font=f, fill=CREAM)

# barra inferior
b0 = H - 128
ImageDraw.Draw(cv).rectangle((0, b0, W, H), fill=BLACK + (245,)); ImageDraw.Draw(cv).rectangle((0, b0, W, b0 + 5), fill=TERRA + (255,))
put(cv, 46, b0 + 20, "0416-676 83 93", ImageFont.truetype(ANTON, 72), CREAM, sp=2, op=0, anchor="l")
fr = mont(24, "SemiBold"); dr = ImageDraw.Draw(cv)
for i, t in enumerate(["ALEXMAR  ·  Tovar · Pueblo Llano", "Lunes a sábado 8 am a 6 pm"]):
    tw = dr.textlength(t, font=fr); dr.text((W - 46 - tw, b0 + 30 + i * 38), t, font=fr, fill=LIGHT if i == 0 else CREAM)

# marca de agua
wm = Image.new("RGBA", (1500, 420), (0, 0, 0, 0))
ImageDraw.Draw(wm).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 10))
wm = wm.rotate(55, expand=True, resample=Image.BICUBIC); cv.alpha_composite(wm, ((W - wm.width) // 2, (H - wm.height) // 2))
cv.convert("RGB").save(OUT, quality=94)
print("ok", crop.size)
