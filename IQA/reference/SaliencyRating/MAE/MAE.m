function MEA= MAE( img,imgn )
%MSE Summary of this function goes here
%   Detailed explanation goes here
[h w]=size(img);
%imgn=imresize(img,[floor(h/2) floor(w/2)]);
%imgn=imresize(imgn,[h w]);
img=double(img);
imgn=double(imgn);

B=8;                %����һ�������ö��ٶ�����λ
MAX=2^B-1;          %ͼ���ж��ٻҶȼ�
MEA=sum(sum(abs(img-imgn)))/(h*w); %������       

end

