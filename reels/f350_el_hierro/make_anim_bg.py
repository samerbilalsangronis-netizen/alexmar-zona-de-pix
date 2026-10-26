"""Fondo elegante 1080x1920 para la animación de la luz lateral (se mezcla con modo 'lighten')."""
import os, math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; M9 = f"{R}/fonts/Mont900.ttf"
W, H = 1080, 1920
TERRA = (217, 119, 87)
bg = Image.new("RGB", (W, H), (20, 18, 18))
# brillo naranja suave desde las esquinas y la parte baja
glow = Image.new("RGB", (W, H), (0, 0, 0)); g = ImageDraw.Draw(glow)
g.ellipse((-500, -500, 600, 500), fill=(120, 55, 30)); g.ellipse((500, 1500, 1600, 2500), fill=(140, 62, 34))
glow = glow.filter(ImageFilter.GaussianBlur(260))
bg = Image.fromarray(__import__("numpy").clip(__import__("numpy").asarray(bg).astype(int) + __import__("numpy").asarray(glow).astype(int), 0, 255).astype("uint8"))
cv = bg.convert("RGBA")
# patrón diagonal ALEXMAR muy tenue
t = Image.new("RGBA", (2600, 2600), (0, 0, 0, 0)); td = ImageDraw.Draw(t); f = ImageFont.truetype(ANTON, 120)
for row in range(0, 2600, 260):
    off = (row // 260 % 2) * 300
    for col in range(-600, 2600, 600): td.text((col + off, row), "ALEXMAR", font=f, fill=(255, 255, 255, 10))
t = t.rotate(30, resample=Image.BICUBIC); cv.alpha_composite(t.crop(((2600 - W) // 2, (2600 - H) // 2, (2600 - W) // 2 + W, (2600 - H) // 2 + H)))
# logo grande fantasma detrás de la pieza
lg = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); lg = lg.crop(lg.getbbox())
lw = 900; lg = lg.resize((lw, int(lg.height * lw / lg.width)), Image.LANCZOS).convert("LA").convert("RGBA")
a = lg.split()[3].point(lambda v: int(v * 0.09)); lg.putalpha(a)
cv.alpha_composite(lg, ((W - lw) // 2, (H - lg.height) // 2 + 40))
# anillo naranja fino detrás de la pieza
ring = Image.new("RGBA", (W, H), (0, 0, 0, 0)); rd = ImageDraw.Draw(ring)
cx, cy, r = W // 2, H // 2 + 40, 470
rd.ellipse((cx - r, cy - r, cx + r, cy + r), outline=TERRA + (70,), width=3)
rd.ellipse((cx - r - 26, cy - r - 26, cx + r + 26, cy + r + 26), outline=TERRA + (28,), width=2)
cv.alpha_composite(ring.filter(ImageFilter.GaussianBlur(0.6)))
# marco fino con esquinas
fr = ImageDraw.Draw(cv); m = 46; L = 110
for (x, y, dx, dy) in [(m, m, 1, 1), (W - m, m, -1, 1), (m, H - m, 1, -1), (W - m, H - m, -1, -1)]:
    fr.line((x, y, x + dx * L, y), fill=TERRA + (200,), width=4); fr.line((x, y, x, y + dy * L), fill=TERRA + (200,), width=4)
cv.convert("RGB").save(f"{D}/anim_ov/anim_bg.png")
print("ok")
