%% Blonde test
clear all;close all;
% Initializes the random number generator
rng(2);

% Loads and normalizes image
im=double(imread('Blonde.png'));
im=im/255;

% Adds noisy lines to the image
sigma=0.3;
imb=im;
[nx,ny,m]=size(im);
for i=1:nx
  imb(i,:,1)=im(i,:,1)+sigma*randn;
  imb(i,:,2)=im(i,:,2)+sigma*randn;
  imb(i,:,3)=im(i,:,3)+sigma*randn;
end

% Display
figure(1);image(uint8(255*imb));title('Noisy image')

% Defines the filter (a line)
filter=zeros(size(im));
filter(1,:)=1/size(im,1);

% Denoising algorithm
x=im;
for i=1:3
  ub=imb(:,:,i); % Treats every components separately
  [y,Gap,Primal,Dual,EstP,EstD]=VSNR(ub,0,2,filter,4e-4,1000,2e-3,100);
  x(:,:,i)=y;
end

% Display the result
figure(2);image(uint8(255*x));title('Denoised image');
