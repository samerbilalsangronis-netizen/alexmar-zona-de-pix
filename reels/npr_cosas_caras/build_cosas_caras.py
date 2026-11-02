"""Reel 'Cosas caras' estilo ALEXMAR — NPR verde en la sede de Pueblo Llano.
v2: tomas completas 16:9 (se ve el camión entero y el trabajo), color natural, fondo desenfocado;
v3: sin frase, cliente corto, más tomas del camión (~20 s). Marca grande.
1080x1920, sin audio. Uso: python build_cosas_caras.py <dir_clips a/b/c.mp4> <salida.mp4>"""
import os, sys, subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter
SRC, OUT = sys.argv[1], sys.argv[2]
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
ANTON = f"{R}/fonts/Anton.ttf"; VF = f"{R}/fonts/Montserrat-VF.ttf"; M9 = f"{R}/fonts/Mont900.ttf"
TERRA = (217, 119, 87); LIGHT = (240, 165, 126); CREAM = (245, 240, 232)
W, H, BAR = 1080, 1920, 250
MH = H - 2 * BAR                       # alto de la zona de video (1420)
LOGO = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); LOGO = LOGO.crop(LOGO.getbbox())
TMP = os.path.join(SRC, "_tmp"); os.makedirs(TMP, exist_ok=True)
XF = 0.35

# (clip, inicio, duración, centro x en la fuente 640x360)
SEG = [("b", 0.0, 3.0),    # el NPR completo de lado, trabajando en la plataforma
       ("a", 0.4, 3.0),    # instalando debajo de la plataforma, cajas
       ("a", 3.6, 1.4),    # rueda delantera y estribo
       ("b", 3.0, 2.0),    # recorrido al frente: cromados y parachoques
       ("c", 2.0, 1.3),    # el frente completo de la cabina
       ("b", 5.0, 2.6),    # parabrisas y emblema CHEVROLET tecnología ISUZU
       ("c", 6.0, 1.8),    # luz ámbar de la cabina
       ("b", 8.4, 2.2),    # recorrido por el lado de la cabina
       ("a", 4.6, 1.8),    # la cabina por dentro
       ("c", 9.0, 1.6)]    # el cliente saluda (corto)
END = 2.8
VW, VH, VY = 1080, 608, 600          # video 16:9 completo, sin recortar


def mont(size, weight):
    f = ImageFont.truetype(VF, size); f.set_variation_by_name(weight); return f


def shadow(im, blur=10, op=200, off=(0, 4)):
    pad = blur * 3; base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255); blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad + off[0], pad + off[1]), blk)
    sh = sh.filter(ImageFilter.GaussianBlur(blur)); base.alpha_composite(sh); base.alpha_composite(im, (pad, pad)); return base, pad


def text(cv, cx, y, s, font, fill, sp=0, op=220, blur=10):
    dr = ImageDraw.Draw(cv); w = sum(dr.textlength(c, font=font) for c in s) + sp * (len(s) - 1)
    lay = Image.new("RGBA", (int(w) + 40, int(font.size * 1.6)), (0, 0, 0, 0)); ld = ImageDraw.Draw(lay); xx = 20
    for c in s: ld.text((xx, 10), c, font=font, fill=fill + (255,)); xx += ld.textlength(c, font=font) + sp
    lay = lay.crop(lay.getbbox()); lay, p = shadow(lay, blur, op)
    cv.alpha_composite(lay, (int(cx - lay.width // 2), int(y - p))); return y + lay.height - 2 * p


def blank(): return Image.new("RGBA", (W, H), (0, 0, 0, 0))


import math, random
def andes(cv, y_base, alto, op_back=70, op_front=150, seed=3):
    """Silueta de la cordillera andina (dos filas de montañas) con borde naranja."""
    rnd = random.Random(seed); lay = Image.new("RGBA", cv.size, (0, 0, 0, 0)); d = ImageDraw.Draw(lay)
    for fila, (amp, op, col) in enumerate([(1.0, op_back, LIGHT), (0.62, op_front, TERRA)]):
        pts = [(0, y_base)]; x = -40; up = rnd.random() < 0.5
        while x < W + 80:
            h = rnd.uniform(0.55, 1.0) if up else rnd.uniform(0.12, 0.38)
            pts.append((x, y_base - h * alto * amp)); x += rnd.randint(70, 150); up = not up
        pts.append((W, y_base))
        d.polygon(pts, fill=(16, 16, 16, op))
        d.line(pts[1:-1], fill=col + (min(255, op + 90),), width=4 if fila else 3, joint="curve")
    cv.alpha_composite(lay)


# 1) barras con la marca grande + marca de agua
cv = blank(); dr = ImageDraw.Draw(cv)
dr.rectangle((0, 0, W, BAR), fill=(0, 0, 0, 255)); dr.rectangle((0, H - BAR, W, H), fill=(0, 0, 0, 255))
dr.rectangle((0, BAR - 6, W, BAR), fill=TERRA + (255,)); dr.rectangle((0, H - BAR, W, H - BAR + 6), fill=TERRA + (255,))
lw = 230; lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS)
lg, p = shadow(lg, 10, 200); cv.alpha_composite(lg, (40 - p, (BAR - 6 - (lg.height - 2 * p)) // 2 - p))
fa = ImageFont.truetype(ANTON, 118); dr = ImageDraw.Draw(cv); bb = dr.textbbox((0, 0), "ALEXMAR", font=fa)
x0 = 40 + lw + 34; dr.text((x0, (BAR - 6 - (bb[3] - bb[1])) // 2 - bb[1] - 10), "ALEXMAR", font=fa, fill=TERRA)
dr.text((x0 + 4, BAR - 58), "AUTOPERIQUITOS Y ROTULADOS", font=ImageFont.truetype(M9, 22), fill=LIGHT)
fp = ImageFont.truetype(ANTON, 100); s_ = "0416-676 83 93"; bb = dr.textbbox((0, 0), s_, font=fp)
dr.text(((W - (bb[2] - bb[0])) // 2 - bb[0], H - BAR + 34 - bb[1]), s_, font=fp, fill=CREAM)
fl = ImageFont.truetype(M9, 30); s_ = "TOVAR  ·  PUEBLO LLANO  ·  @autoalexmar_car"
dr.text(((W - dr.textlength(s_, font=fl)) // 2, H - 78), s_, font=fl, fill=LIGHT)
t = Image.new("RGBA", (1500, 420), (0, 0, 0, 0)); ImageDraw.Draw(t).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 320), fill=(255, 255, 255, 18))
t = t.rotate(58, expand=True, resample=Image.BICUBIC); cv.alpha_composite(t, ((W - t.width) // 2, (H - t.height) // 2))
cv.save(f"{TMP}/bars.png")

# 2) la frase (estilo tendencia: centrada, texto claro con sombra)
cv = blank(); dr = ImageDraw.Draw(cv)
# arriba del video: sede + vehículo
andes(cv, VY - 6, 120, op_back=70, op_front=140)
y = text(cv, W // 2, VY - 262, "PUEBLO LLANO  ·  EDO. MÉRIDA", mont(30, "ExtraBold"), LIGHT, sp=7, op=240, blur=8) + 18
text(cv, W // 2, y, "CHEVROLET  NPR", ImageFont.truetype(ANTON, 130), CREAM, sp=4, op=240, blur=12)
# líneas naranjas enmarcando el video
dr.rectangle((0, VY - 5, W, VY), fill=TERRA + (255,)); dr.rectangle((0, VY + VH, W, VY + VH + 5), fill=TERRA + (255,))
# debajo del video
y = text(cv, W // 2, VY + VH + 70, "TRABAJO  HECHO  EN", mont(30, "ExtraBold"), LIGHT, sp=9, op=230, blur=8) + 16
y = text(cv, W // 2, y, "ALEXMAR", ImageFont.truetype(ANTON, 120), TERRA, sp=5, op=240, blur=12) + 18
y = text(cv, W // 2, y, "Pueblo Llano, estado Mérida", mont(34, "Bold"), CREAM, op=235, blur=10) + 10
text(cv, W // 2, y, "C-9, sector La Curva de Los Luises", mont(28, "SemiBold"), LIGHT, op=235, blur=10)
andes(cv, H - BAR, 110, op_back=80, op_front=150, seed=5)
cv.save(f"{TMP}/frase.png")

# 3) cierre: logo gigante
cv = Image.new("RGBA", (W, H), (12, 12, 12, 255)); lw = 600
lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 18, 220)
cv.alpha_composite(lg, ((W - lg.width) // 2, 200 - p))
y = 200 + lg.height - 2 * p + 40
y = text(cv, W // 2, y, "ALEXMAR", ImageFont.truetype(ANTON, 190), TERRA, sp=6) + 10
y = text(cv, W // 2, y, "AUTOPERIQUITOS Y ROTULADOS", ImageFont.truetype(M9, 36), CREAM, sp=4) + 50
y = text(cv, W // 2, y, "0416-676 83 93", ImageFont.truetype(ANTON, 130), CREAM, sp=3) + 30
y = text(cv, W // 2, y, "Sede Pueblo Llano: C-9, sector La Curva de Los Luises", mont(32, "SemiBold"), LIGHT) + 12
y = text(cv, W // 2, y, "Tovar: Carrera 4ta, El Llano", mont(32, "SemiBold"), LIGHT) + 12
text(cv, W // 2, y, "Lunes a sábado · 8 am a 6 pm", mont(32, "SemiBold"), CREAM)
andes(cv, H, 300, op_back=255, op_front=255, seed=5)
text(cv, W // 2, H - 370, "PUEBLO LLANO  ·  EDO. MÉRIDA", mont(34, "ExtraBold"), CREAM, sp=7, op=240, blur=8)
cv.convert("RGB").save(f"{TMP}/cierre.png")

# 4) segmentos 16:9 completos, color natural (bajando el sol quemado) + nitidez
GRADE = ("hqdn3d=2:2:5:5,curves=all='0/0 0.5/0.48 0.85/0.78 1/0.9',"
         "eq=saturation=1.06:contrast=1.06:gamma=0.95,scale={w}:{h}:flags=lanczos,unsharp=5:5:0.9")
segs = []
for i, (c, ss, d) in enumerate(SEG):
    o = f"{TMP}/s{i}.mp4"; zw, zh = int(VW * 1.05) // 2 * 2, int(VH * 1.05) // 2 * 2
    vf = (GRADE.format(w=zw, h=zh) +
          f",crop={VW}:{VH}:'(iw-{VW})*(t/{d})':'(ih-{VH})/2',fps=30,format=yuv420p")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-ss", str(ss), "-t", str(d), "-i", f"{SRC}/{c}.mp4",
                    "-vf", vf, "-an", "-c:v", "libx264", "-preset", "veryfast", "-crf", "16", o], check=True)
    segs.append((o, d))

# 5) montaje con fundidos + barras + frase + cierre
inp = []; fc = []
for o, _ in segs: inp += ["-i", o]
n = len(segs); prev = "[0:v]"; off = 0
for i in range(1, n):
    off += segs[i - 1][1] - XF
    fc.append(f"{prev}[{i}:v]xfade=transition=fade:duration={XF}:offset={off:.3f}[x{i}]"); prev = f"[x{i}]"
vid_len = sum(d for _, d in segs) - XF * (n - 1)
inp += ["-loop", "1", "-i", f"{TMP}/bars.png", "-loop", "1", "-i", f"{TMP}/frase.png",
        "-loop", "1", "-t", str(END), "-i", f"{TMP}/cierre.png"]
b, fr, ci = n, n + 1, n + 2
fc.append(f"{prev}split[v1][v2]")
fc.append(f"[v1]scale=-2:{MH},crop={W}:{MH},boxblur=28:2,eq=brightness=-0.20:saturation=0.85,pad={W}:{H}:0:{BAR}:black[bgp]")
fc.append(f"[bgp][v2]overlay=0:{VY}[pv]")
fc.append(f"[{fr}:v]format=rgba,fade=in:st=0.2:d=0.6:alpha=1,fade=out:st={vid_len - 0.6:.2f}:d=0.5:alpha=1[fx]")
fc.append(f"[pv][{b}:v]overlay=shortest=1[pb]")
fc.append(f"[pb][fx]overlay=shortest=1,trim=0:{vid_len:.3f},setpts=PTS-STARTPTS,fps=30,settb=1/30,format=yuv420p[main]")
fc.append(f"[{ci}:v]fps=30,format=yuv420p,trim=0:{END},setpts=PTS-STARTPTS,settb=1/30[end]")
fc.append(f"[main][end]xfade=transition=fade:duration=0.5:offset={vid_len - 0.5:.3f}[out]")
subprocess.run(["ffmpeg", "-v", "error", "-y", *inp, "-filter_complex", ";".join(fc), "-map", "[out]", "-an",
                "-c:v", "libx264", "-pix_fmt", "yuv420p", "-profile:v", "high", "-level", "4.1", "-preset", "veryfast", "-crf", "20", "-maxrate", "6M", "-bufsize", "16M",
                "-movflags", "+faststart", "-r", "30", OUT], check=True)
print("ok", round(vid_len + END - 0.5, 2), "s")
