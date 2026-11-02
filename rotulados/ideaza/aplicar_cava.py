"""Simulación: logo IDEAZA en vinil negro en las puertas traseras de la cava, centrado debajo de 'IDEAZA'.
Uso: python aplicar_cava.py [alto_px] [centro_x] [arriba_y]"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
HL = int(sys.argv[1]) if len(sys.argv) > 1 else 620
CX = int(sys.argv[2]) if len(sys.argv) > 2 else 830
TOP = int(sys.argv[3]) if len(sys.argv) > 3 else 560
im = Image.open("cava_trasera.jpg").convert("RGB")
logo = Image.open("logo_ideaza_negro.png")
w = round(logo.width * HL / logo.height); x0 = CX - w // 2
alpha = logo.split()[3].resize((w, HL), Image.LANCZOS).filter(ImageFilter.GaussianBlur(0.6))
reg = np.asarray(im.crop((x0, TOP, x0 + w, TOP + HL)), np.float32) / 255
lum = reg.mean(2, keepdims=True)
vin = 0.05 + 0.12 * (lum - np.median(lum)) + 0.035 * lum          # vinil satinado, deja ver manchas/relieve
vin = np.repeat(np.clip(vin, 0, 1), 3, 2)
a = np.asarray(alpha, np.float32)[..., None] / 255 * 0.97
# corte del vinil en la junta de las puertas (línea izquierda de la tapajunta) y borde de la tapajunta
seam = Image.new("L", (w, HL), 0); d = ImageDraw.Draw(seam)
def xs(y, x500, x1300): return x500 + (x1300 - x500) * (y - 500) / 800 - x0
y1, y2 = TOP, TOP + HL
d.line((xs(y1, 803, 783), 0, xs(y2, 803, 783), HL), fill=255, width=3)
cut = np.asarray(seam.filter(ImageFilter.GaussianBlur(0.7)), np.float32)[..., None] / 255
edge = Image.new("L", (w, HL), 0); ImageDraw.Draw(edge).line((xs(y1, 838, 822), 0, xs(y2, 838, 822), HL), fill=255, width=2)
edge = np.asarray(edge.filter(ImageFilter.GaussianBlur(0.8)), np.float32)[..., None] / 255
out = reg * (1 - a) + vin * a
out = out * (1 - cut * a) + (reg * 0.55) * cut * a                 # en la junta se ve el hueco, no vinil
out = out + 0.10 * edge * a                                         # brillo del borde de la tapajunta
im.paste(Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8)), (x0, TOP))
im.save("cava_logo_ideaza.jpg", quality=95)
im.crop((300, 300, 1360, 1320)).save("cava_logo_ideaza_detalle.jpg", quality=95)
print(w, HL, x0, TOP)
