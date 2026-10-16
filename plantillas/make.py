import sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance, ImageChops
S='/tmp/claude-0/-home-claude/ea00b5f3-b07d-5263-8d5f-f3ee0bdba86b/scratchpad/fonts/'
F=lambda n,s: ImageFont.truetype(S+n,s)
OR=(217,119,87); ORL=(240,165,126); BK=(26,26,26); CH=(43,43,43); CR=(245,240,232)
U='/mnt/user-data/uploads/'
LOGO_SRC='/root/.claude/uploads/ea00b5f3-b07d-5263-8d5f-f3ee0bdba86b/27fc7394-Collage_Vertical_Recuerdos_del_Verano_Aesthetic_Blanco_Post_de_Instagram.png'
OUT='/home/claude/pisos/out/'
import os; os.makedirs(OUT,exist_ok=True)

def logo():
    im=Image.open(LOGO_SRC).convert('RGBA')
    w,h=im.size
    # flood-fill outer white -> transparent
    rgb=im.convert('RGB')
    marker=(1,2,3)
    for p in [(0,0),(w-1,0),(0,h-1),(w-1,h-1)]:
        ImageDraw.floodfill(rgb,p,marker,thresh=40)
    px=rgb.load(); a=im.copy(); ap=a.load()
    for y in range(h):
        for x in range(w):
            if px[x,y]==marker: ap[x,y]=(0,0,0,0)
    a=a.crop(a.getbbox())
    # sticker outline so dark strokes read on dark backgrounds
    al=a.split()[3]
    big=Image.new('L',(a.width+40,a.height+40),0); big.paste(al,(20,20))
    ring=big.filter(ImageFilter.MaxFilter(25)).filter(ImageFilter.GaussianBlur(1.5))
    st=Image.new('RGBA',big.size,(245,240,232,0)); st.putalpha(ring)
    st.alpha_composite(a,(20,20))
    return st
LOGO=logo()

# name, file, line1 (vehicle), extra tag, product bbox in original px (x0,y0,x1,y1)
ITEMS=[
 ('01_hembrita_doble_cabina','1792081297648_image.png','TOYOTA HEMBRITA','DOBLE CABINA',(30,140,900,1140)),
 ('02_4runner_3_filas','1792081322282_image.png','TOYOTA 4RUNNER','3 FILAS DE ASIENTOS',(80,50,900,1215)),
 ('03_agya','1792081361313_image.png','TOYOTA AGYA','JUEGO COMPLETO',(0,270,960,1050)),
 ('04_jac_arena','1792081444309_image.png','JAC ARENA','JUEGO COMPLETO',(20,260,930,1105)),
 ('05_agya_maletero','1792081476518_image.png','TOYOTA AGYA','+ BANDEJA DE MALETERO',(90,260,925,1125)),
 ('06_hembrita','1792081502454_image.png','TOYOTA HEMBRITA','JUEGO DELANTERO',(0,430,960,1030)),
 ('07_hilux_kavak','1792081528511_image.png','TOYOTA HILUX KAVAK','DOBLE CABINA',(55,275,950,1090)),
]

def text_c(d,cx,y,t,f,fill,stroke=0,sf=None):
    w=d.textlength(t,font=f); d.text((cx-w/2,y),t,font=f,fill=fill,stroke_width=stroke,stroke_fill=sf)

def fit_font(d,t,name,size,maxw):
    while size>20:
        f=F(name,size)
        if d.textlength(t,font=f)<=maxw: return f
        size-=2
    return F(name,size)

def watermark(W,H):
    wm=Image.new('RGBA',(W*2,H*2),(0,0,0,0)); d=ImageDraw.Draw(wm); f=F('Anton.ttf',70)
    for yi,y in enumerate(range(0,H*2,190)):
        off=(yi%2)*200
        for x in range(-400+off,W*2,420):
            d.text((x,y),'ALEXMAR',font=f,fill=(245,240,232,13))
    wm=wm.rotate(28,resample=Image.BICUBIC)
    return wm.crop((W//2,H//2,W//2+W,H//2+H))

def build(item,W,H):
    name,fn,veh,tag,bb=item
    src=Image.open(U+fn).convert('RGB')
    src=ImageEnhance.Contrast(src).enhance(1.08); src=ImageEnhance.Color(src).enhance(1.05)
    story=H>1500
    top=470 if story else 300; bot=H-(470 if story else 230)
    # background: same photo cover-scaled, blurred & darkened
    sc=max(W/src.width,H/src.height)
    bg=src.resize((int(src.width*sc),int(src.height*sc)),Image.LANCZOS)
    bg=bg.crop(((bg.width-W)//2,(bg.height-H)//2,(bg.width-W)//2+W,(bg.height-H)//2+H))
    bg=bg.filter(ImageFilter.GaussianBlur(28)); bg=ImageEnhance.Brightness(bg).enhance(0.45)
    canvas=bg.convert('RGBA')
    # foreground photo scaled so product fits zone
    bw=bb[2]-bb[0]; bh=bb[3]-bb[1]
    s=min((bot-top-20)/bh,(W-40)/bw)
    fg=src.resize((int(src.width*s),int(src.height*s)),Image.LANCZOS)
    cx=(bb[0]+bb[2])/2*s; cy=(bb[1]+bb[3])/2*s
    ox=int(W/2-cx); oy=int((top+bot)/2-cy)
    # feather mask
    m=Image.new('L',fg.size,0); md=ImageDraw.Draw(m)
    fe=60
    md.rectangle((fe,fe,fg.width-fe,fg.height-fe),fill=255)
    m=m.filter(ImageFilter.GaussianBlur(fe/2))
    canvas.paste(fg,(ox,oy),m)
    # gradients for bands
    g=Image.new('RGBA',(W,H),(0,0,0,0)); gd=ImageDraw.Draw(g)
    for y in range(H):
        a=0
        if y<top+40: a=int(235*min(1,(top+40-y)/110)) if y>top-70 else 235
        if y>bot-40: a=max(a,int(240*min(1,(y-(bot-40))/110)))
        gd.line([(0,y),(W,y)],fill=(26,26,26,a))
    canvas=Image.alpha_composite(canvas,g)
    canvas=Image.alpha_composite(canvas,watermark(W,H))
    d=ImageDraw.Draw(canvas)
    # header
    lh=240 if story else 190
    lg=LOGO.resize((int(LOGO.width*lh/LOGO.height),lh),Image.LANCZOS)
    pad=34
    y0=70 if story else 26
    canvas.alpha_composite(lg,(pad,y0))
    tx=pad+lg.width+26; tw=W-tx-pad
    # pill
    fp=F('Mont900.ttf',26 if story else 22)
    pt='ORIGINALES'; pw=d.textlength(pt,font=fp)
    d.rounded_rectangle((tx,y0+6,tx+pw+36,y0+6+(48 if story else 40)),radius=24,fill=OR)
    d.text((tx+18,y0+(15 if story else 12)),pt,font=fp,fill=BK)
    fh=fit_font(d,'PISOS 5D','Anton.ttf',120 if story else 100,tw)
    hy=y0+(58 if story else 44)
    d.text((tx,hy),'PISOS 5D',font=fh,fill=CR)
    hy+=int(fh.size*1.18)
    fs=fit_font(d,'TIPO BANDEJA','Mont900.ttf',44 if story else 36,tw)
    d.text((tx,hy),'TIPO BANDEJA',font=fs,fill=ORL)
    # vehicle line under header, full width
    vy=y0+lh+(30 if story else 12)
    fv=fit_font(d,veh,'Anton.ttf',96 if story else 64,W-2*pad)
    if story:
        text_c(d,W/2,vy,veh,fv,OR,3,BK)
        ft=fit_font(d,tag,'Mont700.ttf',38,W-2*pad)
        text_c(d,W/2,vy+fv.size+18,tag,ft,CR,2,BK)
    else:
        # vehicle + tag on one line if fits
        ft=F('Mont700.ttf',30)
        vw=d.textlength(veh,font=fv); twd=d.textlength('  ·  '+tag,font=ft)
        if vw+twd<=W-2*pad:
            x=(W-vw-twd)/2
            d.text((x,vy),veh,font=fv,fill=OR,stroke_width=3,stroke_fill=BK)
            d.text((x+vw,vy+fv.size*0.42),'  ·  '+tag,font=ft,fill=CR,stroke_width=2,stroke_fill=BK)
        else:
            text_c(d,W/2,vy,veh,fv,OR,3,BK)
    # footer
    fb=F('Anton.ttf',110 if story else 84)
    fy=H-(445 if story else 212)
    benefit='A LA MEDIDA · BORDES ALTOS · FÁCIL DE LAVAR'
    fbn=fit_font(d,benefit,'Mont700.ttf',30 if story else 24,W-2*pad)
    text_c(d,W/2,fy,benefit,fbn,CR)
    fy+=fbn.size+(26 if story else 14)
    # ALEXMAR + phone row
    aw=d.textlength('ALEXMAR',font=fb)
    fpn=F('Anton.ttf',64 if story else 52)
    ph='0416-676 83 93'; pw=d.textlength(ph,font=fpn)
    if story:
        text_c(d,W/2,fy,'ALEXMAR',fb,OR,4,BK)
        fy+=fb.size+40
        # phone pill
        bx0=(W-pw)/2-40; d.rounded_rectangle((bx0,fy,bx0+pw+80,fy+fpn.size+34),radius=50,fill=OR)
        text_c(d,W/2,fy+8,ph,fpn,BK)
        fl=F('Mont700.ttf',28)
        text_c(d,W/2,H-62,'Tovar  ·  Pueblo Llano  ·  Envíos a todo el país',fl,CR)
    else:
        gap=34; tot=aw+gap+pw+60; x=(W-tot)/2
        d.text((x,fy),'ALEXMAR',font=fb,fill=OR,stroke_width=3,stroke_fill=BK)
        px=x+aw+gap; py=fy+(fb.size-fpn.size)/2+6
        d.rounded_rectangle((px,py-4,px+pw+60,py+fpn.size+22),radius=40,fill=OR)
        d.text((px+30,py+2),ph,font=fpn,fill=BK)
        fl=F('Mont700.ttf',22)
        text_c(d,W/2,H-40,'Tovar  ·  Pueblo Llano  ·  Envíos a todo el país',fl,CR)
    out=OUT+f"{name}_{'estado_1080x1920' if story else 'post_1080x1350'}.jpg"
    canvas.convert('RGB').save(out,quality=92)
    return out

if __name__=='__main__':
  for it in ITEMS:
    print(build(it,1080,1350)); print(build(it,1080,1920))
