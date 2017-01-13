#!/bin/bash

for ref in 1 2 4 8
do
    echo The bitrate of kris and stoc:
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Kris_ref_$ref.mp4
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Stoc_ref_$ref.mp4
done


