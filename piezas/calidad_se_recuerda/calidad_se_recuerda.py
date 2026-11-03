"""'El precio se olvida, la calidad se recuerda' — dos fotos de la sede (editadas en Higgsfield) + frase.
Post 1080x1350. Uso: python calidad_se_recuerda.py <foto_tienda.png> <foto_cargo_1721.png> <dir_plantillas> <salida.jpg>"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter
A, B, P, OUT = sys.argv[1:5]
ANTON = f"{P}/fonts/Anton.ttf"; VF = f"{P}/fonts/Montserrat-VF.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); BLACK = (26, 26, 26)
LOGO = Image.open(f"{P}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
W, H = 1080, 1350


def mont(size, weight):
    f = ImageFont.truetype(VF, size); f.set_variation_by_name(weight); return f


def shadow(im, blur=14, op=200, off=(0, 5)):
    pad = blur * 3; b = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); k = Image.new("RGBA", im.size, (0, 0, 0, 255)); k.putalpha(a)
    s = Image.new("RGBA", b.size, (0, 0, 0, 0)); s.paste(k, (pad + off[0], pad + off[1]), k)
    s = s.filter(ImageFilter.GaussianBlur(blur)); b.alpha_composite(s); b.alpha_composite(im, (pad, pad)); return b, pad


def text_layer(s, font, fill, sp=0):
    d = ImageDraw.Draw(Image.new("L", (1, 1))); w = sum(d.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 60, int(font.size * 1.8)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 30
    for c in s: ld.text((xx, 14), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    return lay.crop(lay.getbbox())


def put(cv, x, y, lay, op=200, blur=14, anchor="c"):
    lay, p = shadow(lay, blur, op)
    X = {"c": x - lay.width // 2, "l": x - p, "r": x - lay.width + p}[anchor]
    cv.alpha_composite(lay, (int(X), int(y - p))); return y + lay.height - 2 * p


def cover(src, w, h, fy=0.5, fx=0.5, blur_box=None):
    im = Image.open(src).convert("RGB")
    if blur_box: im.paste(im.crop(blur_box).filter(ImageFilter.GaussianBlur(14)), blur_box[:2])
    s = max(w / im.width, h / im.height); im = im.resize((round(im.width * s), round(im.height * s)), Image.LANCZOS)
    x0 = int((im.width - w) * fx); y0 = int((im.height - h) * fy)
    return im.crop((x0, y0, x0 + w, y0 + h))


cv = Image.new("RGBA", (W, H), BLACK + (255,))
TOPH, BOTY = 560, 820
# arriba: la sede con el letrero ALEXMAR y el camión
top = cover(A, W, TOPH + 120, fy=0.32).convert("RGBA")
m = Image.new("L", top.size, 255); dm = ImageDraw.Draw(m)
for i in range(160): dm.line((0, top.height - 1 - i, W, top.height - 1 - i), fill=int(255 * (i / 160) ** 1.3))
top.putalpha(m); cv.alpha_composite(top, (0, 0))
# abajo: el Cargo 1721 (placa difuminada)
bot = cover(B, W, H - BOTY + 140, fy=0.55, fx=0.75, blur_box=(880, 1335, 975, 1435)).convert("RGBA")
m = Image.new("L", bot.size, 255); dm = ImageDraw.Draw(m)
for i in range(170): dm.line((0, i, W, i), fill=int(255 * (i / 170) ** 1.3))
bot.putalpha(m); cv.alpha_composite(bot, (0, BOTY - 140))

# banda oscura central para la frase
g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
for y in range(380, 1010):
    t = 1 - abs((y - 695) / 315); d.line((0, y, W, y), fill=(12, 12, 12, int(235 * min(1, t * 1.8))))
cv.alpha_composite(g)

# frase
y = 430
y = put(cv, W // 2, y, text_layer("El precio se", mont(70, "Light"), CREAM), op=220) + 14
# OLVIDA desgastada: letras con huecos, en gris
ol = text_layer("OLVIDA", ImageFont.truetype(ANTON, 172), (150, 150, 150), sp=8)
rng = np.random.default_rng(4); n = np.zeros((ol.height // 6 + 1, ol.width // 6 + 1), np.float32)
n = rng.random(n.shape).astype(np.float32)
noise = Image.fromarray((n * 255).astype(np.uint8)).resize(ol.size, Image.BICUBIC).filter(ImageFilter.GaussianBlur(3))
fine = Image.fromarray((rng.random((ol.height, ol.width)) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1))
na = (np.asarray(noise, np.float32) * 0.7 + np.asarray(fine, np.float32) * 0.3)
keep = (na < 150).astype(np.float32) * 0.85
al = np.asarray(ol.split()[3], np.float32) * keep
ol.putalpha(Image.fromarray(al.astype(np.uint8)))
y = put(cv, W // 2, y, ol, op=120, blur=10) + 18
y = put(cv, W // 2, y, text_layer("la calidad", mont(70, "Light"), CREAM), op=220) + 10
se = text_layer("se ", mont(70, "Light"), CREAM); rc = text_layer("RECUERDA", ImageFont.truetype(ANTON, 132), TERRA, sp=5)
tot = se.width + rc.width + 18; x0 = (W - tot) // 2
put(cv, x0, y + rc.height - se.height - 8, se, op=220, anchor="l")
put(cv, x0 + se.width + 18, y, rc, op=230, blur=16, anchor="l")

# marca: logo arriba a la izquierda
lh = 128; lg = LOGO.resize((int(LOGO.width * lh / LOGO.height), lh), Image.LANCZOS); lgs, p = shadow(lg, 10, 200)
cv.alpha_composite(lgs, (36 - p, 30 - p))
# barra inferior con teléfono
b0 = H - 128
ImageDraw.Draw(cv).rectangle((0, b0, W, H), fill=BLACK + (242,)); ImageDraw.Draw(cv).rectangle((0, b0, W, b0 + 5), fill=TERRA + (255,))
put(cv, 46, b0 + 22, text_layer("ALEXMAR", ImageFont.truetype(ANTON, 70), TERRA, sp=4), op=0, anchor="l")
fr = mont(22, "SemiBold"); dr = ImageDraw.Draw(cv)
for i, (t, c) in enumerate([("0416-676 83 93", CREAM), ("Tovar · Pueblo Llano · @autoalexmar_car", LIGHT)]):
    f = ImageFont.truetype(ANTON, 50) if i == 0 else fr
    tw = dr.textlength(t, font=f); dr.text((W - 46 - tw, b0 + (18 if i == 0 else 84)), t, font=f, fill=c)
# marca de agua
wm = Image.new("RGBA", (1500, 420), (0, 0, 0, 0))
ImageDraw.Draw(wm).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 12))
wm = wm.rotate(55, expand=True, resample=Image.BICUBIC); cv.alpha_composite(wm, ((W - wm.width) // 2, (H - wm.height) // 2))
cv.convert("RGB").save(OUT, quality=94)
print("ok")
