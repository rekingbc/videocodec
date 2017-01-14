%question 1 QP value 

kris_qbit = [79389184    7013664     967981      337935  124823];
stoc_qbit = [207286409   61707825    2493042     513426  209611];
qp = [10 20 30 40 50];
kris_psnr = [50.45 44.73 41.23 36.17 30.34];
kris_ssim = [0.992920 0.978549 0.967732 0.937466 0.881652];
stoc_psnr = [50.95 41.28 35.41 30.87 26.37];
stoc_ssim = [0.995973 0.966954 0.907471 0.826060 0.689862];

figure(1)
axis normal
plot(qp,kris_qbit,'r:*',qp,stoc_qbit,'b--*');
title('Quantization Parameter','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Quatization Parameter','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rates','FontName','Times New Roman','FontSize',14,'Rotation',90)

legend('KrisAndSara','Stockholm','location','northeast')

figure(2)
axis normal
plot(qp,kris_psnr,'r:*',qp,stoc_psnr,'b--*');
title('PSNR','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Quatization Parameter','FontName','Times New Roman','FontSize',14)
ylabel('PSNR','FontName','Times New Roman','FontSize',14,'Rotation',90)

legend('KrisAndSara','Stockholm','location','northeast')

figure(3)
axis normal
plot(qp,kris_ssim,'r:*',qp,stoc_ssim,'b--*');
title('SSIM','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Quatization Parameter','FontName','Times New Roman','FontSize',14)
ylabel('SSIM','FontName','Times New Roman','FontSize',14,'Rotation',90)

legend('KrisAndSara','Stockholm','location','northeast')

%Kris and Stoc Noise 
stoc_n_psnr =  10.38;

stoc_n_ssim = 0.020186;

kris_n_psnr = 9.99;

kris_n_ssim = 0.022351;


% question 2 GOP length
GOP = [1  5 10 15 30 60 100 300 600];
kris_gbit = [55333791 16197169 11903475 9966509 8524164 7657333 7298386 6912643 6789513];

stoc_gbit = [163377172 82778378 73411324 68307250 65162069 63110767 62296682 61487384 61277754];

figure(4)
axis normal
semilogx(GOP, kris_gbit, GOP, stoc_gbit);
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
plot(refs,kris_rbit,'r:*');
title('Bit Rate KrisAndSara','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Reference Frame','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rate','FontName','Times New Roman','FontSize',14,'Rotation',90)

figure(6)
axis normal
plot(refs,stoc_rbit,'r:*');
title('Bit Rate Stockholm','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Reference Frame','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rate','FontName','Times New Roman','FontSize',14,'Rotation',90)


%question 4 B frame number

nb = [0  2  4 8];
kris_nbit = [9357793  7140795   7069950 7069956];
stoc_nbit = [76612376 62216979  62216979 62216983 ];

figure(7)
axis normal
plot(nb,kris_nbit,'r:*');
title('Bit Rate KrisAndSara','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('B Frames','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rate','FontName','Times New Roman','FontSize',14,'Rotation',90)

figure(8)
axis normal
plot(nb,stoc_nbit,'r:*');
title('Bit Rate Stockholm','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('B Frames','FontName','Times New Roman','FontSize',14)
ylabel('Bit Rate','FontName','Times New Roman','FontSize',14,'Rotation',90)



%question 5 x265

kris_fbit = [566614  168593  68691];
stoc_fbit = [912256  194169  68359];
 
kris_fpsnr = [41.25 36.33 30.82];
stoc_fpsnr = [35.09 31.19 26.79];


 
figure(9)
axis normal
semilogx(kris_qbit,kris_psnr,'r:*',kris_fbit, kris_fpsnr,'b:*');
title('Rate Distortion KrisAndSara','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Bit Rates','FontName','Times New Roman','FontSize',14)
ylabel('PSNR','FontName','Times New Roman','FontSize',14,'Rotation',90)

figure(10)
axis normal
semilogx(stoc_qbit,stoc_psnr,'r:*',stoc_fbit, stoc_fpsnr,'b:*');
title('Rate Distortion Stockholm','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Bit Rates','FontName','Times New Roman','FontSize',14)
ylabel('PSNR','FontName','Times New Roman','FontSize',14,'Rotation',90)



