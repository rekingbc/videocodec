%question 1 QP value 

kris_qbit = [73447153    6436186     984565      339122  114906];
stoc_qbit = [200966240   57549922    2167526     549415  246418];
qp = [10 20 30 40 50];
kris_psnr = [50.279965 44.791771 41.310491 36.307876 30.493389];
kris_ssim = [0.992595 0.978736 0.968098 0.938613 0.883443];
stoc_psnr = [50.757587 41.123134 35.406571 31.110516 26.569856];
stoc_ssim = [0.995754 0.965636 0.907690 0.830986 0.692909];


%x1=0:0.01:50;
%y1=spline(qp, log10(kris_qbit), x1);
%x2=0:0.01:50;
%y2=spline(qp, log10(stoc_qbit), x2);

figure(1)
axis normal
plot(qp,kris_qbit,'r-o',qp,stoc_qbit,'b-*');
title('Quantization Parameter','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Quatization Parameter','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rates','FontName','Times New Roman','FontSize',14,'Rotation',90)

legend('KrisAndSara','Stockholm','location','northeast')

figure(2)
axis normal
plot(qp,kris_psnr,'r:o',qp,stoc_psnr,'b--*');
title('PSNR','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Quatization Parameter','FontName','Times New Roman','FontSize',14)
ylabel('PSNR','FontName','Times New Roman','FontSize',14,'Rotation',90)

legend('KrisAndSara','Stockholm','location','northeast')

figure(3)
axis normal
plot(qp,kris_ssim,'r:o',qp,stoc_ssim,'b--*');
title('SSIM','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Quatization Parameter','FontName','Times New Roman','FontSize',14)
ylabel('SSIM','FontName','Times New Roman','FontSize',14,'Rotation',90)

legend('KrisAndSara','Stockholm','location','northeast')

%Kris and Stoc Noise 
stoc_n_psnr =  10.38;

stoc_n_ssim = 0.020186;

kris_n_psnr = 9.99;

kris_n_ssim = 0.020186;


% question 2 GOP length
GOP = [1  5 10 15 30 60 100 300 600];
kris_gbit = [ 55333791 15905440 11548909 9595549 8024457 7075823 6705817 6329136 6236500];

stoc_gbit = [163377172 79463504 70036831 64955705 61259414 58913241 58115550 57298176 57104851];

figure(4)
axis normal
gop = spcrv([[GOP(1) GOP GOP(end)]; [kris_gbit(1) kris_gbit kris_gbit(end)];...
   [stoc_gbit(1) stoc_gbit stoc_gbit(end)]],2);

semilogx(gop(1,:), gop(2,:), 'r-', gop(1,:), gop(3,:), 'b-');
hold on
semilogx(GOP, kris_gbit, 'ro', GOP,stoc_gbit, 'b*');
title('Group of Pictures','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('GOP','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rates','FontName','Times New Roman','FontSize',14,'Rotation',90)
legend('KrisAndSara','Stockholm','location','northeast')
% question 3 reference frame number

refs = [1 2 4 8 16];
kris_rbit = [6686136 6468722 6436068 6349736 6298276];
stoc_rbit= [58974077 57765690 57549805 57069703 56970097];

figure(5)
axis normal
plot(refs,kris_rbit,'r-*');
title('Bit Rate KrisAndSara','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Reference Frame','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rate','FontName','Times New Roman','FontSize',14,'Rotation',90)

figure(6)
axis normal
plot(refs,stoc_rbit,'r-*');
title('Bit Rate Stockholm','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Reference Frame','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rate','FontName','Times New Roman','FontSize',14,'Rotation',90)


%question 4 B frame number

nb = [0  2  4 8];
kris_nbit = [9357793  6865721   6073309  5895726];
stoc_nbit = [76612376 60888126  55806909 53061038];

figure(7)
axis normal
plot(nb,kris_nbit,'r-*');
title('Bit Rate KrisAndSara','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('B Frames','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rate','FontName','Times New Roman','FontSize',14,'Rotation',90)

figure(8)
axis normal
plot(nb,stoc_nbit,'r-*');
title('Bit Rate Stockholm','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('B Frames','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rate','FontName','Times New Roman','FontSize',14,'Rotation',90)



%question 5 x265

kris_fbit = [57863889  5451746  698336  203057  68642];
stoc_fbit = [169566721 47081751 1613408 236060 68323];
 
kris_fpsnr = [49.749144 45.049451 41.450203 36.403956 30.732630];
stoc_fpsnr = [48.708179 40.756137 35.674830 31.382468 26.764052];


  
figure(9)
axis normal

kris = spcrv([log10([kris_qbit(1) kris_qbit kris_qbit(end)]); [kris_psnr(1) kris_psnr kris_psnr(end)] ;...
   log10([kris_fbit(1) kris_fbit kris_fbit(end)]); [kris_fpsnr(1) kris_fpsnr kris_fpsnr(end)]],2);
%plot(values(1,:),values(2,:), 'g');
%semilogx(kris_qbit,kris(2,:),'r-',kris_fbit, kris(4,:),'b-');
%hold on
semilogx(kris_qbit,kris_psnr,'r-o',kris_fbit, kris_fpsnr,'b-*');
title('Rate Distortion KrisAndSara','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Bit Rates','FontName','Times New Roman','FontSize',14)
ylabel('PSNR','FontName','Times New Roman','FontSize',14,'Rotation',90)
legend('264','265','location','northeast')

figure(10)
axis normal
semilogx(stoc_qbit,stoc_psnr,'r-o',stoc_fbit, stoc_fpsnr,'b-*');
title('Rate Distortion Stockholm','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Bit Rates','FontName','Times New Roman','FontSize',14)
ylabel('PSNR','FontName','Times New Roman','FontSize',14,'Rotation',90)
legend('264','265','location','northeast')
