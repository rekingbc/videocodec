%PSNRHA PSNRHMA
clear

close all

Im1Path ='D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\A\';
Im1Enum = dir([Im1Path,'*.bmp']);
Im1Num = length(Im1Enum);

Im2Path ='D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\Copy_2_of_color\';
Im2Enum = dir([Im2Path,'*.bmp']);
Im2Num = length(Im2Enum);


tic
for i =1:185
    if(i<=10)

        im1 = imread([Im1Path,Im1Enum(1).name]);
        im2 = imread([Im2Path,Im2Enum(i).name]);
  
    elseif(10<i&&i<=35)

        im1 = imread([Im1Path,Im1Enum(2).name]);
        im2 = imread([Im2Path,Im2Enum(i).name]);

  
        
    elseif(35<i&&i<=55)

        im1 = imread([Im1Path,Im1Enum(3).name]);
        im2 = imread([Im2Path,Im2Enum(i).name]);

  
        
    elseif(55<i&&i<=75)

        im1 = imread([Im1Path,Im1Enum(4).name]);
        im2 = imread([Im2Path,Im2Enum(i).name]);

        
    elseif(75<i&&i<=100)

        im1 = imread([Im1Path,Im1Enum(5).name]);
        im2 = imread([Im2Path,Im2Enum(i).name]);

        
    elseif(100<i&&i<=115)

        im1 = imread([Im1Path,Im1Enum(6).name]);
        im2 = imread([Im2Path,Im2Enum(i).name]);

        
    elseif(115<i&&i<=130)

        im1 = imread([Im1Path,Im1Enum(7).name]);
        im2 = imread([Im2Path,Im2Enum(i).name]);

        
    elseif(130<i&&i<=150)

        im1 = imread([Im1Path,Im1Enum(8).name]);
        im2 = imread([Im2Path,Im2Enum(i).name]);

        
    elseif(150<i&&i<=170)

        im1 = imread([Im1Path,Im1Enum(9).name]);
        im2 = imread([Im2Path,Im2Enum(i).name]);

        
    elseif(170<i&&i<=185)

        im1 = imread([Im1Path,Im1Enum(10).name]);
        im2 = imread([Im2Path,Im2Enum(i).name]);

        
    end
    
ref_img=(im1);
dst_img=(im2);

[p_hvs_m(i,1), p_hvs(i,1)] = color_psnrhma( ref_img, dst_img );
end

toc
%%
    MOSPath = 'D:\1zjmzjmzjmzjm\计算机\D\1111\数据库\IVC_SubQualityDB\ivciqa\MOS_2.txt';
     MOS_2=load(MOSPath);
     psnrhma=p_hvs_m;
     psnrha=p_hvs;

    Srocc_hma = corr(MOS_2,psnrhma,'type','spearman');
     Krocc_hma = corr(MOS_2,psnrhma,'type','kendall');
    Srocc_ha = corr(MOS_2,psnrha,'type','spearman');
     Krocc_ha = corr(MOS_2,psnrha,'type','kendall');
toc
%%
save  ivcpsnrha_psnrhma psnrha psnrhma Srocc_ha Krocc_ha Srocc_hma Krocc_hma MOS_2 