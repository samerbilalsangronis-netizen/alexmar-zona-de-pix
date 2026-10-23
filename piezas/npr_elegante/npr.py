"""Pieza elegante sobre foto real de Chevrolet NPR (balizas ámbar, rines cromados) frente a la sede.
Estilo sobrio: tipografía espaciada, líneas finas, sin bloques de color. Post 1080x1350 e historia 1080x1920."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance, ImageChops
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; M9 = f"{R}/fonts/Mont900.ttf"; M7 = f"{R}/fonts/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
BEACONS = [(458, 600), (893, 522), (1128, 595)]   # balizas reales en la foto original

def shadow(im, blur=12, op=200, off=(0, 5)):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad + off[0], pad + off[1]), blk)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)); base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad

def txt(cv, xy, s, font, fill, sp=0, anchor="l", sh=True, op=200):
    dr = ImageDraw.Draw(cv)
    w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 40, int(font.size * 1.6)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); x = 20
    for c in s: ld.text((x, 10), c, font=font, fill=fill + (255,)); x += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); p = 0
    if sh: lay, p = shadow(lay, 12, op)
    X = xy[0] - p if anchor == "l" else xy[0] - lay.width // 2
    cv.alpha_composite(lay, (int(X), int(xy[1] - p))); return xy[1] + lay.height - 2 * p

def photo():
    ph = Image.open(f"{D}/foto_original.jpg").convert("RGB")
    ph = ImageEnhance.Contrast(ph).enhance(1.1); ph = ImageEnhance.Color(ph).enhance(1.08)
    # calidez suave y brillo de las balizas ámbar reales
    r, g, b = ph.split(); ph = Image.merge("RGB", (r.point(lambda v: min(255, int(v * 1.03))), g, b.point(lambda v: int(v * 0.97))))
    gl = Image.new("L", ph.size, 0); d = ImageDraw.Draw(gl)
    k = ph.width / 1500
    for (x, y) in BEACONS: x, y = x * k, y * k; d.ellipse((x - 95 * k, y - 85 * k, x + 95 * k, y + 85 * k), fill=255)
    gl = gl.filter(ImageFilter.GaussianBlur(55)).point(lambda v: int(v * 0.55))
    amber = Image.new("RGB", ph.size, (255, 150, 30))
    return ImageChops.screen(ph, Image.composite(amber, Image.new("RGB", ph.size), gl))

def build(W, H, out, yf, story=False):
    ph = photo(); s = max(W / ph.width, H / ph.height)
    ph = ph.resize((round(ph.width * s), round(ph.height * s)), Image.LANCZOS)
    x0 = (ph.width - W) // 2; y0 = int((ph.height - H) * yf)
    cv = ph.crop((x0, y0, x0 + W, y0 + H)).convert("RGBA")
    # viñeta suave + degradados arriba-izquierda y abajo
    g = Image.new("L", (W, H), 0); d = ImageDraw.Draw(g)
    d.ellipse((-W * 0.5, -H * 0.3, W * 0.75, H * (0.33 if story else 0.36)), fill=135); g = g.filter(ImageFilter.GaussianBlur(150))
    dk = Image.new("RGBA", (W, H), (6, 10, 22, 255)); dk.putalpha(g); cv.alpha_composite(dk)
    gb = Image.new("RGBA", (W, H), (0, 0, 0, 0)); db = ImageDraw.Draw(gb); b0 = int(H * (0.68 if story else 0.72))
    for y in range(b0, H): db.line((0, y, W, y), fill=(10, 9, 9, int(235 * ((y - b0) / (H - b0)) ** 0.9)))
    cv.alpha_composite(gb)
    t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 14))
    t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))
    dr = ImageDraw.Draw(cv)
    # bloque superior: kicker espaciado, línea fina, titular
    x = 60; y = 120 if story else 58
    y = txt(cv, (x, y), "CHEVROLET NPR", ImageFont.truetype(M9, 26), LIGHT, sp=10, op=170) + 20
    dr.line((x, y, x + 90, y), fill=TERRA + (255,), width=3); y += 26
    y = txt(cv, (x, y), "ELEGANCIA", ImageFont.truetype(ANTON, 132 if story else 116), CREAM, sp=4) + 10
    txt(cv, (x + 2, y), "que se nota en cada viaje", ImageFont.truetype(M7, 36 if story else 32), CREAM, op=220)
    # logo discreto arriba a la derecha
    lw = 180 if story else 160; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS)
    lg, p = shadow(lg, 10, 170); cv.alpha_composite(lg, (W - lw - 44 - p, (110 if story else 44) - p))
    # firma inferior
    y = H - (395 if story else 268)
    y = txt(cv, (W // 2, y), "AUTOPERIQUITOS  Y  ROTULADOS", ImageFont.truetype(M9, 26), LIGHT, sp=8, anchor="c", op=160) + 10
    y = txt(cv, (W // 2, y), "ALEXMAR", ImageFont.truetype(ANTON, 140 if story else 100), TERRA, sp=14, anchor="c") + 18
    dr.line((W // 2 - 220, y, W // 2 + 220, y), fill=(245, 240, 232, 150), width=2); y += 16
    y = txt(cv, (W // 2, y), "0416-676 83 93", ImageFont.truetype(ANTON, 58 if story else 46), CREAM, sp=3, anchor="c") + 12
    txt(cv, (W // 2, y), "Tovar  ·  Pueblo Llano  ·  Lunes a sábado 8 am a 6 pm", ImageFont.truetype(M7, 26 if story else 23), CREAM, anchor="c", sh=False)
    if story: txt(cv, (W // 2, H - 80), "@autoalexmar_car", ImageFont.truetype(M7, 30), LIGHT, anchor="c", sh=False)
    cv.convert("RGB").save(f"{D}/{out}", quality=95)

build(1080, 1350, "alexmar_npr_elegante_post.jpg", yf=0.35)
build(1080, 1920, "alexmar_npr_elegante_historia.jpg", yf=0.5, story=True)
print("ok")
