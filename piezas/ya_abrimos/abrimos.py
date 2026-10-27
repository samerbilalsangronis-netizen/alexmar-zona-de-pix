"""Post 1080x1350 "¡Buenos días! Ya abrimos" sobre foto real de la tienda."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; M9 = f"{R}/fonts/Mont900.ttf"; M7 = f"{R}/fonts/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); BLACK = (26, 26, 26)
W, H = 1080, 1350
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
def shadow(im, blur=12, op=200):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad, pad + 5), blk); sh = sh.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad
def txt(cv, x, y, s, f, fill, sp=0, anchor="r"):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=f) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 40, int(f.size * 1.6)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 20
    for c in s: ld.text((xx, 10), c, font=f, fill=fill + (255,)); xx += ld.textlength(c, font=f) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, 12, 210)
    X = x - lay.width + p if anchor == "r" else (x - lay.width // 2 if anchor == "c" else x - p)
    cv.alpha_composite(lay, (int(X), int(y - p))); return y + lay.height - 2 * p
import sys
SRC = sys.argv[1] if len(sys.argv) > 1 else "foto_tienda.jpg"; OUT = sys.argv[2] if len(sys.argv) > 2 else "alexmar_ya_abrimos.jpg"
ph = Image.open(f"{D}/{SRC}").convert("RGB")
if False:   # (desactivado) tapar la pantalla de la laptop
    k = ph.width / 1500; box = tuple(int(v * k) for v in (960, 1010, 1500, 1345))
    reg = ph.crop(box).filter(ImageFilter.GaussianBlur(40)); reg = ImageEnhance.Brightness(reg).enhance(0.55); ph.paste(reg, box)
ph = ImageEnhance.Contrast(ph).enhance(1.08); ph = ImageEnhance.Color(ph).enhance(1.12)
s = max(W / ph.width, H / ph.height); ph = ph.resize((round(ph.width * s), round(ph.height * s)), Image.LANCZOS)
y0 = 0; cv = ph.crop((0, y0, W, y0 + H)).convert("RGBA")
# oscurecer arriba a la derecha (cielo) y abajo
g = Image.new("L", (W, H), 0); d = ImageDraw.Draw(g); d.ellipse((W * 0.25, -H * 0.3, W * 1.5, H * 0.3), fill=150); g = g.filter(ImageFilter.GaussianBlur(150))
dk = Image.new("RGBA", (W, H), (8, 12, 24, 255)); dk.putalpha(g); cv.alpha_composite(dk)
gb = Image.new("RGBA", (W, H), (0, 0, 0, 0)); db = ImageDraw.Draw(gb); b0 = int(H * 0.78)
for yy in range(b0, H): db.line((0, yy, W, yy), fill=(12, 10, 10, int(200 * (yy - b0) / (H - b0))))
cv.alpha_composite(gb)
lw = 190; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 10, 180); cv.alpha_composite(lg, (40 - p, 40 - p))
x = W - 50; y = 46
y = txt(cv, x, y, "¡BUENOS DÍAS!", ImageFont.truetype(M9, 34), CREAM, sp=4) + 12
y = txt(cv, x, y, "YA ABRIMOS", ImageFont.truetype(ANTON, 118), TERRA, sp=2) + 12
txt(cv, x, y, "Sonido Pioneer, luces y accesorios para tu carro" if SRC == "foto_pioneer.jpg" else "Te esperamos con todo para tu carro", ImageFont.truetype(M7, 27), CREAM)
bh = 112; bar = Image.new("RGBA", (W, bh), TERRA + (255,)); bd = ImageDraw.Draw(bar)
fp = ImageFont.truetype(ANTON, 66); bd.text((46, (bh - fp.size) / 2 - 10), "0416-676 83 93", font=fp, fill=BLACK + (255,))
fl = ImageFont.truetype(M9, 26)
for i, s_ in enumerate(["TOVAR · PUEBLO LLANO", "LUNES A SÁBADO 8 AM - 6 PM"]):
    sw = bd.textlength(s_, font=fl); bd.text((W - 46 - sw, bh / 2 - 34 + i * 38), s_, font=fl, fill=BLACK + (255,))
cv.alpha_composite(bar, (0, H - bh))
cv.convert("RGB").save(f"{D}/{OUT}", quality=95); print("ok")
