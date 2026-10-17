src=open('/home/claude/scorpion/overlays.py').read().split("card('01'")[0].replace("O = '/home/claude/scorpion/ov/'","O = '/home/claude/alfombras/ov/'")
exec(src)
base().save(O+'base.png')
card('01','SCORPION','ALFOMBRAS','TIPO BANDEJA',y=1150,size=124,sub='Protección con estilo para tu carro')
card('02','PARA TU','CHEVROLET',None,y=1260,size=150)
card('03','PARA TU','TOYOTA',None,y=1260,size=150)
card('04','PARA TU','FIAT',None,y=1260,size=150)
card('05','PARA TU','FORD',None,y=1260,size=150)
card('06','Y MUCHAS MÁS','TENEMOS LA','DE TU MARCA',size=118)
c=base(); shade(c,1020,1640,190); d=ImageDraw.Draw(c); y=1080
pill(d,W/2,y,'SCORPION · 5 PIEZAS',F('Mont900.ttf',36)); y+=110
for t in ['Alta resistencia y durabilidad','Respaldo antideslizante','Para todo tipo de clima']:
    tc(d,W/2,y,'✓',F('Mont900.ttf',44),OR,2,BK) if False else None
    tc(d,W/2,y,t,F('Mont900.ttf',50),CR,3,BK); y+=82
c.save(O+'07.png')
card('08','YA DISPONIBLES','TE ESPERAMOS','EN TIENDA',size=118)
from PIL import ImageFilter
c=Image.open('/home/claude/alfombras/src/foto1.jpg').convert('RGBA').resize((W,int(W*2560/1920))).crop((0,0,W,H)).filter(ImageFilter.GaussianBlur(7))
c=Image.alpha_composite(c,Image.new('RGBA',(W,H),BK+(210,))); c.alpha_composite(WM); d=ImageDraw.Draw(c)
lg=LOGO.resize((int(LOGO.width*400/LOGO.height),400),Image.LANCZOS); c.alpha_composite(lg,((W-lg.width)//2,170)); d=ImageDraw.Draw(c)
tc(d,W/2,630,'Autoperiquitos y Rotulados',F('Mont900.ttf',46),CR)
tc(d,W/2,695,'ALEXMAR',F('Anton.ttf',196),OR,4,BK)
fp=F('Anton.ttf',96); ph='0416-676 83 93'; pw=d.textlength(ph,font=fp)
d.rounded_rectangle(((W-pw)/2-56,965,(W+pw)/2+56,1105),radius=70,fill=OR); tc(d,W/2,977,ph,fp,BK)
y=1170
for t,f,col in [('Tovar  ·  Pueblo Llano',F('Mont900.ttf',44),CR),('Lunes a sábado · 8 am a 6 pm',F('Mont900.ttf',42),ORL),('Envíos a todo el país',F('Mont700.ttf',38),CR)]:
    tc(d,W/2,y,t,f,col); y+=70
tc(d,W/2,y+24,'@autoalexmar_car',F('Mont900.ttf',46),ORL)
c.convert('RGB').save(O+'cierre.jpg',quality=94)
print('ok')
