function normalizedImage = testlocalnormalize_raw(im)
%im=imread('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/img979.bmp');
fim=mat2gray(im); %把一个double类的任意数值转换成值范围在[0,1]的归一化double类数值
gaussian=fspecial('gaussian',7,7/6);%得到高斯滤波核
num=fim-imfilter(fim,gaussian);
den=sqrt(imfilter(num.^2,gaussian));
lnfim=num./den+1;
normalizedImage=mat2gray(lnfim);
%imshow(fim);
%figure,imshow(normalizedImage);
