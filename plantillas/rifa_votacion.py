"""Historia de votación A/B del rotulado del carro de la rifa (Rifas Prestigio)."""
from PIL import Image, ImageDraw, ImageEnhance
src = open('/home/claude/alexmar-zona-de-pix/plantillas/overlays_reel.py').read().split("card('01'")[0]
exec(src)
R = '/home/claude/alexmar-zona-de-pix/rotulados/rifa_prestigio/'
OUT = '/home/claude/alexmar-zona-de-pix/historias/'

def panel(path, box, w, h):
    im = Image.open(path).convert('RGB').crop(box).resize((w, h), Image.LANCZOS)
    return ImageEnhance.Contrast(im).enhance(1.05)

c = Image.new('RGBA', (W, H), BK + (255,))
box = (190, 640, 1750, 1521)
c.paste(panel(R + 'mock_A_trasera.jpg', box, W, 610), (0, 500))
c.paste(panel(R + 'mock_B_trasera.jpg', box, W, 610), (0, 1170))
c.alpha_composite(base(top_shade=False))
d = ImageDraw.Draw(c)
d.rectangle((0, 1110, W, 1170), fill=OR)
tc(d, W / 2, 288, '¿CUÁL LE PONEMOS', F('Anton.ttf', 86), CR, 3, BK)
tc(d, W / 2, 388, 'AL CARRO DE LA RIFA?', F('Anton.ttf', 86), OR, 3, BK)
pill(d, W / 2, 522, 'A  ·  CORONA PREMIUM', F('Mont900.ttf', 36), fill=CR)
pill(d, W / 2, 1192, 'B  ·  FRANJA DE IMPACTO', F('Mont900.ttf', 36), fill=OR)
f = F('Mont900.ttf', 34)
tc(d, W / 2, 1806, '¡VOTA Y TE LO MOSTRAMOS TERMINADO!', f, CR, 2, BK)
tc(d, W / 2, 1858, 'Rotulados ALEXMAR  ·  Tovar  ·  Pueblo Llano', F('Mont700.ttf', 28), ORL, 2, BK)
name = OUT + '2026-10-17_rifa_votacion_A_o_B_historia_1080x1920'
c.convert('RGB').save(name + '.jpg', quality=93)
print(name)
