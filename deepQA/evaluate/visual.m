mse = [0.0611 0.0363 0.0302 0.0266 0.0244 0.0224 0.0205 0.0222 0.0201 0.0188]
step = [1 2 3 4 5 6 7 8 9 10];
step = 3000 * step;
figure(1) 
axis normal
plot(step,mse,'r:*');
title('Deep Training','FontName','Times New Roman','FontWeight','Bold','FontSize',16)
xlabel('Training Iter','FontName','Times New Roman','FontSize',14)
ylabel('Mean Squared Error','FontName','Times New Roman','FontSize',14,'Rotation',90)