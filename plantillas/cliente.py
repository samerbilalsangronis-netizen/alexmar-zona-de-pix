"""Pieza de cliente (post 1080x1350 + historia 1080x1920).
Uso: python3 cliente.py <foto> <modelo> <nombre cliente> <salida_base> <crop_post x0,y0,x1> <crop_story x0,x1> [y_offset_story]
Las coordenadas de recorte van en píxeles de la foto original.
"""
import sys
from PIL import Image, ImageDraw, ImageFont, ImageEnhance, ImageFilter
P = '/home/claude/alexmar-zona-de-pix/plantillas/'
F = lambda n, s: ImageFont.truetype(P + 'fonts/' + n, s)
OR = (217, 119, 87); ORL = (240, 165, 126); BK = (26, 26, 26); CR = (245, 240, 232)
LOGO = Image.open(P + 'assets/logo_alexmar_sticker.png').convert('RGBA')


def tc(d, cx, y, t, f, fill, stroke=0, sf=None):
    w = d.textlength(t, font=f); d.text((cx - w / 2, y), t, font=f, fill=fill, stroke_width=stroke, stroke_fill=sf)


def fit(d, t, name, size, maxw):
    while size > 20:
        f = F(name, size)
        if d.textlength(t, font=f) <= maxw: return f
        size -= 2
    return F(name, size)


def watermark(W, H):
    wm = Image.new('RGBA', (W * 2, H * 2), (0, 0, 0, 0)); d = ImageDraw.Draw(wm); f = F('Anton.ttf', 70)
    for yi, y in enumerate(range(0, H * 2, 190)):
        off = (yi % 2) * 200
        for x in range(-400 + off, W * 2, 420):
            d.text((x, y), 'ALEXMAR', font=f, fill=(245, 240, 232, 13))
    wm = wm.rotate(28, resample=Image.BICUBIC)
    return wm.crop((W // 2, H // 2, W // 2 + W, H // 2 + H))


def grad(c, W, H, top_end, top_fade, bot_start, bot_fade):
    g = Image.new('RGBA', (W, H), (0, 0, 0, 0)); gd = ImageDraw.Draw(g)
    for y in range(H):
        a = 0
        if y < top_end: a = 225 if y < top_end - top_fade else int(225 * (top_end - y) / top_fade)
        if y > bot_start: a = max(a, int(235 * min(1, (y - bot_start) / bot_fade)))
        gd.line([(0, y), (W, y)], fill=BK + (a,))
    return Image.alpha_composite(c, g)


def header(c, W, modelo, cliente, y0, logo_h=200, cliente_y=None):
    d = ImageDraw.Draw(c)
    lg = LOGO.resize((int(LOGO.width * logo_h / LOGO.height), logo_h), Image.LANCZOS); c.alpha_composite(lg, (30, y0)); d = ImageDraw.Draw(c)
    x = 30 + lg.width + 24
    fp = F('Mont900.ttf', 22); t = 'CLIENTES ALEXMAR'; pw = d.textlength(t, font=fp)
    d.rounded_rectangle((x, y0 + 10, x + pw + 36, y0 + 50), radius=20, fill=OR); d.text((x + 18, y0 + 19), t, font=fp, fill=BK)
    d.text((x, y0 + 62), 'ASÍ LUCE EL', font=F('Mont900.ttf', 34), fill=CR)
    fh = fit(d, modelo, 'Anton.ttf', 104, W - x - 30)
    d.text((x, y0 + 100), modelo, font=fh, fill=OR, stroke_width=3, stroke_fill=BK)
    tc(d, W / 2, cliente_y or y0 + 248, f'de nuestro fiel cliente  {cliente}', F('Mont700.ttf', 36), CR, 2, BK)


def footer(c, W, fy):
    d = ImageDraw.Draw(c)
    tc(d, W / 2, fy - 45, 'AUTOPERIQUITOS · ROTULADOS · ACCESORIOS', F('Mont700.ttf', 26), CR)
    fb = F('Anton.ttf', 84); fpn = F('Anton.ttf', 52); ph = '0416-676 83 93'
    aw = d.textlength('ALEXMAR', font=fb); pw = d.textlength(ph, font=fpn); gap = 34
    xx = (W - (aw + gap + pw + 60)) / 2
    d.text((xx, fy), 'ALEXMAR', font=fb, fill=OR, stroke_width=3, stroke_fill=BK)
    px = xx + aw + gap; py = fy + (fb.size - fpn.size) / 2 + 6
    d.rounded_rectangle((px, py - 4, px + pw + 60, py + fpn.size + 22), radius=40, fill=OR); d.text((px + 30, py + 2), ph, font=fpn, fill=BK)
    tc(d, W / 2, fy + 120, 'Tovar  ·  Pueblo Llano', F('Mont700.ttf', 26), CR)


foto, modelo, cliente, out = sys.argv[1:5]
px0, py0, px1 = map(int, sys.argv[5].split(','))
sx0, sx1 = map(int, sys.argv[6].split(','))
yoff = int(sys.argv[7]) if len(sys.argv) > 7 else 0
src = Image.open(foto).convert('RGB')
src = ImageEnhance.Contrast(src).enhance(1.06); src = ImageEnhance.Color(src).enhance(1.08)

# POST 1080x1350
W, H = 1080, 1350
cw = px1 - px0; ch = int(cw * H / W)
im = src.crop((px0, py0, px1, min(src.height, py0 + ch))).resize((W, H), Image.LANCZOS)
c = grad(im.convert('RGBA'), W, H, 330, 150, 1050, 110)
c = Image.alpha_composite(c, watermark(W, H))
header(c, W, modelo, cliente, 24)
footer(c, W, 1145)
c.convert('RGB').save(out + '_post_1080x1350.jpg', quality=93)

# HISTORIA 1080x1920: foto a lo ancho, desplazada hacia abajo; arriba fondo desenfocado
W, H = 1080, 1920
cw = sx1 - sx0; s = W / cw
ph = src.crop((sx0, 0, sx1, src.height)).resize((W, int(src.height * s)), Image.LANCZOS)
bg = ph.resize((int(W * 1.3), int(H * 1.3))).crop((int(W * .15), 0, int(W * .15) + W, H)).filter(ImageFilter.GaussianBlur(30))
bg = ImageEnhance.Brightness(bg).enhance(0.5)
bg.paste(ph, (0, yoff))
c = grad(bg.convert('RGBA'), W, H, 560, 180, 1500, 140)
c = Image.alpha_composite(c, watermark(W, H))
header(c, W, modelo, cliente, 150, cliente_y=420)
footer(c, W, 1660)
c.convert('RGB').save(out + '_historia_1080x1920.jpg', quality=93)
print('ok')
