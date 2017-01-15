#!/bin/bash

for qp in 10 20 30 40 50
do
    echo The bitrate ofr kris and stoc of 265 coding:
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Kris_265_$qp.mp4
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Stoc_265_$qp.mp4
done



