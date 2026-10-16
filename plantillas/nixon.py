import sys; sys.path.insert(0,'/home/claude/pisos')
from make import *
W,H=1080,1350
src=Image.open('/root/.claude/uploads/ea00b5f3-b07d-5263-8d5f-f3ee0bdba86b/9a26d668-image.jpg').convert('RGB')
src=ImageEnhance.Contrast(src).enhance(1.06); src=ImageEnhance.Color(src).enhance(1.08)
# blurred background from same photo
sc=H/src.height; bg=src.resize((int(src.width*sc),H),Image.LANCZOS)
bg=bg.crop(((bg.width-W)//2,0,(bg.width-W)//2+W,H)).filter(ImageFilter.GaussianBlur(30))
bg=ImageEnhance.Brightness(bg).enhance(0.4); c=bg.convert('RGBA')
# main photo: scale so width = 1180 (slight crop of far-left fence), centered vertically
fw=1200; fg=src.resize((fw,int(src.height*fw/src.width)),Image.LANCZOS)
ox=W-fw+40; oy=370
m=Image.new('L',fg.size,0); ImageDraw.Draw(m).rectangle((0,40,fg.width,fg.height-40),fill=255)
m=m.filter(ImageFilter.GaussianBlur(22))
c.paste(fg,(ox,oy),m)
c=Image.alpha_composite(c,watermark(W,H)); d=ImageDraw.Draw(c)
lg=LOGO.resize((int(LOGO.width*210/LOGO.height),210),Image.LANCZOS); c.alpha_composite(lg,(30,28)); d=ImageDraw.Draw(c)
x=30+lg.width+24
fp=F('Mont900.ttf',24); t='SEDE PUEBLO LLANO'; pw=d.textlength(t,font=fp)
d.rounded_rectangle((x,40,x+pw+40,84),radius=22,fill=OR); d.text((x+20,49),t,font=fp,fill=BK)
d.text((x,100),'TRABAJANDO EN EL',font=F('Mont900.ttf',34),fill=CR)
fh=fit_font(d,'FORD CARGO 1721','Anton.ttf',104,W-x-30)
d.text((x,140),'FORD CARGO 1721',font=fh,fill=OR,stroke_width=3,stroke_fill=BK)
text_c(d,W/2,300,'de nuestro cliente Nixon, de Pueblo Llano',F('Mont700.ttf',36),CR,2,BK)
y0=oy+fg.height-10
text_c(d,W/2,y0+20,'AUTOPERIQUITOS · ROTULADOS · ACCESORIOS',F('Mont700.ttf',26),CR)
fb=F('Anton.ttf',84); fpn=F('Anton.ttf',52); ph='0416-676 83 93'
aw=d.textlength('ALEXMAR',font=fb); pw=d.textlength(ph,font=fpn); gap=34
xx=(W-(aw+gap+pw+60))/2; fy=y0+70
d.text((xx,fy),'ALEXMAR',font=fb,fill=OR,stroke_width=3,stroke_fill=BK)
px=xx+aw+gap; py=fy+(fb.size-fpn.size)/2+6
d.rounded_rectangle((px,py-4,px+pw+60,py+fpn.size+22),radius=40,fill=OR); d.text((px+30,py+2),ph,font=fpn,fill=BK)
text_c(d,W/2,fy+125,'Pueblo Llano: C-9, sector La Curva de Los Luises',F('Mont700.ttf',26),CR)
text_c(d,W/2,fy+165,'También en Tovar  ·  Lunes a sábado, 8 am a 6 pm',F('Mont700.ttf',24),ORL)
c.convert('RGB').save('/home/claude/exr/alexmar_1721_nixon_pueblollano_post_1080x1350.jpg',quality=93)
print(y0, fy+165)
