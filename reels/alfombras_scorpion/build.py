import subprocess, os
os.chdir('/home/claude/alfombras'); os.makedirs('seg', exist_ok=True)
GR = "eq=contrast=1.10:saturation=1.18:brightness=0.01,unsharp=5:5:0.6,vignette=PI/5"
V = "scale=1080:1920:force_original_aspect_ratio=increase:flags=lanczos,crop=1080:1920"
# horizontal: video al ancho, fondo desenfocado
L = ("split[a][b];[a]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=30:3,eq=brightness=-0.25[bg];"
     "[b]scale=1080:-2:flags=lanczos[fg];[bg][fg]overlay=0:(H-h)/2-120")

def run(c): subprocess.run(c, check=True)

def seg(n, f, ss, d, ov, mode='V', speed=1.0):
    sd = d * speed
    geo = V if mode == 'V' else L
    fc = (f"[0:v]setpts=(PTS-STARTPTS)/{speed},fps=30,{geo},{GR}[v];"
          f"[1:v]format=rgba,fade=in:st=0.3:d=0.3:alpha=1[o];[v][o]overlay=0:0:shortest=1,format=yuv420p[out]")
    run(['ffmpeg', '-v', 'error', '-y', '-ss', str(ss), '-t', str(sd), '-i', f'src/{f}.mp4', '-loop', '1', '-t', str(d), '-i', f'ov/{ov}.png',
         '-filter_complex', fc, '-map', '[out]', '-t', str(d), '-an', '-c:v', 'libx264', '-preset', 'medium', '-crf', '18', '-r', '30', f'seg/{n}.mp4'])

def still(n, img, d, ov):
    fc = (f"[0:v]scale=2160:3840:force_original_aspect_ratio=increase,crop=2160:3840,zoompan=z='1.15-0.0018*on':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30,{GR}[v];"
          f"[1:v]format=rgba,fade=in:st=0.3:d=0.3:alpha=1[o];[v][o]overlay=0:0:shortest=1,format=yuv420p[out]")
    run(['ffmpeg', '-v', 'error', '-y', '-loop', '1', '-t', str(d), '-i', img, '-loop', '1', '-t', str(d), '-i', f'ov/{ov}.png',
         '-filter_complex', fc, '-map', '[out]', '-t', str(d), '-an', '-c:v', 'libx264', '-preset', 'medium', '-crf', '18', '-r', '30', f'seg/{n}.mp4'])

S = [
 ('01','w147',0.0,2.6,'01','V',0.85),
 ('02','w147',4.6,2.6,'02','V',0.85),
 ('03','w147',11.3,2.4,'03','V',0.85),
 ('04','w147',16.4,2.4,'04','V',0.85),
 ('05','w147',21.6,2.6,'05','V',0.85),
 ('06','w144',1.0,2.6,'06','V',0.85),
 ('07','w147',26.0,3.4,'07','V',0.85),
]
for n,f,ss,d,ov,m,sp in S: seg(n,f,ss,d,ov,m,sp)
still('08','src/foto1.jpg',3.0,'08')
run(['ffmpeg','-v','error','-y','-loop','1','-i','ov/cierre.jpg','-t','3.6','-vf',"scale=2160:3840,zoompan=z='min(1+0.0010*on,1.08)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30,format=yuv420p",'-c:v','libx264','-preset','medium','-crf','18','-r','30','seg/09.mp4'])
order=['01','02','03','04','05','06','07','08','09']
dur={n:float(subprocess.run(['ffprobe','-v','error','-show_entries','format=duration','-of','csv=p=0',f'seg/{n}.mp4'],capture_output=True,text=True).stdout) for n in order}
tr=['fadewhite','smoothleft','smoothleft','smoothleft','circleopen','fade','slideup','fadeblack']
T=0.4
inp=[];f=[];acc=dur[order[0]];prev='[0:v]'
for n in order: inp+=['-i',f'seg/{n}.mp4']
for i in range(1,len(order)):
    off=acc-T; out=f'[x{i}]'
    f.append(f'{prev}[{i}:v]xfade=transition={tr[i-1]}:duration={T}:offset={off:.3f}{out}')
    prev=out; acc=off+dur[order[i]]
fc=';'.join(f)+f';{prev}format=yuv420p[v]'
run(['ffmpeg','-v','error','-y']+inp+['-f','lavfi','-i','anullsrc=r=44100:cl=stereo','-filter_complex',fc,'-map','[v]','-map',f'{len(order)}:a','-c:v','libx264','-preset','medium','-crf','19','-r','30','-c:a','aac','-shortest','-movflags','+faststart','ALEXMAR_Reel_Alfombras_Scorpion_sin_audio.mp4'])
print('total',round(acc,2))
