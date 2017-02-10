function im=rescaleUINT16(im)

m=min(im(:));
M=max(im(:));

if (M==m)
  im=zeros(size(im));
else
  im=uint16(2^16*(im-m)/(M-m));
end