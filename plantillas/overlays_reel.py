from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os
P = '/home/claude/alexmar-zona-de-pix/plantillas/'
F = lambda n, s: ImageFont.truetype(P + 'fonts/' + n, s)
OR = (217, 119, 87); ORL = (240, 165, 126); BK = (26, 26, 26); CR = (245, 240, 232)
W, H = 1080, 1920
O = '/home/claude/scorpion/ov/'
os.makedirs(O, exist_ok=True)
LOGO = Image.open(P + 'assets/logo_alexmar_sticker.png').convert('RGBA')


def tc(d, cx, y, t, f, fill, stroke=0, sf=None):
    w = d.textlength(t, font=f)
    d.text((cx - w / 2, y), t, font=f, fill=fill, stroke_width=stroke, stroke_fill=sf)


def watermark():
    wm = Image.new('RGBA', (W * 2, H * 2), (0, 0, 0, 0)); d = ImageDraw.Draw(wm); f = F('Anton.ttf', 70)
    for yi, y in enumerate(range(0, H * 2, 190)):
        off = (yi % 2) * 200
        for x in range(-400 + off, W * 2, 420):
            d.text((x, y), 'ALEXMAR', font=f, fill=(245, 240, 232, 14))
    wm = wm.rotate(28, resample=Image.BICUBIC)
    return wm.crop((W // 2, H // 2, W // 2 + W, H // 2 + H))


WM = watermark()


def shade(c, y0, y1, a=170):
    """vertical gradient band for legibility"""
    g = Image.new('L', (1, y1 - y0))
    n = y1 - y0
    for i in range(n):
        t = i / n
        g.putpixel((0, i), int(a * min(1, t * 2.2) * min(1, (1 - t) * 2.2)))
    g = g.resize((W, n))
    band = Image.new('RGBA', (W, n), BK + (0,)); band.putalpha(g)
    c.alpha_composite(band, (0, y0))


def base(top_shade=True):
    c = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    if top_shade:
        g = Image.new('L', (1, 330))
        for i in range(330): g.putpixel((0, i), int(140 * (1 - i / 330)))
        b = Image.new('RGBA', (W, 330), BK + (0,)); b.putalpha(g.resize((W, 330))); c.alpha_composite(b, (0, 0))
    c.alpha_composite(WM)
    lg = LOGO.resize((int(LOGO.width * 170 / LOGO.height), 170), Image.LANCZOS)
    c.alpha_composite(lg, (40, 70))
    d = ImageDraw.Draw(c)
    d.text((40 + lg.width + 18, 112), 'ALEXMAR', font=F('Anton.ttf', 64), fill=CR, stroke_width=3, stroke_fill=BK)
    d.text((40 + lg.width + 20, 190), '0416-676 83 93', font=F('Mont900.ttf', 30), fill=ORL, stroke_width=2, stroke_fill=BK)
    return c


def pill(d, cx, y, t, f, fill=OR, tf=BK, pad=30, h=None):
    w = d.textlength(t, font=f); bb = f.getbbox(t); th = bb[3] - bb[1]
    h = h or th + 34
    d.rounded_rectangle((cx - w / 2 - pad, y, cx + w / 2 + pad, y + h), radius=h // 2, fill=fill)
    d.text((cx - w / 2, y + (h - th) / 2 - bb[1]), t, font=f, fill=tf)


def card(name, tag, l1, l2=None, sub=None, y=1180, tagcol=OR, l1col=CR, l2col=OR, size=112):
    c = base(); shade(c, y - 120, y + 520, 175); d = ImageDraw.Draw(c)
    yy = y
    if tag:
        pill(d, W / 2, yy, tag, F('Mont900.ttf', 38), fill=tagcol); yy += 100
    tc(d, W / 2, yy, l1, F('Anton.ttf', size), l1col, 4, BK); yy += int(size * 1.18)
    if l2:
        tc(d, W / 2, yy, l2, F('Anton.ttf', size), l2col, 4, BK); yy += int(size * 1.18)
    if sub:
        tc(d, W / 2, yy + 6, sub, F('Mont700.ttf', 40), CR, 2, BK)
    c.save(O + name + '.png')


card('01', 'ANTES', '¿TODAVÍA CON', 'LUZ AMARILLA?', y=1120)
card('02', 'SCORPION', 'BOMBILLOS LED', '55.000 LÚMENES', 'Alta y baja · Ford F-250 Super Duty', size=104)
card('03', 'INSTALACIÓN', 'LUCES DE', 'PARRILLA', size=118)
card('04', 'INSTALACIÓN', 'LUZ DE PLACA', 'TRASERA', size=112)
card('05', 'SCORPION', 'PORTAPLACAS', 'AHUMADOS', size=118)
card('06', None, 'PARRILLA', 'ENCENDIDA', size=118)
# after: two spec lines
c = base(); shade(c, 1000, 1640, 180); d = ImageDraw.Draw(c)
pill(d, W / 2, 1050, 'DESPUÉS', F('Mont900.ttf', 38), fill=CR, tf=BK)
tc(d, W / 2, 1150, 'LUZ BLANCA', F('Anton.ttf', 128), CR, 4, BK)
tc(d, W / 2, 1310, 'Alta y baja · 55.000 lm', F('Mont900.ttf', 46), ORL, 2, BK)
tc(d, W / 2, 1380, 'Exploradoras · 12.000 lm', F('Mont900.ttf', 46), ORL, 2, BK)
tc(d, W / 2, 1460, 'SCORPION', F('Anton.ttf', 64), OR, 3, BK)
c.save(O + '07.png')
# slogan
c = base(); shade(c, 1080, 1560, 175); d = ImageDraw.Draw(c)
tc(d, W / 2, 1140, 'Luz que se nota.', F('Anton.ttf', 104), CR, 4, BK)
tc(d, W / 2, 1270, 'Estilo que se impone.', F('Anton.ttf', 104), OR, 4, BK)
c.save(O + '08.png')
card('09', 'HECHO EN', 'ALEXMAR', None, 'Tovar · Pueblo Llano', size=150, l1col=OR)


def closing(bgframe):
    c = Image.open(bgframe).convert('RGBA').resize((W, H))
    c = c.filter(ImageFilter.GaussianBlur(6))
    c = Image.alpha_composite(c, Image.new('RGBA', (W, H), BK + (205,)))
    c.alpha_composite(WM); d = ImageDraw.Draw(c)
    lg = LOGO.resize((int(LOGO.width * 430 / LOGO.height), 430), Image.LANCZOS)
    c.alpha_composite(lg, ((W - lg.width) // 2, 170)); d = ImageDraw.Draw(c)
    tc(d, W / 2, 660, 'Autoperiquitos y Rotulados', F('Mont900.ttf', 46), CR)
    tc(d, W / 2, 725, 'ALEXMAR', F('Anton.ttf', 200), OR, 4, BK)
    fp = F('Anton.ttf', 96); ph = '0416-676 83 93'; pw = d.textlength(ph, font=fp)
    d.rounded_rectangle(((W - pw) / 2 - 56, 1000, (W + pw) / 2 + 56, 1140), radius=70, fill=OR)
    tc(d, W / 2, 1012, ph, fp, BK)
    y = 1200
    for t in ['Iluminación LED · Somos instaladores', 'Tovar · Pueblo Llano', 'Lunes a sábado · 8 am a 6 pm']:
        tc(d, W / 2, y, t, F('Mont700.ttf', 42), CR); y += 68
    tc(d, W / 2, y + 26, '@autoalexmar_car', F('Mont900.ttf', 46), ORL)
    c.convert('RGB').save(O + 'cierre.jpg', quality=94)


import sys
if len(sys.argv) > 1:
    closing(sys.argv[1])
print('ok')

card('00', 'FORD F-250 SUPER DUTY', 'TU CAMIONETA', 'MERECE MÁS', y=1120, size=124)
card('05b', 'SCORPION', 'PORTAPLACAS', 'AHUMADO', y=1380, size=118)
