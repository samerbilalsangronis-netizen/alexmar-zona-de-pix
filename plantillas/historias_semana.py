from PIL import Image, ImageDraw, ImageFilter, ImageEnhance
src = open('/home/claude/scorpion/overlays.py').read().split("card('01'")[0].replace("O = '/home/claude/scorpion/ov/'", "O = '/home/claude/historias/out/'")
exec(src)
FR = '/home/claude/historias/fr/'


def fit_img(path, w, h, cy=0.5):
    im = Image.open(path).convert('RGB')
    s = max(w / im.width, h / im.height); im = im.resize((int(im.width * s) + 1, int(im.height * s) + 1), Image.LANCZOS)
    x = (im.width - w) // 2; y = int((im.height - h) * cy)
    return ImageEnhance.Color(ImageEnhance.Contrast(im.crop((x, y, x + w, y + h))).enhance(1.06)).enhance(1.1)


def footer(c, y=1745, txt='Tovar  ·  Pueblo Llano'):
    d = ImageDraw.Draw(c)
    g = Image.new('L', (1, 330))
    for i in range(330): g.putpixel((0, i), int(225 * min(1, i / 140)))
    b = Image.new('RGBA', (W, 330), BK + (0,)); b.putalpha(g.resize((W, 330))); c.alpha_composite(b, (0, H - 330)); d = ImageDraw.Draw(c)
    fp = F('Anton.ttf', 64); ph = '0416-676 83 93'; pw = d.textlength(ph, font=fp)
    d.rounded_rectangle(((W - pw) / 2 - 40, y - 100, (W + pw) / 2 + 40, y - 6), radius=46, fill=OR); tc(d, W / 2, y - 92, ph, fp, BK)
    tc(d, W / 2, y + 14, txt, F('Mont900.ttf', 34), CR, 2, BK)


def split(name, top, bot, t_lab, b_lab, q1, q2, cyt=0.5, cyb=0.5):
    c = Image.new('RGBA', (W, H), BK + (255,))
    c.paste(fit_img(FR + top if '/' not in top else top, W, 950, cyt), (0, 0))
    c.paste(fit_img(FR + bot if '/' not in bot else bot, W, 950, cyb), (0, 970))
    c = c.convert('RGBA'); c.alpha_composite(base(top_shade=True))
    d = ImageDraw.Draw(c)
    d.rectangle((0, 948, W, 972), fill=OR)
    pill(d, 120, 840, t_lab, F('Mont900.ttf', 38), fill=CR); pill(d, 140, 1000, b_lab, F('Mont900.ttf', 38), fill=OR)
    # pregunta centrada sobre la franja
    d = ImageDraw.Draw(c)
    f = F('Anton.ttf', 92)
    bw = max(d.textlength(q1, font=f), d.textlength(q2, font=f)) + 80
    d.rounded_rectangle(((W - bw) / 2, 280, (W + bw) / 2, 520), radius=30, fill=BK + (225,))
    tc(d, W / 2, 295, q1, f, CR); tc(d, W / 2, 400, q2, f, OR)
    footer(c)
    c.convert('RGB').save(O + name + '.jpg', quality=93)


def full(name, img, tag, l1, l2, sub=None, ty=1150, cy=0.5, size=120, foot='Tovar  ·  Pueblo Llano'):
    c = fit_img(img if '/' in img else FR + img, W, H, cy).convert('RGBA')
    c.alpha_composite(base()); shade(c, ty - 120, ty + 470, 185); d = ImageDraw.Draw(c)
    y = ty
    if tag: pill(d, W / 2, y, tag, F('Mont900.ttf', 38)); y += 100
    tc(d, W / 2, y, l1, F('Anton.ttf', size), CR, 4, BK); y += int(size * 1.15)
    if l2: tc(d, W / 2, y, l2, F('Anton.ttf', size), OR, 4, BK); y += int(size * 1.15)
    if sub: tc(d, W / 2, y + 6, sub, F('Mont700.ttf', 40), CR, 2, BK)
    footer(c, txt=foot)
    c.convert('RGB').save(O + name + '.jpg', quality=93)


def grid(name):
    c = Image.new('RGBA', (W, H), BK + (255,))
    fs = ['alf_chev', 'alf_toyo', 'alf_fiat', 'alf_ford']
    for i, f in enumerate(fs):
        x = (i % 2) * 545; y = 430 + (i // 2) * 580
        c.paste(fit_img(FR + f + '.jpg', 535, 570, 0.55), (x, y))
    c.alpha_composite(base())
    d = ImageDraw.Draw(c)
    tc(d, W / 2, 262, '¿CUÁL ES LA TUYA?', F('Anton.ttf', 96), OR, 4, BK)
    tc(d, W / 2, 372, 'Alfombras tipo bandeja Scorpion', F('Mont900.ttf', 36), CR, 2, BK)
    for i, t in enumerate(['CHEVROLET', 'TOYOTA', 'FIAT', 'FORD']):
        x = (i % 2) * 545 + 267; y = 430 + (i // 2) * 580 + 490
        pill(d, x, y, t, F('Mont900.ttf', 34))
    footer(c)
    c.convert('RGB').save(O + name + '.jpg', quality=93)


import os; os.makedirs(O, exist_ok=True)
split('01_sab_1930_f250_amarilla_o_blanca', 'f250_antes.jpg', '/home/claude/scorpion/hf/A_frente.jpg', 'ANTES', 'DESPUÉS', '¿AMARILLA', 'O BLANCA?', 0.45, 0.6)
split('03_dom_1930_aveo_antes_despues', 'aveo_antes.jpg', '/home/claude/aveo/fr/a1_38.5.jpg', 'ANTES', 'DESPUÉS', '¿CON CUÁL', 'TE QUEDAS?', 0.5, 0.55)
full('04_lun_0730_abrimos_hoy', '/home/claude/alfombras/src/foto1.jpg', 'ABRIMOS HOY', 'TE ESPERAMOS', 'DE 8 AM A 6 PM', sub='Carrera 4ta, El Llano, Tovar', cy=0.3, size=112, foot='También en Pueblo Llano')
full('05_lun_1930_cargo_noche', 'cargo_noche.jpg', 'FORD CARGO 1721', 'ASÍ BRILLA', 'DE NOCHE', sub='Iluminación LED completa', ty=1120, size=130, foot='Sede Pueblo Llano  ·  También en Tovar')
grid('06_mar_0730_alfombras_cual_es_la_tuya')
print('ok')
