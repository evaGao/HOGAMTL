function ln=local(IM)
gaussian=fspecial('gaussian',3,7/6);
num=IM-imfilter(IM,gaussian);
den=sqrt(imfilter(num.^2,gaussian));
ln=num./den+1;