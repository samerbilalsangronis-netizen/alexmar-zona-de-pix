"""Reel "Estamos abiertos" sede Pueblo Llano: estribos, luces, cornetas, bombillos LED, sonido, rines.
Videos horizontales de WhatsApp (640x360): se montan al centro sobre fondo desenfocado del mismo video.
Uso: python3 build_abiertos.py <carpeta con wa0..wa4.mp4>"""
import os, sys, subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
V = sys.argv[1] if len(sys.argv) > 1 else D
FT = f"{R}/fonts"; ANTON = f"{FT}/Anton.ttf"; M8 = f"{FT}/Mont900.ttf"; M4 = f"{FT}/Mont700.ttf"
TERRA = (217, 119, 87, 255); LIGHT = (240, 165, 126, 255); CREAM = (245, 240, 232, 255)
W, H, FPS = 1080, 1920, 30
S = f"{D}/seg"; O = f"{D}/ov"; os.makedirs(S, exist_ok=True); os.makedirs(O, exist_ok=True)
def run(c): subprocess.run(c, shell=True, check=True)
GRADE = "eq=contrast=1.11:saturation=1.20:brightness=-0.03"


FW, FH = 1080, 860; FY = (H - FH) // 2
def vid_land(name, src, ss, dur, cx=0.5, cy=0.5, z0=1.0, z1=1.08, kick=0.16, dark=0.0, blur_fg=False):
    n = int(dur * FPS)
    fgx = ",boxblur=6:2,eq=brightness=-0.35" if blur_fg else ""
    fc = (f"[0:v]fps={FPS},split[a][b];"
          f"[a]scale={W}:{H}:force_original_aspect_ratio=increase,crop={W}:{H},boxblur=28:3,eq=brightness={-0.12-dark}:saturation=1.35[bg];"
          f"[b]scale=-2:{FH*2}:flags=lanczos,crop={FW*2}:{FH*2},zoompan=z='{z0}+({z1}-{z0})*on/{n}+{kick}*exp(-on/4)':x='max(0,min(iw-iw/zoom,{cx}*iw-iw/zoom/2))':y='max(0,min(ih-ih/zoom,{cy}*ih-ih/zoom/2))':d=1:s={FW}x{FH}:fps={FPS},unsharp=5:5:0.9,{GRADE}{fgx}[fg];"
          f"[bg][fg]overlay=0:{FY},drawbox=x=0:y={FY-6}:w={W}:h=6:color=0xD97757:t=fill,drawbox=x=0:y={FY+FH}:w={W}:h=6:color=0xD97757:t=fill,format=yuv420p")
    run(f'ffmpeg -v error -y -ss {ss} -t {dur} -i "{src}" -filter_complex "{fc}" -an -c:v libx264 -preset veryfast -crf 17 {S}/{name}.mp4')

v = lambda n: f"{V}/wa{n}.mp4"
plan = [("h0", 2.3, None, 0), ("c1", 1.8, "fadewhite", 0.15), ("c2", 2.0, "slideup", 0.2),
        ("c3", 2.0, "fadewhite", 0.15), ("c4", 1.8, "wipeleft", 0.2), ("c5", 1.8, "zoomin", 0.25),
        ("c6", 1.7, "fadewhite", 0.15), ("c7", 1.7, "hlslice", 0.2), ("c8", 2.0, "radial", 0.25),
        ("c9", 2.0, "fadewhite", 0.15), ("c10", 1.9, "pixelize", 0.3), ("c11", 2.0, "smoothleft", 0.2),
        ("c12", 2.2, "circleopen", 0.3), ("c13", 4.4, "fadeblack", 0.4)]
d = dict((p[0], p[1]) for p in plan)
vid_land("h0", v(4), 0.3, d["h0"], 0.45, 0.45)          # camioneta rotulada ALEXMAR
vid_land("c1", v(4), 7.5, d["c1"], 0.45, 0.5)           # llegando a la sede
vid_land("c2", v(4), 12.6, d["c2"], 0.45, 0.5)          # adentro de la tienda
vid_land("c3", v(1), 0.3, d["c3"], 0.5, 0.5)            # estribos
vid_land("c4", v(1), 6.0, d["c4"], 0.5, 0.5)            # luces y faros
vid_land("c5", v(2), 11.5, d["c5"], 0.5, 0.5)           # stops LED
vid_land("c6", v(3), 0.2, d["c6"], 0.5, 0.5)            # cornetas
vid_land("c7", v(3), 3.9, d["c7"], 0.5, 0.5)            # cornetas de aire
vid_land("c8", v(2), 20.6, d["c8"], 0.5, 0.5)           # bombillos LED
vid_land("c9", v(1), 10.3, d["c9"], 0.5, 0.5)           # sonido
vid_land("c10", v(0), 0.5, d["c10"], 0.5, 0.5)          # rines Hercules
vid_land("c11", v(0), 8.6, d["c11"], 0.5, 0.5)          # exhibición
vid_land("c12", v(4), 9.2, d["c12"], 0.45, 0.5)         # fachada
vid_land("c13", v(4), 13.0, d["c13"], 0.45, 0.5, z0=1.1, z1=1.0, kick=0, dark=0.1, blur_fg=True)
spots = {}
inputs = " ".join(f"-i {S}/{p[0]}.mp4" for p in plan)
fc = []; prev = "[0:v]"; t = 0.0; st = [0.0]
for i in range(1, len(plan)):
    t += plan[i - 1][1] - plan[i][3]; st.append(t)
    fc.append(f"{prev}[{i}:v]xfade=transition={plan[i][2]}:duration={plan[i][3]}:offset={t:.3f}[x{i}]"); prev = f"[x{i}]"
total = t + plan[-1][1]
run(f'ffmpeg -v error -y {inputs} -filter_complex "{";".join(fc)}" -map "{prev}" -c:v libx264 -preset veryfast -crf 17 {S}/base.mp4')

# ---------------- overlays ----------------
def shadow(im, blur=14, off=(0, 6), op=180):
    pad = blur * 3
    base = Image.new("RGBA", (im.width + pad * 2, im.height + pad * 2), (0, 0, 0, 0))
    a = im.split()[3].point(lambda v: v * op // 255)
    blk = Image.new("RGBA", im.size, (0, 0, 0, 255)); blk.putalpha(a)
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); sh.paste(blk, (pad + off[0], pad + off[1]), blk)
    sh = sh.filter(ImageFilter.GaussianBlur(blur))
    base = Image.alpha_composite(base, sh); base.alpha_composite(im, (pad, pad)); return base
def spaced_w(t, f, sp):
    dd = ImageDraw.Draw(Image.new("RGBA", (1, 1))); return sum(dd.textlength(c, font=f) for c in t) + sp * (len(t) - 1)
def spaced(dr, xy, t, f, fill, sp):
    x, y = xy
    for c in t: dr.text((x, y), c, font=f, fill=fill); x += dr.textlength(c, font=f) + sp

def card(name, kicker, lines, col=CREAM, size=112, sub=None):
    im = Image.new("RGBA", (W, 760), (0, 0, 0, 0)); dr = ImageDraw.Draw(im); y = 0
    if kicker:
        fk = ImageFont.truetype(M8, 28); sp = 8; kw = spaced_w(kicker, fk, sp)
        spaced(dr, ((W - kw) / 2, y), kicker, fk, LIGHT, sp); y += 50
        dr.rectangle(((W - 110) / 2, y, (W + 110) / 2, y + 5), fill=TERRA); y += 30
    for ln in lines:
        s = size
        while True:
            fm = ImageFont.truetype(ANTON, s); b = dr.textbbox((0, 0), ln, font=fm)
            if b[2] - b[0] <= W - 110 or s < 40: break
            s -= 4
        dr.text(((W - (b[2] - b[0])) / 2 - b[0], y - b[1]), ln, font=fm, fill=col); y += (b[3] - b[1]) + 20
    if sub:
        fs = ImageFont.truetype(M4, 38); sw = dr.textlength(sub, font=fs)
        dr.text(((W - sw) / 2, y + 6), sub, font=fs, fill=CREAM); y += 60
    im = im.crop((0, 0, W, y + 10)); pad = 50
    band = Image.new("RGBA", (W, im.height + pad * 2), (0, 0, 0, 0)); bd = ImageDraw.Draw(band)
    for yy in range(band.height):
        e = min(yy, band.height - 1 - yy) / pad
        bd.line((0, yy, W, yy), fill=(10, 10, 10, int(160 * min(1, e))))
    band.alpha_composite(shadow(im, blur=16, op=210).crop((48, 48, 48 + W, 48 + im.height)), (0, pad))
    band.save(f"{O}/{name}.png")

card("h", "AUTOPERIQUITOS Y ROTULADOS ALEXMAR", ["¡ESTAMOS ABIERTOS!"], col=LIGHT, size=150)
card("t1", "SEDE PUEBLO LLANO", ["TE ESPERAMOS"], col=LIGHT, size=136, sub="Y llegamos a todo el estado Mérida")
card("t3", "LO MEJOR PARA TU VEHÍCULO", ["ESTRIBOS"], col=LIGHT, size=140)
card("t4", "LO MEJOR PARA TU VEHÍCULO", ["LUCES"], col=LIGHT, size=150)
card("t6", "LO MEJOR PARA TU VEHÍCULO", ["CORNETAS"], col=LIGHT, size=146)
card("t8", "LO MEJOR PARA TU VEHÍCULO", ["BOMBILLOS LED"], col=LIGHT, size=136)
card("t9", "LO MEJOR PARA TU VEHÍCULO", ["SONIDO"], col=LIGHT, size=150)
card("t10", "", ["¡Y MUCHO MÁS!"], col=LIGHT, size=146)
card("b1", "", ["TODO PARA TU CARRO", "EN UN SOLO LUGAR"], col=CREAM, size=96)
card("b2", "", ["VEN A VISITARNOS"], col=CREAM, size=110, sub="Pueblo Llano · Tovar")
lgi = Image.open(f"{R}/assets/logo_alexmar_sticker.png").convert("RGBA"); lgi = lgi.crop(lgi.getbbox())
def logo(wd): return lgi.resize((wd, int(lgi.height * wd / lgi.width)), Image.LANCZOS)
shadow(logo(210), blur=10, op=190).save(f"{O}/logo_s.png")
shadow(logo(540), blur=18, op=200).save(f"{O}/logo_b.png")
bar = Image.new("RGBA", (W, 120), (0, 0, 0, 0)); dr = ImageDraw.Draw(bar)
for yy in range(120): dr.line((0, yy, W, yy), fill=(10, 10, 10, int(200 * yy / 119)))
dr.text((44, 52), "ALEXMAR", font=ImageFont.truetype(ANTON, 50), fill=TERRA)
fp = ImageFont.truetype(ANTON, 52); pw = dr.textlength("0416-676 83 93", font=fp)
dr.text((W - 44 - pw, 50), "0416-676 83 93", font=fp, fill=CREAM); bar.save(f"{O}/bar.png")
wm = Image.new("RGBA", (W, H), (0, 0, 0, 0))
txt = Image.new("RGBA", (1400, 400), (0, 0, 0, 0)); ImageDraw.Draw(txt).text((20, 0), "ALEXMAR", font=ImageFont.truetype(ANTON, 300), fill=(255, 255, 255, 20))
txt = txt.rotate(60, expand=True, resample=Image.BICUBIC); wm.alpha_composite(txt, ((W - txt.width) // 2, (H - txt.height) // 2)); wm.save(f"{O}/wm.png")
end = Image.new("RGBA", (W, 820), (0, 0, 0, 0)); dr = ImageDraw.Draw(end)
fk = ImageFont.truetype(M8, 34); sp = 8; k = "AUTOPERIQUITOS Y ROTULADOS"; kw = spaced_w(k, fk, sp); spaced(dr, ((W - kw) / 2, 0), k, fk, CREAM, sp)
fa = ImageFont.truetype(ANTON, 190); b = dr.textbbox((0, 0), "ALEXMAR", font=fa)
dr.text(((W - (b[2] - b[0])) / 2 - b[0], 60 - b[1]), "ALEXMAR", font=fa, fill=TERRA); yy = 60 + (b[3] - b[1]) + 30
dr.rectangle(((W - 160) / 2, yy, (W + 160) / 2, yy + 5), fill=LIGHT); yy += 40
fpn = ImageFont.truetype(ANTON, 120); b = dr.textbbox((0, 0), "0416-676 83 93", font=fpn)
dr.text(((W - (b[2] - b[0])) / 2 - b[0], yy - b[1]), "0416-676 83 93", font=fpn, fill=CREAM); yy += (b[3] - b[1]) + 34
fl = ImageFont.truetype(M4, 38)
for s_, col_ in [("Lunes a sábado · 8 am a 6 pm", CREAM), ("Tovar · Pueblo Llano · @autoalexmar_car", LIGHT)]:
    sw = dr.textlength(s_, font=fl); dr.text(((W - sw) / 2, yy), s_, font=fl, fill=col_); yy += 58
shadow(end.crop((0, 0, W, yy + 10)), blur=16, op=220).save(f"{O}/end.png")

# ---------------- composición ----------------
e0 = st[13]
def fa_(a_, b_): return f"fade=t=in:st={a_:.2f}:d=0.18:alpha=1,fade=t=out:st={b_:.2f}:d=0.15:alpha=1"
idx = {p[0]: i for i, p in enumerate(plan)}
def c_(nm, i0, i1, y, a=0.15): return (nm, st[i0] + a, st[i1] - 0.08, y)
TOP, BOT = 390, 1580
cards = [c_("h", 0, 1, TOP, 0.1), c_("t1", 1, 3, TOP), c_("t3", 3, 4, TOP), c_("t4", 4, 6, TOP),
         c_("t6", 6, 8, TOP), c_("t8", 8, 9, TOP), c_("t9", 9, 10, TOP), c_("t10", 10, 12, TOP),
         c_("b1", 10, 12, BOT, 0.3), c_("b2", 12, 13, BOT)]
L = f"-framerate {FPS} -loop 1 -t {total:.2f}"
names = ["wm", "bar", "logo_s", "logo_b", "end"] + [c[0] for c in cards]
ins = f"-i {S}/base.mp4 " + " ".join(f"{L} -i {O}/{n}.png" for n in names)
sk = list(spots.keys()); ins += " " + " ".join(f"{L} -i {spots[k]}" for k in sk)
f = [f"[1]format=rgba,fade=t=out:st={e0:.2f}:d=0.5:alpha=1[wm]",
     f"[2]format=rgba,fade=t=in:st=0.3:d=0.5:alpha=1,fade=t=out:st={e0:.2f}:d=0.5:alpha=1[bar]",
     f"[3]format=rgba,fade=t=in:st=0.2:d=0.5:alpha=1,fade=t=out:st={e0:.2f}:d=0.5:alpha=1[ls]",
     f"[4]format=rgba,fade=t=in:st={e0+0.3:.2f}:d=0.6:alpha=1[lb]",
     f"[5]format=rgba,fade=t=in:st={e0+0.8:.2f}:d=0.6:alpha=1[en]"]
cur = "0:v"; bi = 6 + len(cards)
for j, k in enumerate(sk):
    i = idx[k]; a_ = st[i]; b_ = st[i] + plan[i][1] - 0.35
    f.append(f"[{bi+j}]format=rgba,fade=t=in:st={a_+0.1:.2f}:d=0.35:alpha=1,fade=t=out:st={b_:.2f}:d=0.3:alpha=1[s{j}]")
    f.append(f"[{cur}][s{j}]overlay=0:0[q{j}]"); cur = f"q{j}"
f += [f"[{cur}][wm]overlay=0:0[a0]", "[a0][bar]overlay=0:H-h[a1]", "[a1][ls]overlay=30:40[a2]"]; cur = "a2"
for i, (nm, a_, b_, y) in enumerate(cards):
    f.append(f"[{6+i}]format=rgba,{fa_(a_, b_)}[c{i}]"); f.append(f"[{cur}][c{i}]overlay=(W-w)/2:{y}-h/2[b{i}]"); cur = f"b{i}"
f += [f"[{cur}][lb]overlay=(W-w)/2:300[e1]", "[e1][en]overlay=(W-w)/2:930,format=yuv420p[v]"]
run(f'ffmpeg -v error -y {ins} -filter_complex "{";".join(f)}" -map "[v]" -an -c:v libx264 -preset medium -crf 19 -r {FPS} -movflags +faststart -t {total:.2f} {D}/alexmar_abiertos_sin_audio.mp4')
print("total", round(total, 2), "starts", [round(x, 2) for x in st])
