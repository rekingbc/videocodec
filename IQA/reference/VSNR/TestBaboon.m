%% Creates images
% Load and normalize image.
im=double(imread('mandril_gray.tif'))/255;

% Seeds the random number generator (to produce identical experiments every time).
rng(3); 

% Generates noise patterns.
% First, an isotropic sinc convolved with Gaussian noise.
[ny,nx]=size(im); % generates a sinc
[X,Y]=meshgrid(linspace(-1,1,nx),linspace(-1,1,ny));
R=100*sqrt(X.^2+Y.^2);
psi1=sin(R)./(R+1e-10);
psi1=1e-2*psi1/max(psi1(:)); % Normalization
b1=randn(size(im)); %Gaussian process
bpsi1=ifft2(fft2(b1).*fft2(psi1)); %convolution of the Gaussian process with psi1

%Second, a Gabor function convolved with a Bernoulli process
psi2=gabor_fn(1,pi,0,0,1,0.05); % a Gabor function
psi2=ZeroAdd(psi2,im);  %padds with zeros
psi2=1e-2*psi2/max(psi2(:)); %Normalization
b2=rand(size(im)); %generates a Bernoulli process
b2=double(b2>0.999);
bpsi2=ifft2(fft2(b2).*fft2(psi2)); %convolution of the Bernoulli process with psi2

%Create noisy imagge
imb=im+bpsi1+50*bpsi2;

%Stores the filters in a single array.
Gabors=zeros(ny,nx,2);
Gabors(:,:,1)=psi1;
Gabors(:,:,2)=psi2;

%% Denoising and display
%Sets algorithms parameters
p=[2,1]; %(indexes of p-norms)
alpha=[0.12,0.05]; %data terms.
epsilon = 0; %no regularization of TV-norm
prec= 5e-3; %stopping criterion (initial dual gap multiplied by prec)
C = 1; %ball-diameter to define a restricted duality gap. 
maxit=500; %Maximal number of iterations

%You can use the Matlab implementation:
tic;
[u,Gap,Primal,Dual,EstP,EstD]=VSNR(imb,epsilon,p,Gabors,alpha,maxit+1,prec,C);
toc;
%Or C implementation (if library fftw3 is installed):
%mex VSNR_c.c -l fftw3
%tic;
%[u,Gap,Primal,Dual,EstP,EstD]=VSNR_c(imb,epsilon,p,Gabors,alpha,maxit,prec,C);
%toc;

%Retrieving noise components (EstP contains the estimation of noise processes)
cp1=-ifft2(fft2(EstP(:,:,1)).*fft2(psi1));
cp2=-ifft2(fft2(EstP(:,:,2)).*fft2(psi2));

%Displaying the whole
figure(1);colormap gray;imagesc(imb);title('Noisy image')
figure(2);colormap gray;imagesc(u);title('Restored image')
figure(3);colormap gray;imagesc(bpsi1);title('First noise component - real')
figure(4);colormap gray;imagesc(cp1);title('First noise component - estimated')
figure(5);colormap gray;imagesc(50*bpsi2);title('Second noise component - real')
figure(6);colormap gray;imagesc(cp2);title('Second noise component - estimated')