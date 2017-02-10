function result = RFSIM(imRef, imDis)
% ========================================================================
% RFSIM Index with automatic downsampling, Version 1.0
% Copyright(c) 2010 Lin ZHANG, Lei Zhang, and Xuanqin Mou 
% All Rights Reserved.
% ----------------------------------------------------------------------
% Permission to use, copy, or modify this software and its documentation
% for educational and research purposes only and without fee is hereby
% granted, provided that this copyright notice and the original authors'
% names appear on all copies and supporting documentation. This program
% shall not be used, rewritten, or adapted as the basis of a commercial
% software or hardware product without first obtaining permission of the
% authors. The authors make no representations about the suitability of
% this software for any purpose. It is provided "as is" without express
% or implied warranty.
%----------------------------------------------------------------------
% This is an implementation of the algorithm for calculating the
% Riesz-transform based Feature SIMilarity (RFSIM) index between two images
%----------------------------------------------------------------------
% Please refer to the following paper and the website
%
% Lin Zhang, Lei Zhang, and Xuanqin Mou, "RFSIM: a feature based image 
% quality assessment metric using Riesz transforms", in: Proc. IEEE
% International Conference on Image Processing, 2010, Hong Kong.
%
% http://www.comp.polyu.edu.hk/~cslinzhang
% http://www.comp.polyu.edu.hk/~cslzhang
%----------------------------------------------------------------------
%
%Input : (1) imRef: the first image being compared
%        (2) imDis: the second image being compared
%
%Output: result: the similarity index   
%========================================================================

if isrgb(imRef)
   imRef = rgb2gray(imRef);
end

if isrgb(imDis)
   imDis = rgb2gray(imDis);
end

imRef = double(imRef);
imDis = double(imDis);

%do the downsampling using the empirical steps suggested by Zhou Wang
%http://www.ece.uwaterloo.ca/~z70wang/research/ssim/
[rows,cols] = size(imRef);
minDimension = min(rows,cols);

F = max(1,round(minDimension / 256));
aveKernel = fspecial('average',F);

imRef = conv2(imRef, aveKernel,'same');
imDis = conv2(imDis, aveKernel,'same');
imRef = imRef(1:F:rows,1:F:cols);
imDis = imDis(1:F:rows,1:F:cols);

%get the Riesz transform responses
[refRx, refRy, refRxx, refRxy, refRyy] = RieszTransform(imRef);
[disRx, disRy, disRxx, disRxy, disRyy] = RieszTransform(imDis);

edgeRef = edge(imRef,'canny', [0.08 0.13], 3.6);
edgeDis = edge(imDis,'canny', [0.08 0.13], 3.6);

strcture = strel('square',4);
mask1 = imdilate(edgeRef,strcture,'same');
mask2 = imdilate(edgeDis,strcture,'same');
mask = mask1 | mask2;

C = 1.2;
%==================================================================================
%this is one kind of similarity measure
diffMatrixRx = (2 * refRx .* disRx + C) ./ (refRx .^ 2 + disRx.^ 2 + C);
diffMatrixRy = (2 * refRy .* disRy + C) ./ (refRy .^ 2 + disRy.^ 2 + C);
diffMatrixRxx = (2 * refRxx .* disRxx + C) ./ (refRxx .^ 2 + disRxx.^ 2 + C);
diffMatrixRxy = (2 * refRxy .* disRxy + C) ./ (refRxy .^ 2 + disRxy.^ 2 + C);
diffMatrixRyy = (2 * refRyy .* disRyy + C) ./ (refRyy .^ 2 + disRyy.^ 2 + C);

validPoints = sum(sum(mask));
d2 = sum(sum(diffMatrixRx .* mask))/ validPoints;
d3 = sum(sum(diffMatrixRy .* mask))/ validPoints;
d4 = sum(sum(diffMatrixRxx .* mask))/ validPoints;
d5 = sum(sum(diffMatrixRxy .* mask))/ validPoints;
d6 = sum(sum(diffMatrixRyy .* mask))/ validPoints;

result = d2 * d3 * d4 * d5 * d6;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function does the Riesz transform to the input gray-scale image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Rx, Ry, Rxx, Rxy, Ryy] = RieszTransform(im)

im = double(im);
[rows,cols] = size(im);
[u1, u2] = meshgrid(([1:cols]-(fix(cols/2)+1))/(cols-mod(cols,2)), ...
 			([1:rows]-(fix(rows/2)+1))/(rows-mod(rows,2)));

u1 = ifftshift(u1);  
u2 = ifftshift(u2);
   
radius = sqrt(u1.^2 + u2.^2);    
radius(1,1) = 1;

RxK = -i*u1./radius;  
RyK = -i*u2./radius;
RxK(1,1) = 0;
RyK(1,1) = 0;

RxxK = RxK .* RxK;
RxyK = RxK .* RyK;
RyyK = RyK .* RyK;

fftim = fft2(im);
Rx = real(ifft2(fftim.*RxK));
Ry = real(ifft2(fftim.*RyK));
Rxx = real(ifft2(fftim.*RxxK));
Rxy = real(ifft2(fftim.*RxyK));
Ryy = real(ifft2(fftim.*RyyK));
return;