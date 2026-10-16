from cover import bg_fit, bands  # cover.py regenerates its images; harmless
from make import *
W,H=1080,1920
R='/home/claude/pisos/reel/'
# HOOK frame
it=ITEMS[6]
c=bg_fit(it[1],it[4],560,1500,W,H)
c=bands(c,560,1500); c=Image.alpha_composite(c,watermark(W,H)); d=ImageDraw.Draw(c)
lg=LOGO.resize((int(LOGO.width*200/LOGO.height),200),Image.LANCZOS); c.alpha_composite(lg,((W-lg.width)//2,70)); d=ImageDraw.Draw(c)
text_c(d,W/2,300,'¿CUÁL ES EL',F('Anton.ttf',120),CR,4,BK)
text_c(d,W/2,430,'DE TU CARRO?',F('Anton.ttf',120),OR,4,BK)
fp=F('Mont900.ttf',40); t='PISOS 5D TIPO BANDEJA'; pw=d.textlength(t,font=fp)
d.rounded_rectangle(((W-pw)/2-34,1560,(W+pw)/2+34,1640),radius=40,fill=OR); text_c(d,W/2,1575,t,fp,BK)
text_c(d,W/2,1680,'ORIGINALES · A LA MEDIDA',F('Mont700.ttf',38),CR)
c.convert('RGB').save(R+'00_hook.jpg',quality=93)
# CIERRE 9:16
c=bg_fit(ITEMS[1][1],ITEMS[1][4],0,H,W,H)
c=Image.alpha_composite(c,Image.new('RGBA',(W,H),(26,26,26,215)))
c=Image.alpha_composite(c,watermark(W,H)); d=ImageDraw.Draw(c)
lg=LOGO.resize((int(LOGO.width*420/LOGO.height),420),Image.LANCZOS); c.alpha_composite(lg,((W-lg.width)//2,150)); d=ImageDraw.Draw(c)
text_c(d,W/2,660,'¿NO VES TU MODELO?',F('Anton.ttf',96),CR,3,BK)
text_c(d,W/2,790,'Escríbenos y te decimos si lo tenemos',F('Mont700.ttf',38),ORL)
text_c(d,W/2,900,'ALEXMAR',F('Anton.ttf',190),OR,4,BK)
fpn=F('Anton.ttf',96); ph='0416-676 83 93'; pw=d.textlength(ph,font=fpn)
d.rounded_rectangle(((W-pw)/2-56,1160,(W+pw)/2+56,1300),radius=70,fill=OR); text_c(d,W/2,1172,ph,fpn,BK)
y=1380
for t in ['Somos instaladores','Envíos a todo el país','Tovar · Pueblo Llano','Lunes a sábado · 8 am a 6 pm']:
    text_c(d,W/2,y,t,F('Mont700.ttf',40),CR); y+=66
text_c(d,W/2,y+30,'@autoalexmar_car',F('Mont900.ttf',42),OR)
c.convert('RGB').save(R+'99_cierre.jpg',quality=93)
print('ok')
