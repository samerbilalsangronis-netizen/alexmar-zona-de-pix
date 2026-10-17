set -e; cd /home/claude/aveo; mkdir -p seg
GRADE="eq=contrast=1.08:saturation=1.15:brightness=0.01,vignette=PI/5"
seg(){ n=$1; f=$2; ss=$3; d=$4; ov=$5; g=${6:-$GRADE}
 ffmpeg -v error -y -ss $ss -t $d -i src/$f -loop 1 -t $d -i ov/$ov.png -filter_complex "[0:v]setpts=PTS-STARTPTS,scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,fps=30,$g[v];[1:v]format=rgba,fade=in:st=0.15:d=0.3:alpha=1[o];[v][o]overlay=0:0:shortest=1,format=yuv420p[out]" -map "[out]" -t $d -an -c:v libx264 -preset medium -crf 18 -r 30 seg/$n.mp4; }
seg r01 a2.mp4 4.9 2.2 01 "eq=contrast=1.02:saturation=0.75:brightness=-0.02,unsharp=5:5:0.8,vignette=PI/4"
seg r03 a1.mp4 9.6 2.0 03
seg r05 a1.mp4 37.6 1.9 05
seg r07 a1.mp4 61.0 1.6 base
ffmpeg -v error -y -loop 1 -i ov/cierre.jpg -t 3.2 -vf "scale=2160:3840,zoompan=z='min(1+0.0010*on,1.08)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30,format=yuv420p" -c:v libx264 -preset medium -crf 18 -r 30 seg/r09.mp4
