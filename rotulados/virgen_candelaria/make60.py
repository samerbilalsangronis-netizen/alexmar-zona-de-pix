from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.boundsPen import BoundsPen
f = TTFont("fonts/damion/package/files/damion-latin-400-normal.woff")
gs = f.getGlyphSet(); cmap = f.getBestCmap(); upm = f["head"].unitsPerEm
hm = f["hmtx"]
def text_path(t, size, x0, base):
    s = size / upm; x = 0; parts = []
    for ch in t:
        g = cmap[ord(ch)]; pen = SVGPathPen(gs); gs[g].draw(pen)
        d = pen.getCommands()
        if d: parts.append(f'<path transform="translate({x0 + x * s:.2f},{base}) scale({s:.5f},{-s:.5f})" d="{d}"/>')
        x += hm[g][0]
    return "\n".join(parts), x * s
txt, tw = text_path("Virgen de la Candelaria", 150, 0, 0)

# silueta de la Virgen (estilo esténcil, todo negro; cara en blanco con evenodd)
virgen = '''
<g fill="#000">
  <!-- aureola de rayos (de r=46 a r=74, sin tocar la cara) -->
  <g>
    ''' + "\n    ".join(
      (lambda a, m=__import__("math"): f'<path d="M{100+46*m.cos(m.radians(a-4.5)):.1f} {62-46*m.sin(m.radians(a-4.5)):.1f} L{100+74*m.cos(m.radians(a-3.2)):.1f} {62-74*m.sin(m.radians(a-3.2)):.1f} L{100+74*m.cos(m.radians(a+3.2)):.1f} {62-74*m.sin(m.radians(a+3.2)):.1f} L{100+46*m.cos(m.radians(a+4.5)):.1f} {62-46*m.sin(m.radians(a+4.5)):.1f} Z"/>')(a)
      for a in range(18, 170, 18)) + '''
  </g>
  <!-- corona -->
  <path d="M78 34 L84 14 L92 28 L100 8 L108 28 L116 14 L122 34 Z"/>
  <!-- manto (velo + vestido acampanado) con la cara recortada -->
  <path fill-rule="evenodd" d="
    M100 32 C80 32 70 48 70 68 C70 90 60 110 52 140 C40 185 30 230 22 268 C60 276 140 276 178 268
    C170 230 160 185 148 140 C140 110 130 90 130 68 C130 48 120 32 100 32 Z
    M100 48 C110 48 116 58 116 70 C116 84 109 94 100 94 C91 94 84 84 84 70 C84 58 90 48 100 48 Z"/>
  <!-- Niño en el brazo (izquierda del espectador) -->
  <g stroke="#fff" stroke-width="5" stroke-linejoin="round">
    <path d="M64 128 C60 140 55 156 52 172 C64 178 84 178 94 172 C91 156 86 140 82 128 C78 124 68 124 64 128 Z"/>
    <circle cx="73" cy="115" r="11"/>
  </g>
  <!-- vela en la otra mano -->
  <g stroke="#fff" stroke-width="5" stroke-linejoin="round">
    <rect x="140" y="104" width="10" height="64" rx="2"/>
    <path d="M145 76 C155 88 155 98 145 102 C135 98 135 88 145 76 Z"/>
  </g>
  <!-- media luna a los pies -->
  <path d="M20 272 C60 300 140 300 180 272 C150 286 50 286 20 272 Z"/>
</g>'''
from fontTools.pens.boundsPen import BoundsPen
# medir el texto real (incluye la cola de la g)
def text_bounds(t):
    x = 0; xmin = ymin = 1e9; xmax = ymax = -1e9
    for ch in t:
        g = cmap[ord(ch)]; bp = BoundsPen(gs); gs[g].draw(bp)
        if bp.bounds:
            b = bp.bounds; xmin = min(xmin, x + b[0]); xmax = max(xmax, x + b[2]); ymin = min(ymin, b[1]); ymax = max(ymax, b[3])
        x += hm[g][0]
    return xmin, xmax, ymin, ymax
T = "Virgen de la Candelaria"
bx0, bx1, by0, by1 = text_bounds(T)
# lienzo en milímetros: 600 x 80 (60 x 8 cm)
WMM, HMM, M = 600.0, 80.0, 3.0
VX0, VX1, VY0, VY1 = 20, 180, -14, 296            # caja de la silueta en sus unidades
vh = HMM - 2 * M; vs = vh / (VY1 - VY0); vw = (VX1 - VX0) * vs
gap = 10.0
tw_avail = WMM - 2 * M - vw - gap
ts = min(tw_avail / (bx1 - bx0), (HMM - 2 * M) * 0.92 / (by1 - by0))   # escala del texto (mm por unidad)
tw = (bx1 - bx0) * ts; th = (by1 - by0) * ts
tx = M + vw + gap + (tw_avail - tw) / 2 - bx0 * ts
ty = HMM / 2 + (by1 + by0) / 2 * ts                 # baseline para centrar verticalmente
size = ts * upm
txt, _ = text_path(T, size, 0, 0)
svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {WMM} {HMM}" width="{WMM/10}cm" height="{HMM/10}cm">
<rect width="100%" height="100%" fill="#fff"/>
<g transform="translate({M - VX0*vs:.3f},{M - VY0*vs:.3f}) scale({vs:.5f})">{virgen}</g>
<g fill="#000" transform="translate({tx:.3f},{ty:.3f})">{txt}</g>
</svg>'''
open("virgen_de_la_candelaria_60x8.svg", "w").write(svg)
open("virgen_de_la_candelaria_60x8_sin_fondo.svg", "w").write(svg.replace('<rect width="100%" height="100%" fill="#fff"/>\n', ''))
print("texto alto mm", round(th,1), "virgen alto mm", round(vh,1), "ancho virgen", round(vw,1), "texto ancho", round(tw,1))
