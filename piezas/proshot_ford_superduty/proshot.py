"""/proshot Ford Super Duty: diseño ALEXMAR sobre foto de estudio (Higgsfield gpt_image_2_5).
Uso: python proshot.py <dir_con_fuentes_y_logo> <imagen_estudio> <salida> <variante a|b>"""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
R, SRC, OUT, V = sys.argv[1:5]
ANTON = f"{R}/Anton.ttf"; M9 = f"{R}/Mont900.ttf"; M7 = f"{R}/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); INK = (26, 26, 26)
W, H = 1080, 1350
LOGO = Image.open(f"{R}/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
TXT = {
    "a": ("FORD  SUPER  DUTY", "FRENTE CROMADO", "PARRILLA  ·  FAROS  ·  COWL"),
    "b": ("FORD  SUPER  DUTY", "TODO PARA TU FORD", "FAROS  ·  PARRILLAS  ·  EMBLEMAS  ·  VOLANTES"),
}[V]

def shadow(im, blur=12, op=200, off=(0, 5)):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad + off[0], pad + off[1]), blk)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)); base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad

def txt(cv, cx, y, s, font, fill, sp=0, sh=True, op=200):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 40, int(font.size * 1.6)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); x = 20
    for c in s: ld.text((x, 10), c, font=font, fill=fill + (255,)); x += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); p = 0
    if sh: lay, p = shadow(lay, 12, op)
    cv.alpha_composite(lay, (int(cx - lay.width // 2), int(y - p))); return y + lay.height - 2 * p

cv = Image.open(SRC).convert("RGB").resize((W, H), Image.LANCZOS).convert("RGBA")
# oscurecer un poco arriba y abajo para leer el texto
g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
for y in range(0, 300): d.line((0, y, W, y), fill=(8, 8, 8, int(150 * (1 - y / 300))))
b0 = H - 300
for y in range(b0, H): d.line((0, y, W, y), fill=(10, 10, 10, int(235 * ((y - b0) / 300) ** 0.9)))
cv.alpha_composite(g)
# marca de agua
t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 12))
t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))
dr = ImageDraw.Draw(cv)
# cabecera
y = txt(cv, W // 2, 52, TXT[0], ImageFont.truetype(M9, 26), LIGHT, sp=9, op=150) + 16
dr.line((W // 2 - 50, y, W // 2 + 50, y), fill=TERRA + (255,), width=3); y += 22
txt(cv, W // 2, y, TXT[1], ImageFont.truetype(ANTON, 104 if V == "a" else 92), CREAM, sp=3)
# logo discreto
lw = 118; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 10, 170)
cv.alpha_composite(lg, (W - lw - 34 - p, 34 - p))
# especificaciones y firma
y = H - 262
y = txt(cv, W // 2, y, TXT[2], ImageFont.truetype(M9, 24 if V == "a" else 21), CREAM, sp=4, op=230) + 26
dr = ImageDraw.Draw(cv); dr.line((80, y, W - 80, y), fill=(245, 240, 232, 70), width=2); fb = y + 26
fl = ImageFont.truetype(ANTON, 64); dr.text((80, fb - 6), "ALEXMAR", font=fl, fill=TERRA)
dr.text((82, fb + 76), "AUTOPERIQUITOS Y ROTULADOS", font=ImageFont.truetype(M9, 17), fill=LIGHT)
fp = ImageFont.truetype(ANTON, 54); pw = dr.textlength("0416-676 83 93", font=fp); dr.text((W - 80 - pw, fb - 2), "0416-676 83 93", font=fp, fill=CREAM)
fs = ImageFont.truetype(M7, 19)
for i, s in enumerate(["Tovar · Pueblo Llano", "Lunes a sábado 8 am a 6 pm"]):
    sw = dr.textlength(s, font=fs); dr.text((W - 80 - sw, fb + 66 + i * 26), s, font=fs, fill=CREAM)
cv.convert("RGB").save(OUT, quality=95)
print("ok", OUT)
