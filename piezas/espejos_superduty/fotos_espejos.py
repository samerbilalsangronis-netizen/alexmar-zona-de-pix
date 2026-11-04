"""Fotos post 1080x1350 de los espejos originales Super Duty (cromado y negro), con el mismo estilo del comercial:
foto real trabajada (luz clara, nitidez), logo ALEXMAR grande arriba, título limpio abajo, teléfono.
Uso: python fotos_espejos.py <dir_plantillas> <dir_salida>"""
import sys, os
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
P, O = sys.argv[1:3]
D = os.path.dirname(os.path.abspath(__file__)); RC = os.path.join(D, "..", "..", "reels")
VF = f"{P}/fonts/Montserrat-VF.ttf"; ANTON = f"{P}/fonts/Anton.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
LOGO = Image.open(f"{P}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
W, H = 1080, 1350


def mont(s, w):
    f = ImageFont.truetype(VF, s); f.set_variation_by_name(w); return f


def shadow(im, blur=12, op=200, off=(0, 4)):
    pad = blur * 3; b = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); k = Image.new("RGBA", im.size, (0, 0, 0, 255)); k.putalpha(a)
    s = Image.new("RGBA", b.size, (0, 0, 0, 0)); s.paste(k, (pad + off[0], pad + off[1]), k)
    s = s.filter(ImageFilter.GaussianBlur(blur)); b.alpha_composite(s); b.alpha_composite(im, (pad, pad)); return b, pad


def text(cv, cx, y, s, font, fill, sp=0, op=210, blur=12):
    d = ImageDraw.Draw(cv); w = sum(d.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 60, int(font.size * 1.8)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); x = 30
    for c in s: ld.text((x, 12), c, font=font, fill=fill + (255,)); x += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, blur, op)
    cv.alpha_composite(lay, (int(cx - lay.width // 2), int(y - p))); return y + lay.height - 2 * p


def grade(im):
    im = ImageEnhance.Brightness(im).enhance(1.10); im = ImageEnhance.Contrast(im).enhance(1.08)
    im = ImageEnhance.Color(im).enhance(1.08)
    a = np.asarray(im, np.float32) / 255; a = a ** 0.85                      # abre sombras
    a = a * np.array([1.02, 1.0, 0.98])
    im = Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8))
    return im.filter(ImageFilter.UnsharpMask(radius=2, percent=70, threshold=2))


def photo(src, mode, cx=0.5, dy=0):
    im = grade(Image.open(src).convert("RGB"))
    if mode == "crop":                      # espejo solo: recorte 4:5 sobre la foto, bajado dy px para que el logo no lo tape
        hh = H - dy // 2; s = hh / im.height; im = im.resize((round(im.width * s), hh), Image.LANCZOS)
        x0 = int(min(max(0, im.width * cx - W / 2), im.width - W)); ph = im.crop((x0, 0, x0 + W, hh))
        if not dy: return ph
        top = ph.crop((0, 0, W, 160)).resize((W, dy + 200), Image.BICUBIC).filter(ImageFilter.GaussianBlur(24))
        top = ImageEnhance.Brightness(top).enhance(0.7); cv = Image.new("RGB", (W, H)); cv.paste(top, (0, 0))
        m = Image.new("L", ph.size, 255); dm = ImageDraw.Draw(m)
        for i in range(110): dm.line((0, i, W, i), fill=int(255 * (i / 110) ** 1.3))
        cv.paste(ph, (0, dy), m); return cv
    # par: foto completa a lo ancho, fundida con su propio fondo extendido (sin marco)
    s = W / im.width; fg = im.resize((W, round(im.height * s)), Image.LANCZOS)
    bg = im.resize((round(im.width * H / im.height), H), Image.LANCZOS)
    bg = bg.crop(((bg.width - W) // 2, 0, (bg.width - W) // 2 + W, H)).filter(ImageFilter.GaussianBlur(28))
    bg = ImageEnhance.Brightness(bg).enhance(0.55)
    y0 = (H - fg.height) // 2 + 30; m = Image.new("L", fg.size, 255); dm = ImageDraw.Draw(m)
    for i in range(90):
        v = int(255 * (i / 90) ** 1.4); dm.line((0, i, W, i), fill=v); dm.line((0, fg.height - 1 - i, W, fg.height - 1 - i), fill=v)
    bg.paste(fg, (0, y0), m); return bg


def piece(src, mode, cx, kicker, big, sub, out, dy=0):
    cv = photo(src, mode, cx, dy).convert("RGBA"); g = ImageDraw.Draw(cv)
    sh = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(sh)
    for y in range(0, 330): d.line((0, y, W, y), fill=(0, 0, 0, int(120 * (1 - y / 330) ** 1.5)))
    for y in range(H - 360, H): d.line((0, y, W, y), fill=(0, 0, 0, int(215 * min(1, (y - (H - 360)) / 220))))
    cv.alpha_composite(sh)
    lw = 330; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lgs, p = shadow(lg, 16, 220)
    cv.alpha_composite(lgs, ((W - lg.width) // 2 - p, 40 - p))
    y = H - 300
    y = text(cv, W // 2, y, kicker, mont(28, "Medium"), CREAM, sp=14, op=200, blur=8) + 16
    ImageDraw.Draw(cv).rectangle((W // 2 - 65, y, W // 2 + 65, y + 3), fill=TERRA + (255,)); y += 18
    y = text(cv, W // 2, y, big, mont(66, "ExtraBold"), CREAM, sp=7, op=230, blur=16) + 14
    y = text(cv, W // 2, y, sub, mont(34, "SemiBold"), LIGHT, sp=6, op=220, blur=8) + 20
    text(cv, W // 2, y, "0416-676 83 93  ·  Tovar · Pueblo Llano", mont(28, "Bold"), CREAM, sp=2, op=230, blur=8)
    wm = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(wm).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 12))
    wm = wm.rotate(55, expand=True, resample=Image.BICUBIC); cv.alpha_composite(wm, ((W - wm.width) // 2, (H - wm.height) // 2))
    cv.convert("RGB").save(f"{O}/{out}", quality=95); print(out)


CR = f"{RC}/espejos_superduty/clips"; NG = f"{RC}/espejos_superduty_negro/clips"
K = "FORD  SUPER  DUTY"
piece(f"{CR}/f6.jpg", "par", 0.5, K, "ESPEJOS ORIGINALES", "Cromados con luz · Juego completo", "cromado_par.jpg")
piece(f"{CR}/f2.jpg", "crop", 0.36, K, "CROMADO CON LUZ", "Espejos originales", "cromado_lado.jpg", dy=200)
piece(f"{CR}/f3.jpg", "crop", 0.70, K, "ESPEJO ORIGINAL", "Cromado con luz", "cromado_frente.jpg", dy=190)
piece(f"{NG}/f3.jpg", "par", 0.5, K, "ESPEJOS ORIGINALES", "Negros con luz · Juego completo", "negro_par.jpg")
piece(f"{NG}/f1.jpg", "crop", 0.68, K, "NEGRO CON LUZ", "Espejos originales", "negro_lado.jpg", dy=200)
piece(f"{NG}/f4.jpg", "crop", 0.40, K, "ESPEJO ORIGINAL", "Negro con luz", "negro_frente.jpg", dy=200)
