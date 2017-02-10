function [  ] = myAssess( runNum,dataset,datasetpath,part1,part2,part3,ImgNum,h,assessType)
B=cell(1,12);%显著方法
B{1,1}='VA';B{1,2}='SR';B{1,3}='SO';B{1,4}='SF';B{1,5}='RC';B{1,6}='NS';B{1,7}='MR';B{1,8}='HS';B{1,9}='GS';B{1,10}='FT';B{1,11}='NIFS';B{1,12}='DVAS';

A=cell(1,36);%函数
A{1,1}='quality assessment function';A{1,2}='Polynomial Model1';   A{1,3}='Polynomial Model2';    A{1,4}='Polynomial Model3';      A{1,5}='Exponential Model 1';
A{1,6}='Exponential Model 2';        A{1,7}='Exponential Model 3'; A{1,8}='Exponential Model 4';  A{1,9}='Fourier Series Model 11';A{1,10}='Fourier Series Model 12';
A{1,11}='Fourier Series Model 13';   A{1,12}='Gaussian Model 11';  A{1,13}='Gaussian Model 12';   A{1,14}='Gaussian Model 13';     A{1,15}='Gaussian Model 2';
A{1,16}='Gaussian Model 3';          A{1,17}='Sum of Sine Model 1';A{1,18}='Sum of Sine Model 21';A{1,19}='Sum of Sine Model 22';  A{1,20}='Sum of Sine Model 23';
A{1,21}='Rational Model 01';         A{1,22}='Rational Model 02';  A{1,23}='Rational Model 03';   A{1,24}='Rational Model 04';     A{1,25}='Rational Model 11';
A{1,26}='Rational Model 12';         A{1,27}='Rational Model 13';  A{1,28}='Rational Model 14';   A{1,29}='Rational Model 21';     A{1,30}='Rational Model 22';
A{1,31}='Rational Model 23';         A{1,32}='Rational Model 24';  A{1,33}='Rational Model 31';   A{1,34}='Rational Model 32';     A{1,35}='Rational Model 33';
A{1,36}='Rational Model 34';

    file_path =  [datasetpath,dataset,'\groundtruth\'];
    xlswrite(strcat(assessType,'_',dataset,'_',B{1,h},'.xls'),{[B{1,h},'run',int2str(runNum)]},'Sheet1',strcat(char(runNum+65),int2str(1)));
    fprintf( '%s\n',B{1,h} );
    file_path1  =  strcat(datasetpath,dataset,'\',B{1,h},'saliency\noise1\');%各显著算法结果路�?
    sum1=0;
    for i=[1,2,19,29]
        xlswrite(strcat(assessType,'_',dataset,'_',B{1,h},'.xls'),{A{1,i}},'Sheet1',strcat('A',int2str(i+2)));
        fprintf( '%s\n',A{1,i} );
        sum3=0;
        for j = 1:ImgNum
            fprintf('%d\n',j);
            image = double(imread(strcat(file_path,'g',' (',int2str(j),')','.png')));
            if i==1%I=1计算原显著算法mse
               image1 = double(imread(strcat(file_path1,int2str(j),'.png')));
               ass1= metrix_mux(image,image1,assessType);
               sum1=sum1+ass1;
            end
        end
        for j=part1
            image = double(imread(strcat(file_path,'g',' (',int2str(j),')','.png')));
            s1=[B{1,h},'run',int2str(runNum),'BigdataBC.txt'];
            image3=Fpiture( dataset,datasetpath,h,i,j,s1);
            image3=  image3*255;
            ass3= metrix_mux(image,image3,assessType);
            sum3=sum3+ass3;
        end
       for j=part2
           image = double(imread(strcat(file_path,'g',' (',int2str(j),')','.png')));
           s1=[B{1,h},'run',int2str(runNum),'BigdataAC.txt'];
           image3=Fpiture( dataset,datasetpath,h,i,j,s1);
           image3=  image3*255;
           ass3= metrix_mux(image,image3,assessType);
           sum3=sum3+ass3;
       end
      for j=part3
          image = double(imread(strcat(file_path,'g',' (',int2str(j),')','.png')));
           s1=[B{1,h},'run',int2str(runNum),'BigdataAB.txt'];
           image3=Fpiture( dataset,datasetpath,h,i,j,s1);
           image3=  image3*255;
           ass3= metrix_mux(image,image3,assessType);
           sum3=sum3+ass3;
      end
        
     if i==1
      xlswrite(strcat(assessType,'_',dataset,'_',B{1,h},'.xls'),sum1/ImgNum,'Sheet1',strcat(char(runNum+65),int2str(2)));
     end
      xlswrite(strcat(assessType,'_',dataset,'_',B{1,h},'.xls'),sum3/ImgNum,'Sheet1',strcat(char(runNum+65),int2str(i+2)));
    end
end
