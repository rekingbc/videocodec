clear;
close all;
file1='D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\';
file2='D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\tid2013\tid2013\distorted_images\';
tic
xount=1;

%%
img1=imread('D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\avion.bmp');
for i=1:5
img2=imread([file1,sprintf('avion_j2000_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('avion_jpeg_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

toc
%%
img1=imread('D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\barba.bmp');
for i=1:5
img2=imread([file1,sprintf('barba_flou_f%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('barba_j2000_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('barba_jpeg_lumichr_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('barba_jpeg_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('barba_lar_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end
toc
%%
img1=imread('D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\boats.bmp');
for i=1:5
img2=imread([file1,sprintf('boats_flou_f%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('boats_j2000_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end


for i=1:5
img2=imread([file1,sprintf('boats_jpeg_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('boats_lar_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end
toc
%%
img1=imread('D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\clown.bmp');


for i=1:5
img2=imread([file1,sprintf('clown_j2000_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('clown_jpeg_lumichr_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('clown_jpeg_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('clown_lar_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end
toc
%%
img1=imread('D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\fruit.bmp');
for i=1:5
img2=imread([file1,sprintf('fruit_flou_f%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('fruit_j2000_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('fruit_jpeg_lumichr_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('fruit_jpeg_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('fruit_lar_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end
toc
%%
img1=imread('D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\house.bmp');


for i=1:5
img2=imread([file1,sprintf('house_j2000_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('house_jpeg_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('house_lar_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end
toc
%%
img1=imread('D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\isabe.bmp');

for i=1:5
img2=imread([file1,sprintf('isabe_j2000_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('isabe_jpeg_lumichr_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('isabe_jpeg_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

toc
%%
img1=imread('D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\lenat.bmp');
for i=1:5
img2=imread([file1,sprintf('lenat_flou_f%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('lenat_j2000_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('lenat_jpeg_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('lenat_lar_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end
toc
%%
img1=imread('D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\mandr.bmp');

for i=1:5
img2=imread([file1,sprintf('mandr_j2000_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('mandr_jpeg_lumichr_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('mandr_jpeg_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('mandr_lar_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end
toc
%%
img1=imread('D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\color\pimen.bmp');

for i=1:5
img2=imread([file1,sprintf('pimen_j2000_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('pimen_jpeg_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end

for i=1:5
img2=imread([file1,sprintf('pimen_lar_r%d.bmp',i)]);
kk(xount,1)=VSI(img1, img2);
xount=xount+1;
end
toc
%%

w=load('mos_2.txt');
Srocc=corr(kk,w,'type','Spearman');
Krocc=corr(kk,w,'type','Kendall');
toc