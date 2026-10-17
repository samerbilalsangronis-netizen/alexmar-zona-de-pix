"""Propuestas A y B. Cada pieza devuelve la lista de capas (máscara, color) de abajo hacia arriba."""
from kit import *

PH_TICKET = 'TICKET  $ XX'
PH_SORTEO = 'SORTEO  XX/XX'
PH_TEL = '04XX-XXX XX XX'
CREDIT = 'Rotulado por ALEXMAR · 0416-676 83 93'


def M(size):
    return Image.new('L', size, 0)


def line(size, x0, y0, x1, y1, w):
    m = M(size)
    ImageDraw.Draw(m).rounded_rectangle([x0, y0 - w / 2, x1, y0 + w / 2] if y0 == y1 else [x0 - w / 2, y0, x0 + w / 2, y1], radius=w / 2, fill=255)
    return m


# ---------------- PROPUESTA A · "Corona Premium" ----------------
def rear_A():
    S = (1700, 500)
    crown, laur, _ = crown_masks(S, 300, 18, 260)
    rifas = text_mask(S, 'RIFAS', F_SERIF, 72, 430, 232, tracking=6)
    prest = text_mask(S, 'PRESTIGIO', F_SERIF, 72, 430, 322, max_w=560, tracking=4)
    tag = text_mask(S, 'EXCLUSIVIDAD Y FORTUNA', F_SANS, 25, 430, 388, max_w=520, tracking=3)
    l1 = line(S, 200, 420, 660, 420, 5)
    div = line(S, 860, 70, 860, 430, 6)
    g1 = text_mask(S, '¡GÁNATE', F_BLACK, 100, 1275, 125, max_w=700)
    g2 = text_mask(S, 'ESTE CARRO!', F_BLACK, 100, 1275, 250, max_w=740)
    info = text_mask(S, PH_TICKET + '   ·   ' + PH_SORTEO, F_SANS, 34, 1275, 338, max_w=720)
    tel = text_mask(S, PH_TEL, F_BLACK, 52, 1275, 418, max_w=560, tracking=3)
    cred = text_mask(S, CREDIT, F_SANS, 15, 1275, 478)
    white_txt = add(rifas, prest)
    return S, [
        (grow(white_txt, 7), 'green'),           # contorno verde (capa de abajo)
        (laur, 'green'), (tag, 'green'), (g1, 'green'), (tel, 'green'),
        (white_txt, WHITE), (g2, WHITE), (info, WHITE), (cred, WHITE),
        (crown, 'holo'), (l1, 'holo'), (div, 'holo'),
    ]


def side_A():
    S = (800, 600)
    g1 = text_mask(S, '¡GÁNATE', F_BLACK, 98, 400, 120, max_w=700)
    g2 = text_mask(S, 'ESTE', F_BLACK, 98, 400, 238, max_w=700)
    g3 = text_mask(S, 'CARRO!', F_BLACK, 98, 400, 356, max_w=700)
    l1 = line(S, 150, 432, 650, 432, 7)
    tel = text_mask(S, PH_TEL, F_BLACK, 46, 400, 508, max_w=680, tracking=2)
    return S, [(g1, 'green'), (tel, 'green'), (g2, WHITE), (g3, WHITE), (l1, 'holo')]


def quarter_A():
    S = (320, 618)
    crown, laur, _ = crown_masks(S, 45, 380, 230, laurels=False)
    return S, [(crown, 'holo')]


def wind_A():
    S = (1500, 152)
    t = text_mask(S, 'RIFAS PRESTIGIO', F_SERIF, 66, 750, 80, tracking=10, max_w=1020)
    c1, _, _ = crown_masks(S, 70, 34, 140, laurels=False)
    c2, _, _ = crown_masks(S, 1290, 34, 140, laurels=False)
    return S, [(grow(t, 6), 'green'), (t, WHITE), (add(c1, c2), 'holo')]


# ---------------- PROPUESTA B · "Franja de Impacto" ----------------
def rear_B():
    S = (1700, 500)
    band = M(S)
    ImageDraw.Draw(band).rounded_rectangle([40, 330, 1660, 462], radius=22, fill=255)
    slogan = text_mask(S, '¡GÁNATE ESTE CARRO!', F_BLACK, 86, 850, 396, max_w=1500, tracking=4)
    crown, laur, _ = crown_masks(S, 215, 40, 230, laurels=True)
    rp = text_mask(S, 'RIFAS PRESTIGIO', F_SERIF, 84, 1010, 120, max_w=1000, tracking=6)
    tag = text_mask(S, 'EXCLUSIVIDAD Y FORTUNA', F_SANS, 26, 1010, 200, max_w=700, tracking=4)
    l1 = line(S, 560, 200, 700, 200, 5)
    l2 = line(S, 1320, 200, 1460, 200, 5)
    info = text_mask(S, PH_TICKET + '   |   ' + PH_SORTEO + '   |   ' + PH_TEL, F_SANS, 34, 850, 280, max_w=1500)
    cred = text_mask(S, CREDIT, F_SANS, 15, 850, 484)
    return S, [
        (band, 'green'), (laur, 'green'), (tag, 'green'),
        (slogan, BLACK),                      # negro encima del verde (papel sobre papel)
        (rp, WHITE), (info, WHITE), (cred, WHITE),
        (crown, 'holo'), (l1, 'holo'), (l2, 'holo'),
    ]


def side_B():
    S = (800, 600)
    # franjas diagonales de carrera abajo
    stripes = M(S)
    d = ImageDraw.Draw(stripes)
    d.polygon([(0, 445), (800, 405), (800, 600), (0, 600)], fill=255)
    cut = M(S)
    ImageDraw.Draw(cut).polygon([(0, 430), (800, 390), (800, 400), (0, 440)], fill=255)
    thin = M(S)
    ImageDraw.Draw(thin).polygon([(0, 415), (800, 375), (800, 383), (0, 423)], fill=255)
    t1 = text_mask(S, '¡GÁNATELO!', F_BLACK, 104, 400, 120, max_w=740)
    t2 = text_mask(S, 'RIFAS PRESTIGIO', F_SERIF, 50, 400, 245, max_w=700, tracking=4)
    t3 = text_mask(S, PH_TICKET, F_SANS, 40, 400, 330, max_w=600)
    tel = text_mask(S, PH_TEL, F_BLACK, 52, 400, 515, max_w=700, tracking=2)
    return S, [(stripes, 'green'), (t3, 'green'), (tel, BLACK), (t1, WHITE), (t2, 'holo'), (thin, 'holo')]


def quarter_B():
    S = (320, 618)
    full = Image.new('L', S, 255)
    crown, _, _ = crown_masks(S, 45, 380, 230, laurels=False)
    return S, [(full, 'green'), (crown, BLACK)]


def wind_B():
    S = (1500, 152)
    full = Image.new('L', S, 255)
    t = text_mask(S, 'RIFAS PRESTIGIO', F_BLACK, 68, 750, 80, tracking=10, max_w=860)
    c1, _, _ = crown_masks(S, 135, 36, 130, laurels=False)
    c2, _, _ = crown_masks(S, 1235, 36, 130, laurels=False)
    return S, [(full, 'green'), (add(t, c1, c2), BLACK)]
