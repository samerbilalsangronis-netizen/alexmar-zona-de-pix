"""Post 1080x1350 de suspenso "PRÓXIMAMENTE" sobre foto del local en preparación."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; M9 = f"{R}/fonts/Mont900.ttf"; M7 = f"{R}/fonts/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
W, H = 1080, 1350
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
ph = Image.open(f"{D}/foto_local.jpg").convert("RGB")
s = max(W / ph.width, H / ph.height); ph = ph.resize((round(ph.width * s), round(ph.height * s)), Image.LANCZOS)
ph = ph.crop(((ph.width - W) // 2, 0, (ph.width - W) // 2 + W, H))
ph = ImageEnhance.Color(ph).enhance(0.55)
blur = ph.filter(ImageFilter.GaussianBlur(14))
# foco nítido solo sobre los pisos de la pared (la pista)
m = Image.new("L", (W, H), 0); d = ImageDraw.Draw(m); d.ellipse((560, 230, 1180, 980), fill=255); m = m.filter(ImageFilter.GaussianBlur(120))
cv = Image.composite(ImageEnhance.Brightness(ph).enhance(0.75), ImageEnhance.Brightness(blur).enhance(0.35), m).convert("RGBA")
v = Image.new("L", (W, H), 0); dv = ImageDraw.Draw(v); dv.ellipse((-W * 0.3, -H * 0.2, W * 1.3, H * 1.2), fill=255); v = v.filter(ImageFilter.GaussianBlur(200))
dark = Image.new("RGBA", (W, H), (6, 6, 8, 235)); dark.putalpha(v.point(lambda x: 235 - x * 235 // 255 // 1)); cv.alpha_composite(dark)
dr = ImageDraw.Draw(cv)
def center(y, t, f, fill, sp=0):
    w = sum(dr.textlength(c, font=f) for c in t) + sp * (len(t) - 1); x = (W - w) / 2
    for c in t: dr.text((x, y), c, font=f, fill=fill); x += dr.textlength(c, font=f) + sp
lw = 170; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); cv.alpha_composite(lg, ((W - lw) // 2, 60))
center(330, "ALGO GRANDE SE VIENE", ImageFont.truetype(M9, 34), LIGHT, sp=10)
dr.line((W / 2 - 70, 392, W / 2 + 70, 392), fill=TERRA, width=4)
# PRÓXIMAMENTE con brillo
lay = Image.new("RGBA", (W, 260), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); f = ImageFont.truetype(ANTON, 168)
b = ld.textbbox((0, 0), "PRÓXIMAMENTE", font=f); tx = (W - (b[2] - b[0])) / 2 - b[0]
ld.text((tx, 40 - b[1]), "PRÓXIMAMENTE", font=f, fill=TERRA + (255,))
glow = lay.filter(ImageFilter.GaussianBlur(22)); cv.alpha_composite(glow, (0, 420)); cv.alpha_composite(glow, (0, 420)); cv.alpha_composite(lay, (0, 420))
dr = ImageDraw.Draw(cv)
center(1060, "Estamos preparando algo nuevo para ti", ImageFont.truetype(M7, 32), CREAM)
center(1110, "¿Adivinas qué es? Déjalo en los comentarios 👇".replace(" 👇", ""), ImageFont.truetype(M7, 28), LIGHT)
center(1230, "AUTOPERIQUITOS Y ROTULADOS ALEXMAR", ImageFont.truetype(M9, 24), CREAM, sp=5)
center(1270, "@autoalexmar_car", ImageFont.truetype(M7, 24), LIGHT)
cv.convert("RGB").save(f"{D}/alexmar_proximamente.jpg", quality=95); print("ok")
