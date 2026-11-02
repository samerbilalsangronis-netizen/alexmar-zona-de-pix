"""Reel 'Cosas caras' estilo ALEXMAR — NPR verde en la sede de Pueblo Llano.
Formato de tendencia: frase reflexiva centrada sobre tomas oscuras y cinematográficas, con la marca grande.
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
SEG = [("b", 0.0, 2.2, 330),    # el NPR completo, trabajando en la plataforma
       ("a", 1.0, 2.0, 500),    # trabajando debajo de la plataforma
       ("b", 6.2, 1.8, 330),    # CHEVROLET tecnología ISUZU
       ("c", 6.6, 1.4, 300),    # luz ámbar de la cabina
       ("a", 4.6, 1.3, 420),    # la cabina por dentro
       ("c", 8.5, 4.2, 300)]    # el cliente contento en su camión
END = 2.8


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
FR = ["A un camionero que sabe",
      "trabajar y cuidar lo suyo,",
      "lo único que le interesa",
      "y le impresiona es la seriedad,",
      "el trato y el detalle con que",
      "le atiendes su camión."]
cv = blank()
f = mont(50, "SemiBold"); y = BAR + int(MH * 0.40)
text(cv, W // 2, y - 70, "SEDE  PUEBLO  LLANO", mont(26, "ExtraBold"), LIGHT, sp=8, op=230, blur=8)
for ln in FR: y = text(cv, W // 2, y, ln, f, CREAM, op=245, blur=12) + 14
y += 18
y = text(cv, W // 2, y, "Ya saben…", mont(50, "SemiBold"), CREAM, op=245, blur=12) + 16
text(cv, W // 2, y, "COSAS DE ALEXMAR.", ImageFont.truetype(ANTON, 92), TERRA, sp=3, op=245, blur=14)
cv.save(f"{TMP}/frase.png")

# 3) cierre: logo gigante
cv = Image.new("RGBA", (W, H), (12, 12, 12, 255)); lw = 640
lg = LOGO.resize((lw, int(LOGO.height * lw / LOGO.width)), Image.LANCZOS); lg, p = shadow(lg, 18, 220)
cv.alpha_composite(lg, ((W - lg.width) // 2, 300 - p))
y = 300 + lg.height - 2 * p + 40
y = text(cv, W // 2, y, "ALEXMAR", ImageFont.truetype(ANTON, 190), TERRA, sp=6) + 10
y = text(cv, W // 2, y, "AUTOPERIQUITOS Y ROTULADOS", ImageFont.truetype(M9, 36), CREAM, sp=4) + 50
y = text(cv, W // 2, y, "0416-676 83 93", ImageFont.truetype(ANTON, 130), CREAM, sp=3) + 30
y = text(cv, W // 2, y, "Sede Pueblo Llano: C-9, sector La Curva de Los Luises", mont(32, "SemiBold"), LIGHT) + 12
y = text(cv, W // 2, y, "Tovar: Carrera 4ta, El Llano", mont(32, "SemiBold"), LIGHT) + 12
text(cv, W // 2, y, "Lunes a sábado · 8 am a 6 pm", mont(32, "SemiBold"), CREAM)
cv.convert("RGB").save(f"{TMP}/cierre.png")

# 4) segmentos: recorte vertical, mejora de calidad, look oscuro/cinematográfico
GRADE = ("hqdn3d=3:3:6:6,scale={w}:{h}:flags=lanczos,unsharp=5:5:0.8,"
         "eq=saturation=0.62:contrast=1.08:brightness=-0.07:gamma=0.92,"
         "colorbalance=rs=-0.04:bs=0.06:rh=0.07:bh=-0.05,"
         "curves=all='0/0 0.5/0.40 1/0.88',vignette=PI/4.2")
cw = round(360 * W / MH) // 2 * 2       # ancho de recorte en la fuente
segs = []
for i, (c, ss, d, cx) in enumerate(SEG):
    x = max(0, min(640 - cw, cx - cw // 2)); o = f"{TMP}/s{i}.mp4"
    vf = (f"crop={cw}:360:{x}:0," + GRADE.format(w=int(W * 1.08), h=int(MH * 1.08)) +
          f",crop={W}:{MH}:'(iw-{W})*(0.5+0.5*t/{d})':'(ih-{MH})/2',fps=30,format=yuv420p")
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
fc.append(f"{prev}pad={W}:{H}:0:{BAR}:black[pv]")
fc.append(f"[{fr}:v]format=rgba,fade=in:st=0.4:d=0.8:alpha=1,fade=out:st={vid_len - 0.6:.2f}:d=0.5:alpha=1[fx]")
fc.append(f"[pv][{b}:v]overlay=shortest=1[pb]")
fc.append(f"[pb][fx]overlay=shortest=1,trim=0:{vid_len:.3f},setpts=PTS-STARTPTS,fps=30,settb=1/30,format=yuv420p[main]")
fc.append(f"[{ci}:v]fps=30,format=yuv420p,trim=0:{END},setpts=PTS-STARTPTS,settb=1/30[end]")
fc.append(f"[main][end]xfade=transition=fade:duration=0.5:offset={vid_len - 0.5:.3f}[out]")
subprocess.run(["ffmpeg", "-v", "error", "-y", *inp, "-filter_complex", ";".join(fc), "-map", "[out]", "-an",
                "-c:v", "libx264", "-preset", "veryfast", "-crf", "19", "-maxrate", "8M", "-bufsize", "16M",
                "-movflags", "+faststart", "-r", "30", OUT], check=True)
print("ok", round(vid_len + END - 0.5, 2), "s")
