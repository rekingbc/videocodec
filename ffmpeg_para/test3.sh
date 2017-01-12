#!/bin/bash

for ref in 1 2 4 8
do
    ffmpeg -i KristenAndSara_720p.y4m -c:v libx264 -pix_fmt yuv420p -an -qp 20 -g 250 -keyint_min 250 -refs $ref Kris_ref_$ref.mp4
    ffmpeg -i Stockholm_720p.y4m  -c:v libx264 -pix_fmt yuv420p -an -qp 20 -g 250 -keyint_min 250 -refs $ref Stoc_ref_$ref.mp4
done


