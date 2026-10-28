"""Reel underground ALEXMAR: instalación en Ford Fiesta (4 clips de Samer). 1080x1920, sin audio.
Uso: python build_ug.py <dir_clips c1..c4.mp4> <salida.mp4>"""
import os, sys, subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter
SRC, OUT = sys.argv[1], sys.argv[2]
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; M9 = f"{R}/fonts/Mont900.ttf"; M7 = f"{R}/fonts/Mont700.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232); INK = (20, 20, 20)
W, H = 1080, 1920
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
TMP = os.path.join(SRC, "_ug"); os.makedirs(TMP, exist_ok=True)

# (clip, inicio, duración, velocidad)
SEG = [("c4", 0.6, 1.4, 1.0),   # emblema Ford de cerca
       ("c1", 0.4, 1.5, 1.0),   # sentado con la pieza
       ("c2", 0.8, 1.2, 1.0),   # cableado interior
       ("c2", 2.8, 1.1, 1.0),   # control con botones
       ("c2", 5.1, 1.1, 1.0),   # puerta
       ("c2", 12.2, 1.3, 1.0),  # debajo del parachoques
       ("c3", 0.8, 1.3, 1.0),   # manos en la parrilla
       ("c1", 6.2, 1.1, 1.0),   # frente del carro
       ("c4", 2.2, 3.6, 1.0),   # luces encendidas
       ("c4", 9.0, 3.4, 1.15)]  # sale el Fiesta

def shadow(im, blur=10, op=210, off=(0, 4)):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad + off[0], pad + off[1]), blk)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)); base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad

def text(cv, x, y, s, font, fill, sp=0, anchor="l", rot=0, op=210):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 40, int(font.size * 1.6)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 20
    for c in s: ld.text((xx, 10), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox())
    if rot: lay = lay.rotate(rot, expand=True, resample=Image.BICUBIC)
    lay, p = shadow(lay, 10, op)
    X = x - p if anchor == "l" else x - lay.width // 2
    cv.alpha_composite(lay, (int(X), int(y - p))); return lay.width - 2 * p, lay.height - 2 * p

def tape(cv, x, y, s, size=64, bg=TERRA, fg=INK, rot=-3):
    """Texto sobre cinta (estilo sticker/underground)."""
    f = ImageFont.truetype(ANTON, size); dr = ImageDraw.Draw(cv); w = dr.textlength(s, font=f)
    lay = Image.new("RGBA", (int(w) + 60, int(size * 1.45)), bg + (255,)); ld = ImageDraw.Draw(lay)
    ld.text((30, size * 0.12), s, font=f, fill=fg + (255,))
    lay = lay.rotate(rot, expand=True, resample=Image.BICUBIC); lay, p = shadow(lay, 12, 200)
    cv.alpha_composite(lay, (int(x - lay.width // 2), int(y - p)))

def png(name, cv): cv.save(f"{TMP}/{name}.png")
def blank(): return Image.new("RGBA", (W, H), (0, 0, 0, 0))

# capa fija: REC + marca + teléfono
cv = blank(); dr = ImageDraw.Draw(cv)
dr.ellipse((52, 74, 80, 102), fill=(230, 40, 30, 255)); text(cv, 94, 66, "REC", ImageFont.truetype(M9, 30), CREAM, sp=4, op=160)
text(cv, 94, 112, "TOVAR · MÉRIDA", ImageFont.truetype(M7, 20), LIGHT, sp=3, op=160)
lw = 120; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 8, 170); cv.alpha_composite(lg, (W - lw - 40 - p, 56 - p))
f = ImageFont.truetype(ANTON, 46); text(cv, W // 2, H - 220, "ALEXMAR  ·  0416-676 83 93", f, CREAM, anchor="c")
t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 13))
t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))
png("base", cv)

# gancho: ALEXMAR gigante
cv = blank(); text(cv, W // 2, 640, "AUTOPERIQUITOS  Y  ROTULADOS", ImageFont.truetype(M9, 30), LIGHT, sp=8, anchor="c")
text(cv, W // 2, 700, "ALEXMAR", ImageFont.truetype(ANTON, 250), TERRA, sp=6, anchor="c", op=230)
tape(cv, W // 2, 1010, "AQUÍ SE TRABAJA DE VERDAD", 58); png("hook", cv)
cv = blank(); tape(cv, W // 2, 330, "SIN FILTRO", 92, bg=CREAM, rot=2); png("t1", cv)
cv = blank(); tape(cv, W // 2, 330, "CABLEADO LIMPIO", 84, rot=-2); png("t2", cv)
cv = blank(); tape(cv, W // 2, 330, "MANOS A LA OBRA", 84, bg=CREAM, rot=3); png("t3", cv)
cv = blank(); text(cv, W // 2, 300, "LISTO.", ImageFont.truetype(ANTON, 230), CREAM, sp=6, anchor="c", op=230)
tape(cv, W // 2, 600, "LUCES QUE SE NOTAN", 64); png("t4", cv)
cv = blank(); tape(cv, W // 2, 330, "PA' LA CALLE", 96, bg=CREAM, rot=-3); png("t5", cv)

# cierre
cv = Image.new("RGBA", (W, H), (14, 13, 12, 255)); dr = ImageDraw.Draw(cv)
for i in range(0, H, 6): dr.line((0, i, W, i), fill=(255, 255, 255, 6))
lw = 460; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 16, 220)
cv.alpha_composite(lg, ((W - lg.width) // 2, 330 - p)); y = 330 + int(LOGO.height * lw / LOGO.width) + 60
text(cv, W // 2, y, "AUTOPERIQUITOS  Y  ROTULADOS", ImageFont.truetype(M9, 32), LIGHT, sp=8, anchor="c"); y += 60
text(cv, W // 2, y, "ALEXMAR", ImageFont.truetype(ANTON, 210), TERRA, sp=8, anchor="c"); y += 290
tape(cv, W // 2, y, "0416-676 83 93", 96, bg=CREAM, rot=-2); y += 210
text(cv, W // 2, y, "Tovar  ·  Pueblo Llano", ImageFont.truetype(M7, 44), CREAM, anchor="c"); y += 70
text(cv, W // 2, y, "Lunes a sábado 8 am a 6 pm", ImageFont.truetype(M7, 36), CREAM, anchor="c"); y += 64
text(cv, W // 2, y, "@autoalexmar_car", ImageFont.truetype(M9, 36), LIGHT, anchor="c")
cv.convert("RGB").save(f"{TMP}/end.png")

# 1) segmentos
starts = []; t0 = 0; parts = []
for i, (c, ss, d, sp) in enumerate(SEG):
    out = f"{TMP}/s{i}.mp4"; starts.append(t0)
    vf = f"setpts=PTS/{sp},scale=1080:1920,fps=30,setsar=1"
    if i in (0, 8): vf += ",zoompan=z='min(1+0.0025*on,1.18)':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920:fps=30"
    subprocess.check_call(["ffmpeg", "-v", "error", "-y", "-ss", str(ss), "-t", str(d * sp), "-i", f"{SRC}/{c}.mp4", "-an", "-vf", vf,
                           "-c:v", "libx264", "-crf", "16", "-preset", "fast", out])
    parts.append(out); t0 += d
END_T = t0; TOTAL = t0 + 2.6
with open(f"{TMP}/list.txt", "w") as fh: fh.writelines(f"file '{p}'\n" for p in parts)
subprocess.check_call(["ffmpeg", "-v", "error", "-y", "-f", "concat", "-safe", "0", "-i", f"{TMP}/list.txt", "-c", "copy", f"{TMP}/cat.mp4"])

# 2) look underground + textos + destellos en los cortes
cuts = starts[1:] + [END_T]
flash = "+".join(f"between(t,{c - 0.02:.2f},{c + 0.07:.2f})" for c in cuts)
glitch = "+".join(f"between(t,{c:.2f},{c + 0.12:.2f})" for c in cuts)
s = starts
ov = [("hook", 0.15, s[1] - 0.05), ("t1", s[1] + 0.1, s[2]), ("t2", s[2] + 0.1, s[4]), ("t3", s[5] + 0.1, s[8]),
      ("t4", s[8] + 0.6, s[9]), ("t5", s[9] + 0.2, END_T)]
inputs = ["-i", f"{TMP}/cat.mp4", "-loop", "1", "-t", f"{TOTAL}", "-i", f"{TMP}/base.png"]
for n, _, _ in ov: inputs += ["-loop", "1", "-t", f"{TOTAL}", "-i", f"{TMP}/{n}.png"]
inputs += ["-loop", "1", "-t", "2.6", "-i", f"{TMP}/end.png"]
fc = ["[0:v]eq=contrast=1.32:saturation=0.62:brightness=-0.03:gamma=0.95,"
      "colorbalance=rs=-0.04:bs=0.06:rh=0.10:gh=0.02:bh=-0.08,"
      f"rgbashift=rh=-14:bh=14:enable='{glitch}',"
      "noise=alls=16:allf=t,vignette=PI/4.2,"
      f"crop=w=1056:h=1878:x='12+12*sin(t*53)*({glitch})':y=21,scale=1080:1920,"
      f"drawbox=c=0xD97757@0.75:t=fill:enable='{flash}',fps=30,format=rgba[g]",
      "[g][1:v]overlay=0:0[b0]"]
last = "b0"
for k, (n, a, b) in enumerate(ov):
    fc.append(f"[{k + 2}:v]format=rgba,fade=in:st=0:d=0.08:alpha=1[o{k}]")
    fc.append(f"[{last}][o{k}]overlay=0:0:enable='between(t,{a:.2f},{b:.2f})'[b{k + 1}]"); last = f"b{k + 1}"
e = len(ov) + 2
fc.append(f"[{last}]trim=0:{END_T:.2f},setpts=PTS-STARTPTS,format=yuv420p,settb=1/30[m]")
fc.append(f"[{e}:v]scale=1080:1920,fps=30,noise=alls=12:allf=t,format=yuv420p,settb=1/30[en]")
fc.append(f"[m][en]xfade=transition=pixelize:duration=0.4:offset={END_T - 0.4:.2f},format=yuv420p[v]")
subprocess.check_call(["ffmpeg", "-v", "error", "-y", *inputs, "-filter_complex", ";".join(fc), "-map", "[v]",
                       "-c:v", "libx264", "-crf", "18", "-preset", "medium", "-pix_fmt", "yuv420p", "-movflags", "+faststart", OUT])
print("ok", OUT, round(END_T + 2.2, 2), "s | cortes:", [round(x, 2) for x in starts])
