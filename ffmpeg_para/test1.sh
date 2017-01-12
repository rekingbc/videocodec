#!/bin/bash

for qp in 10 20 30 40 50
do
    ffmpeg -i KristenAndSara_720p.y4m -c:v libx264 -pix_fmt yuv420p -an -qp $qp Kris_qp_$qp.mp4
    ffmpeg -i Stockholm_720p.y4m  -c:v libx264 -pix_fmt yuv420p -an -qp $qp Stoc_qp_$qp.mp4
done



