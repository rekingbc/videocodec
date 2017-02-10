clear;
close all;

tic
xount=1;
for k=1:9
    sk=num2str(k)
    toc
    img1=imread(strcat('D:\1zjmzjmzjmzjm\计算机\D\\1111\数据库\tid2013\tid2013\reference_images\I0',sk,'.bmp'));
for i=1:9
    for j=1:5
        si=num2str(i);
        sj=num2str(j);
        
img2=imread(strcat('D:\1zjmzjmzjmzjm\计算机\D\\1111\数据库\tid2013\tid2013\distorted_images\I0',sk,'_0',si,'_',sj,'.bmp'));
 ref_img=double(img1);
 dst_img=double(img2);
%  ref_img=rgb2ycbcr(img1);
%  dst_img=rgb2ycbcr(img2);
%  ref_img=squeeze(ref_img(:,:,1));
%  dst_img=squeeze(dst_img(:,:,1));
%   ref_img=double(  ref_img);
%   dst_img=double(  dst_img);

[psnr(xount,1), mse(xount,1)] = psnr_mse( ref_img, dst_img );

name(xount,1)={strcat('I0',sk,'_0',si,'_',sj,'.bmp')};
xount=xount+1;
    end
end
for i=10:24
    for j=1:5
        si=num2str(i);
        sj=num2str(j);    
img2=imread(strcat('D:\1zjmzjmzjmzjm\计算机\D\\1111\数据库\tid2013\tid2013\distorted_images\I0',sk,'_',si,'_',sj,'.bmp'));
 ref_img=double(img1);
 dst_img=double(img2);


[psnr(xount,1), mse(xount,1)] = psnr_mse( ref_img, dst_img ); 

name(xount,1)={strcat('I0',sk,'_',si,'_',sj,'.bmp')};
xount=xount+1;

    end
end
end

for k=10:25
    sk=num2str(k)
    toc
    img1=imread(strcat('D:\1zjmzjmzjmzjm\计算机\D\\1111\数据库\tid2013\tid2013\reference_images\I',sk,'.bmp'));
for i=1:9
    for j=1:5
        si=num2str(i);
        sj=num2str(j);
        
img2=imread(strcat('D:\1zjmzjmzjmzjm\计算机\D\\1111\数据库\tid2013\tid2013\distorted_images\I',sk,'_0',si,'_',sj,'.bmp'));
 ref_img=double(img1);
 dst_img=double(img2);


[psnr(xount,1), mse(xount,1)] = psnr_mse( ref_img, dst_img );

name(xount,1)={strcat('I',sk,'_0',si,'_',sj,'.bmp')};
xount=xount+1;
    end
end
for i=10:24
    for j=1:5
        si=num2str(i);
        sj=num2str(j);    
img2=imread(strcat('D:\1zjmzjmzjmzjm\计算机\D\\1111\数据库\tid2013\tid2013\distorted_images\I',sk,'_',si,'_',sj,'.bmp'));
 ref_img=double(img1);
 dst_img=double(img2);


[psnr(xount,1), mse(xount,1)] = psnr_mse( ref_img, dst_img );

name(xount,1)={strcat('I',sk,'_',si,'_',sj,'.bmp')};
xount=xount+1;

    end
end
end
toc

%save mydemoPSNRC
%%
PSNRc=load('D:\1zjmzjmzjmzjm\计算机\D\特征\06PSNRc.txt');
C=roundn(psnr,-4);
q=find(PSNRc==C);
