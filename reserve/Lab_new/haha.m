clear all; 
close all; clc;

% Image will be divided into patchSize x patchSize patches
patchSize = 32;
% window size used in local contrast normalization
% A window of windowSize x windowSize will be used
windowSize = 3;
HOG=cell(1,1);
result=0;
% Prompt user for the directory holding input images
image=imread('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/img1.bmp');
image = rgb2lab(image);
image=image(:,:,1);
image = double(image);    
    % Divide the image into patchSize x patchSize size patches
imagePatches = getImagePatches(image, patchSize); 
[nRowPatches, nColPatches] = size(imagePatches);
img = imagePatches{4, 19};
[m n]=size(img);
            %%%%%%%%%%%%%%%%%下面是求图像中各个像素值的梯度幅值和梯度方向%%%%%%%%%%%%%%%%%%%%%
fy=[-1 0 1];        %定义竖直模板
fx=fy';             %定义水平模板
Iy=imfilter(img,fy,'replicate');    %竖直边缘
Ix=imfilter(img,fx,'replicate');    %水平边缘
Ied=sqrt(Ix.^2+Iy.^2);              %梯度幅值
Iphase=Iy./Ix;              %梯度方向，有些为inf,-inf,nan，其中nan需要再处理一下
            %%%%%%利用循环遍历求解图像中各个8*8网格(non-overlap)的梯度直方图向量,为9维.并按其在图像中的位置以元组细胞的形式放入Cell元组变量中%%%%%%
step=16;                %step*step个像素作为一个单元
orient=9;               %方向直方图的方向个数
jiao=360/orient;        %每个方向包含的角度数
Cell=cell(1,1);              %所有的角度直方图,cell是可以动态增加的，所以先设了一个
ii=1;                      
jj=1;
for i=1:step:m          %如果处理的m/step不是整数，最好是i=1:step:m-step
    ii=1;
    for j=1:step:n      %注释同上
        tmpx=Ix(i:i+step-1,j:j+step-1);%当前8*8网格下的水平边缘值矩阵
        tmped=Ied(i:i+step-1,j:j+step-1);%当前8*8网格下的梯度幅值矩阵
        tmpphase=Iphase(i:i+step-1,j:j+step-1);%当前8*8网格下的梯度方向矩阵
        Hist=zeros(1,orient);               %当前8×8网格下的梯度直方图向量
        for p=1:step
            for q=1:step
                if isnan(tmpphase(p,q))==1  %0/0会得到nan，如果像素是nan，重设为0
                    tmpphase(p,q)=0;
                end
                ang=atan(tmpphase(p,q));    %atan求的是[-90 90]度之间
                ang=mod(ang*180/pi,360);    %全部变正，-90变270
                if tmpx(p,q)<0              %根据x方向确定真正的角度
                    if ang<90               %如果是第一象限
                         ang=ang+180;        %移到第三象限,x的方向大于0的仍然是在第一象限
                    end
                    if ang>270              %如果是第四象限
                         ang=ang-180;        %移到第二象限,x的方向大于0的仍然是在第四象限
                    end
                 end
                 if ang==0
                     ang=ang+0.0000001;          %防止ang为0
                 end
                     Hist(ceil(ang/jiao))=Hist(ceil(ang/jiao))+tmped(p,q);  %ceil向上取整，求出该角度对应到梯度方向中的位置，然后将其梯度幅值加进去
            end
         end
         Cell{jj,ii}=Hist;       %将当前的8*8网格的梯度方向直方图向量放入Cell中
         ii=ii+1;                %横向上计算当前8*8网格的序数
     end
     jj=jj+1;                    %纵向上计算当前8*8网格的序数
end
%下面是求feature,2*2个网格合成一个block(overlap),现在该block的梯度方向直方图向量为36维.并把每个block以元组细胞的形式放入最终整个图像patch的梯度方向直方图向量中
[m n]=size(Cell);
feature=cell(1,(m-1)*(n-1));%计算以8像素重叠滑动后形成的总block数,共9个block
for i=1:m-1
    for j=1:n-1           
        f=[];
        f=[f Cell{i,j}(:)' Cell{i,j+1}(:)' Cell{i+1,j}(:)' Cell{i+1,j+1}(:)'];%将当前block中的36维向量放入f中
        f=f/(sum(f.^2).^0.5);  %对block进行l2归一化
        feature{(i-1)*(n-1)+j}=f;%把当前block以元组细胞的形式放入最终整个图像patch的梯度方向直方图向量中
     end
end
%到此结束，feature即为所求
l=length(feature);
f=[];
for i=1:l
     f=[f feature{i}(:)'];  
end 
%HOG{(k-1)*nImages+g,1}=f;
result=result+1;
HOG{result,1}=f;