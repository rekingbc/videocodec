function [psnr, mse] = psnr_mse(img1, img2, L)

MAX_PSNR = 1000;

if (nargin < 2 | nargin > 3)
   psnr = -Inf;
   mse = -Inf;
   disp(['Error in psnr_mse.m: wrong input argument']);
   return;
end

if (size(img1) ~= size(img2))
   psnr = -Inf;
   mse = -Inf;
   disp(['Error in psnr_mse.m: images need to have the same size']);
   return;
end

if (~exist('L'))
   L = 255;
end

mse = mean2((double(img1) - double(img2)).^2);
psnr = 10*log10(L^2/mse);
psnr = min(MAX_PSNR, psnr);