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
        fs = ImageFont.truetype(M4, 36); sw = dr.textlength(sub, font=fs)
        dr.text(((W - sw) / 2, y + 6), sub, font=fs, fill=CREAM); y += 58
    im = im.crop((0, 0, W, y + 10)); pad = 50
    band = Image.new("RGBA", (W, im.height + pad * 2), (0, 0, 0, 0)); bd = ImageDraw.Draw(band)
    for yy in range(band.height):
        e = min(yy, band.height - 1 - yy) / pad
        bd.line((0, yy, W, yy), fill=(10, 10, 10, int(160 * min(1, e))))
    band.alpha_composite(shadow(im, blur=16, op=210).crop((48, 48, 48 + W, 48 + im.height)), (0, pad))
    band.save(f"{O}/{name}.png")

card("t1", "AUTOPERIQUITOS Y ROTULADOS ALEXMAR", ["INSTALACIÓN", "DE LUCES LED"], size=124)
card("t2", "FORD CARGO 1721", ["BARRA LED"], col=LIGHT, size=130)
card("t3", "FORD CARGO 1721", ["MARCADORES LED"], col=LIGHT, size=124)
card("t4", "FORD CARGO 1721", ["LUCES LATERALES LED"], col=LIGHT, size=124)
card("t5", "FORD CARGO 1721", ["CINTAS LED"], col=LIGHT, size=130)
card("t6", "FORD CARGO 1721", ["ILUMINACIÓN FRONTAL"], col=LIGHT, size=124)
card("t7", "FORD CARGO 1721", ["MARCADORES", "DE CHASIS LED"], col=LIGHT, size=124)
card("t8", "FORD CARGO 1721", ["LUCES TRASERAS LED"], col=LIGHT, size=124)
lg = Image.open(f"{U}/8316991f-image.jpg").convert("RGB"); g = lg.convert("L")
ink = g.point(lambda v: 255 if v < 200 else 0)
al = ink.filter(ImageFilter.MaxFilter(21)).filter(ImageFilter.MaxFilter(9)).filter(ImageFilter.MinFilter(9)).filter(ImageFilter.GaussianBlur(1.5))
lgi = lg.convert("RGBA"); lgi.putalpha(al); lgi = lgi.crop(lgi.getbbox())
def logo(wd): return lgi.resize((wd, int(lgi.height * wd / lgi.width)), Image.LANCZOS)
shadow(logo(210), blur=10, op=190).save(f"{O}/logo_s.png")
shadow(logo(560), blur=18, op=200).save(f"{O}/logo_b.png")

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
for s_, col_ in [("Ford Cargo · NPR · Walker · FVR · Dina y más", CREAM), ("Tovar · Pueblo Llano · Mérida", LIGHT)]:
    sw = dr.textlength(s_, font=fl); dr.text(((W - sw) / 2, yy), s_, font=fl, fill=col_); yy += 58
shadow(end.crop((0, 0, W, yy + 10)), blur=16, op=220).save(f"{O}/end.png")

