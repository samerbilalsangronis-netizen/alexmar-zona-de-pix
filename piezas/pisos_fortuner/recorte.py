"""Recorta los 3 pisos reales (rembg isnet + limpieza de juntas de baldosa) -> PNG transparente."""
import numpy as np
from scipy import ndimage as nd
from PIL import Image, ImageFilter
from rembg import remove, new_session
im = Image.open("foto_pisos_fortuner_5d.jpg").convert("RGB")
al = np.asarray(remove(im, session=new_session("isnet-general-use")).split()[3]).astype(np.float32) / 255
m = al > 0.5
_a = np.asarray(im).astype(np.float32)
orange = (_a[..., 0] - _a[..., 2] > 45) & (_a.max(2) - _a.min(2) > 50)      # baldosas
m &= ~nd.binary_dilation(orange, iterations=2)
core = nd.binary_opening(m, structure=np.ones((3, 3)), iterations=22)                # rompe las juntas finas
lab, n = nd.label(core); sz = nd.sum(core, lab, range(1, n + 1))
keep = np.zeros(n + 1, bool); keep[1 + np.argsort(sz)[::-1][:3]] = True
core = keep[lab]
m2 = m & nd.binary_dilation(core, structure=np.ones((3, 3)), iterations=23)
# en el anillo exterior, quitar lo que tenga color de junta (gris verdoso más claro que el piso)
a = np.asarray(im).astype(np.float32); L = a.mean(2); gcol = (L > 95) & (a[..., 1] - a[..., 0] > 3)
ring = m2 & ~nd.binary_erosion(core, iterations=2)
m2 &= ~(ring & gcol)
m2 = nd.binary_opening(m2, iterations=3)
lab2, n2 = nd.label(m2); s2 = nd.sum(m2, lab2, range(1, n2 + 1)); k2 = np.zeros(n2 + 1, bool); k2[1 + np.argsort(s2)[::-1][:3]] = True; m2 = k2[lab2]
alpha = np.where(m2, al, 0)
A = Image.fromarray((alpha * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8))
out = im.convert("RGBA"); out.putalpha(A); out = out.crop(A.getbbox())
out.save("pisos_fortuner_recorte.png"); print(out.size)
prev = Image.new("RGB", out.size, (40, 40, 40)); prev.paste(out, mask=out.split()[3]); prev.resize((out.width // 4, out.height // 4)).save("/tmp/fr/rec.jpg")
