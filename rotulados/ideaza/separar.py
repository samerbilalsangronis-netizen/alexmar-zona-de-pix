"""Separa el logo IDEAZA por color: marrón (martillo, herramientas, textos), gris (casa), amarillo (sierra)."""
import numpy as np
from scipy import ndimage as nd
from PIL import Image, ImageFilter
im = Image.open("logo_pantalla.jpg").convert("RGB").crop((100, 280, 1560, 1790)).filter(ImageFilter.MedianFilter(5))
a = np.asarray(im).astype(np.float32); R, G, B = a[..., 0], a[..., 1], a[..., 2]; L = a.mean(2)
H, W = L.shape; yy, xx = np.mgrid[0:H, 0:W] / 1000.
gr, br = G - R, B - R
bgm = (gr > 22) & (br > 15)
X = np.stack([np.ones_like(xx), xx, yy, xx * xx, yy * yy, xx * yy], -1)
c, *_ = np.linalg.lstsq(X[bgm][::50], L[bgm][::50], rcond=None)
r = nd.gaussian_filter(L / (X @ c), 2.5); bbs = nd.gaussian_filter(br, 2.5)
Rs, Gs, Bs = [nd.gaussian_filter(ch, 3) for ch in (R, G, B)]
m = (r < 0.84) | (bbs < 5)
m = nd.binary_opening(m, iterations=2); m[340:, :300] = False
lab, n = nd.label(m); sizes = nd.sum(m, lab, range(1, n + 1))
keep = np.zeros(n + 1, bool); keep[1:] = sizes > 400
for v in np.unique(lab[-25:, :]): keep[v] = keep[v] and v != 0 and sizes[v - 1] > 20000
m = keep[lab]
yellow = m & (Gs - Rs > 4) & (Gs - Bs > 40)
brown = m & ~yellow & (Rs - Gs > 6)
gray = m & ~yellow & ~brown
np.savez_compressed("/tmp/capas.npz", m=m, yellow=yellow, brown=brown, gray=gray)
vis = np.ones((H, W, 3), np.uint8) * 255
vis[brown] = (160, 112, 62); vis[gray] = (165, 172, 178); vis[yellow] = (214, 226, 30)
Image.fromarray(vis).save("/tmp/fr/capas.png")
print(H, W, brown.sum(), gray.sum(), yellow.sum())

# ---- elementos por zona (coords del recorte) ----
yy, xx = np.mgrid[0:H, 0:W]
core = nd.binary_opening(gray, iterations=4)
lb, nb = nd.label(core); big = np.argmax(nd.sum(core, lb, range(1, nb + 1))) + 1
house = nd.binary_dilation(lb == big, iterations=4) & m
rest = m & ~house
def box(x1, y1, x2, y2): return (xx >= x1) & (xx < x2) & (yy >= y1) & (yy < y2)
emblem = rest & box(515, 770, 1010, 1200)
carp = rest & box(555, 1195, 1005, 1285)
idz = rest & box(496, 1285, 1070, 1480)
hammer = rest & ~emblem & ~carp & ~idz & ((yy < 440) | (xx < 496))
# color dentro del emblema: amarillo/marrón por vecino más cercano
ycore = nd.binary_erosion(yellow, iterations=1); bcore = nd.binary_erosion(brown, iterations=1)
dy = nd.distance_transform_edt(~ycore); db = nd.distance_transform_edt(~bcore)
emb_y = emblem & (dy < db)
np.savez_compressed("capas_ideaza.npz", house=house, hammer=hammer, emblem=emblem, emb_y=emb_y, carp=carp, idz=idz)
vis = np.ones((H, W, 3), np.uint8) * 255
for k, col in [(hammer, (160, 112, 62)), (house, (165, 172, 178)), (emblem, (160, 112, 62)), (emb_y, (214, 226, 30)), (carp, (120, 60, 30)), (idz, (200, 80, 40))]:
    vis[k] = col
Image.fromarray(vis).save("/tmp/fr/elem.png")
