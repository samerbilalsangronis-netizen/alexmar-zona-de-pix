from make import *
W,H=1080,1350
def bg_fit(fn,bb,top,bot,W,H):
    src=Image.open(U+fn).convert('RGB')
    src=ImageEnhance.Contrast(src).enhance(1.08)
    sc=max(W/src.width,H/src.height)
    bg=src.resize((int(src.width*sc),int(src.height*sc)),Image.LANCZOS)
    bg=bg.crop(((bg.width-W)//2,(bg.height-H)//2,(bg.width-W)//2+W,(bg.height-H)//2+H))
    bg=ImageEnhance.Brightness(bg.filter(ImageFilter.GaussianBlur(28))).enhance(0.45)
    c=bg.convert('RGBA')
    bw=bb[2]-bb[0]; bh=bb[3]-bb[1]; s=min((bot-top)/bh,(W-40)/bw)
    fg=src.resize((int(src.width*s),int(src.height*s)),Image.LANCZOS)
    ox=int(W/2-(bb[0]+bb[2])/2*s); oy=int((top+bot)/2-(bb[1]+bb[3])/2*s)
    m=Image.new('L',fg.size,0); ImageDraw.Draw(m).rectangle((60,60,fg.width-60,fg.height-60),fill=255)
    c.paste(fg,(ox,oy),m.filter(ImageFilter.GaussianBlur(30)))
    return c
def bands(c,top,bot):
    g=Image.new('RGBA',c.size,(0,0,0,0)); gd=ImageDraw.Draw(g)
    for y in range(c.height):
        a=0
        if y<top+40: a=235 if y<=top-70 else int(235*(top+40-y)/110)
        if y>bot-40: a=max(a,int(240*min(1,(y-(bot-40))/110)))
        gd.line([(0,y),(c.width,y)],fill=(26,26,26,a))
    return Image.alpha_composite(c,g)

# ---------- PORTADA ----------
it=ITEMS[1]; top,bot=430,1060
c=bands(bg_fit(it[1],it[4],top,bot,W,H),top,bot)
c=Image.alpha_composite(c,watermark(W,H)); d=ImageDraw.Draw(c)
lg=LOGO.resize((int(LOGO.width*150/LOGO.height),150),Image.LANCZOS)
c.alpha_composite(lg,((W-lg.width)//2,22)); d=ImageDraw.Draw(c)
f1=F('Anton.ttf',150); text_c(d,W/2,170,'PISOS 5D',f1,CR,4,BK)
f2=F('Mont900.ttf',48); text_c(d,W/2,345,'TIPO BANDEJA',f2,ORL)
fp=F('Mont900.ttf',30); t='ORIGINALES · A LA MEDIDA'; pw=d.textlength(t,font=fp)
d.rounded_rectangle(((W-pw)/2-28,410,(W+pw)/2+28,462),radius=26,fill=OR); text_c(d,W/2,419,t,fp,BK)
# models
fm=F('Anton.ttf',46)
rows=[['HEMBRITA','4RUNNER','AGYA'],['JAC ARENA','HILUX KAVAK']]
y=1070
for r in rows:
    ws=[d.textlength(x,font=fm)+44 for x in r]; tot=sum(ws)+18*(len(r)-1); x=(W-tot)/2
    for t,w in zip(r,ws):
        d.rounded_rectangle((x,y,x+w,y+66),radius=14,outline=OR,width=3,fill=(26,26,26))
        d.text((x+22,y+4),t,font=fm,fill=CR); x+=w+18
    y+=82
fs=F('Anton.ttf',50); tw=d.textlength('DESLIZA',font=fs); x0=(W-tw-70)/2
d.text((x0,1240),'DESLIZA',font=fs,fill=OR)
ax=x0+tw+22; ay=1272
d.rectangle((ax,ay-6,ax+30,ay+6),fill=OR); d.polygon([(ax+26,ay-20),(ax+50,ay),(ax+26,ay+20)],fill=OR)
fl=F('Mont700.ttf',26); text_c(d,W/2,1305,'ALEXMAR  ·  0416-676 83 93',fl,CR)
c.convert('RGB').save(OUT+'00_carrusel_portada_1080x1350.jpg',quality=92)

# ---------- CIERRE ----------
it=ITEMS[6]
c=bg_fit(it[1],it[4],0,H,W,H)
c=Image.alpha_composite(c,Image.new('RGBA',(W,H),(26,26,26,215)))
c=Image.alpha_composite(c,watermark(W,H)); d=ImageDraw.Draw(c)
lg=LOGO.resize((int(LOGO.width*330/LOGO.height),330),Image.LANCZOS)
c.alpha_composite(lg,((W-lg.width)//2,60)); d=ImageDraw.Draw(c)
text_c(d,W/2,420,'¿NO VES TU MODELO?',F('Anton.ttf',84),CR,3,BK)
text_c(d,W/2,530,'Escríbenos y te decimos si lo tenemos',F('Mont700.ttf',38),ORL)
text_c(d,W/2,620,'ALEXMAR',F('Anton.ttf',150),OR,4,BK)
fpn=F('Anton.ttf',84); ph='0416-676 83 93'; pw=d.textlength(ph,font=fpn)
d.rounded_rectangle(((W-pw)/2-50,815,(W+pw)/2+50,935),radius=60,fill=OR); text_c(d,W/2,825,ph,fpn,BK)
fi=F('Mont700.ttf',32); y=990
for t in ['Somos instaladores','Envíos a todo el país por MRW y Zoom','Tovar  ·  Pueblo Llano','Lunes a sábado · 8 am a 6 pm']:
    text_c(d,W/2,y,t,fi,CR); y+=56
text_c(d,W/2,y+20,'@autoalexmar_car',F('Mont900.ttf',34),OR)
c.convert('RGB').save(OUT+'08_carrusel_cierre_1080x1350.jpg',quality=92)
print('ok')
