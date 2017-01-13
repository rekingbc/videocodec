#!/bin/bash

for mse in 4 8 16
do
    echo The Bit rate for kris, simple and full:
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Kris_simple_$mse.mp4
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Kris_full_$mse.mp4
    echo The Bit rate for stoc, simple and full:
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Stoc_simple_$mse.mp4
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Stoc_full_$mse.mp4
done

