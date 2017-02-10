clear;
file_path1     =  'F:\code\PSNR\MSRA1000\groundtruth\';% 图像文件夹路径
file_path2     =  'F:\code\PSNR\MSRA1000\SOsaliency\noise1\';
fd_mse         =   fopen( 'F:\code\PSNR\MSRA1000\SOsaliency\noise1\SO_MSE.txt', 'wt');
fd_psnr        =   fopen( 'F:\code\PSNR\MSRA1000\SOsaliency\noise1\SO_PSNR.txt', 'wt');
fd_ssim        =   fopen( 'F:\code\PSNR\MSRA1000\SOsaliency\noise1\SO_SSIM.txt', 'wt');
fd_mssim       =   fopen( 'F:\code\PSNR\MSRA1000\SOsaliency\noise1\SO_MSSIM.txt', 'wt');
fd_vsnr        =   fopen( 'F:\code\PSNR\MSRA1000\SOsaliency\noise1\SO_VSNR.txt', 'wt');
fd_vifp        =   fopen( 'F:\code\PSNR\MSRA1000\SOsaliency\noise1\SO_VIFP.txt', 'wt');
fd_uqi         =   fopen( 'F:\code\PSNR\MSRA1000\SOsaliency\noise1\SO_UQI.txt', 'wt');
fd_nqm         =   fopen( 'F:\code\PSNR\MSRA1000\SOsaliency\noise1\SO_NQM.txt', 'wt');
fd_wsnr        =   fopen( 'F:\code\PSNR\MSRA1000\SOsaliency\noise1\SO_WSNR.txt', 'wt');
fd_snr         =   fopen( 'F:\code\PSNR\MSRA1000\SOsaliency\noise1\SO_SNR.txt', 'wt');
sum_mse=0;
sum_psnr=0;
sum_ssim=0;
sum_mssim=0;
sum_vsnr=0;
sum_vifp=0;
sum_uqi=0;
sum_nqm=0;
sum_wsnr=0;
sum_snr=0;
        for j = 1:1000%逐一读取图像
            image1 = double(imread(strcat(file_path1,'g',' (',int2str(j),')','.png')));
            image2 = double(imread(strcat(file_path2,int2str(j),'.jpg')));
            fprintf('%d\n',j);% 显示正在处理的图像名
            mse=metrix_mux(image1,image2,'MSE');
            fprintf(fd_mse, '%d:%f\n', j,mse);
             sum_mse=sum_mse+mse;
             psnr=metrix_mux(image1,image2,'PSNR');
            fprintf(fd_psnr, '%d:%f\n', j,psnr);
            sum_psnr=sum_psnr+psnr;
            ssim=metrix_mux(image1,image2,'SSIM');
            fprintf(fd_ssim, '%d:%f\n', j,ssim);
            sum_ssim=sum_ssim+ssim;
            mssim=metrix_mux(image1,image2,'MSSIM');
            fprintf(fd_mssim, '%d:%f\n', j,mssim);
            sum_mssim=sum_mssim+mssim;
            vsnr=metrix_mux(image1,image2,'VSNR');
            fprintf(fd_vsnr, '%d:%f\n', j,vsnr);
            sum_vsnr=sum_vsnr+vsnr;
            vifp=metrix_mux(image1,image2,'VIFP');
            fprintf(fd_vifp, '%d:%f\n', j,vifp);
            sum_vifp=sum_vifp+vifp;
            uqi=metrix_mux(image1,image2,'UQI');
            fprintf(fd_uqi, '%d:%f\n', j,uqi);
            sum_uqi=sum_uqi+uqi;
            nqm=metrix_mux(image1,image2,'NQM');
            fprintf(fd_nqm, '%d:%f\n', j,nqm);
            sum_nqm=sum_nqm+nqm;
            wsnr=metrix_mux(image1,image2,'WSNR');
            fprintf(fd_wsnr, '%d:%f\n', j,wsnr);
            sum_wsnr=sum_wsnr+wsnr;
            snr=metrix_mux(image1,image2,'SNR');
            fprintf(fd_snr, '%d:%f\n', j,snr);
            sum_snr=sum_snr+snr;
            
        end
    fclose(fd_mse);
    