#!/bin/bash

for mse in 4 8 16
do
    ffmpeg -i KristenAndSara_720p.y4m -c:v libx264 -pix_fmt yuv420p -an -qp 20 -g 250 -keyint_min 250 -refs 2  -me_method epzs -me_range $mse Kris_simple_$mse.mp4
    ffmpeg -i KristenAndSara_720p.y4m -c:v libx264 -pix_fmt yuv420p -an -qp 20 -g 250 -keyint_min 250 -refs 2  -me_method full -me_range $mse Kris_full_$mse.mp4
    ffmpeg -i Stockholm_720p.y4m -c:v libx264 -pix_fmt yuv420p -an -qp 20 -g 250 -keyint_min 250 -refs 2  -me_method epzs -me_range $mse Stoc_simple_$mse.mp4
    ffmpeg -i Stockholm_720p.y4m -c:v libx264 -pix_fmt yuv420p -an -qp 20 -g 250 -keyint_min 250 -refs 2  -me_method full -me_range $mse Stoc_full_$mse.mp4
done


