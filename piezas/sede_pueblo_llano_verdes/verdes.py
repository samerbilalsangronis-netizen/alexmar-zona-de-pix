"""Pieza 'Hasta que nademos entre los verdes' — sede Pueblo Llano.
Estilo frase sobre papel (referencia de Samer) + foto real de la sede fundida abajo. Post 1080x1350 e historia 1080x1920."""
import os, random
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance, ImageChops
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
F = f"{R}/fonts"; ANTON = f"{F}/Anton.ttf"; M9 = f"{F}/Mont900.ttf"; VF = f"{F}/Montserrat-VF.ttf"; SCRIPT = f"{F}/GreatVibes.ttf"
TERRA = (217, 119, 87); INK = (26, 26, 26); CHAR = (43, 43, 43); PAPER = (245, 240, 232); CREAM = (245, 240, 232)
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())

def mont(size, weight):
    f = ImageFont.truetype(VF, size); f.set_variation_by_name(weight); return f

def paper(W, H):
    random.seed(7); base = Image.new("RGB", (W, H), PAPER)
    n = Image.effect_noise((W, H), 22).convert("L").filter(ImageFilter.GaussianBlur(0.6))
    n = ImageEnhance.Contrast(n).enhance(0.55)
    tex = Image.merge("RGB", (n, n, n)); base = ImageChops.blend(base, ImageChops.multiply(base, tex.point(lambda v: 200 + v // 4)), 0.55)
    g = Image.new("L", (W, H), 0); d = ImageDraw.Draw(g)   # luz suave arriba a la izquierda
    d.ellipse((-W * 0.6, -H * 0.5, W * 0.9, H * 0.55), fill=255); g = g.filter(ImageFilter.GaussianBlur(200))
    return Image.composite(base, ImageEnhance.Brightness(base).enhance(0.93), g).convert("RGBA")

def shadow(im, blur=10, op=190, off=(0, 4)):
    pad = blur * 3; b = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); k = Image.new("RGBA", im.size, (0, 0, 0, 255)); k.putalpha(a)
    s = Image.new("RGBA", b.size, (0, 0, 0, 0)); s.paste(k, (pad + off[0], pad + off[1]), k)
    s = s.filter(ImageFilter.GaussianBlur(blur)); b.alpha_composite(s); b.alpha_composite(im, (pad, pad)); return b, pad

def build(W, H, out, story=False):
    cv = paper(W, H); dr = ImageDraw.Draw(cv)
    top = 150 if not story else 300; size = 66 if not story else 74
    # kicker
    k = "SEDE  PUEBLO  LLANO"; fk = mont(26 if not story else 30, "Bold"); kw = dr.textlength(k, font=fk) + 6 * len(k)
    x = (W - kw) / 2
    for c in k: dr.text((x, top), c, font=fk, fill=TERRA); x += dr.textlength(c, font=fk) + 6
    # frase: “Hasta que nademos / entre los verdes.”
    y = top + (90 if not story else 110)
    l1, l2 = "Hasta que nademos", "entre los verdes."
    fr, fb = mont(size, "Regular"), mont(size, "ExtraBold")
    w1, w2 = dr.textlength(l1, font=fr), dr.textlength(l2, font=fb)
    x1 = (W - w1) / 2 + 30; x2 = (W - w2) / 2
    fq = ImageFont.truetype(ANTON, int(size * 1.9)); dr.text((x1 - 92, y - int(size * 0.55)), "“", font=fq, fill=TERRA)
    dr.text((x1, y), l1, font=fr, fill=INK); y += int(size * 1.22)
    dr.text((x2, y), l2, font=fb, fill=INK)
    # marca de agua tipo usuario, como en la referencia
    fw = mont(19 if not story else 22, "Medium"); s = "@ A U T O A L E X M A R _ C A R"
    dr.text(((W - dr.textlength(s, font=fw)) / 2, y + int(size * 1.25)), s, font=fw, fill=(150, 145, 138))
    # firma
    fs = ImageFont.truetype(SCRIPT, 112 if not story else 128); sig = "Alexmar"
    sw = dr.textlength(sig, font=fs); sy = y + (150 if not story else 190)
    dr.text((W - sw - (150 if not story else 170), sy), sig, font=fs, fill=INK)
    dr.line((W - sw - 140, sy + (122 if not story else 140), W - 130, sy + (114 if not story else 132)), fill=INK, width=2)
    # foto de la sede abajo, fundida con el papel
    ph = Image.open(f"{D}/foto_sede.jpg").convert("RGB")
    ph = ImageEnhance.Color(ph).enhance(1.12); ph = ImageEnhance.Contrast(ph).enhance(1.06)
    ph_top = int(H * (0.43 if not story else 0.47)); ph_h = H - ph_top
    sc = max(W / ph.width, ph_h / ph.height); ph = ph.resize((round(ph.width * sc), round(ph.height * sc)), Image.LANCZOS)
    cx = int(ph.width * 0.5 - W / 2); ph = ph.crop((max(0, cx), ph.height - ph_h, max(0, cx) + W, ph.height)).convert("RGBA")
    m = Image.new("L", (W, ph_h), 255); md = ImageDraw.Draw(m); fade = int(ph_h * 0.32)
    for yy in range(fade): md.line((0, yy, W, yy), fill=int(255 * (yy / fade) ** 1.6))
    ph.putalpha(m); cv.alpha_composite(ph, (0, ph_top))
    # pie: degradado oscuro + logo + teléfono
    g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); gd = ImageDraw.Draw(g); g0 = H - (300 if not story else 420)
    for yy in range(g0, H): gd.line((0, yy, W, yy), fill=(10, 10, 10, int(215 * ((yy - g0) / (H - g0)) ** 1.1)))
    cv.alpha_composite(g)
    lw = 170 if not story else 210; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg)
    ly = H - lg.height + 2 * p - (40 if not story else 120); cv.alpha_composite(lg, (44 - p, ly - p))
    dr = ImageDraw.Draw(cv); xt = 44 + lw + 26
    fa = ImageFont.truetype(ANTON, 70 if not story else 84); dr.text((xt, ly + 4), "ALEXMAR", font=fa, fill=TERRA)
    fp = ImageFont.truetype(ANTON, 50 if not story else 60); dr.text((xt, ly + (86 if not story else 104)), "0416-676 83 93", font=fp, fill=CREAM)
    fl = mont(20 if not story else 24, "SemiBold"); dr.text((xt, ly + (148 if not story else 178)), "Pueblo Llano · C-9, sector La Curva de Los Luises", font=fl, fill=CREAM)
    cv.convert("RGB").save(f"{D}/{out}", quality=95)

build(1080, 1350, "alexmar_verdes_pueblo_llano_post.jpg")
build(1080, 1920, "alexmar_verdes_pueblo_llano_historia.jpg", story=True)
print("ok")
