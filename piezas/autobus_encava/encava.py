"""Pieza "Al mejor estilo ALEXMAR" sobre foto real de autobús Encava (frente a la sede).
Texto en el cielo (arriba-izquierda), barra con teléfono abajo. Post 1080x1350 e historia 1080x1920."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; M9 = f"{R}/fonts/Mont900.ttf"; M7 = f"{R}/fonts/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); BLACK = (26, 26, 26)
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())

def shadow(im, blur=12, op=200, off=(0, 6)):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad + off[0], pad + off[1]), blk)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)); base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad

def txt(cv, xy, s, font, fill, sp=0, anchor="l", sh=True):
    dr = ImageDraw.Draw(cv)
    w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 40, int(font.size * 1.6)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); x = 20
    for c in s: ld.text((x, 10), c, font=font, fill=fill + (255,)); x += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); p = 0
    if sh: lay, p = shadow(lay, 12, 210)
    X = xy[0] - p if anchor == "l" else xy[0] - lay.width // 2
    cv.alpha_composite(lay, (int(X), int(xy[1] - p))); return xy[1] + lay.height - 2 * p

def build(W, H, out, cx, yf, story=False):
    ph = Image.open(f"{D}/foto_original.jpg").convert("RGB")
    ph = ImageEnhance.Contrast(ph).enhance(1.08); ph = ImageEnhance.Color(ph).enhance(1.12)
    s = max(W / ph.width, H / ph.height); ph = ph.resize((round(ph.width * s), round(ph.height * s)), Image.LANCZOS)
    x0 = int(min(max(ph.width * cx - W / 2, 0), ph.width - W)); y0 = int((ph.height - H) * yf)
    cv = ph.crop((x0, y0, x0 + W, y0 + H)).convert("RGBA")
    # sombra suave desde la esquina superior izquierda (sobre el cielo) y degradado abajo
    g = Image.new("L", (W, H), 0); d = ImageDraw.Draw(g)
    d.ellipse((-W * 0.55, -H * 0.35, W * 0.85, H * (0.42 if story else 0.48)), fill=150)
    g = g.filter(ImageFilter.GaussianBlur(160))
    dark = Image.new("RGBA", (W, H), (8, 14, 30, 255)); dark.putalpha(g); cv.alpha_composite(dark)
    gb = Image.new("RGBA", (W, H), (0, 0, 0, 0)); db = ImageDraw.Draw(gb); b0 = int(H * (0.80 if story else 0.82))
    for y in range(b0, H): db.line((0, y, W, y), fill=(12, 10, 10, int(210 * (y - b0) / (H - b0))))
    cv.alpha_composite(gb)
    # marca de agua
    t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 16))
    t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))
    # logo
    lw = 230 if story else 210; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS)
    lg, p = shadow(lg, 12, 190); top = 90 if story else 44; cv.alpha_composite(lg, (W - lw - 40 - p, top - p))
    # titular en el cielo
    x = 56; y = top + (40 if story else 20)
    y = txt(cv, (x, y), "AUTOPERIQUITOS Y ROTULADOS", ImageFont.truetype(M9, 28), LIGHT, sp=6) + 18
    ImageDraw.Draw(cv).rectangle((x, y, x + 120, y + 7), fill=TERRA + (255,)); y += 30
    if story:
        y = txt(cv, (x, y), "AL MEJOR", ImageFont.truetype(ANTON, 120), CREAM) + 6
        y = txt(cv, (x, y), "ESTILO", ImageFont.truetype(ANTON, 120), CREAM) + 10
    else:
        y = txt(cv, (x, y), "AL MEJOR ESTILO", ImageFont.truetype(ANTON, 84), CREAM) + 8
    y = txt(cv, (x - 4, y), "ALEXMAR", ImageFont.truetype(ANTON, 200 if story else 150), TERRA, sp=3) + 16
    txt(cv, (x, y), "Rotulados · Iluminación · Accesorios", ImageFont.truetype(M7, 34 if story else 29), CREAM)
    # barra inferior
    bh = 128 if story else 112; bar = Image.new("RGBA", (W, bh), TERRA + (255,)); bd = ImageDraw.Draw(bar)
    fp = ImageFont.truetype(ANTON, 74 if story else 66); bd.text((46, (bh - fp.size) / 2 - 10), "0416-676 83 93", font=fp, fill=BLACK + (255,))
    fl = ImageFont.truetype(M9, 26)
    for i, s_ in enumerate(["TOVAR · PUEBLO LLANO", "LUNES A SÁBADO 8 AM - 6 PM"]):
        sw = bd.textlength(s_, font=fl); bd.text((W - 46 - sw, bh / 2 - 34 + i * 38), s_, font=fl, fill=BLACK + (255,))
    cv.alpha_composite(bar, (0, H - bh - (110 if story else 0)))
    if story: txt(cv, (W // 2, H - 84), "@autoalexmar_car", ImageFont.truetype(M7, 32), LIGHT, anchor="c", sh=False)
    cv.convert("RGB").save(f"{D}/{out}", quality=95)

build(1080, 1350, "alexmar_encava_post.jpg", cx=0.5, yf=0.2)
build(1080, 1920, "alexmar_encava_historia.jpg", cx=0.42, yf=0.5, story=True)
print("ok")
