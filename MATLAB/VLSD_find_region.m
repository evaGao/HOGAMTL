clc;
clear all;
%对预训练得到的图像块质量分数分配不同权重后再重新写入文件
addpath /home/xiaogao/Downloads/screen_content/simpsal/simpsal;
%各变量目的：LSD和局部熵用于判断是否为空白块，VLSD用于做普通权重，Saliency用于做面积权重
%len是所有测试图像块的数量；outputs是分配权重后各测试图像块的预测质量分数列表;scores是各测试图像块的真实质量分数列表
%entropy中的每个元素为局部熵图中每个块的平均局部熵值，lsd中的每个元素值为LSD图中每个块的平均LSD值;
%T为局部熵的阈值（判断是否为pictual region),T1为LSD图的阈值（判断是否为text region）
%tr为一幅图像中的文字块数量，pr为一幅图像中图像块的数量，amount为文字块和图像块的总数量
%all用于统计所有的权重之和，作为最后的分母
%k用于记录每一块的位置，也就是说现在到了哪一行，哪一块
addpath libsvm;
k=0;
p=1;
%获得测试图像块的名字、分数列表
%[patch]=textread('/media/xiaogao/GLORIA/SCIQAD/outputs/image_label/test.txt','%s%*[^\n]')
%获得测试图像的名字列表
[val]=textread('/media/xiaogao/GLORIA/SCID/cross/cross_name','%s');
%[val]=textread('/media/xiaogao/GLORIA/SCID/name_norepetition.txt','%s');
%[val]=textread('/media/xiaogao/GLORIA/SCIQAD/outputs/name.txt','%s');
%获得所有图像块的预测分数值
output=textread('/media/xiaogao/GLORIA/SCID/cross_result/origin/output_insert.txt','%s');
%output=textread('/media/xiaogao/GLORIA/SCIQAD/new_outputs/8.29/origin/output_insert.txt','%s');
%获得所有图像块的真实分数值
score=textread('/media/xiaogao/GLORIA/SCID/cross_result/origin/scores_insert.txt','%s');
%score=textread('/media/xiaogao/GLORIA/SCIQAD/new_outputs/8.29/origin/scores_insert.txt','%s');
len=length(output);
outputs=[];
scores=[];
patchSize=32;
%%%%%%%%%%%%%%%%%   一张张读取测试图像     %%%%%%%%%%%%%%%%%%%%
for i=1:length(val)
   im = imread(strcat('/home/xiaogao/Downloads/screen_content/SCID/distorted_after/',val{i,1}));
   %im = imread(strcat('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/',val{i,1}));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    求一幅图像的LSD图：den     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
all=0;
fim=rgb2gray(im);%将测试图像转为灰度图
fim=double(fim);%%转换为double型，扩大精度范围
gaussian=fspecial('gaussian',3,1.5);%高斯滤波参数
num=fim-imfilter(fim,gaussian);%去均值滤波
den=sqrt(imfilter(num.^2,gaussian));%局部标准差LSD

%%%%%%%%%%%%%%%%%%%          对所求的局部标准差LSD图进行分块操作:new      %%%%%%%%%%%%%%%%%%%%%
[rows, cols] = size(den);
nRowPatches = double(int32(rows / patchSize));
nColPatches = double(int32(cols / patchSize));
nScaledRows = nRowPatches * patchSize;
nScaledCols = nColPatches * patchSize;
resizedImage = imresize(den, [nScaledRows nScaledCols]);
rowPatchSizeVector = patchSize * ones(1, nRowPatches);
colPatchSizeVector = patchSize * ones(1, nColPatches);
new = mat2cell(resizedImage, rowPatchSizeVector, colPatchSizeVector);%把图像进行分块
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%     求图像块的VLSD值，large中的每个元素为该图像中个各图像块的VLSD值:large     %%%%%%%%%%%%%%%%%%
large=cellfun(@(x) sum((x(:)-mean(x(:))).^2)/1024,new);%每一块子图像的VLSD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%      找到一幅图像中去掉空白块后文字块和图像块各自的数量及其总数:tr,pr,amount        %%%%%%%%%%%%%%%%%%  
[entropy,lsd,T,T1] = findVacancy(im);%该函数用于发现空白块
tr=0;
pr=0;
amount=0;
saliency=my_simpsal(im);%求图像的显著性区域,saliency中的每个元素为显著性图像中各图像分块中像素的最大值
[r,c]=size(saliency);
for m=1:nRowPatches
    for n=1:nColPatches
        if entropy(m,n)>T || lsd(m,n)>T1 %%是老夫选中的块，小样，你很荣幸嘛！
            if saliency(m,n)>=0 && saliency(m,n)<=0.03
                tr=tr+1; %努力地统计文字块数量ing...
            else
                pr=pr+1; %努力地统计图像块数量ing...
            end
            amount=amount+1;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%   %让原始预测的每一块的分数乘以他的权重，得到新的预测分数列表：outputs  %%%%%%%%%%%%%
for m=1:nRowPatches
    for n=1:nColPatches
        k=k+1;
        if entropy(m,n)>T || lsd(m,n)>T1  %只有被朕选中的块才有资格进行以下操作，空白块，你想都别想！
            if saliency(m,n)>=0 && saliency(m,n)<=0.03 %如果你是文字块的话，嘿嘿...
                large(m,n)=large(m,n)^1.5*entropy(m,n)^8.0+tr;%这是朕赐予你文字块的专属权重，朕不容许你拒绝!
                %large(m,n)=tr;
                all=all+large(m,n); %all用于统计所有的权重之和，作为最后的分母
                outputs(k,1)=str2double(output{k,1})*large(m,n);%待求和的每一块子图像的s值
                scores(k,1)=str2double(score{k,1});
            else %如果你是图像块，哈哈...
                large(m,n)=large(m,n)^1.5*entropy(m,n)^8.0+pr;%这是朕赐予你图像块的独有权重，别块勿觊觎，否则杀无赦！
                %large(m,n)=pr;
                all=all+large(m,n);
                outputs(k,1)=str2double(output{k,1})*large(m,n);%待求和的每一块子图像的s值
                scores(k,1)=str2double(score{k,1});
            end
        else
            outputs(k,1)=0;%你作为一个空白块，就不考虑你咯
            scores(k,1)=str2double(score{k,1});
        end
       % k=k+1;%k用于记录每一块的位置，也就是说现在到了哪一行，哪一块
    end
end
outputs(length(outputs)-nRowPatches*nColPatches+1:length(outputs))= outputs(length(outputs)-nRowPatches*nColPatches+1:length(outputs))/all;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%  将所得到的新的预测分数列表和真实质量分数值放到文件中：fid1,fid2  %%%%%%%%%%%%%%%%%%%%%%
[m,n]=size(outputs);
fid1=fopen('/media/xiaogao/GLORIA/SCID/cross_result/new/output.txt','wt');
fid2=fopen('/media/xiaogao/GLORIA/SCID/cross_result/new/scores.txt','wt');
%fid1=fopen('/media/xiaogao/GLORIA/SCIQAD/new_outputs/8.29/new/output.txt','wt');
%fid2=fopen('/media/xiaogao/GLORIA/SCIQAD/new_outputs/8.29/new/scores.txt','wt');
for i=1:m
    fprintf(fid1,'%g',outputs(i,:));
    fprintf(fid1,'\n');
end
fclose(fid1);
for i=1:m
    fprintf(fid2,'%g',scores(i,:));
    fprintf(fid2,'\n');
end
fclose(fid2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%