"""'ESTAMOS ABIERTOS' — foto de la tienda con el Ford Cargo (editada en Higgsfield: sin el muchacho sentado, luz cálida).
Post 1080x1350. Uso: python estamos_abiertos.py <foto_ia_4x5.png> <dir_plantillas> <salida.jpg>"""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter
SRC, P, OUT = sys.argv[1:4]
ANTON = f"{P}/fonts/Anton.ttf"; VF = f"{P}/fonts/Montserrat-VF.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); BLACK = (26, 26, 26)
LOGO = Image.open(f"{P}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
W, H = 1080, 1350


def mont(size, weight):
    f = ImageFont.truetype(VF, size); f.set_variation_by_name(weight); return f


def shadow(im, blur=14, op=200, off=(0, 5)):
    pad = blur * 3; b = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); k = Image.new("RGBA", im.size, (0, 0, 0, 255)); k.putalpha(a)
    s = Image.new("RGBA", b.size, (0, 0, 0, 0)); s.paste(k, (pad + off[0], pad + off[1]), k)
    s = s.filter(ImageFilter.GaussianBlur(blur)); b.alpha_composite(s); b.alpha_composite(im, (pad, pad)); return b, pad


def put(cv, x, y, s, font, fill, sp=0, op=200, blur=14, anchor="r"):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 60, int(font.size * 1.8)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 30
    for c in s: ld.text((xx, 14), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, blur, op)
    X = {"c": x - lay.width // 2, "l": x - p, "r": x - lay.width + p}[anchor]
    cv.alpha_composite(lay, (int(X), int(y - p))); return y + lay.height - 2 * p


def grad(cv, y0, y1, a0, a1, col=(10, 10, 10)):
    g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
    for y in range(y0, y1):
        t = (y - y0) / max(1, y1 - y0 - 1); d.line((0, y, W, y), fill=col + (int(a0 + (a1 - a0) * t),))
    cv.alpha_composite(g)


ph = Image.open(SRC).convert("RGB").resize((W, H), Image.LANCZOS)
# placa difuminada (la IA alteró las letras)
box = (536, 518, 612, 560); pl = ph.crop(box).filter(ImageFilter.GaussianBlur(9)); ph.paste(pl, box)
cv = ph.convert("RGBA")

# barra superior con la marca grande
BAR = 190
grad(cv, BAR, BAR + 120, 150, 0)
ImageDraw.Draw(cv).rectangle((0, 0, W, BAR), fill=BLACK + (236,)); ImageDraw.Draw(cv).rectangle((0, BAR - 5, W, BAR), fill=TERRA + (255,))
lh = 150; lg = LOGO.resize((int(LOGO.width * lh / LOGO.height), lh), Image.LANCZOS)
fa = ImageFont.truetype(ANTON, 112); tw = ImageDraw.Draw(cv).textlength("ALEXMAR", font=fa) + 6 * 6
bx = (W - (lg.width + 28 + tw)) // 2; lgs, p = shadow(lg, 8, 160); cv.alpha_composite(lgs, (int(bx) - p, (BAR - 5 - lh) // 2 - p))
xt = int(bx + lg.width + 28)
put(cv, xt, 22, "ALEXMAR", fa, TERRA, sp=6, op=0, anchor="l")
put(cv, xt + 4, 140, "AUTOPERIQUITOS Y ROTULADOS", mont(23, "Bold"), CREAM, sp=3, op=0, anchor="l")

# titular sobre el piso (zona derecha, sin tapar el camión)
grad(cv, 760, H - 150, 0, 200)
xr = W - 46
y = put(cv, xr, 800, "TOVAR  ·  PUEBLO LLANO", mont(28, "ExtraBold"), LIGHT, sp=6, op=230, blur=10)
ImageDraw.Draw(cv).rectangle((xr - 110, y + 14, xr, y + 19), fill=TERRA + (255,))
y = put(cv, xr, y + 34, "ESTAMOS", ImageFont.truetype(ANTON, 150), CREAM, sp=4, op=235, blur=18)
y = put(cv, xr, y + 6, "ABIERTOS", ImageFont.truetype(ANTON, 150), TERRA, sp=4, op=235, blur=18)
put(cv, xr, y + 18, "Lunes a sábado · 8 am a 6 pm", mont(32, "SemiBold"), CREAM, op=235, blur=10)

# barra inferior: teléfono grande
b0 = H - 132
ImageDraw.Draw(cv).rectangle((0, b0, W, H), fill=BLACK + (240,)); ImageDraw.Draw(cv).rectangle((0, b0, W, b0 + 5), fill=TERRA + (255,))
put(cv, W // 2, b0 + 18, "0416-676 83 93", ImageFont.truetype(ANTON, 76), CREAM, sp=3, op=0, anchor="c")
put(cv, W // 2, b0 + 100, "Tovar · Pueblo Llano · @autoalexmar_car", mont(22, "SemiBold"), LIGHT, sp=1, op=0, anchor="c")

# marca de agua
wm = Image.new("RGBA", (1500, 420), (0, 0, 0, 0))
ImageDraw.Draw(wm).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 14))
wm = wm.rotate(55, expand=True, resample=Image.BICUBIC); cv.alpha_composite(wm, ((W - wm.width) // 2, (H - wm.height) // 2))
cv.convert("RGB").save(OUT, quality=94)
print("ok")
