import sys
from kit import *
import designs as D

REAR = '1001900747.jpg'; SIDE = '1001900746.jpg'; FRONT = '1001900744.jpg'

# Coordenadas en las fotos originales
REAR_BOX = (395, 842, 1545, 1180)
REAR_POLY = [(478, 822), (1448, 822), (1522, 885), (1568, 1000), (1585, 1180), (1575, 1240),
             (1530, 1265), (430, 1265), (378, 1240), (366, 1180), (382, 1000), (420, 885)]
DOOR_BOX = (1568, 500, 1928, 768)
DOOR_POLY = [(1556, 488), (1936, 488), (1936, 770), (1540, 772)]
QTR_BOX = (1950, 505, 2085, 766)
QTR_POLY = [(1956, 502), (1965, 505), (2020, 575), (2075, 665), (2077, 765), (1956, 765)]
WIND_BOX = (505, 604, 1375, 690)
WIND_POLY = [(565, 606), (1318, 606), (1372, 692), (512, 692)]


def render(S, layers):
    return compose(S, layers)


def build(tag):
    rear = getattr(D, 'rear_' + tag)(); side = getattr(D, 'side_' + tag)()
    qtr = getattr(D, 'quarter_' + tag)(); wind = getattr(D, 'wind_' + tag)()
    out = {}
    p = Image.open(REAR).convert('RGB')
    p = apply_on_photo(p, render(*rear), REAR_BOX, REAR_POLY)
    out['trasera'] = p
    p = Image.open(SIDE).convert('RGB')
    p = apply_on_photo(p, render(*side), DOOR_BOX, DOOR_POLY)
    p = apply_on_photo(p, render(*qtr), QTR_BOX, QTR_POLY)
    out['lateral'] = p
    p = Image.open(FRONT).convert('RGB')
    p = apply_on_photo(p, render(*wind), WIND_BOX, WIND_POLY)
    out['frontal'] = p
    for k, im in out.items():
        im.save(f'mock_{tag}_{k}.jpg', quality=92)
    return out


if __name__ == '__main__':
    for t in sys.argv[1:] or ['A', 'B']:
        build(t)
