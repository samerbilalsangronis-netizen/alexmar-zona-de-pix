"""Overlays 1080x1920 para el reel de parrillas Ford (Super Duty negra, cromada, Tritón). Args extra: y de cada parrilla.
Uso: python overlays.py <dir_fuentes_logo> <frame_final.png> <dir_salida>"""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
R, LAST, O = sys.argv[1:4]
ANTON = f"{R}/Anton.ttf"; M9 = f"{R}/Mont900.ttf"; M7 = f"{R}/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); INK = (26, 26, 26)
W, H = 1080, 1920
LOGO = Image.open(f"{R}/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())

def shadow(im, blur=12, op=200, off=(0, 5)):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad + off[0], pad + off[1]), blk)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)); base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad

def txt(cv, cx, y, s, font, fill, sp=0, op=210):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 40, int(font.size * 1.6)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); x = 20
    for c in s: ld.text((x, 10), c, font=font, fill=fill + (255,)); x += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, 12, op)
    cv.alpha_composite(lay, (int(cx - lay.width // 2), int(y - p))); return y + lay.height - 2 * p

def base():
    cv = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 12))
    t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))
    lw = 130; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 10, 170)
    cv.alpha_composite(lg, (W - lw - 34 - p, 40 - p))
    dr = ImageDraw.Draw(cv); f = ImageFont.truetype(ANTON, 50); s = "ALEXMAR  ·  0416-676 83 93"
    lay = Image.new("RGBA", (W, 120), (0, 0, 0, 0)); ImageDraw.Draw(lay).text((0, 0), s, font=f, fill=CREAM + (235,))
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, 10, 200); cv.alpha_composite(lay, ((W - lay.width) // 2, H - 250 - p))
    return cv

def label(name, kicker, title, y=250, size=118):
    cv = base(); yy = txt(cv, W // 2, y, kicker, ImageFont.truetype(M9, 30), LIGHT, sp=10, op=160) + 16
    ImageDraw.Draw(cv).line((W // 2 - 55, yy, W // 2 + 55, yy), fill=TERRA + (255,), width=4); yy += 26
    txt(cv, W // 2, yy, title, ImageFont.truetype(ANTON, size), CREAM, sp=3)
    cv.save(f"{O}/{name}.png")

def pill(cv, x, y, kick, name):
    f1 = ImageFont.truetype(M9, 20); f2 = ImageFont.truetype(ANTON, 40); dr = ImageDraw.Draw(cv)
    w = max(dr.textlength(kick, font=f1) + 4 * len(kick), dr.textlength(name, font=f2)) + 44
    lay = Image.new("RGBA", (int(w), 96), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay)
    ld.rounded_rectangle((0, 0, w - 1, 95), radius=14, fill=(20, 20, 20, 225), outline=TERRA + (255,), width=3)
    xx = 22
    for c in kick: ld.text((xx, 12), c, font=f1, fill=LIGHT + (255,)); xx += ld.textlength(c, font=f1) + 4
    ld.text((22, 36), name, font=f2, fill=CREAM + (255,))
    lay, p = shadow(lay, 10, 180); cv.alpha_composite(lay, (x - p, y - p))

base().save(f"{O}/ov_base.png")
label("ov_hook", "PARRILLAS  FORD", "ELIGE TU ESTILO", y=60, size=100)
label("ov_back", "EMBLEMA  FORD", "SE DESMONTA", y=60, size=100)
T = sys.argv[4:7] if len(sys.argv) > 6 else ["229", "687", "1170"]
cv = Image.new("RGBA", (W, H), (0, 0, 0, 0))
pill(cv, 56, int(T[0]) - 40, "SUPER  DUTY", "NEGRA ORIGINAL")
pill(cv, 56, int(T[1]) - 40, "SUPER  DUTY", "CROMADA")
pill(cv, 56, int(T[2]) - 40, "FORD", "TRITÓN")
cv.save(f"{O}/ov_tags.png")
label("ov_white", "PARRILLAS  FORD", "3 MODELOS DISPONIBLES", y=60, size=88)

# cierre
ph = Image.open(LAST).convert("RGB").resize((W, H), Image.LANCZOS)
ph = ImageEnhance.Brightness(ph.filter(ImageFilter.GaussianBlur(14))).enhance(0.35).convert("RGBA")
lw = 420; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 16, 200)
ph.alpha_composite(lg, ((W - lg.width) // 2, 330 - p))
y = 330 + int(LOGO.height * lw / LOGO.width) + 70
y = txt(ph, W // 2, y, "AUTOPERIQUITOS  Y  ROTULADOS", ImageFont.truetype(M9, 32), LIGHT, sp=8) + 14
y = txt(ph, W // 2, y, "ALEXMAR", ImageFont.truetype(ANTON, 190), TERRA, sp=10) + 30
ImageDraw.Draw(ph).line((W // 2 - 240, y, W // 2 + 240, y), fill=(245, 240, 232, 150), width=2); y += 34
y = txt(ph, W // 2, y, "0416-676 83 93", ImageFont.truetype(ANTON, 104), CREAM, sp=3) + 30
y = txt(ph, W // 2, y, "Tovar  ·  Pueblo Llano", ImageFont.truetype(M7, 42), CREAM) + 16
y = txt(ph, W // 2, y, "Lunes a sábado 8 am a 6 pm", ImageFont.truetype(M7, 36), CREAM) + 40
txt(ph, W // 2, y, "Envíos por MRW y Zoom", ImageFont.truetype(M9, 34), LIGHT, sp=2)
ph.convert("RGB").save(f"{O}/end.jpg", quality=95)
print("ok")
