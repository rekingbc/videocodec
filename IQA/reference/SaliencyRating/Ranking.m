B=cell(1, 6);
B{1,1}='SO';B{1,2}='VA';B{1,3}='MR';B{1,4}='HS';B{1,5}='GS';B{1,6}='RC';

A=cell(1, 4);
A{1,1}='PRAUC';A{1,1}='Fbeta';A{1,1}='KRCC';A{1,4}='SRCC';

dataset = 'msra000';
imgNum = 1000;
GrPath = '/home/rasin/Dev/msra000/groundtruth/';
SaPath = '/home/rasin/Dev/msra000/';

% %%%PR use
% sumPR = 0;
%  aucP = zeros(1, imgNum);
% precisionP = zeros(imgNum, 256);
% recallP = zeros(imgNum, 256);
% 
% %%%Fbeta use
% sumF = 0;
 
% pre_sumF = 0;
% rec_sumF = 0;
% precisionF = zeros(imgNum, 256);
% recallF = zeros(imgNum, 256);
% 
% %%%SORCC use
  
% 
% %%%KORCC use
  

for i = 1 : 500
    %%%PR use
    sumPR = 0;

    precisionP = zeros(imgNum, 256);
    recallP = zeros(imgNum, 256);

    %%%Fbeta use
    sumF = 0;
    precisionF = zeros(imgNum, 256);
    recallF = zeros(imgNum, 256);

    %%%SORCC use
    %aucS = zeros(1, imgNum);

    %%%KORCC use
    %aucK = zeros(1, imgNum);
    
    for h = 1:6
        aucK = zeros(1, imgNum);
        aucP = zeros(1, imgNum);
        aucS = zeros(1, imgNum);
        aucF = zeros(1, imgNum);
        image = double(imread(strcat(GrPath, 'g (',int2str(i), ').png' )));
        image1 = double(imread(strcat(SaPath, char(B{1,h}), 'saliency/noise1/', int2str(i), '.png')));
        
%         PR calculation
        [precisionP(i,:),recallP(i,:),fpr_temp,thresh]=prec_rec(double(image1(:)),double(image(:)));
        n=256;
        for i2=2:n
            aucP(i) = aucP(i) + trapezoid(recallP(i,(i2-1)), recallP(i,i2), precisionP(i,(i2-1)), precisionP(i,i2));
       end
       aucP(i)= aucP(i) + precisionP(i,1)*recallP(i,1);
       sumPR = sumPR+aucP(i);
%         PR end
        
        %Newer PR
%         TP = 0.5;
%         WhiteP = find(image > round(255*TP));
%         BlackP = find(image < round(255*TP));
%         image(WhiteP) = 255;
%         image(BlackP) = 0;
%         
%         [precisionP(i),recallP(i),fpr_P,thresh]=prec_rec(double(image1(:)),double(image(:)));
%         n=256;
%         for i2=2:n
%             aucP(i) = aucP(i) + trapezoid(recallP(i, (i2-1)), recallP(i, i2), precisionP(i, (i2-1)), precisionP(i, i2));
%         end
%         aucP(i) = aucP(i), precisionP(i, 1) * recallP(i, 1);
%         sumPR = sumPR+aucP(i);
        
        %保存单张数据
%         file = fopen([SaPath,'_PRsingle_', int2str(i), ])
        %Newer PR undone
        
        %Fbeta calculation
        TF =2 * mean(image1(:));
        image1tmp = image1;
        White = find(image1tmp > TF);
        Black = find(image1tmp <= TF);
        image1tmp(White) = 255;
        image1tmp(Black) = 0;
        [precisionF(i), recallF(i), fpr_temp, thresh] = prec_rec_AT(double(image1tmp(:)), double(image(:)), TF);
        Fb = (1+0.3)*precisionF(i)*recallF(i)/(0.3*precisionF(i)+recallF(i));
        aucF(i)=Fb;
        sumF = sumF + Fb;

        
        %Fbeta done
        
        %SROCC calculation
        Srocc = corr(image1(:),image(:),'type','Spearman');
        aucS(i) = Srocc;
        %SROCC done
        
        %KROCC calculation
        Krocc = corr(image1(:), image(:), 'type', 'Kendall');
        aucK(i) = Krocc;
        %KROCC done
        
        %PR saving
        name = [SaPath, 'PR_', B{1, h}, '_', int2str(i),'_auc.mat'];
        save(name, 'aucP');
        %PR done

        %Fbeta saving
        name = [SaPath, 'Fbeta_', B{1, h}, '_', int2str(i),'_auc.mat'];
        save(name, 'aucF');
        %PR done

        %SROCC saving 
        name = [SaPath, 'SROCC_', B{1, h}, '_', int2str(i),'_auc.mat'];
        save(name, 'aucS');
        %SROCC done

        %SROCC saving 
        name = [SaPath, 'KROCC_', B{1, h}, '_', int2str(i),'_auc.mat'];
        save(name, 'aucK');
        %SROCC done
    end
    
%     %PR saving
%     name = [SaPath, 'PR_', B{1, h}, '_all_auc.mat'];
%     save(name, 'aucP');
%     %PR done
%     
%     %Fbeta saving
%     name = [SaPath, 'Fbeta_', B{1, h}, '_all_auc.mat'];
%     save(name, 'aucF');
%     %PR done
%     
%     %SROCC saving 
%     name = [SaPath, 'SROCC_', B{1, h}, '_all_auc.mat'];
%     save(name, 'aucS');
%     %SROCC done
%     
%     %SROCC saving 
%     name = [SaPath, 'KROCC_', B{1, h}, '_all_auc.mat'];
%     save(name, 'aucK');
%     %SROCC done
    
end

%PRAUC
avgP = sumPR / imgNum;
stdP = std(aucP);

%Fbeta continue
avgF = sumF / imgNum;
stdF = std(aucF);
%Fbeta saving

%SROCC 
avgS = mean(aucS);
stdS = std(aucS);

%KROCC
avgK = mean(aucK);
stdK = std(aucK);

xlswrite('msra000_all_avg&std.xls', 'Average', 'Sheet1', 'B1');
xlswrite('msra000_all_avg&std.xls', 'STD', 'Sheet1', 'C1');
xlswrite('msra000_all_avg&std.xls', 'PRAUC', 'Sheet1', 'A2');
xlswrite('msra000_all_avg&std.xls', 'Fbeta', 'Sheet1', 'A3');
xlswrite('msra000_all_avg&std.xls', 'SROCC', 'Sheet1', 'A4');
xlswrite('msra000_all_avg&std.xls', 'KROCC','Sheet1', 'A5');

xlswrite('msra000_all_avg&std.xls', avgP, 'Sheet1', 'B2');
xlswrite('msra000_all_avg&std.xls', stdP, 'Sheet1', 'C2');

xlswrite('msra000_all_avg&std.xls', avgF, 'Sheet1', 'B3');
xlswrite('msra000_all_avg&std.xls', stdF, 'Sheet1', 'C3');

xlswrite('msra000_all_avg&std.xls', avgS, 'Sheet1', 'B4');
xlswrite('msra000_all_avg&std.xls', stdS, 'Sheet1', 'C4');

xlswrite('msra000_all_avg&std.xls', avgK, 'Sheet1', 'B5');
xlswrite('msra000_all_avg&std.xls', stdK, 'Sheet1', 'C5');












