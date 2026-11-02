"""'Normalicemos contarle a Dios primero' sobre la foto del escritorio (sede ALEXMAR).
Edición tipo fotógrafo: recuperación de altas luces, sombras, balance cálido, claridad,
desenfoque de fondo (profundidad de campo) y viñeta. Frase en letra manuscrita.
Uso: python contarle_a_dios.py <foto> <dir_plantillas> <dir_salida>"""
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

SRC, P, O = sys.argv[1:4]
F = f"{P}/fonts"; HAND = f"{F}/RockSalt-Regular.ttf"; ANTON = f"{F}/Anton.ttf"; VF = f"{F}/Montserrat-VF.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
LOGO = Image.open(f"{P}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
LINES = ["NORMALICEMOS", "CONTARLE A", "DIOS", "PRIMERO"]


def mont(size, weight):
    f = ImageFont.truetype(VF, size); f.set_variation_by_name(weight); return f


def to_np(im): return np.asarray(im, np.float32) / 255
def to_im(a): return Image.fromarray((np.clip(a, 0, 1) * 255).astype(np.uint8))


def develop(src):
    im = Image.open(src).convert("RGB"); a = to_np(im); H, W, _ = a.shape
    lum = a @ np.array([0.299, 0.587, 0.114], np.float32)
    # 1) altas luces (ventana y tragaluz quemados) y sombras
    hl = np.clip((lum - 0.62) / 0.38, 0, 1) ** 1.3
    a = a * (1 - 0.30 * hl[..., None])
    sh = np.clip(1 - lum / 0.35, 0, 1)
    a = a + 0.10 * sh[..., None] * (1 - a)
    # 2) balance: un toque cálido, sombras neutras
    a = a * np.array([1.035, 1.0, 0.95], np.float32)
    # 3) curva S suave
    a = np.clip(a, 0, 1); a = a + 0.10 * (a - 0.5) * (1 - np.abs(2 * a - 1)) * 2
    # 4) vibrance
    m = a.mean(axis=2, keepdims=True); sat = np.abs(a - m).max(axis=2, keepdims=True)
    a = m + (a - m) * (1 + 0.22 * (1 - np.clip(sat * 3, 0, 1)))
    out = to_im(a)
    # 5) claridad (contraste local) + nitidez
    out = out.filter(ImageFilter.UnsharpMask(radius=40, percent=22, threshold=0))
    out = out.filter(ImageFilter.UnsharpMask(radius=1.6, percent=70, threshold=2))
    # 6) profundidad de campo: fondo de la tienda desenfocado, escritorio nítido
    bg = out.filter(ImageFilter.GaussianBlur(7))
    yy = np.arange(H, dtype=np.float32)[:, None]
    mask = np.clip((640 - yy) / 230, 0, 1) ** 1.2 * np.ones((1, W), np.float32)
    a = to_np(out) * (1 - mask[..., None]) + to_np(bg) * mask[..., None]
    # 7) viñeta
    xx = np.linspace(-1, 1, W)[None, :]; y2 = np.linspace(-1, 1, H)[:, None]
    v = 1 - 0.30 * np.clip(np.sqrt(xx ** 2 * 0.8 + y2 ** 2) - 0.45, 0, 1) ** 1.6
    a = a * v[..., None]
    # 8) grano fino de película
    a = a + np.random.default_rng(1).normal(0, 0.008, a.shape).astype(np.float32)
    return to_im(a)


def shadow(im, blur=14, op=200, off=(0, 4)):
    pad = blur * 3; b = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); k = Image.new("RGBA", im.size, (0, 0, 0, 255)); k.putalpha(a)
    s = Image.new("RGBA", b.size, (0, 0, 0, 0)); s.paste(k, (pad + off[0], pad + off[1]), k)
    s = s.filter(ImageFilter.GaussianBlur(blur)); b.alpha_composite(s); b.alpha_composite(im, (pad, pad)); return b, pad


def put(cv, x, y, s, font, fill, sp=0, op=200, blur=14, anchor="c"):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 80, int(font.size * 2.4)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 40
    for c in s: ld.text((xx, font.size // 2), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, blur, op)
    X = x - lay.width // 2 if anchor == "c" else x - p
    cv.alpha_composite(lay, (int(X), int(y - p))); return y + lay.height - 2 * p, lay.width - 2 * p


def piece(photo, W, H, cx, out, story=False):
    # foto COMPLETA a lo ancho (se ve toda la tienda); arriba/abajo se extiende el fondo desenfocado
    ph = photo.resize((W, round(photo.height * W / photo.width)), Image.LANCZOS).convert("RGBA")
    py = H - ph.height
    cv = Image.new("RGBA", (W, H), (0, 0, 0, 255))
    if py > 0:  # extensión superior: franja de arriba estirada y muy desenfocada
        ext = ph.crop((0, 0, W, 220)).resize((W, py + 260), Image.BICUBIC).filter(ImageFilter.GaussianBlur(26))
        cv.alpha_composite(ext, (0, 0))
    yb = py + ph.height
    if yb < H:  # extensión inferior (historia)
        ext = ph.crop((0, ph.height - 160, W, ph.height)).resize((W, H - yb + 200), Image.BICUBIC).filter(ImageFilter.GaussianBlur(26))
        cv.alpha_composite(ext, (0, yb - 200))
    m = Image.new("L", ph.size, 255); dm = ImageDraw.Draw(m)
    for i in range(140):
        a = int(255 * (i / 140) ** 1.2)
        if py > 0: dm.line((0, i, W, i), fill=a)
        if yb < H: dm.line((0, ph.height - 1 - i, W, ph.height - 1 - i), fill=min(a, 255))
    ph.putalpha(m); cv.alpha_composite(ph, (0, py))
    # sombra suave arriba para la frase, y abajo para la marca
    g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g)
    top = int(H * (0.50 if not story else 0.40))
    for y in range(top): d.line((0, y, W, y), fill=(0, 0, 0, int(120 * (1 - y / top) ** 1.4)))
    b0 = int(H * 0.86)
    for y in range(b0, H): d.line((0, y, W, y), fill=(0, 0, 0, int(190 * ((y - b0) / (H - b0)) ** 1.2)))
    cv.alpha_composite(g)
    # frase manuscrita
    k = 1.0 if not story else 1.08
    sizes = [60, 60, 76, 76]; y = int(H * (0.06 if not story else 0.16)); rot = [-2.2, 1.4, -1.0, 1.8]
    for ln, sz, r in zip(LINES, sizes, rot):
        f = ImageFont.truetype(HAND, int(sz * k))
        lay = Image.new("RGBA", (W, int(sz * k * 2.6)), (0, 0, 0, 0)); put(lay, W // 2, int(sz * k * 0.5), ln, f, CREAM, sp=2, op=210, blur=16)
        lay = lay.rotate(r, resample=Image.BICUBIC, center=(W // 2, lay.height // 2)); cv.alpha_composite(lay, (0, y))
        y += int(sz * k * 1.5)
    # marca discreta abajo: logo + ALEXMAR + @ + teléfono
    lh = 92 if not story else 110; lg = LOGO.resize((int(LOGO.width * lh / LOGO.height), lh), Image.LANCZOS)
    by = H - lh - (34 if not story else 60); lgs, p = shadow(lg, 8, 170); cv.alpha_composite(lgs, (40 - p, by - p))
    xt = 40 + lg.width + 20
    put(cv, xt, by + 4, "ALEXMAR", ImageFont.truetype(ANTON, 54 if not story else 62), TERRA, sp=3, op=200, blur=8, anchor="l")
    put(cv, xt + 2, by + (66 if not story else 76), "@autoalexmar_car  ·  0416-676 83 93", mont(24 if not story else 27, "SemiBold"), CREAM, op=220, blur=6, anchor="l")
    # marca de agua muy sutil
    wm = Image.new("RGBA", (1500, 420), (0, 0, 0, 0))
    ImageDraw.Draw(wm).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 9))
    wm = wm.rotate(55, expand=True, resample=Image.BICUBIC); cv.alpha_composite(wm, ((W - wm.width) // 2, (H - wm.height) // 2))
    cv.convert("RGB").save(f"{O}/{out}", quality=95)


if __name__ == "__main__":
    ph = develop(SRC); ph.save(f"{O}/foto_editada_completa.jpg", quality=95)
    piece(ph, 1080, 1350, 1390, "alexmar_contarle_a_dios_post.jpg")
    piece(ph, 1080, 1920, 1300, "alexmar_contarle_a_dios_historia.jpg", story=True)
    print("ok")
