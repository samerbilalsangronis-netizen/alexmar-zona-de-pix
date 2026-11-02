"""PRÓXIMAMENTE — foto real de la obra (pared abierta) con juego de luz: tienda en penumbra,
luz cálida saliendo del hueco con rayos volumétricos y el obrero a contraluz.
Uso: python proximamente.py <foto> <dir_plantillas> <dir_salida> [intensidad_rayos]"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

SRC, P, O = sys.argv[1:4]
RAYK = float(sys.argv[4]) if len(sys.argv) > 4 else 1.0
F = f"{P}/fonts"; ANTON = f"{F}/Anton.ttf"; VF = f"{F}/Montserrat-VF.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); BLACK = (26, 26, 26)
LOGO = Image.open(f"{P}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
CX, CY = 985, 1060          # centro del hueco (coords de la foto original 1659x2212)


def mont(size, weight):
    f = ImageFont.truetype(VF, size); f.set_variation_by_name(weight); return f


def relight(src, rayk=1.0):
    im = np.asarray(Image.open(src).convert("RGB")).astype(np.float32) / 255
    H, W, _ = im.shape
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    lum = im @ np.array([0.299, 0.587, 0.114], np.float32)
    # máscara del hueco: zona brillante dentro de la abertura
    box = np.zeros((H, W), np.float32); box[835:1420, 868:1105] = 1
    box = np.asarray(Image.fromarray((box * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(18))) / 255
    hole = np.clip((lum - 0.55) / 0.3, 0, 1) * box
    # luz ambiente: penumbra con caída suave alrededor del hueco
    d2 = ((xx - CX) / 1.0) ** 2 + ((yy - CY) / 1.25) ** 2
    amb = 0.15 + 0.60 * np.exp(-d2 / (2 * 520 ** 2))
    base = im ** 1.15 * amb[..., None]
    # tono: sombras neutras/frías, medios cálidos
    warm = np.array([1.10, 0.93, 0.78], np.float32)
    base = base * (warm * amb[..., None] / 0.75 + (1 - amb[..., None] / 0.75))
    # hueco: luz dorada intensa
    glow_col = np.array([1.0, 0.80, 0.55], np.float32)
    holev = np.clip(im * 1.15, 0, 1) * glow_col + 0.15
    out = base * (1 - hole[..., None]) + holev * hole[..., None]
    # rayos volumétricos (zoom blur radial de la máscara del hueco), a escala 1/4
    s = 4; h4, w4 = H // s, W // s
    src4 = Image.fromarray((hole * 255).astype(np.uint8)).resize((w4, h4), Image.BILINEAR)
    acc = np.zeros((h4, w4), np.float32); n = 48
    for i in range(n):
        k = 1 + 2.4 * i / n
        ww, hh = int(w4 * k), int(h4 * k)
        z = np.asarray(src4.resize((ww, hh), Image.BILINEAR), np.float32) / 255
        ox, oy = int(CX / s * k - CX / s), int(CY / s * k - CY / s)
        acc += z[oy:oy + h4, ox:ox + w4] * (1 - i / n) ** 1.3
    acc /= acc.max()
    rays = np.asarray(Image.fromarray((acc * 255).astype(np.uint8)).resize((W, H), Image.BICUBIC)
                      .filter(ImageFilter.GaussianBlur(6)), np.float32) / 255
    rays = rays ** 1.4 * 0.75 * rayk
    ray_col = np.array([1.0, 0.68, 0.42], np.float32)
    out = 1 - (1 - out) * (1 - rays[..., None] * ray_col)          # screen
    # bloom general del hueco
    bl = np.asarray(Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8))
                    .filter(ImageFilter.GaussianBlur(60)), np.float32) / 255
    bl = np.clip(bl - 0.45, 0, 1) * 0.9
    out = 1 - (1 - out) * (1 - bl)
    # polvo flotando en la luz
    rng = np.random.default_rng(7); dust = np.zeros((H, W), np.float32)
    for _ in range(900):
        x, y = rng.integers(0, W), rng.integers(0, H)
        dust[y, x] = rng.uniform(0.4, 1)
    dust = np.asarray(Image.fromarray((dust * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.6)), np.float32) / 255 * 6
    out = out + (dust * rays * 1.2)[..., None] * ray_col
    return Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8))


def shadow(im, blur=14, op=200, off=(0, 5)):
    pad = blur * 3; b = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); k = Image.new("RGBA", im.size, (0, 0, 0, 255)); k.putalpha(a)
    s = Image.new("RGBA", b.size, (0, 0, 0, 0)); s.paste(k, (pad + off[0], pad + off[1]), k)
    s = s.filter(ImageFilter.GaussianBlur(blur)); b.alpha_composite(s); b.alpha_composite(im, (pad, pad)); return b, pad


def put(cv, x, y, s, font, fill, sp=0, anchor="c", op=200, blur=14, glow=None):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 60, int(font.size * 1.8)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 30
    for c in s: ld.text((xx, 14), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, blur, op)
    if glow:  # resplandor naranja detrás del texto
        g = Image.new("RGBA", lay.size, glow + (0,)); g.putalpha(lay.split()[3].filter(ImageFilter.GaussianBlur(26)).point(lambda v: min(255, v * 2)))
        gl = Image.new("RGBA", lay.size, (0, 0, 0, 0)); gl.alpha_composite(g); gl.alpha_composite(lay); lay = gl
    X = x - lay.width // 2 if anchor == "c" else (x - p if anchor == "l" else x - lay.width + p)
    cv.alpha_composite(lay, (int(X), int(y - p))); return y + lay.height - 2 * p, lay.width - 2 * p


def grad(cv, y0, y1, a0, a1, col=(10, 10, 10)):
    W, H = cv.size; g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
    for y in range(y0, y1):
        t = (y - y0) / max(1, y1 - y0 - 1); d.line((0, y, W, y), fill=col + (int(a0 + (a1 - a0) * t),))
    cv.alpha_composite(g)


def frame(lit, W, H, story=False, tk=1.0):
    """tk: opacidad del bloque de título (para animar)."""
    # recorte centrado en el hueco
    s = max(W / lit.width, H / lit.height)
    bg = lit.resize((round(lit.width * s), round(lit.height * s)), Image.LANCZOS)
    cx = int(CX * s); x0 = min(max(0, cx - W // 2 - (40 if story else 0)), bg.width - W)
    cy = int(CY * s); y0 = min(max(0, cy - int(H * (0.43 if not story else 0.45))), bg.height - H)
    cv = bg.crop((x0, y0, x0 + W, y0 + H)).convert("RGBA")
    k = 1.0 if not story else 1.1
    bar_t = int(178 * k) + (90 if story else 0); bar_b = int(170 * k) + (110 if story else 0)
    grad(cv, bar_t, bar_t + 160, 225, 0); grad(cv, int(H * 0.56), H - bar_b, 0, 215)
    dr = ImageDraw.Draw(cv)
    # barra superior: logo grande + ALEXMAR + Autoperiquitos y Rotulados
    dr.rectangle((0, 0, W, bar_t), fill=BLACK + (238,)); dr.rectangle((0, bar_t, W, bar_t + 5), fill=TERRA + (255,))
    lh = int(150 * k); lg = LOGO.resize((int(LOGO.width * lh / LOGO.height), lh), Image.LANCZOS)
    top = (bar_t - lh) // 2 + (45 if story else 0)
    tw = ImageDraw.Draw(cv).textlength("ALEXMAR", font=ImageFont.truetype(ANTON, int(104 * k))) + 6 * 7
    bx = int((W - (lg.width + 28 + tw)) // 2)
    lgs, p = shadow(lg, 8, 160); cv.alpha_composite(lgs, (bx - p, top - p))
    xt = bx + lg.width + 28
    put(cv, xt, top + int(6 * k), "ALEXMAR", ImageFont.truetype(ANTON, int(104 * k)), TERRA, sp=6, anchor="l", op=0)
    put(cv, xt + 4, top + int(118 * k), "AUTOPERIQUITOS Y ROTULADOS", mont(int(22 * k), "Bold"), CREAM, sp=3, anchor="l", op=0)
    # barra inferior: teléfono grande
    yb0 = H - bar_b
    dr = ImageDraw.Draw(cv); dr.rectangle((0, yb0, W, H), fill=BLACK + (238,)); dr.rectangle((0, yb0 - 5, W, yb0), fill=TERRA + (255,))
    yb = yb0 + int(22 * k)
    yb, _ = put(cv, W // 2, yb, "0416-676 83 93", ImageFont.truetype(ANTON, int(88 * k)), CREAM, sp=3, op=0)
    put(cv, W // 2, yb + int(14 * k), "Tovar  ·  Pueblo Llano  ·  @autoalexmar_car", mont(int(25 * k), "SemiBold"), LIGHT, sp=1, op=0)
    # título
    if tk > 0:
        t = Image.new("RGBA", cv.size, (0, 0, 0, 0))
        yt = yb0 - int(330 * k) - (40 if story else 0)
        y, _ = put(t, W // 2, yt, "ESTAMOS  CRECIENDO", mont(int(30 * k), "ExtraBold"), LIGHT, sp=8, op=230, blur=10)
        y += int(14 * k); ImageDraw.Draw(t).rectangle((W // 2 - 45, y, W // 2 + 45, y + 5), fill=TERRA + (255,)); y += int(22 * k)
        fs = int(168 * k)
        while ImageDraw.Draw(t).textlength("PRÓXIMAMENTE", font=ImageFont.truetype(ANTON, fs)) + 44 > W - 90: fs -= 2
        y, _ = put(t, W // 2, y, "PRÓXIMAMENTE", ImageFont.truetype(ANTON, fs), CREAM, sp=4, op=240, blur=18, glow=TERRA)
        y += int(18 * k)
        put(t, W // 2, y, "Algo nuevo se está abriendo en ALEXMAR", mont(int(34 * k), "SemiBold"), CREAM, op=235, blur=10)
        if tk < 1: t.putalpha(t.split()[3].point(lambda v: int(v * tk)))
        cv.alpha_composite(t)
    # marca de agua diagonal
    wm = Image.new("RGBA", (1500, 420), (0, 0, 0, 0))
    ImageDraw.Draw(wm).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 16))
    wm = wm.rotate(55, expand=True, resample=Image.BICUBIC); cv.alpha_composite(wm, ((W - wm.width) // 2, (H - wm.height) // 2))
    return cv.convert("RGB")


if __name__ == "__main__":
    lit = relight(SRC, RAYK); lit.save(f"{O}/foto_iluminada.jpg", quality=93)
    frame(lit, 1080, 1350).save(f"{O}/alexmar_proximamente_post.jpg", quality=95)
    frame(lit, 1080, 1920, story=True).save(f"{O}/alexmar_proximamente_historia.jpg", quality=95)
    print("ok")
