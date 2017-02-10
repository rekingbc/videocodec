function MEA= MAE( img,imgn )
%MSE Summary of this function goes here
%   Detailed explanation goes here
[h w]=size(img);
%imgn=imresize(img,[floor(h/2) floor(w/2)]);
%imgn=imresize(imgn,[h w]);
img=double(img);
imgn=double(imgn);

B=8;                %编码一个像素用多少二进制位
MAX=2^B-1;          %图像有多少灰度级
MEA=sum(sum(abs(img-imgn)))/(h*w); %均方差       

end

