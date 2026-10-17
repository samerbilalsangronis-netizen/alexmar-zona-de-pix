"""Publicidad exploradoras Ford Fiesta Max 2008-2010 · post 1080x1350 + historia 1080x1920 (solo imagen)."""
from PIL import Image, ImageDraw, ImageFilter
import numpy as np, os
HERE = os.path.dirname(os.path.abspath(__file__)) + '/'
SRC = open('/home/claude/alexmar-zona-de-pix/plantillas/overlays_reel.py').read().split("card('01'")[0]


def make(Wt, Ht, out, layout):
    g = {}
    exec(SRC.replace('W, H = 1080, 1920', f'W, H = {Wt}, {Ht}'), g)
    W, H, F, OR, ORL, BK, CR = g['W'], g['H'], g['F'], g['OR'], g['ORL'], g['BK'], g['CR']
    tc, pill, base = g['tc'], g['pill'], g['base']

    # fondo: carbón con resplandor naranja detrás del producto
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    cy = layout['lamp_y'] + layout['lamp_h'] * 0.45
    r = np.sqrt((xx - W / 2) ** 2 + ((yy - cy) * 1.25) ** 2)
    glow = np.clip(1 - r / (W * 0.62), 0, 1) ** 1.7
    bgc = np.array([30, 28, 27], np.float32)
    orc = np.array([217, 119, 87], np.float32)
    img = bgc[None, None] * (1 - glow[..., None] * 0.9) + orc[None, None] * glow[..., None] * 0.55
    vig = np.clip(1 - (np.sqrt((xx - W / 2) ** 2 + (yy - H / 2) ** 2) / (H * 0.75)) ** 2 * 0.5, 0.45, 1)
    img = img * vig[..., None]
    c = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), 'RGB').convert('RGBA')

    # haces de luz suaves (exploradoras encendidas)
    beams = Image.new('L', (W, H), 0)
    d = ImageDraw.Draw(beams)
    for side in (-1, 1):
        x0 = W / 2 + side * W * 0.22
        y0 = layout['lamp_y'] + layout['lamp_h'] * 0.42
        d.polygon([(x0, y0), (x0 + side * W * 0.9, y0 - H * 0.12), (x0 + side * W * 0.9, y0 + H * 0.22)], fill=60)
    beams = beams.filter(ImageFilter.GaussianBlur(60))
    light = Image.new('RGBA', (W, H), (255, 236, 200, 0)); light.putalpha(beams)
    c.alpha_composite(light)

    # piso: línea de reflejo
    fy = layout['lamp_y'] + layout['lamp_h']
    floor = Image.new('L', (W, H), 0)
    ImageDraw.Draw(floor).ellipse([W * 0.08, fy - 28, W * 0.92, fy + 40], fill=120)
    floor = floor.filter(ImageFilter.GaussianBlur(22))
    sh = Image.new('RGBA', (W, H), (0, 0, 0, 0)); sh.putalpha(floor); c.alpha_composite(sh)

    # exploradoras completas, par izquierda/derecha
    L = Image.open(HERE + 'exploradora_izq.png'); R = Image.open(HERE + 'exploradora_der.png')
    s = layout['lamp_h'] / L.height
    L = L.resize((int(L.width * s), int(L.height * s)), Image.LANCZOS)
    R = R.resize((int(R.width * s), int(R.height * s)), Image.LANCZOS)
    gap = layout.get('gap', 10)
    x0 = (W - (L.width + R.width + gap)) // 2
    from PIL import ImageEnhance
    def lift(im):
        a = im.getchannel('A'); im2 = ImageEnhance.Brightness(im.convert('RGB')).enhance(1.18).convert('RGBA'); im2.putalpha(a); return im2
    L, R = lift(L), lift(R)
    # resplandor cálido detrás de cada lente
    for cxr, im, x in ((0.43, L, x0), (0.57, R, x0 + L.width + gap)):
        gl = Image.new('L', (W, H), 0)
        lx, ly, rr = x + im.width * cxr, layout['lamp_y'] + im.height * 0.44, im.width * 0.42
        ImageDraw.Draw(gl).ellipse([lx - rr, ly - rr, lx + rr, ly + rr], fill=150)
        gl = gl.filter(ImageFilter.GaussianBlur(45))
        lt = Image.new('RGBA', (W, H), (255, 214, 160, 0)); lt.putalpha(gl); c.alpha_composite(lt)
    for im, x in ((L, x0), (R, x0 + L.width + gap)):
        # reflejo en el piso
        ref = im.transpose(Image.FLIP_TOP_BOTTOM).crop((0, 0, im.width, int(im.height * 0.35)))
        a = ref.getchannel('A')
        grad = Image.linear_gradient('L').resize(ref.size).point(lambda v: int((255 - v) * 0.28))
        ref.putalpha(Image.composite(grad, Image.new('L', ref.size, 0), a))
        c.alpha_composite(ref, (x, layout['lamp_y'] + im.height))
        c.alpha_composite(im, (x, layout['lamp_y']))

    c.alpha_composite(base(top_shade=True))
    d = ImageDraw.Draw(c)
    y = layout['hook_y']
    tc(d, W / 2, y, '¿NEBLINA EN LA VÍA?', F('Anton.ttf', layout['hook_size']), CR, 4, BK)
    tc(d, W / 2, y + int(layout['hook_size'] * 1.12), 'ALUMBRA TU CAMINO', F('Anton.ttf', layout['hook_size']), OR, 4, BK)
    pill(d, W / 2, layout['tag_y'], 'EXPLORADORAS FORD FIESTA MAX', F('Mont900.ttf', layout['tag_size']), fill=OR)
    tc(d, W / 2, layout['tag_y'] + layout['tag_size'] + 46, '2008  ·  2009  ·  2010', F('Mont900.ttf', int(layout['tag_size'] * 0.95)), CR, 2, BK)

    # chips de beneficios
    chips = ['JUEGO X2', 'SOMOS INSTALADORES', 'ENVÍOS A TODO EL PAÍS']
    fch = F('Mont900.ttf', layout['chip_size'])
    widths = [d.textlength(t, font=fch) + 48 for t in chips]
    total = sum(widths) + 16 * (len(chips) - 1)
    if total > W - 60:
        # en dos filas
        rows = [chips[:2], chips[2:]]
    else:
        rows = [chips]
    cy0 = layout['chip_y']
    for ri, row in enumerate(rows):
        ws = [d.textlength(t, font=fch) + 48 for t in row]
        x = (W - (sum(ws) + 16 * (len(row) - 1))) / 2
        for t, w in zip(row, ws):
            h = layout['chip_size'] + 30
            yy0 = cy0 + ri * (h + 14)
            d.rounded_rectangle((x, yy0, x + w, yy0 + h), radius=h // 2, fill=BK + (230,), outline=ORL, width=3)
            bb = fch.getbbox(t)
            d.text((x + 24, yy0 + (h - (bb[3] - bb[1])) / 2 - bb[1]), t, font=fch, fill=CR)
            x += w + 16

    # cierre: llamado a la acción
    fy2 = layout['foot_y']
    fp = F('Anton.ttf', layout['phone_size']); ph = 'ESCRÍBENOS  0416-676 83 93'
    pw = d.textlength(ph, font=fp)
    d.rounded_rectangle(((W - pw) / 2 - 40, fy2, (W + pw) / 2 + 40, fy2 + layout['phone_size'] + 34), radius=46, fill=OR)
    tc(d, W / 2, fy2 + 8, ph, fp, BK)
    tc(d, W / 2, fy2 + layout['phone_size'] + 52, 'Autoperiquitos y Rotulados ALEXMAR  ·  Tovar  ·  Pueblo Llano', F('Mont700.ttf', layout['foot_size']), CR, 2, BK)
    c.convert('RGB').save(HERE + out, quality=93)
    print(out)


make(1080, 1350, 'exploradoras_fiesta_max_post_1080x1350.jpg',
     dict(hook_y=270, hook_size=92, tag_y=500, tag_size=34, lamp_y=640, lamp_h=400, gap=20,
          chip_y=1088, chip_size=23, foot_y=1185, phone_size=54, foot_size=24))
make(1080, 1920, 'exploradoras_fiesta_max_historia_1080x1920.jpg',
     dict(hook_y=330, hook_size=112, tag_y=620, tag_size=38, lamp_y=850, lamp_h=470, gap=10,
          chip_y=1440, chip_size=32, foot_y=1650, phone_size=60, foot_size=28))
