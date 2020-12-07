clear all;
close all;
clc;

img=imread('/home/xiaogao/Downloads/screen_content/SCIQAD/references/references/cim1.bmp');
image=rgb2gray(img);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%对图像进行分块处理%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
patchsize=32;    %模板半径
[rows, cols] = size(image);
nRowPatches = double(int32(rows / patchsize));
nColPatches = double(int32(cols / patchsize));
nScaledRows = nRowPatches * patchsize;
nScaledCols = nColPatches * patchsize;
resizedImage = imresize(image, [nScaledRows nScaledCols]);
rowPatchSizeVector = patchsize * ones(1, nRowPatches);
colPatchSizeVector = patchsize * ones(1, nColPatches);
imagepatches= mat2cell(resizedImage(:,:,1), rowPatchSizeVector, colPatchSizeVector);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%对每一块求局部熵,loencell的每一个元素值为该图像块的局部熵值%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loencell=cellfun(@entropy,imagepatches);


for i=1:nRowPatches
	for j=1:nColPatches
		imagepatches{i,j}(:)=loencell(i,j);
    end
end
imgn=cell2mat(imagepatches);
figure,imshow(imgn,[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%求局部熵的熵函数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function loen=entropy(img)
   loen=0;
   Hist=zeros(1,256);
   for i=1:32
      for j=1:32
          Hist(img(i,j)+1)=Hist(img(i,j)+1)+1;    %统计局部直方图
      end
   end
   Hist=Hist/sum(Hist);
   for k=1:256
      if Hist(k)~=0
         loen=loen+Hist(k)*log2(1/Hist(k));  %局部熵
      end
   end
end