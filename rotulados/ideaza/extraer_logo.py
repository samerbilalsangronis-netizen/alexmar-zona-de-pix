"""Extrae el logo Carpintería IDEAZA de la foto de pantalla y lo deja en negro sólido (PNG transparente)."""
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
r = nd.gaussian_filter(L / (X @ c), 2.5); bb = nd.gaussian_filter(br, 2.5)
m = (r < 0.84) | (bb < 5)
m = nd.binary_opening(m, iterations=2)
m[340:, :300] = False   # moiré de la pantalla a la izquierda del mango
lab, n = nd.label(m); sizes = nd.sum(m, lab, range(1, n + 1))
keep = np.zeros(n + 1, bool); keep[1:] = sizes > 400
# fuera lo que toca el borde inferior (línea de la ventana del programa)
for v in np.unique(lab[-25:, :]): keep[v] = keep[v] and v != 0 and sizes[v - 1] > 20000
m = keep[lab]
holes = nd.binary_fill_holes(m) & ~m; hl, hn = nd.label(holes); hs = nd.sum(holes, hl, range(1, hn + 1))
small = np.zeros(hn + 1, bool); small[1:] = hs < 150; m = m | small[hl]
# bordes suaves (supermuestreo)
big = Image.fromarray((m * 255).astype(np.uint8)).resize((W * 2, H * 2), Image.BICUBIC).filter(ImageFilter.GaussianBlur(2.2))
big = big.point(lambda v: 255 if v > 128 else 0).filter(ImageFilter.GaussianBlur(0.8))
bbox = big.getbbox(); big = big.crop(bbox)
out = Image.new("RGBA", big.size, (0, 0, 0, 0)); out.putalpha(big)
out.save("logo_ideaza_negro.png")
prev = Image.new("RGB", big.size, "white"); prev.paste((0, 0, 0), mask=big); prev.save("logo_ideaza_negro_preview.jpg", quality=92)
print(out.size)
