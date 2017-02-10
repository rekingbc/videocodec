function mgsim=QE_GSIM_v2(I1,I2)
Pm=200;Pi=0.1;

[H W]=size(I1);
% automatic downsampling
f = max(1,round(min(H,W)/256));
if(f>1)
    lpf = ones(f,f);
    lpf = lpf/sum(lpf(:));
    I1 = imfilter(I1,lpf,'symmetric','same');
    I2 = imfilter(I2,lpf,'symmetric','same');

    I1 = I1(1:f:end,1:f:end);
    I2 = I2(1:f:end,1:f:end);
end

[grad1]=func_Gm(I1);
[grad2]=func_Gm(I2);

C=1e-5+Pm*max(grad1,grad2);
g_map=(2*grad1.*grad2+C)./(grad1.^2+grad2.^2+C);
e_map=1-((I1-I2)/255).^2;

mgsim=mean2(((1-Pi*g_map).*g_map+Pi*g_map.*e_map));


function [Gm] = func_Gm(input)
G1=[0  0  0  0  0
    1  3  8  3  1
    0  0  0  0  0
   -1 -3 -8 -3 -1
    0  0  0  0  0];

G2=[0 0  1  0  0
    0 8  3  0  0
    1 3  0 -3 -1
    0 0 -3 -8  0
    0 0 -1  0  0];

G3=[0  0  1 0 0
    0  0  3 8 0
   -1 -3  0 3 1
    0 -8 -3 0 0
    0  0 -1 0 0];

G4=[0 1 0 -1 0
    0 3 0 -3 0
    0 8 0 -8 0
    0 3 0 -3 0
    0 1 0 -1 0];
[H,W]=size(input);
grad=zeros(H,W,4);
grad(:,:,1) = filter2(G1,input)/16;
grad(:,:,2) = filter2(G2,input)/16;
grad(:,:,3) = filter2(G3,input)/16;
grad(:,:,4) = filter2(G4,input)/16;
Gm = max(abs(grad),[],3);