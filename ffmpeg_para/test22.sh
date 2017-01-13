#!/bin/bash

for gop in 1 5 10 15 30 60 100 300 600
do
    echo The Bit rate for kris and stoc:
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Kris_gop_$gop.mp4
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Stoc_gop_$gop.mp4
done


