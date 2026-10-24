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
      (lambda a, m=__import__("math"): f'<path d="M{100+46*m.cos(m.radians(a-2.2)):.1f} {62-46*m.sin(m.radians(a-2.2)):.1f} L{100+74*m.cos(m.radians(a-1.2)):.1f} {62-74*m.sin(m.radians(a-1.2)):.1f} L{100+74*m.cos(m.radians(a+1.2)):.1f} {62-74*m.sin(m.radians(a+1.2)):.1f} L{100+46*m.cos(m.radians(a+2.2)):.1f} {62-46*m.sin(m.radians(a+2.2)):.1f} Z"/>')(a)
      for a in range(14, 170, 12)) + '''
  </g>
  <!-- corona -->
  <path d="M78 34 L84 14 L92 28 L100 8 L108 28 L116 14 L122 34 Z"/>
  <!-- manto (velo + vestido acampanado) con la cara recortada -->
  <path fill-rule="evenodd" d="
    M100 32 C80 32 70 48 70 68 C70 90 60 110 52 140 C40 185 30 230 22 268 C60 276 140 276 178 268
    C170 230 160 185 148 140 C140 110 130 90 130 68 C130 48 120 32 100 32 Z
    M100 48 C110 48 116 58 116 70 C116 84 109 94 100 94 C91 94 84 84 84 70 C84 58 90 48 100 48 Z"/>
  <!-- Niño en el brazo (izquierda del espectador) -->
  <g stroke="#fff" stroke-width="3.5" stroke-linejoin="round">
    <path d="M64 128 C60 140 55 156 52 172 C64 178 84 178 94 172 C91 156 86 140 82 128 C78 124 68 124 64 128 Z"/>
    <circle cx="73" cy="115" r="11"/>
  </g>
  <!-- vela en la otra mano -->
  <g stroke="#fff" stroke-width="3.5" stroke-linejoin="round">
    <rect x="140" y="104" width="10" height="64" rx="2"/>
    <path d="M145 76 C155 88 155 98 145 102 C135 98 135 88 145 76 Z"/>
  </g>
  <!-- media luna a los pies -->
  <path d="M20 272 C60 300 140 300 180 272 C150 286 50 286 20 272 Z"/>
</g>'''
H_TXT = 150
vh = 300; scale_v = 2.0                # virgen 600 de alto
W = int(200 * scale_v + 60 + tw + 40)
Hh = int(vh * scale_v + 70)
base = Hh * 0.62
svg = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {Hh}" width="{W}" height="{Hh}">
<rect width="100%" height="100%" fill="#fff"/>
<g transform="translate(10,40) scale({scale_v})">{virgen}</g>
<g fill="#000" transform="translate({int(200*scale_v + 60)},{base:.1f})">{txt}</g>
</svg>'''
open("virgen_de_la_candelaria.svg", "w").write(svg)
# versión sin fondo para Corel
open("virgen_de_la_candelaria_sin_fondo.svg", "w").write(svg.replace('<rect width="100%" height="100%" fill="#fff"/>\n', ''))
print(W, Hh)
