B=cell(1,6);
B{1,1}='SO';B{1,2}='VA';B{1,3}='MR';B{1,4}='HS';B{1,5}='GS';B{1,6}='RC';

dataset='msra000';
ImgNum=1000;                %图片总数
partNum=30;                    %随机图片数量
GrPath='/home/rasin/Dev/msra000/groundtruth/'       %groundtruth路径
SaPath='/home/rasin/Dev/msra000/'                           %saliency路径
for runNum=1          %总运行次数

%随机选择图片%

x=randperm(ImgNum);
x1=x(1:partNum);                  %30张
s1=[dataset,'_','run',int2str(runNum),'_x1'];  %矩阵名
save(s1,'x1');                                            %x1矩阵存储
for h=1:6                       %h为显著算法循环
%xlswrite(strcat('MSE_',dataset,'.xls'),{[B{1,h},'run',int2str(runNum)]},strcat('Sheet',int2str(h)),strcat(char(runNum+65),int2str(1)));%表头

%%%%MSE用
sumMSE=0;

%%SSIM用
sumSSIM=0;

%%PR用
auc1 =0;
%precision1=zeros(partNum,256);
%recall1=zeros(partNum,256);
sumPR=0;

%%MAE用
sumMAE=0;

%%Fbeta用
pre_sumF=0;
rec_sumF=0;
precisionF=zeros(partNum,1);
recallF=zeros(partNum,1);

%%ROC用
sumROC=0;

for  j = x1
        image = double(imread(strcat(GrPath,'g',' (',int2str(j),')','.png')));  
        image1 = double(imread(strcat(SaPath,char(B{1,h}),'saliency/noise1/',int2str(j),'.png')));
        %%%%%随机图片MSE计算
        mse1= MSE(image,image1);        %单张计算
        sumMSE=sumMSE+mse1;                 %求和
     
        %%%%%随机图片SSIM计算
        SSIM1=SSIM(image, image1);
        sumSSIM=sumSSIM+SSIM1;
        
        %%%%%随机图片PR计算
        [precision1,recall1,fpr_temp,thresh]=prec_rec(double(image1(:)),double(image(:)));
        n=256;
        for i2=2:n
            auc1 = auc1 + trapezoid(recall1(i2-1), recall1(i2), precision1(i2-1), precision1(i2));
        end
        auc1=auc1+precision1(1)*recall1(1);
        sumPR=sumPR+auc1;
        
        %%%%%随机图片MAE计算
        MAE1=MAE(image, image1);
        sumMAE=sumMAE+MAE1;
        
        %%%%%随机图片Fbeta计算
        T=2*mean(image1(:));
        image1tmp=image1;
        white=find(image1tmp>T);
        black=find(image1tmp<=T);
        image1tmp(white)=255;
        image1tmp(black)=0;
        [precisionF(j),recallF(j),fpr_tmp,thresh]=prec_rec_AT(double(image1tmp(:)),double(image(:)),T);
        pre_sumF=pre_sumF+precisionF(j);
        rec_sumF=rec_sumF+recallF(j);
        
        %%%%%随机图片ROC计算
        Troc=0.5;
        imageR=im2bw(image,Troc);
        [auc,curve]=ROC(image1(:), imageR(:),1,0);
        sumROC=sumROC+auc;
        
        
end
xlswrite(strcat('MSE_',dataset,'_',char(B{1,h}),'.xls'),sumMSE/partNum,'sheet1',strcat(char(runNum+65),int2str(h)));%MSE存储
xlswrite(strcat('SSIM_',dataset,'_',char(B{1,h}),'.xls'),sumSSIM/partNum,'sheet1',strcat(char(runNum+65),int2str(h)));%SSIM存储
xlswrite(strcat('PRAUC_',dataset,'_',char(B{1,h}),'.xls'),sumPR/partNum,'Sheet1',strcat(char(runNum+65),int2str(h)));%PR存储
xlswrite(strcat('MAE_',dataset,'_',B{1,h},'.xls'),sumMAE/partNum,'Sheet1',strcat(char(runNum+65),int2str(h)));%MAE存储
%%Fbeta后续
pre1 = pre_sumF./partNum;
rec1 = rec_sumF./partNum;
Pmean=mean(pre1);
Rmean=mean(rec1);
b2=0.3;
Fb1=((1+b2)*Pmean*Rmean)/(b2*Pmean+Rmean);
xlswrite(strcat('Fbeta_',dataset,'_',B{1,h},'.xls'),Fb1,'Sheet1',strcat(char(runNum+65),int2str(h)));%Fbeta存储
xlswrite(strcat('ROCAUC_',dataset,'_',B{1,h},'.xls'),sumROC/partNum,'Sheet1',strcat(char(runNum+65),int2str(h)));%Fbeta存储
end
end



