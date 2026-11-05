"""Reel garras Texas (todas las marcas) — estilo comercial, SIN textos (Samer pone música y luego locución).
Logo ALEXMAR grande + marca de agua visible (anti-robo). 1080x1920, sin audio.
Uso: python build_garras.py <dir_clips: v1,v2 (360x640), f1..f3, hero.mp4 opcional> <salida.mp4>"""
import os, sys, subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter
SRC, OUT = sys.argv[1], sys.argv[2]
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; VF = f"{R}/fonts/Montserrat-VF.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
W, H, FPS = 1080, 1920, 30
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
TMP = os.path.join(SRC, "_g"); os.makedirs(TMP, exist_ok=True)


def mont(s, w):
    f = ImageFont.truetype(VF, s); f.set_variation_by_name(w); return f


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


# --- marca fija: logo grande + marca de agua repetida y visible (anti-robo) ---
cv = Image.new("RGBA", (W, H), (0, 0, 0, 0)); g = ImageDraw.Draw(cv)
for y in range(0, 420): g.line((0, y, W, y), fill=(0, 0, 0, int(110 * (1 - y / 420) ** 1.6)))
for y in range(H - 260, H): g.line((0, y, W, y), fill=(0, 0, 0, int(120 * ((y - (H - 260)) / 260) ** 1.4)))
wm = Image.new("RGBA", (W * 2, H * 2), (0, 0, 0, 0)); dw = ImageDraw.Draw(wm); fw = ImageFont.truetype(ANTON, 120)
for row in range(0, 14):
    for col in range(0, 5):
        dw.text((col * 520 + (row % 2) * 260, row * 290), "ALEXMAR", font=fw, fill=(255, 255, 255, 34))
wm = wm.rotate(30, resample=Image.BICUBIC); wm = wm.crop(((wm.width - W) // 2, (wm.height - H) // 2, (wm.width - W) // 2 + W, (wm.height - H) // 2 + H))
cv.alpha_composite(wm)
lw = 400; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lgs, p = shadow(lg, 18, 230)
cv.alpha_composite(lgs, ((W - lg.width) // 2 - p, 60 - p))
text(cv, W // 2, H - 110, "0416-676 83 93  ·  @autoalexmar_car", mont(32, "Bold"), CREAM, sp=3, op=235, blur=8)
cv.save(f"{TMP}/brand.png")

# --- destello ---
import numpy as np
st = Image.new("L", (900, 2600), 0); ImageDraw.Draw(st).rectangle((390, 0, 510, 2600), fill=255)
st = st.filter(ImageFilter.GaussianBlur(70)); core = Image.new("L", st.size, 0)
ImageDraw.Draw(core).rectangle((440, 0, 460, 2600), fill=255); core = core.filter(ImageFilter.GaussianBlur(10))
a = np.maximum(np.asarray(st, np.float32) * 0.5, np.asarray(core, np.float32) * 0.85).astype("uint8")
streak = Image.new("RGBA", st.size, (255, 245, 230, 0)); streak.putalpha(Image.fromarray(a))
streak.rotate(-22, expand=True, resample=Image.BICUBIC).save(f"{TMP}/streak.png")

# --- cierre (solo marca, sin frases) ---
cv = Image.new("RGBA", (W, H), (8, 8, 8, 255))
glow = Image.new("RGBA", (W, H), (0, 0, 0, 0)); ImageDraw.Draw(glow).ellipse((90, 300, 990, 1200), fill=TERRA + (80,))
cv.alpha_composite(glow.filter(ImageFilter.GaussianBlur(150)))
lw = 720; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lgs, p = shadow(lg, 22, 230)
cv.alpha_composite(lgs, ((W - lg.width) // 2 - p, 300 - p)); y = 300 + lg.height + 60
y = text(cv, W // 2, y, "ALEXMAR", ImageFont.truetype(ANTON, 210), TERRA, sp=14) + 30
y = text(cv, W // 2, y, "0416-676 83 93", mont(96, "ExtraBold"), CREAM, sp=4) + 24
text(cv, W // 2, y, "TOVAR  ·  PUEBLO LLANO", mont(36, "SemiBold"), CREAM, sp=8)
cv.convert("RGB").save(f"{TMP}/end.png")

GRADE = ("eq=gamma=1.20:contrast=1.12:saturation=1.22:brightness=0.02,"
         "curves=master='0/0 0.25/0.22 0.75/0.85 1/1',unsharp=7:7:1.0,vignette=PI/7")
UP = "hqdn3d=2:2:4:4,scale=1080:1920:flags=lanczos,unsharp=5:5:1.1"

# (fuente, inicio, duración, velocidad, movimiento, destello)
SEG = []
if os.path.exists(f"{SRC}/hero.mp4"): SEG.append(("hero", 0.0, 4.2, 1.0, "v", False))
SEG += [("v2", 0.0, 1.6, 1.0, "v", True),    # Ford rojo
        ("v2", 2.0, 1.6, 1.0, "v", False),   # Chevrolet verde
        ("v2", 4.2, 1.5, 1.0, "v", True),    # Chevrolet azul
        ("v2", 6.4, 1.5, 1.0, "v", False),   # Chevrolet rojo
        ("v2", 10.4, 1.7, 0.9, "v", True),   # Texas Edition
        ("v2", 13.4, 1.6, 1.0, "v", False),  # Chevrolet blanco
        ("v2", 17.2, 1.6, 1.0, "v", True),   # Texas azul
        ("v2", 19.0, 1.6, 1.0, "v", False),  # Ford azul
        ("v2", 22.6, 1.4, 1.0, "v", True),   # Ford verde
        ("v2", 27.0, 1.6, 1.0, "v", False),  # Ford blanco
        ("v2", 28.6, 1.8, 1.0, "v", True),   # Toyota
        ("f2", 0, 2.2, 1.0, "in", True),     # Ford blanco y azul (foto)
        ("v1", 0.0, 2.2, 1.0, "v", False),   # paneo general
        ("f1", 0, 2.4, 1.0, "out", True)]    # cierre producto
END, XF = 3.0, 0.22

durs = []
for i, (c, ss, d, sp, mv, sw) in enumerate(SEG):
    o = f"{TMP}/s{i}.mp4"
    if c.startswith("f"):
        src = ["-loop", "1", "-framerate", str(FPS), "-t", str(d), "-i", f"{SRC}/{c}.jpg"]
        z = "1.10+0.08*t/%s" % d if mv == "in" else "1.18-0.08*t/%s" % d
        base = (f"scale=-2:{H}:flags=lanczos,crop={W}:{H},scale='iw*({z})':-2:eval=frame:flags=bicubic,"
                f"crop={W}:{H}:(iw-{W})/2:(ih-{H})/2,unsharp=5:5:0.8")
    else:
        fn = f"{SRC}/{c}.mp4"; src = ["-ss", str(ss), "-t", str(d / sp), "-i", fn]
        base = (UP if c != "hero" else f"scale={W}:{H}:force_original_aspect_ratio=increase:flags=lanczos,crop={W}:{H}") + (f",setpts=PTS/{sp}" if sp != 1 else "")
    inputs = src[:]; fc = [f"[0:v]{base},{GRADE},fps={FPS},format=rgba[b]"]; last = "b"
    if sw:
        inputs += ["-loop", "1", "-t", str(d), "-i", f"{TMP}/streak.png"]
        fc.append("[1:v]format=rgba[st]"); fc.append(f"[b][st]overlay=x='-1400+t/{d}*2600':y=-300:shortest=1[w]"); last = "w"
    fc.append(f"[{last}]trim=0:{d},setpts=PTS-STARTPTS,format=yuv420p[v]")
    subprocess.check_call(["ffmpeg", "-v", "error", "-y", *inputs, "-filter_complex", ";".join(fc), "-map", "[v]", "-an",
                           "-c:v", "libx264", "-crf", "16", "-preset", "fast", "-r", str(FPS), o])
    durs.append(d)

inp = []; fc = []
for i in range(len(SEG)): inp += ["-i", f"{TMP}/s{i}.mp4"]
tr = ["fade", "slideleft", "fade", "smoothup", "fade", "slideright", "fade", "circleopen", "fade", "slideleft", "fade", "fadeblack", "fade", "fadeblack"]
prev = "0:v"; off = durs[0] - XF
for i in range(1, len(SEG)):
    t = tr[(i - 1) % len(tr)]
    fc.append(f"[{prev}][{i}:v]xfade=transition={t}:duration={XF}:offset={off:.3f}[x{i}]"); prev = f"x{i}"; off += durs[i] - XF
MAIN = off + XF; n = len(SEG)
inp += ["-loop", "1", "-t", f"{MAIN:.2f}", "-i", f"{TMP}/brand.png", "-loop", "1", "-t", str(END), "-i", f"{TMP}/end.png"]
fc.append(f"[{n}:v]format=rgba[br]")
fc.append(f"[{prev}][br]overlay=0:0:shortest=1,trim=0:{MAIN:.2f},setpts=PTS-STARTPTS,fps={FPS},settb=1/{FPS},format=yuv420p[m]")
fc.append(f"[{n + 1}:v]scale={W}:{H},fps={FPS},format=yuv420p,settb=1/{FPS}[en]")
fc.append(f"[m][en]xfade=transition=fadeblack:duration=0.5:offset={MAIN - 0.5:.2f},format=yuv420p[v]")
subprocess.check_call(["ffmpeg", "-v", "error", "-y", *inp, "-filter_complex", ";".join(fc), "-map", "[v]", "-an",
                       "-c:v", "libx264", "-pix_fmt", "yuv420p", "-profile:v", "high", "-crf", "20", "-preset", "medium",
                       "-maxrate", "10M", "-bufsize", "20M", "-movflags", "+faststart", OUT])
print("ok", round(MAIN - 0.5 + END, 2), "s")
