import sys; sys.path.insert(0,'/home/claude/pisos')
from make import *
W,H=1080,1350
src=Image.open('/root/.claude/uploads/ea00b5f3-b07d-5263-8d5f-f3ee0bdba86b/8885b31b-image.jpg').convert('RGB')
src=ImageEnhance.Contrast(src).enhance(1.06); src=ImageEnhance.Color(src).enhance(1.08)
s=W/src.width; im=src.resize((W,int(src.height*s)),Image.LANCZOS)
top=60; im=im.crop((0,top,W,top+H))
c=im.convert('RGBA')
g=Image.new('RGBA',(W,H),(0,0,0,0)); gd=ImageDraw.Draw(g)
for y in range(H):
    a=0
    if y<330: a=int(225*min(1,(330-y)/150)) if y>180 else 225
    if y>1050: a=max(a,int(235*min(1,(y-1050)/110)))
    gd.line([(0,y),(W,y)],fill=(26,26,26,a))
c=Image.alpha_composite(c,g); c=Image.alpha_composite(c,watermark(W,H)); d=ImageDraw.Draw(c)
lg=LOGO.resize((int(LOGO.width*200/LOGO.height),200),Image.LANCZOS); c.alpha_composite(lg,(30,24)); d=ImageDraw.Draw(c)
x=30+lg.width+24
fp=F('Mont900.ttf',22); t='CLIENTES ALEXMAR'; pw=d.textlength(t,font=fp)
d.rounded_rectangle((x,34,x+pw+36,74),radius=20,fill=OR); d.text((x+18,43),t,font=fp,fill=BK)
d.text((x,86),'ASÍ LUCE EL',font=F('Mont900.ttf',34),fill=CR)
fh=fit_font(d,'CHEVROLET EXR','Anton.ttf',104,W-x-30)
d.text((x,124),'CHEVROLET EXR',font=fh,fill=OR,stroke_width=3,stroke_fill=BK)
text_c(d,W/2,272,'de nuestro fiel cliente  Esteban Lolo',F('Mont700.ttf',36),CR,2,BK)
# footer
text_c(d,W/2,1100,'AUTOPERIQUITOS · ROTULADOS · ACCESORIOS',F('Mont700.ttf',26),CR)
fb=F('Anton.ttf',84); fpn=F('Anton.ttf',52); ph='0416-676 83 93'
aw=d.textlength('ALEXMAR',font=fb); pw=d.textlength(ph,font=fpn); gap=34
xx=(W-(aw+gap+pw+60))/2; fy=1145
d.text((xx,fy),'ALEXMAR',font=fb,fill=OR,stroke_width=3,stroke_fill=BK)
px=xx+aw+gap; py=fy+(fb.size-fpn.size)/2+6
d.rounded_rectangle((px,py-4,px+pw+60,py+fpn.size+22),radius=40,fill=OR); d.text((px+30,py+2),ph,font=fpn,fill=BK)
text_c(d,W/2,H-42,'Tovar  ·  Pueblo Llano',F('Mont700.ttf',24),CR)
c.convert('RGB').save('/home/claude/exr/alexmar_exr_esteban_lolo_post_1080x1350.jpg',quality=93)
print('ok')
