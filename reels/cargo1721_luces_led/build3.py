import os, subprocess
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops
D = os.path.dirname(os.path.abspath(__file__))
U = "/root/.claude/uploads/3312161e-a957-5824-8f73-064addfcce14"
F = os.path.join(D, "..", "npmf", "package", "files")
ANTON = f"{F}/anton-latin-400-normal.woff"; M8 = f"{F}/montserrat-latin-800-normal.woff"; M4 = f"{F}/montserrat-latin-400-normal.woff"
TERRA = (217, 119, 87, 255); LIGHT = (240, 165, 126, 255); CREAM = (245, 240, 232, 255)
W, H, FPS = 1080, 1920, 30
S = f"{D}/seg3"; O = f"{D}/ov2"
os.makedirs(S, exist_ok=True); os.makedirs(O, exist_ok=True)
def run(c): subprocess.run(c, shell=True, check=True)
GRADE = "eq=contrast=1.12:saturation=1.22:brightness=-0.05"

# ---- photo with LED glow boost (only on the real lights detected in the photo)
P1 = f"{U}/d6cb6209-image.jpg"; P2 = f"{U}/2897ee89-image.jpg"
ph = Image.open(P1).convert("RGB"); a = np.asarray(ph).astype(int)
R, G, B = a[..., 0], a[..., 1], a[..., 2]
m = ((R > 200) & (G > 110) & (G < 215) & (B < 120) & (R - B > 110)) | ((B > 170) & (G > 150) & (R < 140) & (B - R > 60))
mask = Image.fromarray((m * 255).astype("uint8")).filter(ImageFilter.MaxFilter(5))
glow_col = Image.new("RGB", ph.size, (255, 150, 40))
g1 = Image.composite(ph, Image.new("RGB", ph.size), mask).filter(ImageFilter.GaussianBlur(18))
g2 = Image.composite(ph, Image.new("RGB", ph.size), mask).filter(ImageFilter.GaussianBlur(6))
glow = ImageChops.screen(ph, ImageChops.screen(g1, g2))
PG = f"{S}/photo_glow.jpg"; glow.save(PG, quality=95)
IW, IH = ph.size

def spot(name, ox, oy, r=330, dark=150):
    im = Image.new("L", (W, H), dark); d = ImageDraw.Draw(im)
    d.ellipse((ox - r, oy - r, ox + r, oy + r), fill=0)
    im = im.filter(ImageFilter.GaussianBlur(r * 0.55))
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0)); out.putalpha(im); out.save(f"{O}/{name}.png")
    return f"{O}/{name}.png"

def photo_punch(name, cx, cy, cw, dur, z0=1.0, z1=1.15, sp=True):
    ch = int(cw * 16 / 9)
    x = int(min(max(cx - cw / 2, 0), IW - cw)); y = int(min(max(cy - ch / 2, 0), IH - ch))
    ox = (cx - x) / cw * W; oy = (cy - y) / ch * H   # light position in output (at z=1)
    n = int(dur * FPS)
    vf = (f"crop={cw}:{ch}:{x}:{y},scale={W*2}:{H*2},"
          f"zoompan=z='{z0}+({z1}-{z0})*on/{n}':x='{ox*2}-{ox*2}/zoom':y='{oy*2}-{oy*2}/zoom':d={n}:s={W}x{H}:fps={FPS},{GRADE},format=yuv420p")
    run(f'ffmpeg -v error -y -loop 1 -i "{PG}" -vf "{vf}" -t {dur} -c:v libx264 -preset veryfast -crf 17 {S}/{name}.mp4')
    return spot(f"sp_{name}", ox, oy) if sp else None

def vid_punch(name, src, ss, dur, cx, cy, z0, z1):
    n = int(dur * FPS)
    vf = (f"scale={W}:{H}:force_original_aspect_ratio=increase,crop={W}:{H},"
          f"zoompan=z='{z0}+({z1}-{z0})*on/{n}':x='max(0,min(iw-iw/zoom,{cx}*iw-iw/zoom/2))':y='max(0,min(ih-ih/zoom,{cy}*ih-ih/zoom/2))':d=1:s={W}x{H}:fps={FPS},{GRADE},format=yuv420p")
    run(f'ffmpeg -v error -y -ss {ss} -t {dur} -i "{src}" -vf "{vf}" -an -c:v libx264 -preset veryfast -crf 17 {S}/{name}.mp4')

def vid_land(name, src, ss, dur, x0, x1):
    vf = (f"[0:v]split[a][b];[a]scale={W}:{H}:force_original_aspect_ratio=increase,crop={W}:{H},boxblur=30:3,eq=brightness=-0.25[bg];"
          f"[b]crop=iw*{x1-x0}:ih:iw*{x0}:0,scale={W}:-2[fg];[bg][fg]overlay=0:(H-h)/2,{GRADE},fps={FPS},format=yuv420p")
    run(f'ffmpeg -v error -y -ss {ss} -t {dur} -i "{src}" -filter_complex "{vf}" -an -c:v libx264 -preset veryfast -crf 17 {S}/{name}.mp4')

def still_full(name, src, dur, z0, z1, dark=0.0, blur=0):
    n = int(dur * FPS); extra = f",boxblur={blur}:2" if blur else ""
    vf = (f"scale={W*2}:{H*2}:force_original_aspect_ratio=increase,crop={W*2}:{H*2},"
          f"zoompan=z='{z0}+({z1}-{z0})*on/{n}':x='iw/2-(iw/zoom/2)':y='ih*0.55-(ih/zoom*0.55)':d={n}:s={W}x{H}:fps={FPS}{extra},eq=brightness={-dark}:contrast=1.1:saturation=1.2,vignette=PI/4,format=yuv420p")
    run(f'ffmpeg -v error -y -loop 1 -i "{src}" -vf "{vf}" -t {dur} -c:v libx264 -preset veryfast -crf 17 {S}/{name}.mp4')

V12 = f"{U}/42d8c74c-VID-20261018-WA0012.mp4"; V14 = f"{U}/bec8ab50-VID-20261018-WA0014.mp4"
V15 = f"{U}/4f3e9030-VID-20261018-WA0015.mp4"; V16 = f"{U}/fbbd82ef-VID-20261018-WA0016.mp4"

plan = [("b1", 2.8, None, 0), ("b2", 2.3, "fadewhite", 0.3), ("b3", 2.3, "zoomin", 0.45),
        ("b4", 2.3, "fadewhite", 0.3), ("b5", 2.4, "smoothleft", 0.4), ("b6", 2.3, "fadewhite", 0.3),
        ("b7", 2.3, "circleopen", 0.45), ("b8", 2.5, "fadewhite", 0.3), ("b9", 2.3, "smoothup", 0.4),
        ("b10", 1.1, "fadewhite", 0.3), ("b11", 4.6, "fade", 0.6)]
d = dict((p[0], p[1]) for p in plan)
spots = {}
still_full("b1", PG, d["b1"], 1.0, 1.14)
spots["b2"] = photo_punch("b2", 1059, 1520, 560, d["b2"])                 # LED bar
vid_punch("b3", V16, 0.6, d["b3"], 0.45, 0.93, 1.6, 1.8)                 # LED bar in motion
spots["b4"] = photo_punch("b4", 696, 1736, 480, d["b4"])                  # lower amber LED markers
vid_land("b5", V12, 0.3, d["b5"], 0.30, 0.95)                              # bumper pass: markers + bar
spots["b6"] = photo_punch("b6", 380, 1080, 440, d["b6"])                  # cab-side LED square + step light
spots["b7"] = photo_punch("b7", 560, 1260, 440, d["b7"])                 # grille amber + LED strip
vid_punch("b8", V15, 0.2, d["b8"], 0.47, 0.72, 1.9, 2.1)                   # front lights blinking
vid_punch("b9", V14, 20.0, d["b9"], 0.34, 0.32, 1.7, 1.9)                 # chassis LED marker
vid_punch("b10", V14, 24.3, d["b10"], 0.3, 0.62, 1.3, 1.4)               # side LED marker close
still_full("b11", P2, d["b11"], 1.12, 1.0, dark=0.33, blur=6)

inputs = " ".join(f"-i {S}/{p[0]}.mp4" for p in plan)
fc = []; prev = "[0:v]"; t = 0.0; st = [0.0]
for i in range(1, len(plan)):
    t += plan[i - 1][1] - plan[i][3]; st.append(t)
    fc.append(f"{prev}[{i}:v]xfade=transition={plan[i][2]}:duration={plan[i][3]}:offset={t:.3f}[x{i}]"); prev = f"[x{i}]"
total = t + plan[-1][1]
run(f'ffmpeg -v error -y {inputs} -filter_complex "{";".join(fc)}" -map "{prev}" -c:v libx264 -preset veryfast -crf 17 {S}/base.mp4')

exec(open(f"{D}/ov_part.py").read())

e0 = st[10]
def fa_(a_, b_): return f"fade=t=in:st={a_:.2f}:d=0.35:alpha=1,fade=t=out:st={b_:.2f}:d=0.3:alpha=1"
idx = {p[0]: i for i, p in enumerate(plan)}
cards = [("t1", st[0] + 0.4, st[1] - 0.15, 640), ("t2", st[1] + 0.25, st[3] - 0.1, 400),
         ("t3", st[3] + 0.25, st[5] - 0.1, 400), ("t4", st[5] + 0.25, st[6] - 0.1, 400),
         ("t5", st[6] + 0.25, st[7] - 0.1, 400), ("t6", st[7] + 0.25, st[8] - 0.1, 400),
         ("t7", st[8] + 0.25, st[9] - 0.05, 400), ("t8", st[9] + 0.15, st[10] - 0.05, 400)]
L = f"-framerate {FPS} -loop 1 -t {total:.2f}"
names = ["wm", "bar", "logo_s", "logo_b", "end"] + [c[0] for c in cards]
ins = f"-i {S}/base.mp4 " + " ".join(f"{L} -i {O}/{n}.png" for n in names)
spot_keys = list(spots.keys())
ins += " " + " ".join(f"{L} -i {spots[k]}" for k in spot_keys)
f = [f"[1]format=rgba,fade=t=out:st={e0:.2f}:d=0.5:alpha=1[wm]",
     f"[2]format=rgba,fade=t=in:st=0.3:d=0.5:alpha=1,fade=t=out:st={e0:.2f}:d=0.5:alpha=1[bar]",
     f"[3]format=rgba,fade=t=in:st=0.2:d=0.5:alpha=1,fade=t=out:st={e0:.2f}:d=0.5:alpha=1[ls]",
     f"[4]format=rgba,fade=t=in:st={e0+0.3:.2f}:d=0.6:alpha=1[lb]",
     f"[5]format=rgba,fade=t=in:st={e0+0.8:.2f}:d=0.6:alpha=1[en]"]
cur = "0:v"
base_i = 6 + len(cards)
for k_i, k in enumerate(spot_keys):
    i = idx[k]; a_ = st[i]; b_ = st[i] + plan[i][1] - 0.35
    f.append(f"[{base_i+k_i}]format=rgba,fade=t=in:st={a_+0.1:.2f}:d=0.35:alpha=1,fade=t=out:st={b_:.2f}:d=0.3:alpha=1[s{k_i}]")
    f.append(f"[{cur}][s{k_i}]overlay=0:0[q{k_i}]"); cur = f"q{k_i}"
f += [f"[{cur}][wm]overlay=0:0[a0]", "[a0][bar]overlay=0:H-h[a1]", "[a1][ls]overlay=30:40[a2]"]
cur = "a2"
for i, (nm, a_, b_, y) in enumerate(cards):
    f.append(f"[{6+i}]format=rgba,{fa_(a_, b_)}[c{i}]"); f.append(f"[{cur}][c{i}]overlay=(W-w)/2:{y}-h/2[b{i}]"); cur = f"b{i}"
f += [f"[{cur}][lb]overlay=(W-w)/2:300[e1]", "[e1][en]overlay=(W-w)/2:930,format=yuv420p[v]"]
run(f'ffmpeg -v error -y {ins} -filter_complex "{";".join(f)}" -map "[v]" -an -c:v libx264 -preset medium -crf 19 -r {FPS} -movflags +faststart -t {total:.2f} {D}/alexmar_luces_led_v3.mp4')
print("total", round(total, 2), "starts", [round(x, 2) for x in st])
