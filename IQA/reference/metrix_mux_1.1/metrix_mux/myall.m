clear;
A=cell(1,10);
A{1,1}='MSE';A{1,2}='PSNR';A{1,3}='SSIM';A{1,4}='MSSIM';A{1,5}='VSNR';A{1,6}='VIFP';A{1,7}='UQI';A{1,8}='NQM';A{1,9}='WSNR';A{1,10}='SNR';
B=cell(1,10);
B{1,1}='VA';B{1,2}='SR';B{1,3}='SO';B{1,4}='SF';B{1,5}='RC';B{1,6}='NS';B{1,7}='MR';B{1,8}='HS';B{1,9}='GS';B{1,10}='FT';
file_path1     =  'F:\林文奇\PSNR\PSNR\MSRA1000\groundtruth\';% 图像文件夹路径
for i=2:10
    fn_txt         = fopen( strcat('F:\林文奇\PSNR\PSNR\MSRA1000\',A{1,i},'_AVE.txt'), 'at');
    for h=1:10
     sum=0;
     fd_txt =   fopen( strcat('F:\林文奇\PSNR\PSNR\MSRA1000\',B{1,h},'saliency\',B{1,h},'_',A{1,i},'.txt'), 'wt');
     file_path2     =  strcat('F:\林文奇\PSNR\PSNR\MSRA1000\',B{1,h},'saliency\noise1\');
     fprintf( '%s_%s\n',B{1,h},A{1,i} );
     for j = 1:1000%逐一读取图像
            image1 = double(imread(strcat(file_path1,'g',' (',int2str(j),')','.png')));
            image2 = double(imread(strcat(file_path2,int2str(j),'.jpg')));
            fprintf('%d\n',j);% 显示正在处理的图像名
            s=metrix_mux(image1,image2,A{1,i});
            fprintf(fd_txt, '%d:%f\n', j,s);
            sum=sum+s;
     end
     fclose(fd_txt);
     fprintf(fn_txt, '%s_%s_ave=:%f\n',B{1,h}, A{1,i},sum/1000);
    end
    fclose(fn_txt);
end
        