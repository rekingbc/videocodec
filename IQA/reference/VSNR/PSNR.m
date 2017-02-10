%function [PSNR,MSE]=PSNR(u0,u)
function [PSNR,MSE]=PSNR(u0,u)

A=max(max(u0(:)),max(u(:)));
dif=u0(:)-u(:);

MSE=mean(dif.^2);

PSNR=10*log(A*A/MSE)/log(10);