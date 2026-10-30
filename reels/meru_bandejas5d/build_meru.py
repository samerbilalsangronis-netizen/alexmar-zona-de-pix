"""Reel ALEXMAR antes/después bandejas 5D Toyota Meru (calidad mejorada). Antes: "Llegaron las bandejas" (modelos que saltan uno tras otro).\nAntes: "Llegando mercancía" (videos de WhatsApp m1, m2). Barras con marca grande, cortes rápidos, sin audio.
Clips: p1-p5, p7 (teléfono) y m1, m2 (WhatsApp). Uso: python build_mercancia.py <dir_clips> <salida.mp4>"""
import os, sys, subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter
SRC, OUT = sys.argv[1], sys.argv[2]
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; M9 = f"{R}/fonts/Mont900.ttf"; M7 = f"{R}/fonts/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
W, H, BAR = 1080, 1920, 190
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
TMP = os.path.join(SRC, "_meru"); os.makedirs(TMP, exist_ok=True)
XF = 0.12  # duración de cada fundido

# (clip, inicio, duración de fuente, velocidad, recorte opcional "w:h:x:y")
SEG = [("w77", 0.5, 2.6, 1.0, None),    # 0 la Meru por fuera
       ("w77", 14.4, 2.0, 1.0, None),   # 1 ANTES: alfombra vieja Toyota
       ("w71", 0.4, 2.0, 1.0, None),    # 2 alfombra vieja delantera
       ("w70", 3.0, 2.0, 1.0, "rot"),   # 3 piso del chofer antes
       ("w69", 0.2, 2.0, 1.0, None),    # 4 trasero antes
       ("w68", 0.8, 2.0, 1.0, None),    # 5 maletera antes
       ("w74", 0.2, 2.3, 0.85, None),   # 6 DESPUÉS: bandeja 5D chofer con logo Meru
       ("w73", 11.6, 1.9, 0.85, None),  # 7 logo Meru
       ("w74", 7.0, 2.2, 0.9, None),    # 8 bandeja copiloto
       ("w72", 4.0, 2.4, 0.9, "rot"),   # 9 bandeja trasera
       ("w76", 12.0, 2.0, 0.9, None),   # 10 trasera
       ("w76", 15.2, 2.2, 1.0, None),   # 11 puerta abierta
       ("w76", 23.6, 3.2, 1.0, None)]   # 12 la Meru lista
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
    card(name, "TOYOTA  MERU", s, y=y, size=96, col=LIGHT)

def title(name, kicker, big, y=330, size=130):
    card(name, kicker, big, y=y, size=size)

card("ti_open", "ALEXMAR  PRESENTA", "TOYOTA MERU", y=760, size=160, col=CREAM)
card("t_antes", "ASÍ  LLEGÓ", "ANTES", y=320, size=190, col=CREAM)
caption("c_tras_a", "PISO TRASERO")
caption("c_mal_a", "MALETERA")
card("t_desp", "BANDEJAS  5D", "DESPUÉS", y=320, size=190, col=TERRA)
caption("c_del", "PISOS DELANTEROS")
caption("c_tras", "PISOS TRASEROS")
card("t_fin", "DELANTEROS · TRASEROS · MALETERA", "JUEGO COMPLETO 5D", y=320, size=118, col=CREAM)

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
    pre = "transpose=1," if crop == "rot" else (f"crop={crop}," if crop else "")
    vf = (pre + "hqdn3d=3:2:4:3,"
          "curves=master='0/0 0.55/0.50 0.85/0.76 1/0.90',eq=gamma=0.94:contrast=1.08:saturation=1.12,"
          f"setpts=PTS/{sp},scale=1080:1920:force_original_aspect_ratio=increase:flags=lanczos,crop=1080:1920,"
          "unsharp=5:5:0.9:3:3:0.4,fps=30,setsar=1")
    if i in (0, 12): vf += ",zoompan=z='1+0.0018*on':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30"
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
ovl = [("ti_open", 0.1, s[1]), ("t_antes", s[1] + 0.05, s[4]), ("c_tras_a", s[4] + 0.1, s[5]), ("c_mal_a", s[5] + 0.1, s[6]),
       ("t_desp", s[6] + 0.05, s[8]), ("c_del", s[8] + 0.1, s[9]), ("c_tras", s[9] + 0.1, s[11]), ("t_fin", s[11] + 0.1, MAIN)]
inputs = ["-i", f"{TMP}/chain.mp4", "-loop", "1", "-t", f"{MAIN:.2f}", "-i", f"{TMP}/bars.png"]
for n, _, _ in ovl: inputs += ["-loop", "1", "-t", f"{MAIN:.2f}", "-i", f"{TMP}/{n}.png"]
inputs += ["-loop", "1", "-t", f"{END}", "-i", f"{TMP}/end.png"]
fc = ["[0:v]eq=contrast=1.04:saturation=1.0,"
      "colorbalance=rh=0.03:bs=0.02:bh=-0.02,"
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
