"""Logo IDEAZA a color con silueta negra (profundidad), reacomodado a lo ancho de las dos puertas de la cava.
Ícono (martillo + casa + sierra) a la izquierda y 'Carpintería / IDEAZA' a la derecha, alineados abajo.
Uso: python aplicar_cava_color.py  (requiere capas_ideaza.npz de separar.py)"""
import numpy as np
from scipy import ndimage as nd
from PIL import Image, ImageFilter

BROWN = (160, 112, 62); GRAY = (166, 172, 177); YELLOW = (216, 228, 30); BLACK = (18, 18, 18)
L = np.load("capas_ideaza.npz")
house, hammer, emblem, emb_y, carp, idz = (L[k] for k in ("house", "hammer", "emblem", "emb_y", "carp", "idz"))
def clean(m, mn):
    lb, n = nd.label(m); sz = nd.sum(m, lb, range(1, n + 1)); k = np.zeros(n + 1, bool); k[1:] = sz >= mn; return k[lb]
carp = clean(carp, 300); idz = clean(idz, 300)
idz[:1300] = False; emblem = clean(emblem, 80); emb_y &= emblem
H, W = house.shape

# área disponible en la foto de la cava (entre 'IDEAZA' y la cerradura, entre bisagras)
AX0, AY0, AX1, AY1 = 300, 580, 1362, 1234
ICON_H = AY1 - AY0 - 30; GAP = 40; T = 7; SH = (8, 10)        # T: grosor de la silueta, SH: desplazamiento de la sombra


def rgba(layers, shape):
    out = np.zeros(shape + (4,), np.float32)
    for m, col in layers:
        out[m, :3] = np.array(col, np.float32) / 255; out[m, 3] = 1
    return out


def shift_scale(mask, s, dx, dy):
    """escala la máscara s veces alrededor de su centro y la desplaza."""
    ys, xs = np.nonzero(mask); cy, cx = ys.mean(), xs.mean()
    yy, xx = np.mgrid[0:H, 0:W]
    src_y = (yy - cy - dy) / s + cy; src_x = (xx - cx - dx) / s + cx
    return nd.map_coordinates(mask.astype(np.float32), [src_y, src_x], order=1) > 0.5


# 1) ícono: la sierra y herramientas bajan al centro de la casa (donde estaban los textos)
EMB = (1.0, 16, 100)
emb2 = shift_scale(emblem, *EMB)
ys_, xs_ = np.nonzero(emblem); cy0, cx0 = (ys_.min() + ys_.max()) / 2, (xs_.min() + xs_.max()) / 2
def same(mask):  # mismo centro de escala que el emblema completo
    yy, xx = np.mgrid[0:H, 0:W]; s_, dx, dy = EMB
    return nd.map_coordinates(mask.astype(np.float32), [(yy - cy0 - dy) / s_ + cy0, (xx - cx0 - dx) / s_ + cx0], order=1) > 0.5
emb2 = same(emblem); emb_y2 = same(emb_y) & emb2
icon = rgba([(house, GRAY), (hammer, BROWN), (emb2 & ~emb_y2, BROWN), (emb_y2, YELLOW)], (H, W))
ia = icon[..., 3] > 0; ys, xs = np.nonzero(ia); icon = icon[ys.min():ys.max() + 1, xs.min():xs.max() + 1]

# 2) bloque de texto: 'Carpintería' sobre 'IDEAZA', mismo ancho
def crop_rgba(m, col):
    ys, xs = np.nonzero(m); sub = m[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    return rgba([(sub, col)], sub.shape)

def to_img(a): return Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8), "RGBA")

icon_img = to_img(icon); s = ICON_H / icon_img.height
icon_img = icon_img.resize((round(icon_img.width * s), ICON_H), Image.LANCZOS)
TW = (AX1 - AX0) - icon_img.width - GAP - 10
c_img = to_img(crop_rgba(carp, BROWN)); i_img = to_img(crop_rgba(idz, BROWN))
c_img = c_img.resize((TW, round(c_img.height * TW / c_img.width)), Image.LANCZOS)
i_img = i_img.resize((TW, round(i_img.height * TW / i_img.width)), Image.LANCZOS)

# 3) composición en el área
area = Image.new("RGBA", (AX1 - AX0 + 40, AY1 - AY0 + 40), (0, 0, 0, 0))
ox, oy = 10, 10
groups = [(icon_img, (ox, oy))]
blk = c_img.height + 22 + i_img.height
ty = oy + int(ICON_H * 0.66) - blk // 2 + c_img.height + 22
groups += [(i_img, (ox + icon_img.width + GAP, ty)), (c_img, (ox + icon_img.width + GAP, ty - 22 - c_img.height))]

def silhouette(img):
    a = np.asarray(img.split()[3], np.float32) / 255 > 0.5
    a = np.pad(a, T + 12); d = nd.binary_dilation(a, structure=nd.generate_binary_structure(2, 1), iterations=T)
    sh = np.zeros_like(d); sh[SH[1]:, SH[0]:] = d[:-SH[1], :-SH[0]]
    sil = (d | sh).astype(np.uint8) * 255
    out = Image.new("RGBA", (sil.shape[1], sil.shape[0]), BLACK + (0,)); out.putalpha(Image.fromarray(sil).filter(ImageFilter.GaussianBlur(0.8)))
    return out, T + 12

for img, (x, y) in groups:          # primero todas las siluetas negras...
    sil, p = silhouette(img); area.alpha_composite(sil, (x - p, y - p))
for img, (x, y) in groups:          # ...luego los colores encima
    area.alpha_composite(img, (x, y))
area.save("logo_ideaza_cava_color.png")

# 4) aplicar en la foto como vinil (toma la luz/suciedad de la puerta)
im = Image.open("cava_trasera.jpg").convert("RGB")
X0, Y0 = AX0 - 10, AY0 - 10
reg = np.asarray(im.crop((X0, Y0, X0 + area.width, Y0 + area.height)), np.float32) / 255
lum = reg.mean(2, keepdims=True); shade = np.clip(0.80 + 0.22 * (lum / np.median(lum)), 0.75, 1.05)
A = np.asarray(area, np.float32) / 255; col, a = A[..., :3], A[..., 3:] * 0.98
col = col * shade + 0.04 * (lum - np.median(lum))
out = reg * (1 - a) + col * a
# vinil cortado en la junta de las puertas + brillo del borde de la tapajunta
from PIL import ImageDraw
def xs(y, x500, x1300): return x500 + (x1300 - x500) * (y - 500) / 800 - X0
hh = area.height; y1, y2 = Y0, Y0 + hh
g = Image.new("L", area.size, 0); ImageDraw.Draw(g).line((xs(y1, 803, 783), 0, xs(y2, 803, 783), hh), fill=255, width=3)
cut = np.asarray(g.filter(ImageFilter.GaussianBlur(0.7)), np.float32)[..., None] / 255
e = Image.new("L", area.size, 0); ImageDraw.Draw(e).line((xs(y1, 838, 822), 0, xs(y2, 838, 822), hh), fill=255, width=2)
edge = np.asarray(e.filter(ImageFilter.GaussianBlur(0.8)), np.float32)[..., None] / 255
out = out * (1 - cut * a) + reg * 0.55 * cut * a + 0.08 * edge * a
im.paste(Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8)), (X0, Y0))
im.save("cava_logo_ideaza_color.jpg", quality=95)
im.crop((250, 300, 1410, 1320)).save("cava_logo_ideaza_color_detalle.jpg", quality=95)
print("ok", icon_img.size, TW)
