function im=rescaleUINT8(im)

m=min(im(:));
M=max(im(:));

if (M==m)
  im=zeros(size(im));
else
  im=uint8(255*(im-m)/(M-m));
end