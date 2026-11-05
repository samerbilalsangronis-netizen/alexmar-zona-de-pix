"""Posts 1080x1350 de garras (fotos de estudio IA) con diseño ALEXMAR: logo, título, teléfono, marca de agua.
Uso: python garras_post.py <dir_plantillas> <foto.png> <kicker> <titulo> <sub> <salida.jpg>"""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
P, SRC, KICK, BIG, SUB, OUT = sys.argv[1:7]
VF = f"{P}/fonts/Montserrat-VF.ttf"; ANTON = f"{P}/fonts/Anton.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); BLACK = (26, 26, 26)
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


ph = Image.open(SRC).convert("RGB"); ph = ImageEnhance.Brightness(ph).enhance(1.06)
s = max(W / ph.width, H / ph.height); ph = ph.resize((round(ph.width * s), round(ph.height * s)), Image.LANCZOS)
ph = ph.crop(((ph.width - W) // 2, (ph.height - H) // 2, (ph.width - W) // 2 + W, (ph.height - H) // 2 + H))
cv = ph.convert("RGBA"); g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
for y in range(0, 300): d.line((0, y, W, y), fill=(0, 0, 0, int(150 * (1 - y / 300) ** 1.4)))
for y in range(H - 420, H): d.line((0, y, W, y), fill=(0, 0, 0, int(225 * min(1, (y - (H - 420)) / 260))))
cv.alpha_composite(g)
# marca de agua repetida (anti-robo)
wm = Image.new("RGBA", (W * 2, H * 2), (0, 0, 0, 0)); dw = ImageDraw.Draw(wm); fw = ImageFont.truetype(ANTON, 110)
for r in range(12):
    for c in range(5): dw.text((c * 480 + (r % 2) * 240, r * 270), "ALEXMAR", font=fw, fill=(255, 255, 255, 26))
wm = wm.rotate(30, resample=Image.BICUBIC); cv.alpha_composite(wm.crop(((wm.width - W) // 2, (wm.height - H) // 2, (wm.width - W) // 2 + W, (wm.height - H) // 2 + H)))
# logo grande arriba a la izquierda
lw = 250; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lgs, p = shadow(lg, 14, 220)
cv.alpha_composite(lgs, (40 - p, 34 - p))
# textos abajo
y = H - 330
y = text(cv, W // 2, y, KICK, mont(28, "Medium"), CREAM, sp=14, op=200, blur=8) + 16
ImageDraw.Draw(cv).rectangle((W // 2 - 65, y, W // 2 + 65, y + 3), fill=TERRA + (255,)); y += 18
f = mont(70, "ExtraBold")
while ImageDraw.Draw(cv).textlength(BIG, font=f) + 7 * len(BIG) > W - 110: f = mont(f.size - 3, "ExtraBold")
y = text(cv, W // 2, y, BIG, f, CREAM, sp=7, op=235, blur=16) + 12
y = text(cv, W // 2, y, SUB, mont(32, "SemiBold"), LIGHT, sp=4, op=220, blur=8) + 26
text(cv, W // 2, y, "0416-676 83 93  ·  Tovar · Pueblo Llano", mont(28, "Bold"), CREAM, sp=2, op=230, blur=8)
cv.convert("RGB").save(OUT, quality=95); print(OUT)
