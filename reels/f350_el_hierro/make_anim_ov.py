"""Reel Ford F-350 plataforma: instalación de luces (base: mercancía nueva): vasos para lámparas láser IVICA (rojos y amarillos) + rines Hercules para NPR.
Uso: python3 build_mercancia.py <carpeta_con_videos>
Videos: v20261021_102324 / 102433 (descarga del camión), 102514 (cajas IVICA y Hercules en tienda),
        103633 (destapando vasos IVICA), 103938 (caja rines 17.5x6.0), 103732 / 103749 (rin de cerca)."""
import os, sys, subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter
D = os.path.dirname(os.path.abspath(__file__)); R = os.path.join(D, "..", "..", "plantillas")
V = sys.argv[1] if len(sys.argv) > 1 else D
FT = f"{R}/fonts"; ANTON = f"{FT}/Anton.ttf"; M8 = f"{FT}/Mont900.ttf"; M4 = f"{FT}/Mont700.ttf"
TERRA = (217, 119, 87, 255); LIGHT = (240, 165, 126, 255); CREAM = (245, 240, 232, 255)
W, H, FPS = 1080, 1920, 30
S = f"{D}/seg"; O = f"{D}/anim_ov"; os.makedirs(S, exist_ok=True); os.makedirs(O, exist_ok=True)
def run(c): subprocess.run(c, shell=True, check=True)
GRADE = "eq=contrast=1.11:saturation=1.20:brightness=-0.03"

def vid_punch(name, src, ss, dur, cx, cy, z0, z1, extra="", kick=0.14):
    n = int(dur * FPS)
    vf = (f"scale={W}:{H}:force_original_aspect_ratio=increase,crop={W}:{H},fps={FPS},"
          f"zoompan=z='{z0}+({z1}-{z0})*on/{n}+{kick}*exp(-on/4)':x='max(0,min(iw-iw/zoom,{cx}*iw-iw/zoom/2))':y='max(0,min(ih-ih/zoom,{cy}*ih-ih/zoom/2))':d=1:s={W}x{H}:fps={FPS},{GRADE}{extra},format=yuv420p")
    run(f'ffmpeg -v error -y -ss {ss} -t {dur} -i "{src}" -vf "{vf}" -an -c:v libx264 -preset veryfast -crf 17 {S}/{name}.mp4')

def photo_punch(name, src, dur, cx, cy, z0, z1, extra="", kick=0.14):
    n = int(dur * FPS)
    vf = (f"scale={W*2}:{H*2}:force_original_aspect_ratio=increase,crop={W*2}:{H*2},"
          f"zoompan=z='{z0}+({z1}-{z0})*on/{n}+{kick}*exp(-on/4)':x='max(0,min(iw-iw/zoom,{cx}*iw-iw/zoom/2))':y='max(0,min(ih-ih/zoom,{cy}*ih-ih/zoom/2))':d={n}:s={W}x{H}:fps={FPS},{GRADE}{extra},format=yuv420p")
    run(f'ffmpeg -v error -y -loop 1 -i "{src}" -vf "{vf}" -t {dur} -c:v libx264 -preset veryfast -crf 17 {S}/{name}.mp4')

def spot(name, ox, oy, r=360, dark=140):
    im = Image.new("L", (W, H), dark); d = ImageDraw.Draw(im)
    d.ellipse((ox - r, oy - r, ox + r, oy + r), fill=0); im = im.filter(ImageFilter.GaussianBlur(r * 0.55))
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0)); out.putalpha(im); out.save(f"{O}/{name}.png"); return f"{O}/{name}.png"

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


card("a1", "AUTOPERIQUITOS Y ROTULADOS ALEXMAR", ["LUZ LATERAL"], col=LIGHT, size=150, sub="Para camiones y plataformas")
card("a2", "", ["CONOCE LA PIEZA"], col=CREAM, size=110)
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

base = Image.new("RGBA", (W, H), (0, 0, 0, 0))
base.alpha_composite(Image.open(f"{O}/wm.png"))
b = Image.open(f"{O}/bar.png"); base.alpha_composite(b, (0, H - b.height))
l = Image.open(f"{O}/logo_s.png"); base.alpha_composite(l, (30, 40))
base.save(f"{O}/anim_base.png")
print("ok")
