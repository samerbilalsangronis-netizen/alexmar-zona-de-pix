"""Pieza publicitaria sobre la foto real del taller (Tovar): post 1080x1350 y historia 1080x1920.
Texto sobre el piso de baldosas para no tapar los carros."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance, ImageChops
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; M9 = f"{R}/fonts/Mont900.ttf"; M7 = f"{R}/fonts/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); BLACK = (26, 26, 26)
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())

def grade(im):
    im = ImageEnhance.Contrast(im).enhance(1.12); im = ImageEnhance.Color(im).enhance(1.2)
    r, g, b = im.split(); r = r.point(lambda v: min(255, int(v * 1.04))); b = b.point(lambda v: int(v * 0.96))
    im = Image.merge("RGB", (r, g, b))
    # brillo de la luz roja real de la parrilla del Toyota
    gl = Image.new("L", im.size, 0); d = ImageDraw.Draw(gl); x, y = 400, 1082
    d.ellipse((x - 70, y - 30, x + 70, y + 30), fill=255); gl = gl.filter(ImageFilter.GaussianBlur(40))
    red = Image.new("RGB", im.size, (255, 40, 30))
    return ImageChops.screen(im, Image.composite(red, Image.new("RGB", im.size), gl.point(lambda v: v * 0.55)))

def shadow(im, blur=12, op=200):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad, pad + 5), blk); sh = sh.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad

def text_c(cv, y, txt, font, fill, sp=0, W=1080, sh=True):
    dr = ImageDraw.Draw(cv)
    w = sum(dr.textlength(c, font=font) for c in txt) + sp * (len(txt) - 1)
    lay = Image.new("RGBA", (int(w) + 20, font.size + 60), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); x = 10
    for c in txt: ld.text((x, 10), c, font=font, fill=fill + (255,)); x += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox())
    if sh: lay, p = shadow(lay, 10, 200)
    else: p = 0
    cv.alpha_composite(lay, (int((W - lay.width) / 2), int(y - p))); return y + lay.height - 2 * p

def fit(txt, path, size, maxw):
    dr = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    while ImageFont.truetype(path, size).getlength(txt) > maxw: size -= 2
    return ImageFont.truetype(path, size)

def build(W, H, out, crop_x=None, zoom=1.0, cx=0.5, yf=0.35):
    ph = grade(Image.open(f"{D}/foto_original.jpg").convert("RGB"))
    s = max(W / ph.width, H / ph.height) * zoom; ph = ph.resize((round(ph.width * s), round(ph.height * s)), Image.LANCZOS)
    x0 = int(min(max(ph.width * cx - W / 2, 0), ph.width - W)) if crop_x is None else crop_x
    y0 = int((ph.height - H) * yf)
    cv = ph.crop((x0, y0, x0 + W, y0 + H)).convert("RGBA")
    # degradados: arriba suave (logo) y abajo fuerte sobre el piso
    gr = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(gr)
    top = int(H * 0.16); bot0 = int(H * 0.52)
    for y in range(top): d.line((0, y, W, y), fill=(10, 10, 10, int(150 * (1 - y / top))))
    for y in range(bot0, H): d.line((0, y, W, y), fill=(14, 12, 11, int(235 * min(1, ((y - bot0) / (H * 0.22))) ** 1.1)))
    cv.alpha_composite(gr)
    # marca de agua
    t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 18))
    t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))
    # logo
    lw = 230 if H > 1500 else 200; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS)
    lg, p = shadow(lg, 12, 190); cv.alpha_composite(lg, (34 - p, (60 if H > 1500 else 34) - p))
    # bloque de texto sobre el piso
    y = int(H * (0.60 if H > 1500 else 0.585))
    dr = ImageDraw.Draw(cv)
    fk = ImageFont.truetype(M9, 30); y = text_c(cv, y, "AUTOPERIQUITOS Y ROTULADOS", fk, LIGHT, sp=7) + 14
    dr.rectangle(((W - 120) / 2, y, (W + 120) / 2, y + 6), fill=TERRA + (255,)); y += 26
    lines = ["TU CARRO EN LAS", "MEJORES MANOS"] if H > 1500 else ["TU CARRO EN LAS MEJORES MANOS"]
    for ln in lines:
        y = text_c(cv, y, ln, fit(ln, ANTON, 118, W - 100), CREAM) + 14
    y += 6
    y = text_c(cv, y, "ALEXMAR", ImageFont.truetype(ANTON, 196 if H > 1500 else 150), TERRA, sp=4) + 22
    y = text_c(cv, y, "ILUMINACIÓN · SONIDO · ACCESORIOS · ROTULADOS", fit("ILUMINACIÓN · SONIDO · ACCESORIOS · ROTULADOS", M7, 32, W - 110), CREAM, sh=False) + 10
    # barra inferior con teléfono
    bh = 130 if H > 1500 else 112; bar = Image.new("RGBA", (W, bh), TERRA + (255,)); bd = ImageDraw.Draw(bar)
    fp = ImageFont.truetype(ANTON, 76 if H > 1500 else 66); ph_t = "0416-676 83 93"
    fl = ImageFont.truetype(M9, 26)
    tw = bd.textlength(ph_t, font=fp); bd.text((48, (bh - fp.size) / 2 - 10), ph_t, font=fp, fill=BLACK + (255,))
    for i, s_ in enumerate(["TOVAR · PUEBLO LLANO", "LUNES A SÁBADO 8 AM - 6 PM"]):
        sw = bd.textlength(s_, font=fl); bd.text((W - 48 - sw, bh / 2 - 34 + i * 38), s_, font=fl, fill=BLACK + (255,))
    cv.alpha_composite(bar, (0, H - bh - (90 if H > 1500 else 0)))
    if H > 1500:  # historia: espacio seguro abajo + usuario
        f2 = ImageFont.truetype(M7, 30); text_c(cv, H - 72, "@autoalexmar_car", f2, LIGHT, sh=False)
    cv.convert("RGB").save(f"{D}/{out}", quality=95)

build(1080, 1350, "alexmar_taller_post.jpg", zoom=1.12, cx=0.45, yf=0.7)
build(1080, 1920, "alexmar_taller_historia.jpg", crop_x=60)
print("ok")
