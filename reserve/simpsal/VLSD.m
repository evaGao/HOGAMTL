k=1;
p=1;
[patch]=textread('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/mappings/scores_val_1.txt','%s%*[^\n]')
[val]=textread('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/mappings/val.txt','%s');
output=textread('/home/xiaogao/下载/NR-IQA-CNN-master1/outputs/output_1.txt','%s');
score=textread('/home/xiaogao/下载/NR-IQA-CNN-master1/outputs/scores_1.txt','%s');
len=length(output);
outputs={};
scores={};
patchSize=32;
for i=1:length(val)
    im = imread(strcat('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/',val{i,1}));%一张张读取测试图像

%im=imread('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/img1.bmp');
%fim=mat2gray(im);
fim=rgb2gray(im);%将测试图像转为灰度图
fim=mat2gray(fim);%归一化该灰度图，便于之后的处理
gaussian1=fspecial('gaussian',3,0.1);%求局部标准差时的高斯滤波参数
gaussian2=fspecial('gaussian',3,25);%求局部平均值时的高斯滤波参数
%meanFilter(:,:,1) = ones(3, 3) / (3 * 3);
% meanFilter(:,:,2) = ones(3, 3) / (3 * 3);
% meanFilter(:,:,3) = ones(3, 3) / (3 * 3);
num=fim-imfilter(fim,gaussian2);
%num=im2double(num);
den=sqrt(imfilter(num.^2,gaussian1));%局部标准差LSD
%den=num./(den+1e-8);
%den=rgb2gray(den);
%den=mat2gray(den);
%imshow(den);
%        lnfim=num./(den+1e-8);
%lnfim=localnormalize(fim,4,4);
%den=mat2gray(den);
den(:)=(den(:)-mean(den(:))).^2;
%den=mat2gray(den);
%imshow(den);
%den=mat2gray(den);
[rows, cols] = size(den);


nRowPatches = double(int32(rows / patchSize));
nColPatches = double(int32(cols / patchSize));
nScaledRows = nRowPatches * patchSize;
nScaledCols = nColPatches * patchSize;


resizedImage = imresize(den, [nScaledRows nScaledCols]);
rowPatchSizeVector = patchSize * ones(1, nRowPatches);
colPatchSizeVector = patchSize * ones(1, nColPatches);
new = mat2cell(resizedImage, rowPatchSizeVector, colPatchSizeVector);%把图像进行分块
large=cellfun(@(x) sum(x(:))/1024,new);%每一块子图像的VLSD
%large=mat2gray(large);
%[entropy,lsd,T,T1] = findVacancy(im);
all=sum(sum(large));
for m=1:nRowPatches
	for n=1:nColPatches
		new{m,n}(:)=large(m,n);
       % if entropy(m,n)>T || lsd(m,n)>T1
        outputs{p,1}=str2double(output{k,1})*large(m,n)/all;%待求和的每一块子图像的S值
        scores{p,1}=str2double(score{k,1});
        k=k+1;
    end
end
%end
%den=cell2mat(new);
%den=mat2gray(den);
%imshow(den);
%figure,imshow(lnfim);
end
a=cell2mat(outputs);
b=cell2mat(scores);
fid1=fopen('/home/xiaogao/下载/NR-IQA-CNN-master1/outputs/outputs_3.txt','wt');
fid2=fopen('/home/xiaogao/下载/NR-IQA-CNN-master1/outputs/scores_3.txt','wt');
for i=1:m
    fprintf(fid1,'%g',a(i,:));
    fprintf(fid1,'\n');
end
fclose(fid1);
for i=1:m
    fprintf(fid2,'%g',b(i,:));
    fprintf(fid2,'\n');
end
fclose(fid2);