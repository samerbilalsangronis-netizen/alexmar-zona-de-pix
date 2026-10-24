"""Post elegante 1080x1350: pisos tipo bandeja Toyota Hilux Kavak 2005-2014 (recorte de foto real)."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; M9 = f"{R}/fonts/Mont900.ttf"; M7 = f"{R}/fonts/Mont700.ttf"
TERRA = (217, 119, 87); CREAM = (245, 240, 232); INK = (26, 26, 26); CHAR = (43, 43, 43)
W, H = 1080, 1350
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())

def spaced(dr, cx, y, t, f, fill, sp):
    w = sum(dr.textlength(c, font=f) for c in t) + sp * (len(t) - 1); x = cx - w / 2
    for c in t: dr.text((x, y), c, font=f, fill=fill); x += dr.textlength(c, font=f) + sp

def center(dr, y, t, f, fill):
    b = dr.textbbox((0, 0), t, font=f); dr.text(((W - (b[2] - b[0])) / 2 - b[0], y - b[1]), t, font=f, fill=fill); return y + b[3] - b[1]

# fondo crema con degradado suave y viñeta cálida
bg = Image.new("RGB", (W, H), CREAM); g = Image.new("L", (W, H), 0); d = ImageDraw.Draw(g)
d.ellipse((-W * 0.4, H * 0.18, W * 1.4, H * 1.15), fill=255); g = g.filter(ImageFilter.GaussianBlur(220))
warm = Image.new("RGB", (W, H), (232, 222, 208)); bg = Image.composite(bg, warm, g)
cv = bg.convert("RGBA"); dr = ImageDraw.Draw(cv)

# marca de agua muy sutil
t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(26, 26, 26, 9))
t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))

# cabecera
spaced(dr, W / 2, 70, "TOYOTA", ImageFont.truetype(M9, 30), TERRA, 16)
y = center(dr, 118, "HILUX KAVAK", ImageFont.truetype(ANTON, 128), INK) + 22
spaced(dr, W / 2, y, "2005  —  2014", ImageFont.truetype(M7, 32), CHAR, 6); y += 62
dr.line((W / 2 - 60, y, W / 2 + 60, y), fill=TERRA + (255,), width=3)

# pisos con sombra suave
mats = Image.open(f"{D}/pisos_recorte.png").convert("RGBA")
rgb = ImageEnhance.Contrast(mats.convert("RGB")).enhance(1.15); rgb = ImageEnhance.Brightness(rgb).enhance(1.12)
mats = Image.merge("RGBA", (*rgb.split(), mats.split()[3]))
mw = 740; mats = mats.resize((mw, int(mats.height * mw / mats.width)), Image.LANCZOS)
mx, my = (W - mw) // 2, 326
sh = Image.new("RGBA", mats.size, (0, 0, 0, 0)); sh.putalpha(mats.split()[3].point(lambda v: v * 0.45))
sh = sh.resize(mats.size); pad = Image.new("RGBA", (mats.width + 120, mats.height + 120), (0, 0, 0, 0))
pad.alpha_composite(sh, (60, 75)); pad = pad.filter(ImageFilter.GaussianBlur(22))
cv.alpha_composite(pad, (mx - 60, my - 60)); cv.alpha_composite(mats, (mx, my))
dr = ImageDraw.Draw(cv)

# pie
y = my + mats.height + 34
spaced(dr, W / 2, y, "PISOS TIPO BANDEJA  ·  JUEGO COMPLETO", ImageFont.truetype(M9, 27), INK, 5); y += 46
spaced(dr, W / 2, y, "Hechos a la medida de tu camioneta", ImageFont.truetype(M7, 27), CHAR, 1)

# firma inferior
fb = H - 120; dr.line((80, fb - 26, W - 80, fb - 26), fill=(26, 26, 26, 60), width=2)
lw = 92; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); cv.alpha_composite(lg, (80, fb - 6))
dr.text((80 + lw + 22, fb + 2), "ALEXMAR", font=ImageFont.truetype(ANTON, 58), fill=TERRA)
dr.text((80 + lw + 24, fb + 70), "AUTOPERIQUITOS Y ROTULADOS", font=ImageFont.truetype(M9, 16), fill=CHAR)
fp = ImageFont.truetype(ANTON, 50); pw = dr.textlength("0416-676 83 93", font=fp)
dr.text((W - 80 - pw, fb + 4), "0416-676 83 93", font=fp, fill=INK)
fl = ImageFont.truetype(M7, 19); s_ = "Tovar · Pueblo Llano · Envíos a todo el país"; sw = dr.textlength(s_, font=fl)
dr.text((W - 80 - sw, fb + 70), s_, font=fl, fill=CHAR)
cv.convert("RGB").save(f"{D}/alexmar_pisos_hilux_kavak.jpg", quality=95)
print("ok")
