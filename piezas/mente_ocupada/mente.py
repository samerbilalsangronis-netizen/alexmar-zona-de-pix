"""Pieza 'Mente ocupada, manos trabajando' sobre foto real (sin el señor de franela azul, editado con IA).
Uso: python mente.py <dir_fuentes_logo> <foto_editada> <dir_salida>  -> post 1080x1350 e historia 1080x1920"""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
R, SRC, O = sys.argv[1:4]
ANTON = f"{R}/Anton.ttf"; M9 = f"{R}/Mont900.ttf"; M7 = f"{R}/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
LOGO = Image.open(f"{R}/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())

def shadow(im, blur=12, op=210, off=(0, 5)):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad + off[0], pad + off[1]), blk)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)); base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad

def text(cv, x, y, s, font, fill, sp=0, op=220, anchor="l"):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 40, int(font.size * 1.6)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 20
    for c in s: ld.text((xx, 10), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, 12, op)
    X = x - p if anchor == "l" else x - lay.width // 2
    cv.alpha_composite(lay, (int(X), int(y - p))); return y + lay.height - 2 * p

def build(W, H, out, story=False):
    TOP, BOT = (250, 210) if story else (200, 150)
    ph = Image.open(SRC).convert("RGB")
    ph = ImageEnhance.Contrast(ph).enhance(1.08); ph = ImageEnhance.Color(ph).enhance(1.08)
    s = max(W / ph.width, H / ph.height); ph = ph.resize((round(ph.width * s), round(ph.height * s)), Image.LANCZOS)
    x0 = (ph.width - W) // 2; y0 = (ph.height - H) // 2
    cv = ph.crop((x0, y0, x0 + W, y0 + H)).convert("RGBA")
    # degradado arriba para la frase sobre el cielo
    g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g); g1 = int(H * 0.50)
    for y in range(TOP, g1): d.line((0, y, W, y), fill=(8, 8, 10, int(205 * (1 - (y - TOP) / (g1 - TOP)) ** 1.2)))
    cv.alpha_composite(g)
    # marca de agua
    t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 18))
    t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))
    dr = ImageDraw.Draw(cv)
    # barra superior con logo + ALEXMAR grandes
    dr.rectangle((0, 0, W, TOP), fill=(0, 0, 0, 255)); dr.rectangle((0, TOP - 6, W, TOP), fill=TERRA + (255,))
    lw = 190 if not story else 230; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS)
    lg, p = shadow(lg, 8, 200); cv.alpha_composite(lg, (40 - p, (TOP - 6 - (lg.height - 2 * p)) // 2 - p))
    fa = ImageFont.truetype(ANTON, 104 if not story else 118); bb = dr.textbbox((0, 0), "ALEXMAR", font=fa)
    x1 = 40 + lw + 30; dr.text((x1, (TOP - 6 - (bb[3] - bb[1])) // 2 - bb[1] - 12), "ALEXMAR", font=fa, fill=TERRA)
    dr.text((x1 + 4, TOP - 52), "AUTOPERIQUITOS Y ROTULADOS", font=ImageFont.truetype(M9, 21 if not story else 23), fill=LIGHT)
    # frase
    y = TOP + (50 if not story else 90)
    y = text(cv, 56, y, "MENTE OCUPADA,", ImageFont.truetype(ANTON, 118 if not story else 132), CREAM, sp=2) + 8
    y = text(cv, 56, y, "MANOS TRABAJANDO.", ImageFont.truetype(ANTON, 118 if not story else 132), TERRA, sp=2) + 22
    dr = ImageDraw.Draw(cv); dr.rectangle((60, y, 200, y + 7), fill=CREAM + (255,)); y += 30
    text(cv, 58, y, "En ALEXMAR no paramos: siempre hay un carro", ImageFont.truetype(M7, 34 if not story else 38), CREAM, op=240)
    text(cv, 58, y + (48 if not story else 54), "esperando quedar mejor.", ImageFont.truetype(M7, 34 if not story else 38), CREAM, op=240)
    # barra inferior con teléfono grande
    dr = ImageDraw.Draw(cv); dr.rectangle((0, H - BOT, W, H), fill=(0, 0, 0, 255)); dr.rectangle((0, H - BOT, W, H - BOT + 6), fill=TERRA + (255,))
    fp = ImageFont.truetype(ANTON, 84 if not story else 100); s_ = "0416-676 83 93"; bb = dr.textbbox((0, 0), s_, font=fp)
    dr.text(((W - (bb[2] - bb[0])) // 2 - bb[0], H - BOT + 22 - bb[1]), s_, font=fp, fill=CREAM)
    fl = ImageFont.truetype(M9, 26 if not story else 30); s_ = "TOVAR  ·  PUEBLO LLANO  ·  LUNES A SÁBADO 8 AM A 6 PM"
    dr.text(((W - dr.textlength(s_, font=fl)) // 2, H - (40 if not story else 70) - 18), s_, font=fl, fill=LIGHT)
    cv.convert("RGB").save(f"{O}/{out}", quality=95)

build(1080, 1350, "alexmar_mente_ocupada_post.jpg")
build(1080, 1920, "alexmar_mente_ocupada_historia.jpg", story=True)
print("ok")
