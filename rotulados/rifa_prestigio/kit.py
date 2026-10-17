"""Herramientas para simular rotulado en vinil sobre los vidrios del Fiesta.
Cada diseño se arma por 'capas de color' (máscaras L) para luego poder separarlas."""
import math, colorsys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops

F_SERIF = '/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf'
F_SERIF2 = '/usr/share/fonts/truetype/crosextra/Caladea-Bold.ttf'
F_SANS = '/usr/share/fonts/truetype/google-fonts/Poppins-Bold.ttf'
F_BLACK = '/usr/share/fonts/opentype/inter/InterDisplay-Black.otf'

GREEN = (26, 190, 122)      # vinil verde reflectivo (muestra de la foto del rollo)
WHITE = (246, 246, 242)
BLACK = (14, 14, 14)


def font(path, size):
    return ImageFont.truetype(path, int(size))


def text_mask(size, text, fpath, h, cx, cy, stroke=0, max_w=None, tracking=0, anchor='mm'):
    """Dibuja texto con altura de mayúsculas ~h centrado en (cx,cy). Devuelve máscara."""
    W, H = size
    f = font(fpath, h * 1.38)
    if max_w:
        while True:
            w = text_width(text, f, tracking)
            if w <= max_w or f.size < 8:
                break
            f = font(fpath, f.size * 0.96)
    m = Image.new('L', size, 0)
    d = ImageDraw.Draw(m)
    if tracking == 0:
        d.text((cx, cy), text, font=f, fill=255, anchor=anchor, stroke_width=stroke, stroke_fill=255)
    else:
        w = text_width(text, f, tracking)
        x = cx - w / 2 if anchor[0] == 'm' else cx
        for ch in text:
            d.text((x, cy), ch, font=f, fill=255, anchor='l' + anchor[1], stroke_width=stroke, stroke_fill=255)
            x += f.getlength(ch) + tracking
    return m


def text_width(text, f, tracking=0):
    return f.getlength(text) + tracking * max(len(text) - 1, 0)


def dilate(mask, px):
    if px <= 0:
        return mask
    k = int(px) * 2 + 1
    return mask.filter(ImageFilter.MaxFilter(min(k, 99))) if k <= 99 else mask.filter(ImageFilter.GaussianBlur(px)).point(lambda v: 255 if v > 20 else 0)


def grow(mask, px):
    """Contorno redondeado (offset) de px pixeles."""
    out = mask
    step = 7
    left = int(px)
    while left > 0:
        s = min(step, left)
        out = out.filter(ImageFilter.MaxFilter(s * 2 + 1 if s * 2 + 1 <= 15 else 15))
        left -= s
    return out.filter(ImageFilter.GaussianBlur(1.2)).point(lambda v: 255 if v > 110 else 0)


def sub(a, b):
    return ImageChops.subtract(a, b)


def add(*ms):
    out = ms[0]
    for m in ms[1:]:
        out = ImageChops.lighter(out, m)
    return out


def ellipse_poly(cx, cy, rx, ry, ang, n=24):
    ca, sa = math.cos(ang), math.sin(ang)
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        x, y = rx * math.cos(t), ry * math.sin(t)
        pts.append((cx + x * ca - y * sa, cy + x * sa + y * ca))
    return pts


def crown_masks(size, x0, y0, w, laurels=True):
    """Corona con $ calado en el centro y laureles. Devuelve (corona, laureles, dolar_hueco)."""
    h = w * 0.62
    cm = Image.new('L', size, 0)
    d = ImageDraw.Draw(cm)
    P = lambda u, v: (x0 + u * w, y0 + v * h)
    body = [P(.12, .80), P(.08, .30), P(.27, .52), P(.31, .16), P(.42, .46), P(.5, .04),
            P(.58, .46), P(.69, .16), P(.73, .52), P(.92, .30), P(.88, .80)]
    d.polygon(body, fill=255)
    d.rounded_rectangle([*P(.10, .78), *P(.90, .96)], radius=w * .03, fill=255)
    for (u, v) in [(.08, .30), (.31, .16), (.5, .04), (.69, .16), (.92, .30)]:
        cx, cy = P(u, v)
        r = w * .045
        d.ellipse([cx - r, cy - r * 1.6, cx + r, cy + r * 0.4], fill=255)
    # $ calado
    hole = Image.new('L', size, 0)
    hd = ImageDraw.Draw(hole)
    cx, cy = P(.5, .60)
    r = w * .145
    hd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
    dol = text_mask(size, '$', F_SANS, r * 1.15, cx, cy + r * .05)
    ring_in = Image.new('L', size, 0)
    ImageDraw.Draw(ring_in).ellipse([cx - r * .78, cy - r * .78, cx + r * .78, cy + r * .78], fill=255)
    # dentro del círculo: círculo calado y el $ sólido de nuevo
    crown = sub(cm, ring_in)
    crown = add(crown, sub(dol, Image.new('L', size, 0)))
    lm = Image.new('L', size, 0)
    if laurels:
        ld = ImageDraw.Draw(lm)
        for side in (-1, 1):
            # arco de hojas bajo/al lado de la corona
            cxa, cya = P(.5, .55)
            R = w * .62
            for i in range(6):
                t = math.radians(200 - i * 13) if side < 0 else math.radians(-20 + i * 13)
                lx = cxa + R * math.cos(t) * 1.0
                ly = cya - R * math.sin(t) * 0.55 * -1
                ang = t + (math.pi / 2 if side < 0 else math.pi / 2)
                ld.polygon(ellipse_poly(lx, ly, w * .06, w * .022, ang - side * 0.5), fill=255)
            # tallo
            pts = []
            for k in range(30):
                t = math.radians(200 - k * 2.6) if side < 0 else math.radians(-20 + k * 2.6)
                pts.append((cxa + R * .93 * math.cos(t), cya + R * .93 * 0.55 * math.sin(t) * -1 * -1))
            ld.line(pts, fill=255, width=max(2, int(w * .012)))
        lm = sub(lm, cm)
    return crown, lm, sub(ring_in, dol)


def holo(size, seed=0):
    """Textura tornasol (holográfica)."""
    W, H = size
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    t = (xx / 260.0 + yy / 420.0 + 0.35 * np.sin(xx / 90.0 + yy / 140.0 + seed))
    hue = (t * 0.55 + 0.45) % 1.0
    rgb = np.zeros((H, W, 3), np.float32)
    hsv_to = np.vectorize(colorsys.hsv_to_rgb, otypes=[float, float, float])
    # vectorizado manual
    h6 = hue * 6.0
    i = np.floor(h6).astype(int) % 6
    f = h6 - np.floor(h6)
    s, v = 0.42, 0.98
    p = v * (1 - s); q = v * (1 - s * f); tt = v * (1 - s * (1 - f))
    r = np.choose(i, [v, q, p, p, tt, v]); g = np.choose(i, [tt, v, v, q, p, p]); b = np.choose(i, [p, p, tt, v, v, q])
    rgb = np.stack([r * np.ones_like(f), g * np.ones_like(f), b * np.ones_like(f)], -1)
    shine = 0.18 * np.sin(xx / 40.0 + yy / 70.0) ** 8
    rgb = np.clip(rgb + shine[..., None], 0, 1)
    return Image.fromarray((rgb * 255).astype(np.uint8), 'RGB')


def solid(size, color):
    return Image.new('RGB', size, color)


def compose(size, layers):
    """layers: lista de (mascara, color|'holo') en orden de abajo hacia arriba. Devuelve RGBA."""
    out = Image.new('RGBA', size, (0, 0, 0, 0))
    hol = None
    for m, c in layers:
        if c == 'holo':
            hol = hol or holo(size)
            fill = hol
        elif c == 'green':
            fill = green_tex(size)
        else:
            fill = solid(size, c)
        lay = fill.convert('RGBA')
        lay.putalpha(m)
        out = Image.alpha_composite(out, lay)
    return out


def green_tex(size):
    W, H = size
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    base = np.array(GREEN, np.float32)[None, None, :]
    k = 1 + 0.10 * np.sin(xx / W * 3.1 + yy / H * 1.7) + 0.06 * np.sin(xx / W * 17 - yy / H * 6) ** 6
    return Image.fromarray(np.clip(base * k[..., None], 0, 255).astype(np.uint8), 'RGB')


def apply_on_photo(photo, design, box, clip_poly=None, opacity=0.93):
    """Pega design (RGBA) escalado al rectángulo box=(x0,y0,x1,y1) del photo, recortado al vidrio."""
    x0, y0, x1, y1 = [int(v) for v in box]
    d = design.resize((x1 - x0, y1 - y0), Image.LANCZOS)
    full = Image.new('RGBA', photo.size, (0, 0, 0, 0))
    full.paste(d, (x0, y0))
    a = full.getchannel('A')
    if clip_poly:
        cm = Image.new('L', photo.size, 0)
        ImageDraw.Draw(cm).polygon(clip_poly, fill=255)
        cm = cm.filter(ImageFilter.GaussianBlur(1.5))
        a = ImageChops.multiply(a, cm)
    a = a.point(lambda v: int(v * opacity))
    # leve reflejo del vidrio por encima del vinil
    base = photo.convert('RGB')
    vin = full.convert('RGB')
    refl = Image.blend(vin, ImageChops.screen(vin, base.point(lambda v: max(0, v - 70))), 0.55)
    return Image.composite(refl, base, a)
