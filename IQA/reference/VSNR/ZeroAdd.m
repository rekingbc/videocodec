%function ZeroAdd(im1,im2)
% 
% Add 0s to im1 so that it has the same size as im2.
% Useful for convolutions via FFT.
function im=ZeroAdd(im1,im2)

[nx1,ny1]=size(im1);
[nx2,ny2]=size(im2);

if (nx1>nx2)
    im1=im1(floor((nx1-nx2)/2)+1:floor((nx1-nx2)/2)+nx2,:);
end
if (ny1>ny2)
    im1=im1(:,floor((ny1-ny2)/2)+1:floor((ny1-ny2)/2)+ny2);
end

im=zeros(size(im2));
im(1:size(im1,1),1:size(im1,2))=im1;

[n1,n2]=size(im1);
im=circshift(im,[-floor(n1/2),-floor(n2/2)]);