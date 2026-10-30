"""'Hasta que nademos entre los verdes' v2 — fondo cinematográfico IA (sede con billetes volando) + tipografía premium.
Uso: python verdes_pro.py <dir_fuentes_logo> <fondo_post 4:5> <fondo_historia 9:16> <dir_salida>"""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
R, BP, BH, O = sys.argv[1:5]
ANTON = f"{R}/Anton.ttf"; VF = f"{R}/Montserrat-VF.ttf"; SCRIPT = f"{R}/GreatVibes.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
LOGO = Image.open(f"{R}/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())

def mont(size, weight):
    f = ImageFont.truetype(VF, size); f.set_variation_by_name(weight); return f

def shadow(im, blur=14, op=200, off=(0, 5)):
    pad = blur * 3; b = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); k = Image.new("RGBA", im.size, (0, 0, 0, 255)); k.putalpha(a)
    s = Image.new("RGBA", b.size, (0, 0, 0, 0)); s.paste(k, (pad + off[0], pad + off[1]), k)
    s = s.filter(ImageFilter.GaussianBlur(blur)); b.alpha_composite(s); b.alpha_composite(im, (pad, pad)); return b, pad

def put(cv, x, y, s, font, fill, sp=0, anchor="c", op=200, blur=14):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 60, int(font.size * 1.8)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 30
    for c in s: ld.text((xx, 14), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, blur, op)
    X = x - lay.width // 2 if anchor == "c" else (x - p if anchor == "l" else x - lay.width + p)
    cv.alpha_composite(lay, (int(X), int(y - p))); return y + lay.height - 2 * p, lay.width - 2 * p

def grad(cv, y0, y1, a0, a1, col=(8, 8, 8)):
    W, H = cv.size; g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
    for y in range(y0, y1):
        t = (y - y0) / max(1, y1 - y0 - 1); d.line((0, y, W, y), fill=col + (int(a0 + (a1 - a0) * t),))
    cv.alpha_composite(g)

def build(src, W, H, out, story=False):
    k = 1.0 if not story else 1.12
    bg = Image.open(src).convert("RGB"); s = max(W / bg.width, H / bg.height)
    bg = bg.resize((round(bg.width * s), round(bg.height * s)), Image.LANCZOS)
    bg = bg.crop(((bg.width - W) // 2, (bg.height - H) // 2, (bg.width - W) // 2 + W, (bg.height - H) // 2 + H))
    cv = ImageEnhance.Contrast(bg).enhance(1.04).convert("RGBA")
    grad(cv, 0, int(H * 0.52), 175, 0); grad(cv, int(H * 0.70), H, 0, 230)
    # marca arriba: logo + ALEXMAR + sede
    top = 46 if not story else 120; lw = int(150 * k)
    lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 10, 200)
    cv.alpha_composite(lg, (48 - p, top - p)); lh = lg.height - 2 * p; dr = ImageDraw.Draw(cv)
    fa = ImageFont.truetype(ANTON, int(92 * k)); bb = dr.textbbox((0, 0), "ALEXMAR", font=fa); xt = 48 + lw + 26
    put(cv, xt, top + (lh - (bb[3] - bb[1])) // 2 - 22, "ALEXMAR", fa, TERRA, sp=3, anchor="l", op=220)
    put(cv, xt + 2, top + (lh + (bb[3] - bb[1])) // 2 - 4, "SEDE  PUEBLO  LLANO", mont(int(24 * k), "Bold"), CREAM, sp=4, anchor="l", op=230, blur=8)
    # frase
    y = top + lh + int(80 * k)
    y += int(40 * k); f1 = mont(int(74 * k), "Regular"); w1 = ImageDraw.Draw(cv).textlength("Hasta que nademos", font=f1)
    fq = ImageFont.truetype(ANTON, int(150 * k)); put(cv, int(W / 2 - w1 / 2 - 14 * k), y - int(30 * k), "“", fq, TERRA, anchor="r", op=190)
    y, _ = put(cv, W // 2, y, "Hasta que nademos", f1, CREAM, op=230)
    y += int(4 * k)
    y, w2 = put(cv, W // 2, y, "entre los verdes.", mont(int(86 * k), "ExtraBold"), CREAM, op=235)
    dr = ImageDraw.Draw(cv); y += int(26 * k)
    dr.rectangle((W // 2 - 60, y, W // 2 + 60, y + 5), fill=TERRA + (255,)); y += int(22 * k)
    put(cv, W // 2 + int(150 * k), y, "Alexmar", ImageFont.truetype(SCRIPT, int(110 * k)), CREAM, op=200, blur=10)
    # pie
    fp = ImageFont.truetype(ANTON, int(96 * k)); yb = H - int(222 * k) - (60 if story else 0)
    yb, _ = put(cv, W // 2, yb, "0416-676 83 93", fp, CREAM, sp=3, op=230)
    yb += int(10 * k)
    yb, _ = put(cv, W // 2, yb, "Pueblo Llano  ·  C-9, sector La Curva de Los Luises", mont(int(26 * k), "SemiBold"), CREAM, op=230, blur=8)
    yb += int(8 * k)
    put(cv, W // 2, yb, "@autoalexmar_car  ·  Lunes a sábado 8 am a 6 pm", mont(int(23 * k), "SemiBold"), LIGHT, op=230, blur=8)
    # marca de agua
    t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 14))
    t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))
    cv.convert("RGB").save(f"{O}/{out}", quality=95)

build(BP, 1080, 1350, "alexmar_verdes_v2_post.jpg")
build(BH, 1080, 1920, "alexmar_verdes_v2_historia.jpg", story=True)
print("ok")
