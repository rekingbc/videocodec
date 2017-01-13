#!/bin/bash

for nb in 0 2 4 8
do
    echo The bit rate of kris and stoc:
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Kris_nb_$nb.mp4
    ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 Stoc_nb_$nb.mp4
done


