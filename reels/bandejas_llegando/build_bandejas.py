"""Reel ALEXMAR "Llegaron las bandejas" (modelos que saltan uno tras otro).\nAntes: "Llegando mercancía" (videos de WhatsApp m1, m2). Barras con marca grande, cortes rápidos, sin audio.
Clips: p1-p5, p7 (teléfono) y m1, m2 (WhatsApp). Uso: python build_mercancia.py <dir_clips> <salida.mp4>"""
import os, sys, subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter
SRC, OUT = sys.argv[1], sys.argv[2]
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; M9 = f"{R}/fonts/Mont900.ttf"; M7 = f"{R}/fonts/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
W, H, BAR = 1080, 1920, 190
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
TMP = os.path.join(SRC, "_ban"); os.makedirs(TMP, exist_ok=True)
XF = 0.12  # duración de cada fundido

# (clip, inicio, duración de fuente, velocidad, recorte opcional "w:h:x:y")
SEG = [("b1", 0.0, 2.0, 1.15, None),    # 0 sacos en el camión
       ("b1", 6.0, 2.2, 1.2, None),    # 1 bajando un saco
       ("b2", 5.0, 2.2, 1.2, None),    # 2 saco al hombro hacia la tienda
       ("b2", 9.0, 1.8, 1.2, None),    # 3 entrando a la tienda
       ("b3", 5.0, 2.4, 1.1, None),    # 4 bandejas en el piso
       ("b4", 3.0, 2.0, 1.1, None),    # 5 bandeja de cerca
       ("b5", 3.0, 2.0, 1.1, None),    # 6 más bandejas
       ("b6", 3.0, 2.4, 1.1, None),    # 7 bandeja trasera
       ("b4", 9.0, 2.0, 1.1, None),    # 8 bandejas
       ("b3", 8.0, 2.2, 1.1, None),    # 9 bandejas y motos
       ("b6", 9.0, 2.2, 1.1, None),    # 10 bandeja larga
       ("b5", 0.2, 2.0, 1.1, None)]    # 11 cierre de bandejas
MODELOS = ["TOYOTA COROLLA CROSS", "FORTUNER", "HILUX VIGO", "MACHITO LS79", "EKAIZEN", "AVEO LT",
           "CHEVROLET LUV D-MAX", "TERIOS VIGO", "FIESTA POWER", "TOYOTA AGYA", "HILUX", "MERU"]
END = 3.2

def shadow(im, blur=10, op=200, off=(0, 4)):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad + off[0], pad + off[1]), blk)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)); base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad

def text(cv, cx, y, s, font, fill, sp=0, sh=True, op=200):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 40, int(font.size * 1.6)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 20
    for c in s: ld.text((xx, 10), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); p = 0
    if sh: lay, p = shadow(lay, 10, op)
    cv.alpha_composite(lay, (int(cx - lay.width // 2), int(y - p))); return y + lay.height - 2 * p

def blank(): return Image.new("RGBA", (W, H), (0, 0, 0, 0))

# barras de cine con la marca GRANDE (fijas)
BAR = 250
cv = blank(); dr = ImageDraw.Draw(cv)
dr.rectangle((0, 0, W, BAR), fill=(0, 0, 0, 255)); dr.rectangle((0, H - BAR, W, H), fill=(0, 0, 0, 255))
dr.rectangle((0, BAR - 6, W, BAR), fill=TERRA + (255,)); dr.rectangle((0, H - BAR, W, H - BAR + 6), fill=TERRA + (255,))
lw = 230; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS)
lg, p = shadow(lg, 10, 200); cv.alpha_composite(lg, (40 - p, (BAR - 6 - (lg.height - 2 * p)) // 2 - p))
fa = ImageFont.truetype(ANTON, 118); dr = ImageDraw.Draw(cv); bb = dr.textbbox((0, 0), "ALEXMAR", font=fa)
x0 = 40 + lw + 34; dr.text((x0, (BAR - 6 - (bb[3] - bb[1])) // 2 - bb[1] - 10), "ALEXMAR", font=fa, fill=TERRA)
fk = ImageFont.truetype(M9, 22); dr.text((x0 + 4, BAR - 58), "AUTOPERIQUITOS Y ROTULADOS", font=fk, fill=LIGHT)
fp = ImageFont.truetype(ANTON, 100); s_ = "0416-676 83 93"; bb = dr.textbbox((0, 0), s_, font=fp)
dr.text(((W - (bb[2] - bb[0])) // 2 - bb[0], H - BAR + 34 - bb[1]), s_, font=fp, fill=CREAM)
fl = ImageFont.truetype(M9, 30); s_ = "TOVAR  ·  PUEBLO LLANO  ·  @autoalexmar_car"
dr.text(((W - dr.textlength(s_, font=fl)) // 2, H - 78), s_, font=fl, fill=LIGHT)
t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 20))
t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))
cv.save(f"{TMP}/bars.png")

def band(cv, y0, y1):
    g = Image.new("RGBA", (W, H), (0, 0, 0, 0)); d = ImageDraw.Draw(g); pad = 60
    for yy in range(y0 - pad, y1 + pad):
        e = min(1, (yy - (y0 - pad)) / pad, ((y1 + pad) - yy) / pad); d.line((0, yy, W, yy), fill=(8, 8, 8, int(175 * max(0, e))))
    cv.alpha_composite(g)

def card(name, kicker, big, y=330, size=130, col=CREAM):  # título grande con franja oscura (como en los reels que gustaron)
    cv = blank(); fb = ImageFont.truetype(ANTON, size); dr = ImageDraw.Draw(cv)
    while dr.textlength(big, font=fb) + 4 * len(big) > W - 140: size -= 4; fb = ImageFont.truetype(ANTON, size)
    h = 50 + 30 + size * 1.25; band(cv, y - 10, int(y + h))
    yy = text(cv, W // 2, y, kicker, ImageFont.truetype(M9, 34), LIGHT, sp=10, op=230) + 14
    ImageDraw.Draw(cv).rectangle((W // 2 - 60, yy, W // 2 + 60, yy + 6), fill=TERRA + (255,)); yy += 30
    text(cv, W // 2, yy, big, fb, col, sp=4, op=230); cv.save(f"{TMP}/{name}.png")

def caption(name, s, y=1430):
    card(name, "FORD  FIESTA", s, y=y, size=96, col=LIGHT)

def title(name, kicker, big, y=330, size=130):
    card(name, kicker, big, y=y, size=size)

card("ti_open", "RECIÉN  LLEGADAS", "¡LLEGARON LAS BANDEJAS!", y=760, size=130, col=CREAM)
title("t0", "DIRECTO A LA TIENDA", "DESCARGANDO", y=320, size=150)

def tape_png(name, s_, bg, fg, rot, size, scale=1.0):
    cv = blank(); f = ImageFont.truetype(ANTON, int(size * scale)); dr = ImageDraw.Draw(cv)
    while dr.textlength(s_, font=f) > (W - 170) * scale: size -= 4; f = ImageFont.truetype(ANTON, int(size * scale))
    w = dr.textlength(s_, font=f); lay = Image.new("RGBA", (int(w) + 70, int(f.size * 1.45)), bg + (255,))
    ImageDraw.Draw(lay).text((35, f.size * 0.12), s_, font=f, fill=fg + (255,))
    lay = lay.rotate(rot, expand=True, resample=Image.BICUBIC); lay, p = shadow(lay, 14, 210)
    cv.alpha_composite(lay, ((W - lay.width) // 2, 900 - lay.height // 2)); cv.save(f"{TMP}/{name}.png")

hdr = blank(); band(hdr, 300, 470)
yy = text(hdr, W // 2, 310, "BANDEJAS  PARA", ImageFont.truetype(M9, 40), LIGHT, sp=12, op=230) + 14
ImageDraw.Draw(hdr).rectangle((W // 2 - 70, yy, W // 2 + 70, yy + 6), fill=TERRA + (255,))
text(hdr, W // 2, yy + 26, "TU CARRO", ImageFont.truetype(ANTON, 110), CREAM, sp=6, op=230); hdr.save(f"{TMP}/hdr.png")
for k, m in enumerate(MODELOS + ["¡Y MUCHO MÁS!"]):
    bg, fg = ((TERRA, (20, 20, 20)) if k % 2 == 0 else (CREAM, (20, 20, 20)))
    rot = (-3, 2, -2, 3)[k % 4]; sz = 120 if k < len(MODELOS) else 132
    tape_png(f"m{k}", m, bg, fg, rot, sz); tape_png(f"m{k}b", m, bg, fg, rot, sz, 1.18)

# cierre (logo grande y nombre bien visible)
cv = Image.new("RGBA", (W, H), (10, 10, 10, 255)); dr = ImageDraw.Draw(cv)
lw = 600; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 18, 210)
cv.alpha_composite(lg, ((W - lg.width) // 2, 230 - p)); y = 230 + int(LOGO.height * lw / LOGO.width) + 50
y = text(cv, W // 2, y, "AUTOPERIQUITOS  Y  ROTULADOS", ImageFont.truetype(M9, 38), CREAM, sp=8) + 14
y = text(cv, W // 2, y, "ALEXMAR", ImageFont.truetype(ANTON, 230), TERRA, sp=12) + 30
ImageDraw.Draw(cv).rectangle((W // 2 - 90, y, W // 2 + 90, y + 6), fill=LIGHT + (255,)); y += 40
y = text(cv, W // 2, y, "0416-676 83 93", ImageFont.truetype(ANTON, 130), CREAM, sp=4) + 30
y = text(cv, W // 2, y, "Tovar  ·  Pueblo Llano", ImageFont.truetype(M7, 46), CREAM) + 14
y = text(cv, W // 2, y, "Lunes a sábado  ·  8 am a 6 pm", ImageFont.truetype(M7, 40), CREAM) + 14
text(cv, W // 2, y, "@autoalexmar_car", ImageFont.truetype(M9, 40), LIGHT)
cv.convert("RGB").save(f"{TMP}/end.png")

# 1) segmentos (mismo tamaño y fps)
durs = []
for i, (c, ss, d, sp, crop) in enumerate(SEG):
    vf = (f"crop={crop}," if crop else "") + f"setpts=PTS/{sp},scale=1080:1920:flags=lanczos,unsharp=5:5:0.8,fps=30,setsar=1"
    if i in (0,): vf += ",zoompan=z='1+0.0018*on':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30"
    subprocess.check_call(["ffmpeg", "-v", "error", "-y", "-ss", str(ss), "-t", str(d), "-i", f"{SRC}/{c}.mp4", "-an", "-vf", vf,
                           "-c:v", "libx264", "-crf", "15", "-preset", "fast", f"{TMP}/s{i}.mp4"])
    durs.append(float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", f"{TMP}/s{i}.mp4"])))

# 2) cadena de fundidos
inp = []; fc = []
for i in range(len(SEG)): inp += ["-i", f"{TMP}/s{i}.mp4"]
starts = [0.0]; off = durs[0] - XF; prev = "0:v"
for i in range(1, len(SEG)):
    fc.append(f"[{prev}][{i}:v]xfade=transition=fade:duration={XF}:offset={off:.3f}[x{i}]"); prev = f"x{i}"
    starts.append(off); off += durs[i] - XF
MAIN = off + XF
subprocess.check_call(["ffmpeg", "-v", "error", "-y", *inp, "-filter_complex", ";".join(fc), "-map", f"[{prev}]",
                       "-c:v", "libx264", "-crf", "15", "-preset", "fast", f"{TMP}/chain.mp4"])

# 3) color de cine + barras + textos + cierre
s = starts
ovl = [("ti_open", 0.1, s[1]), ("t0", s[1] + 0.1, s[4])]
L0 = s[4] + 0.15; L1 = MAIN - 0.2; n = len(MODELOS) + 1; step = (L1 - L0) / n
ovl.append(("hdr", L0, L1 - step + 0.05))
for k in range(n):
    a_ = L0 + k * step; b_ = a_ + step if k < n - 1 else L1
    ovl.append((f"m{k}", a_, b_))
inputs = ["-i", f"{TMP}/chain.mp4", "-loop", "1", "-t", f"{MAIN:.2f}", "-i", f"{TMP}/bars.png"]
for n, _, _ in ovl: inputs += ["-loop", "1", "-t", f"{MAIN:.2f}", "-i", f"{TMP}/{n}.png"]
inputs += ["-loop", "1", "-t", f"{END}", "-i", f"{TMP}/end.png"]
fc = ["[0:v]eq=contrast=1.10:saturation=1.08:gamma=0.98,"
      "colorbalance=rh=0.04:bh=-0.03,"
      "vignette=PI/5,format=rgba[g]",
      "[g][1:v]overlay=0:0[b0]"]
last = "b0"
for k, (n, a, b) in enumerate(ovl):
    d = b - a
    if n.startswith("m"):
        fc.append(f"[{k + 2}:v]format=rgba[o{k}]")
        fc.append(f"[{last}][o{k}]overlay=0:0:enable='between(t,{a:.3f},{b:.3f})'[b{k + 1}]"); last = f"b{k + 1}"
        continue
    fc.append(f"[{k + 2}:v]format=rgba,trim=0:{d:.2f},fade=in:st=0:d=0.15:alpha=1,fade=out:st={max(0.02, d - 0.15):.2f}:d=0.15:alpha=1,setpts=PTS-STARTPTS+{a:.2f}/TB[o{k}]")
    fc.append(f"[{last}][o{k}]overlay=0:0:eof_action=pass[b{k + 1}]"); last = f"b{k + 1}"
e = len(ovl) + 2
fc.append(f"[{last}]trim=0:{MAIN:.2f},setpts=PTS-STARTPTS,fps=30,format=yuv420p,settb=1/30[m]")
fc.append(f"[{e}:v]scale=1080:1920,fps=30,format=yuv420p,settb=1/30[en]")
fc.append(f"[m][en]xfade=transition=fadeblack:duration=0.4:offset={MAIN - 0.4:.2f},format=yuv420p[v]")
subprocess.check_call(["ffmpeg", "-v", "error", "-y", *inputs, "-filter_complex", ";".join(fc), "-map", "[v]",
                       "-c:v", "libx264", "-crf", "20", "-preset", "medium", "-maxrate", "14M", "-bufsize", "28M",
                       "-pix_fmt", "yuv420p", "-movflags", "+faststart", OUT])
print("ok", OUT, "dur≈", round(MAIN - 0.6 + END, 2), "inicios:", [round(x, 2) for x in starts])
