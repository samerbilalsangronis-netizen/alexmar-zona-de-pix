import os
src=open('/home/claude/alexmar-zona-de-pix/plantillas/overlays_reel.py').read().split("card('01'")[0].replace("O = '/home/claude/scorpion/ov/'","O = '/home/claude/aveo/ov/'")
exec(src)
card('01','ANTES','¿INTERIOR','DE FÁBRICA?',y=1120,size=120)
card('02','DESPUÉS','LUJO QUE','SE SIENTE',y=1120,size=128,tagcol=CR)
card('03','INSTALACIÓN','FORROS DE','ASIENTO GM',size=118)
card('04','ALEXMAR','FORROS DE','COJÍN',size=128)
card('05','KIT COMPLETO','FORRO DE','VOLANTE',size=124)
card('06','KIT COMPLETO','PALANCA Y','FRENO DE MANO',size=112)
# frase
c=base(); shade(c,900,1640,190); d=ImageDraw.Draw(c)
y=960
for t,col,sz in [('CUANDO DIOS QUISO',CR,96),('HACER DE DAVID UN REY,',CR,96),('NO LE ENVIÓ',CR,96),('UNA CORONA.',ORL,104),('LE ENVIÓ A GOLIAT.',OR,120)]:
    f=F('Anton.ttf',sz)
    while d.textlength(t,font=f)>W-120: sz-=4; f=F('Anton.ttf',sz)
    tc(d,W/2,y,t,f,col,4,BK); y+=int(sz*1.15)+(20 if t=='HACER DE DAVID UN REY,' or t=='UNA CORONA.' else 0)
c.save(O+'07.png')
# cierre
from PIL import ImageFilter
bgf='/home/claude/aveo/fr/a1_38.5.jpg'
c=Image.open(bgf).convert('RGBA').resize((W,H)).filter(ImageFilter.GaussianBlur(7))
c=Image.alpha_composite(c,Image.new('RGBA',(W,H),BK+(208,))); c.alpha_composite(WM); d=ImageDraw.Draw(c)
lg=LOGO.resize((int(LOGO.width*400/LOGO.height),400),Image.LANCZOS); c.alpha_composite(lg,((W-lg.width)//2,170)); d=ImageDraw.Draw(c)
tc(d,W/2,630,'Autoperiquitos y Rotulados',F('Mont900.ttf',46),CR)
tc(d,W/2,695,'ALEXMAR',F('Anton.ttf',196),OR,4,BK)
fp=F('Anton.ttf',96); ph='0416-676 83 93'; pw=d.textlength(ph,font=fp)
d.rounded_rectangle(((W-pw)/2-56,965,(W+pw)/2+56,1105),radius=70,fill=OR); tc(d,W/2,977,ph,fp,BK)
pill(d,W/2,1160,'SEDE TOVAR',F('Mont900.ttf',36),fill=CR)
y=1250
for t,f,col in [('Carrera 4ta, El Llano, diagonal a LM Market',F('Mont700.ttf',36),CR),('Lunes a sábado · 8 am a 6 pm',F('Mont900.ttf',42),ORL),('También en Pueblo Llano',F('Mont700.ttf',36),CR)]:
    tc(d,W/2,y,t,f,col); y+=66
tc(d,W/2,y+24,'@autoalexmar_car',F('Mont900.ttf',46),ORL)
c.convert('RGB').save(O+'cierre.jpg',quality=94)
print('ok')
