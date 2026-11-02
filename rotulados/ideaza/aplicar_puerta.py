"""Simulación: logo IDEAZA en vinil negro en la puerta del camión, debajo de la base del espejo."""
import sys
import numpy as np
from PIL import Image, ImageFilter
H_LOGO = int(sys.argv[1]) if len(sys.argv) > 1 else 330      # alto del logo en px de la foto
CX, TOP = int(sys.argv[2]) if len(sys.argv) > 2 else 590, int(sys.argv[3]) if len(sys.argv) > 3 else 1360
truck = Image.open("camion.jpg").convert("RGB")
logo = Image.open("logo_ideaza_negro.png")
w = round(logo.width * H_LOGO / logo.height)
alpha = logo.split()[3].resize((w, H_LOGO), Image.LANCZOS).filter(ImageFilter.GaussianBlur(0.5))
x0 = CX - w // 2
reg = np.asarray(truck.crop((x0, TOP, x0 + w, TOP + H_LOGO)), np.float32) / 255
lum = reg.mean(2, keepdims=True)
# vinil negro satinado: casi negro + un poco del brillo/sombra de la pintura de abajo
vin = 0.055 + 0.10 * (lum - lum.mean()) + 0.04 * lum
vin = np.repeat(np.clip(vin, 0, 1), 3, 2) * np.array([1.0, 1.0, 1.04])
a = np.asarray(alpha, np.float32)[..., None] / 255 * 0.97
out = reg * (1 - a) + vin * a
truck.paste(Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8)), (x0, TOP))
truck.save("camion_logo_ideaza.jpg", quality=95)
truck.crop((300, 1050, 1150, 1850)).save("camion_logo_ideaza_detalle.jpg", quality=95)
print(w, H_LOGO, x0, TOP)
