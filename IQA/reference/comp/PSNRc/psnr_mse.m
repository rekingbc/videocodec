function [psnr, mse2] = psnr_mse(img1, img2, L)

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
for q=1:3


mse(q) = mean2((double(img1(:,:,q)) - double(img2(:,:,q))).^2);

end
mse2=(mse(1)+(mse(2)+mse(3)))/3;
psnr = 10*log10(L^2/mse2); 

psnr = min(MAX_PSNR, psnr);