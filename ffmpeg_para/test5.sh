#!/bin/bash

for nb in 0 2 4 8
do
    ffmpeg -i KristenAndSara_720p.y4m -c:v libx264 -pix_fmt yuv420p -an -qp 20 -g 250 -keyint_min 250 -refs 2 -bf $nb Kris_nb_$nb.mp4
    ffmpeg -i Stockholm_720p.y4m  -c:v libx264 -pix_fmt yuv420p -an -qp 20 -g 250 -keyint_min 250 -refs 2 -bf $nb Stoc_nb_$nb.mp4
done


