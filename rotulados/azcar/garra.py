"""Simulación del logo Carrocerías Azcar en el recuadro central de la garra (foto real).
V1: silueta blanca + letras negras + engranaje rojo.  V2: sin silueta, letras blancas + engranaje rojo."""
import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage as ndi
src = Image.open("original.jpg").convert("RGB")
a = np.asarray(src).astype(float); L = a.mean(2)
rows = np.where((L > 235).mean(1) > 0.5)[0]; cols = np.where((L > 235).mean(0) > 0.3)[0]
card = src.crop((cols.min() + 4, rows.min() + 4, cols.max() - 4, rows.max() - 4))
card = card.resize((card.width * 3, card.height * 3), Image.LANCZOS)
b = np.asarray(card).astype(float); R, G, B = b[..., 0], b[..., 1], b[..., 2]
lum = 0.299 * R + 0.587 * G + 0.114 * B
red = np.clip((R - np.maximum(G, B) - 25) / 90, 0, 1)
white = (lum > 150) & (red < 0.3)
lab, n = ndi.label(white)
border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
bg = np.isin(lab, list(border))
sil = ndi.binary_fill_holes(~bg)                       # silueta completa (la calcomanía)
letters = white & ~bg                                  # letras y teléfono (blancas en el original)
def soft(m, r=1.2): return np.asarray(Image.fromarray((m * 255).astype("uint8")).filter(ImageFilter.GaussianBlur(r))).astype(float) / 255
def rgba(rgb, alpha):
    ys, xs = np.where(alpha > 0.02); y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    o = np.dstack([rgb, alpha[..., None] * 255]).clip(0, 255).astype("uint8")[y0:y1, x0:x1]
    return Image.fromarray(o, "RGBA")
redc = np.array([200, 30, 30]); 
# V1: blanco en la silueta, negro en letras, rojo en engranaje
g1 = np.where(letters[..., None], 18, 245) * np.ones(3)
g1 = red[..., None] * redc + (1 - red[..., None]) * g1
v1 = rgba(g1, soft(sil))
# V2: solo letras blancas + engranaje rojo
a2 = np.maximum(soft(letters), soft(red > 0.5))
g2 = red[..., None] * redc + (1 - red[..., None]) * np.full(3, 245.0)
v2 = rgba(g2, a2)
v1.save("azcar_v1_silueta_blanca.png"); v2.save("azcar_v2_letras_blancas.png")

# ---- colocación en perspectiva dentro del recuadro central ----
ph = Image.open("garra_original.jpg").convert("RGB"); P = np.asarray(ph).astype(float)
quad = np.array([[308, 920], [1290, 885], [1328, 1360], [312, 1405]], float)   # TL TR BR BL del recuadro
def homog(srcp, dstp):
    A = []
    for (x, y), (u, v) in zip(srcp, dstp):
        A += [[x, y, 1, 0, 0, 0, -u * x, -u * y, -u], [0, 0, 0, x, y, 1, -v * x, -v * y, -v]]
    h = np.linalg.svd(np.array(A))[2][-1]; return (h / h[-1]).reshape(3, 3)
PW, PH = 1000.0, 480.0                                   # tamaño nominal del recuadro
Hq = homog([(0, 0), (PW, 0), (PW, PH), (0, PH)], quad)   # recuadro plano -> foto
tex = ph.convert("L"); tl = np.asarray(tex).astype(float); tb = np.asarray(tex.filter(ImageFilter.GaussianBlur(25))).astype(float)
texture = np.clip(tl / np.maximum(tb, 1), 0.75, 1.25)
def place(logo, out, fill=0.84):
    asp = logo.width / logo.height; w = PW * fill; h = w / asp
    if h > PH * 0.8: h = PH * 0.8; w = h * asp
    x0, y0 = (PW - w) / 2, (PH - h) / 2
    rect = [(x0, y0), (x0 + w, y0), (x0 + w, y0 + h), (x0, y0 + h)]
    dst = [tuple((Hq @ np.array([x, y, 1]))[:2] / (Hq @ np.array([x, y, 1]))[2]) for x, y in rect]
    Hinv = homog(dst, [(0, 0), (logo.width, 0), (logo.width, logo.height), (0, logo.height)])
    warped = logo.transform(ph.size, Image.PERSPECTIVE, tuple(Hinv.flatten()[:8]), Image.BICUBIC)
    W = np.asarray(warped).astype(float); al = W[..., 3:4] / 255 * 0.97
    col = W[..., :3] * (0.6 + 0.4 * texture[..., None]) * 0.93          # textura de la goma sobre el vinil
    res = P * (1 - al) + col * al
    Image.fromarray(res.clip(0, 255).astype("uint8")).save(out, quality=95)
place(v1, "garra_azcar_v1_silueta_blanca.jpg")
place(v2, "garra_azcar_v2_letras_blancas.jpg")
print(v1.size, v2.size)
