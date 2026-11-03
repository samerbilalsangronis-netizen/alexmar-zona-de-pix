"""/proshot — Pisos 3D Toyota Hilux 2006-2017: recorte real sin IA + diseño ALEXMAR (post 1080x1350).
Uso: python pisos_fiesta_move.py <recorte.png> <dir_plantillas> <salida.jpg>"""
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


# fondo carbón con luz suave al centro
yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
d = np.sqrt(((xx - W / 2) / W) ** 2 + ((yy - H * 0.52) / H) ** 2)
base = np.array([30, 29, 28], np.float32)
bg = np.clip(base[None, None, :] * (1.45 - 1.1 * d[..., None]), 0, 255)
cv = Image.fromarray(bg.astype(np.uint8)).convert("RGBA")

# producto: recorte REAL (sin IA), color neutro, brillo naranja de borde y sombra
pr = Image.open(SRC).convert("RGBA")
rgb = np.asarray(pr.convert("RGB"), np.float32) / 255; al = pr.split()[3]
g = rgb.mean(2, keepdims=True); al = al.filter(ImageFilter.MinFilter(35)).filter(ImageFilter.MaxFilter(35))
rgb = g + (rgb - g) * 0.35          # quita el reflejo naranja del piso de baldosas
rgb = np.clip((rgb - 0.5) * 1.12 + 0.5 - 0.02, 0, 1)
pr = Image.fromarray((rgb * 255).astype(np.uint8)).convert("RGBA"); pr.putalpha(al)
TOP, BOT = 300, 1080
s = min((BOT - TOP) / pr.height, 960 / pr.width)
pr = pr.resize((round(pr.width * s), round(pr.height * s)), Image.LANCZOS)
px, py = (W - pr.width) // 2, TOP + (BOT - TOP - pr.height) // 2
A = pr.split()[3]
sh = Image.new("RGBA", pr.size, (0, 0, 0, 0)); sh.putalpha(A.filter(ImageFilter.GaussianBlur(18)).point(lambda v: v * 200 // 255))
cv.alpha_composite(sh, (px + 8, py + 18))
rim = Image.new("RGBA", pr.size, TERRA + (0,)); rim.putalpha(A.filter(ImageFilter.MaxFilter(9)).filter(ImageFilter.GaussianBlur(7)).point(lambda v: v * 150 // 255))
cv.alpha_composite(rim, (px, py))
cv.alpha_composite(pr, (px, py))

# arriba: logo + kicker + nombre
dr = ImageDraw.Draw(cv)
lg = LOGO.resize((int(LOGO.width * 118 / LOGO.height), 118), Image.LANCZOS); lgs, p = shadow(lg, 8, 180)
cv.alpha_composite(lgs, (W - lg.width - 40 - p, 34 - p))
put(cv, 52, 52, "TOYOTA  HILUX  ·  2006–2017", mont(27, "ExtraBold"), LIGHT, sp=4, op=0, anchor="l")
ImageDraw.Draw(cv).rectangle((52, 100, 152, 105), fill=TERRA + (255,))
y, _ = put(cv, 48, 118, "PISOS 3D", ImageFont.truetype(ANTON, 104), CREAM, sp=3, op=200, anchor="l")
put(cv, 48, y + 2, "PARA TOYOTA HILUX", ImageFont.truetype(ANTON, 60), TERRA, sp=3, op=200, anchor="l")

# especificaciones (solo lo confirmado / visible)
specs = ["Juego completo: 2 delanteros + trasero", "Modelos 2006 al 2017"]
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
print("ok", pr.size)
