#!/bin/bash

for gop in 1 5 10 15 30 60 100 300 600
do
    ffmpeg -i KristenAndSara_720p.y4m -c:v libx264 -pix_fmt yuv420p -an -qp 20 -g $gop -keyint_min $gop Kris_gop_$gop.mp4
    ffmpeg -i Stockholm_720p.y4m  -c:v libx264 -pix_fmt yuv420p -an -qp 20 -g $gop -keyint_min $gop Stoc_gop_$gop.mp4
done


