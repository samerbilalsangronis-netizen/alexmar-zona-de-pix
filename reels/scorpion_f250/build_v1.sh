#!/bin/bash
# Reel Scorpion F-250: segmentos -> concat -> pista de audio en silencio
set -e
cd /home/claude/scorpion
mkdir -p seg
S=src
GRADE="eq=contrast=1.08:saturation=1.18:brightness=0.01,vignette=PI/5"
seg () { # name src start dur overlay [speed] [extra_in_filter]
  n=$1; f=$2; ss=$3; d=$4; ov=$5; sp=${6:-1}; ex=${7:-}
  srcd=$(python3 -c "print($d*$sp)")
  ffmpeg -v error -y -ss $ss -t $srcd -i $S/$f -loop 1 -t $d -i ov/$ov.png -filter_complex \
  "[0:v]setpts=PTS/$sp-STARTPTS,scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,fps=30,$GRADE${ex}[v];\
   [1:v]format=rgba,fade=in:st=0.12:d=0.28:alpha=1[o];[v][o]overlay=0:0:shortest=1,format=yuv420p[out]" \
   -map "[out]" -t $d -an -c:v libx264 -preset medium -crf 18 -r 30 seg/$n.mp4
}
seg 01 20261016_123733.mp4 4.0 2.2 01
seg 02 20261016_124445.mp4 5.3 1.8 02
seg 03 20261016_123201.mp4 2.3 2.0 03 0.5
seg 04 20261016_122825.mp4 14.0 1.8 04
seg 05 20261016_124445.mp4 0.6 1.6 05
seg 06 20261016_134039.mp4 1.0 1.8 06
seg 07 20261016_134020.mp4 0.4 2.8 07 1 ",fade=in:st=0:d=0.3:color=white"
seg 08 20261016_134051.mp4 0.0 2.4 08
seg 09 20261016_122825.mp4 32.4 1.8 09
# cierre con zoom suave
ffmpeg -v error -y -loop 1 -i ov/cierre.jpg -t 2.6 -vf "scale=2160:3840,zoompan=z='min(1+0.0012*on,1.08)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30,fade=in:st=0:d=0.25,format=yuv420p" -c:v libx264 -preset medium -crf 18 -r 30 seg/10.mp4
ls seg/*.mp4 | sed "s/^/file '/;s/$/'/" > list.txt
ffmpeg -v error -y -f concat -safe 0 -i list.txt -f lavfi -i anullsrc=r=44100:cl=stereo -c:v copy -c:a aac -shortest -movflags +faststart ALEXMAR_Reel_F250_Scorpion_sin_audio.mp4
ffprobe -v error -show_entries format=duration -of csv=p=0 ALEXMAR_Reel_F250_Scorpion_sin_audio.mp4
