"""Comercial estilo Ford — espejos ORIGINALES Super Duty, cromados con luz.
Imagen completa (sin barras), color de cine, destello de luz sobre el cromado, tipografía limpia, logo ALEXMAR grande.
1080x1920, sin audio. Uso: python build_comercial.py <dir_clips v1,v2,f1..f6> <salida.mp4>"""
import os, sys, subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter
SRC, OUT = sys.argv[1], sys.argv[2]
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; VF = f"{R}/fonts/Montserrat-VF.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
W, H = 1080, 1920
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
TMP = os.path.join(SRC, "_com"); os.makedirs(TMP, exist_ok=True)
FPS = 30


def mont(size, w):
    f = ImageFont.truetype(VF, size); f.set_variation_by_name(w); return f


def shadow(im, blur=12, op=200, off=(0, 4)):
    pad = blur * 3; b = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); k = Image.new("RGBA", im.size, (0, 0, 0, 255)); k.putalpha(a)
    s = Image.new("RGBA", b.size, (0, 0, 0, 0)); s.paste(k, (pad + off[0], pad + off[1]), k)
    s = s.filter(ImageFilter.GaussianBlur(blur)); b.alpha_composite(s); b.alpha_composite(im, (pad, pad)); return b, pad


def text(cv, cx, y, s, font, fill, sp=0, op=210, blur=12):
    d = ImageDraw.Draw(cv); w = sum(d.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 60, int(font.size * 1.8)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); x = 30
    for c in s: ld.text((x, 12), c, font=font, fill=fill + (255,)); x += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, blur, op)
    cv.alpha_composite(lay, (int(cx - lay.width // 2), int(y - p))); return y + lay.height - 2 * p


def blank(): return Image.new("RGBA", (W, H), (0, 0, 0, 0))


# --- títulos (estilo comercial: kicker fino espaciado + título ancho + línea) ---
def title(name, kicker, big, sub=None, y=1380):
    cv = blank(); g = ImageDraw.Draw(cv)
    for yy in range(y - 260, H):                      # sombra inferior para leer
        t = min(1, (yy - (y - 260)) / 300); g.line((0, yy, W, yy), fill=(0, 0, 0, int(160 * t)))
    yy = text(cv, W // 2, y, kicker, mont(30, "Medium"), CREAM, sp=16, op=200, blur=8) + 26
    g = ImageDraw.Draw(cv); g.rectangle((W // 2 - 70, yy, W // 2 + 70, yy + 3), fill=TERRA + (255,)); yy += 30
    f = mont(84, "ExtraBold")
    while g.textlength(big, font=f) + 10 * len(big) > W - 120: f = mont(f.size - 4, "ExtraBold")
    yy = text(cv, W // 2, yy, big, f, CREAM, sp=10, op=230, blur=16) + 18
    if sub: text(cv, W // 2, yy, sub, mont(34, "SemiBold"), LIGHT, sp=6, op=220, blur=8)
    cv.save(f"{TMP}/{name}.png")


title("t1", "FORD  SUPER  DUTY", "ESPEJOS ORIGINALES")
title("t2", "ACABADO", "CROMADO")
title("t3", "CON  LUZ  INCORPORADA", "VISIBILIDAD TOTAL")
title("t4", "EL  JUEGO  COMPLETO", "ORIGINAL SUPER DUTY", "Ya disponibles en ALEXMAR")

# --- marca fija: logo GRANDE arriba + teléfono abajo (sin marco) ---
cv = blank(); g = ImageDraw.Draw(cv)
for yy in range(0, 380): g.line((0, yy, W, yy), fill=(0, 0, 0, int(90 * (1 - yy / 380) ** 1.5)))
lw = 380; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lgs, p = shadow(lg, 16, 220)
cv.alpha_composite(lgs, ((W - lg.width) // 2 - p, 70 - p))
wm = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(wm).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 13))
wm = wm.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(wm, ((W - wm.width) // 2, (H - wm.height) // 2))
text(cv, W // 2, H - 112, "0416-676 83 93  ·  @autoalexmar_car", mont(30, "Bold"), CREAM, sp=3, op=230, blur=8)
cv.save(f"{TMP}/brand.png")

# --- destello de luz (barrido diagonal sobre el cromado) ---
st = Image.new("L", (900, 2600), 0); ImageDraw.Draw(st).rectangle((390, 0, 510, 2600), fill=255)
st = st.filter(ImageFilter.GaussianBlur(70)); core = Image.new("L", st.size, 0)
ImageDraw.Draw(core).rectangle((440, 0, 460, 2600), fill=255); core = core.filter(ImageFilter.GaussianBlur(10))
st = Image.eval(Image.merge("L", [st]), lambda v: v)
streak = Image.new("RGBA", st.size, (255, 240, 225, 0)); a = Image.eval(st, lambda v: int(v * 0.55))
a = Image.fromarray(__import__("numpy").maximum(__import__("numpy").asarray(a), __import__("numpy").asarray(core) * 0.9).astype("uint8"))
streak.putalpha(a); streak = streak.rotate(-22, expand=True, resample=Image.BICUBIC); streak.save(f"{TMP}/streak.png")

# --- cierre ---
cv = Image.new("RGBA", (W, H), (8, 8, 8, 255)); g = ImageDraw.Draw(cv)
glow = Image.new("RGBA", (W, H), (0, 0, 0, 0)); ImageDraw.Draw(glow).ellipse((90, 250, 990, 1150), fill=TERRA + (70,))
cv.alpha_composite(glow.filter(ImageFilter.GaussianBlur(140)))
lw = 700; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lgs, p = shadow(lg, 22, 230)
cv.alpha_composite(lgs, ((W - lg.width) // 2 - p, 260 - p)); y = 260 + lg.height + 60
y = text(cv, W // 2, y, "AUTOPERIQUITOS  Y  ROTULADOS", mont(34, "Medium"), CREAM, sp=12) + 16
y = text(cv, W // 2, y, "ALEXMAR", ImageFont.truetype(ANTON, 210), TERRA, sp=14) + 36
ImageDraw.Draw(cv).rectangle((W // 2 - 90, y, W // 2 + 90, y + 3), fill=LIGHT + (255,)); y += 44
y = text(cv, W // 2, y, "0416-676 83 93", mont(96, "ExtraBold"), CREAM, sp=4) + 30
y = text(cv, W // 2, y, "TOVAR  ·  PUEBLO LLANO", mont(36, "SemiBold"), CREAM, sp=8) + 16
text(cv, W // 2, y, "Lunes a sábado · 8 am a 6 pm", mont(32, "Regular"), LIGHT, sp=2)
cv.convert("RGB").save(f"{TMP}/end.png")

# --- tomas: (fuente, inicio, duración, movimiento, título, destello) ---
SEG = [("f1", 0, 2.4, "in", "t1", False),     # la caja
       ("f2", 0, 2.4, "pan_r", "t2", True),   # cromado + luz
       ("v2", 0.0, 1.9, "v", "t3", False),    # luz ámbar
       ("f3", 0, 2.0, "pan_l", None, True),   # cromado otro lado
       ("v1", 0.2, 1.8, "v", None, False),
       ("f4", 0, 2.0, "pan_r", None, True),   # el espejo de frente
       ("v2", 6.2, 2.0, "v", None, False),
       ("f6", 0, 3.0, "pan_r", "t4", True)]     # el par
END = 3.2; XF = 0.35
GRADE = ("eq=gamma=1.38:brightness=0.04:contrast=1.06:saturation=1.10,"
         "colorbalance=rh=0.03:gh=0.01:bh=-0.02,"
         "curves=master='0/0.03 0.3/0.38 0.7/0.82 1/1',unsharp=5:5:0.8,vignette=PI/9")

durs = []
for i, (c, ss, d, mv, tt, sw) in enumerate(SEG):
    o = f"{TMP}/s{i}.mp4"
    if c.startswith("f"):
        src = ["-loop", "1", "-framerate", str(FPS), "-t", str(d), "-i", f"{SRC}/{c}.jpg"]
        if mv == "in":   base = f"scale=-2:2240,crop={W}:{H}:'(iw-{W})/2+t*8':'(ih-{H})/2+t*10'"
        elif mv == "out":base = f"scale=-2:2050,crop={W}:{H}:'(iw-{W})/2':'(ih-{H})/2'"
        elif mv == "pan_r": base = f"scale=-2:{H},crop={W}:{H}:'(iw-{W})*(0.15+0.7*t/{d})':0"
        else:            base = f"scale=-2:{H},crop={W}:{H}:'(iw-{W})*(0.85-0.7*t/{d})':0"
    else:
        src = ["-ss", str(ss), "-t", str(d), "-i", f"{SRC}/{c}.mp4"]
        base = (f"hqdn3d=2:2:4:4,scale={W}:{H}:force_original_aspect_ratio=increase:flags=lanczos,crop={W}:{H},"
                f"scale={int(W*1.06)}:{int(H*1.06)},crop={W}:{H}:'(iw-{W})/2':'(ih-{H})/2-t*12'")
    inputs = src[:]; fc = [f"[0:v]{base},{GRADE},fps={FPS},format=rgba[b]"]; last = "b"; k = 1
    if sw:
        inputs += ["-loop", "1", "-t", str(d), "-i", f"{TMP}/streak.png"]
        fc.append(f"[{k}:v]format=rgba[st]")
        fc.append(f"[{last}][st]overlay=x='-1400+t/{d}*2600':y=-300:shortest=1[w]"); last = "w"; k += 1
    if tt:
        inputs += ["-loop", "1", "-t", str(d), "-i", f"{TMP}/{tt}.png"]
        fc.append(f"[{k}:v]format=rgba,fade=in:st=0.25:d=0.45:alpha=1,fade=out:st={d - 0.5:.2f}:d=0.4:alpha=1[tx]")
        fc.append(f"[{last}][tx]overlay=0:'max(0,30-t*60)':shortest=1[x]"); last = "x"; k += 1
    fc.append(f"[{last}]trim=0:{d},setpts=PTS-STARTPTS,format=yuv420p[v]")
    subprocess.check_call(["ffmpeg", "-v", "error", "-y", *inputs, "-filter_complex", ";".join(fc), "-map", "[v]", "-an",
                           "-c:v", "libx264", "-crf", "16", "-preset", "fast", "-r", str(FPS), o])
    durs.append(d)

# --- montaje: fundidos a negro, marca fija, cierre ---
inp = []; fc = []
for i in range(len(SEG)): inp += ["-i", f"{TMP}/s{i}.mp4"]
prev = "0:v"; off = durs[0] - XF
for i in range(1, len(SEG)):
    fc.append(f"[{prev}][{i}:v]xfade=transition=fadeblack:duration={XF}:offset={off:.3f}[x{i}]"); prev = f"x{i}"; off += durs[i] - XF
MAIN = off + XF
n = len(SEG)
inp += ["-loop", "1", "-t", f"{MAIN:.2f}", "-i", f"{TMP}/brand.png", "-loop", "1", "-t", str(END), "-i", f"{TMP}/end.png"]
fc.append(f"[{n}:v]format=rgba[br]")
fc.append(f"[{prev}][br]overlay=0:0:shortest=1,trim=0:{MAIN:.2f},setpts=PTS-STARTPTS,fps={FPS},settb=1/{FPS},format=yuv420p[m]")
fc.append(f"[{n + 1}:v]scale={W}:{H},fps={FPS},format=yuv420p,settb=1/{FPS},fade=in:st=0:d=0.5[en]")
fc.append(f"[m][en]xfade=transition=fadeblack:duration=0.5:offset={MAIN - 0.5:.2f},format=yuv420p[v]")
subprocess.check_call(["ffmpeg", "-v", "error", "-y", *inp, "-filter_complex", ";".join(fc), "-map", "[v]", "-an",
                       "-c:v", "libx264", "-pix_fmt", "yuv420p", "-profile:v", "high", "-crf", "20", "-preset", "medium",
                       "-maxrate", "10M", "-bufsize", "20M", "-movflags", "+faststart", OUT])
print("ok", round(MAIN - 0.5 + END, 2), "s")
