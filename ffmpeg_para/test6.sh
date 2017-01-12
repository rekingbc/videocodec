#!/bin/bash

for qp in  30 40 50
do

    ffmpeg -i KristenAndSara_720p.y4m -c:v libx265 -pix_fmt yuv420p -an -x265-params qp=$qp Kris_265_$qp.mp4
    ffmpeg -i Stockholm_720p.y4m  -c:v libx265 -pix_fmt yuv420p -an -x265-params qp=$qp Stoc_265_$qp.mp4
done



