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
inputDir = uigetdir('.', 'Select input images'' directory');
inputDir = strcat(inputDir, '/');
% Get all image files in the directory
imageFiles = dir(strcat(inputDir, '*.bmp'));


%%
% Run through all images
nImages = length(imageFiles);
nameCell=cell(nImages,1);
for g =  1: nImages
% Read image and convert to a grayscale and double matrix
   nameCell{g} = imageFiles(g).name;
end
d2=sort_nat(nameCell);
for g =  1: nImages
    imageName=d2{g};
    image = imread(strcat(inputDir, imageName));
  %  image = rgb2hsi(image);
   % image=image(:,:,1);
    image = double(image);    
    % Divide the image into patchSize x patchSize size patches
    imagePatches = getImagePatches_3(image, patchSize); 
    [nRowPatches, nColPatches,dim] = size(imagePatches);
    for r = 1 : nRowPatches
        for c = 1 : nColPatches
            levelx=[];
            levely=[];
            for i=1:dim
                middle=imagePatches(:,:,i);
                img(:,:,i)=middle{r,c};
            end
            [m,n,dim]=size(img);
            %%%%%%%%%%%%%%%%%下面是求图像中各个像素值的梯度幅值和梯度方向%%%%%%%%%%%%%%%%%%%%%
            fy=[-1 0 1];        %定义竖直模板
            fx=fy';             %定义水平模板
            levely=imfilter(img,fy,'replicate');    %竖直边缘
            levelx=imfilter(img,fx,'replicate');    %水平边缘
            amplitude=sqrt(levelx.^2+levely.^2);              %梯度幅值
            direction=levely./levelx;              %梯度方向，有些为inf,-inf,nan，其中nan需要再处理一下
            %%%%用于求解三通道中梯度幅值最大值以及对应的梯度方向%%%%%%
            Ied=zeros(m,n);
            Iphase=zeros(m,n);
            Ix=zeros(m,n);
            for i=1:m
                for j=1:n
                    a=[];
                    for k=1:dim
                        mid=amplitude(:,:,k);
                        a=[a,mid(i,j)];
                    end
                    biggest=max(a);
                    [x,y]=find(a==biggest);
                    Ied(i,j)=biggest;
                    direc=direction(:,:,y);
                    Iphase(i,j)=direc(i,j);
                    level=levelx(:,:,y);
                    Ix(i,j)=level(i,j);
                end
            end   
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
                    tmpx=[];
                    tmped=[];
                    tmpphase=[];
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
            if result==98142
                result=result;
            end
            HOG{result,1}=f;
        end
    end
end
            
            
            
            
            
            
            
            
            
% %%求图像的梯度方向直方图（HOG）
% clear all; 
% close all; clc;
% HOG=cell(1,1);
% result=0;
% inputDir = uigetdir('.', 'Select input images'' directory');
% inputDir = strcat(inputDir, '/');
% % Get all image files in the directory
% steps=980; %失真图像一共有980幅，因此需设置外部循环980次，内部循环次数为每个失真图像分块后的数量，从而求每个分块的hog特征
% hwait=waitbar(0,'请等待>>>>>>>>');
% step=steps/100;
% for k=1:steps
%     input=strcat(inputDir,'img',int2str(k),'/');
%     imageFiles = dir(strcat(input, '*.bmp'));%%打开每个失真图像存储对应分块的文件夹
%     nImages = length(imageFiles);%计算出每个失真图像分块后的块数量，作为内部循环次数
%     nameCell=cell(nImages,1);
%     for g =  1: nImages
%     % Read image and convert to a grayscale and double matrix
%         nameCell{g} = imageFiles(g).name;
%     end
%     d2=sort_nat(nameCell); %将失真图像分块按名字顺序访问
%     for g =  1: nImages
%         imageName=d2{g};
%         img= imread(strcat(input, imageName));
%         [m n]=size(img);
%         img=double(img);
%         %img=sqrt(img);      %伽马校正.用于避免图像受其他失真的影响，在平常的HOG提取中需要用到。但是这儿主要针对失真图像，不能破坏其失真水平，故不进行gama校正
% 
%         %%%%%%%%%%%%%%%%%下面是求图像中各个像素值的梯度幅值和梯度方向%%%%%%%%%%%%%%%%%%%%%
%         fy=[-1 0 1];        %定义竖直模板
%         fx=fy';             %定义水平模板
%         Iy=imfilter(img,fy,'replicate');    %竖直边缘
%         Ix=imfilter(img,fx,'replicate');    %水平边缘
%         Ied=sqrt(Ix.^2+Iy.^2);              %梯度幅值
%         Iphase=Iy./Ix;              %梯度方向，有些为inf,-inf,nan，其中nan需要再处理一下
% 
% 
%         %%%%%%利用循环遍历求解图像中各个8*8网格(non-overlap)的梯度直方图向量,为9维.并按其在图像中的位置以元组细胞的形式放入Cell元组变量中%%%%%%
%         step=8;                %step*step个像素作为一个单元
%         orient=9;               %方向直方图的方向个数
%         jiao=360/orient;        %每个方向包含的角度数
%         Cell=cell(1,1);              %所有的角度直方图,cell是可以动态增加的，所以先设了一个
%         ii=1;                      
%         jj=1;
%         for i=1:step:m          %如果处理的m/step不是整数，最好是i=1:step:m-step
%             ii=1;
%             for j=1:step:n      %注释同上
%                 tmpx=Ix(i:i+step-1,j:j+step-1);%当前8*8网格下的水平边缘值矩阵
%                 tmped=Ied(i:i+step-1,j:j+step-1);%当前8*8网格下的梯度幅值矩阵
%                 %tmped=tmped/sum(sum(tmped));        %当前8*8网格下的梯度幅值矩阵的各个像素归一化
%                 tmpphase=Iphase(i:i+step-1,j:j+step-1);%当前8*8网格下的梯度方向矩阵
%                 Hist=zeros(1,orient);               %当前8×8网格下的梯度直方图向量
%                 for p=1:step
%                     for q=1:step
%                         if isnan(tmpphase(p,q))==1  %0/0会得到nan，如果像素是nan，重设为0
%                             tmpphase(p,q)=0;
%                         end
%                         ang=atan(tmpphase(p,q));    %atan求的是[-90 90]度之间
%                         ang=mod(ang*180/pi,360);    %全部变正，-90变270
%                         if tmpx(p,q)<0              %根据x方向确定真正的角度
%                             if ang<90               %如果是第一象限
%                                 ang=ang+180;        %移到第三象限,x的方向大于0的仍然是在第一象限
%                             end
%                             if ang>270              %如果是第四象限
%                                 ang=ang-180;        %移到第二象限,x的方向大于0的仍然是在第四象限
%                             end
%                         end
%                         ang=ang+0.0000001;          %防止ang为0
%                         Hist(ceil(ang/jiao))=Hist(ceil(ang/jiao))+tmped(p,q);  %ceil向上取整，求出该角度对应到梯度方向中的位置，然后将其梯度幅值加进去
%                     end
%                 end
%                % Hist=Hist/sum(Hist);    %再一次方向直方图归一化
%                 Cell{jj,ii}=Hist;       %将当前的8*8网格的梯度方向直方图向量放入Cell中
%                 ii=ii+1;                %横向上计算当前8*8网格的序数
%             end
%             jj=jj+1;                    %纵向上计算当前8*8网格的序数
%         end
% 
% 
%         %下面是求feature,2*2个网格合成一个block(overlap),现在该block的梯度方向直方图向量为36维.并把每个block以元组细胞的形式放入最终整个图像patch的梯度方向直方图向量中
%         [m n]=size(Cell);
%         feature=cell(1,(m-1)*(n-1));%计算以8像素重叠滑动后形成的总block数,共9个block
%         for i=1:m-1
%             for j=1:n-1           
%                 f=[];
%                 f=[f Cell{i,j}(:)' Cell{i,j+1}(:)' Cell{i+1,j}(:)' Cell{i+1,j+1}(:)'];%将当前block中的36维向量放入f中
%                 f=f/(sum(f.^2).^0.5);  %对block进行l2归一化
%                 feature{(i-1)*(n-1)+j}=f;%把当前block以元组细胞的形式放入最终整个图像patch的梯度方向直方图向量中
%             end
%         end
% 
% 
% 
%         %到此结束，feature即为所求
%         l=length(feature);
%         f=[];
%         for i=1:l
%             f=[f feature{i}(:)'];  
%         end 
%         %HOG{(k-1)*nImages+g,1}=f;
%         result=result+1;
%         HOG{result,1}=f;
%     end
%     if steps-k<=5
%         waitbar(k/steps,hwait,'即将完成');
%         pause(0.05);
%     else
%         PerStr=fix(k/step);
%         str=['正在运行中',num2str(PerStr),'%'];
%         waitbar(k/steps,hwait,str);
%         pause(0.05);
%     end
% end
% close(hwait);
% delete(hwait);


% %%
% % Run through all images
% nImages = length(imageFiles);
% for i =  1: nImages
%     % Read image and convert to a grayscale and double matrix
%     imageName = imageFiles(i).name;
%     image = imread(strcat(inputDir, imageName));
% 
% 
% %%%%%%%%%%%%%%%读取图像，将其转换为灰度图%%%%%%%%%%%%%%%%%%%%%%%%%
% image=imread('/home/xiaogao/Downloads/screen_content/lena.jpg');
% img=rgb2gray(image); %%HOG提取的是纹理特征，颜色信息不起作用，所以将彩色图转换为灰度图
% [m n]=size(img);
% img=double(img);
% %img=sqrt(img);      %伽马校正.用于避免图像受其他失真的影响，在平常的HOG提取中需要用到。但是这儿主要针对失真图像，不能破坏其失真水平，故不进行gama校正
% 
% %%%%%%%%%%%%%%%%%下面是求图像中各个像素值的梯度幅值和梯度方向%%%%%%%%%%%%%%%%%%%%%
% fy=[-1 0 1];        %定义竖直模板
% fx=fy';             %定义水平模板
% Iy=imfilter(img,fy,'replicate');    %竖直边缘
% Ix=imfilter(img,fx,'replicate');    %水平边缘
% Ied=sqrt(Ix.^2+Iy.^2);              %梯度幅值
% Iphase=Iy./Ix;              %梯度方向，有些为inf,-inf,nan，其中nan需要再处理一下
% 
% 
% %%%%%%利用循环遍历求解图像中各个8*8网格(non-overlap)的梯度直方图向量,为9维.并按其在图像中的位置以元组细胞的形式放入Cell元组变量中%%%%%%
% step=8;                %step*step个像素作为一个单元
% orient=9;               %方向直方图的方向个数
% jiao=360/orient;        %每个方向包含的角度数
% Cell=cell(1,1);              %所有的角度直方图,cell是可以动态增加的，所以先设了一个
% ii=1;                      
% jj=1;
% for i=1:step:m          %如果处理的m/step不是整数，最好是i=1:step:m-step
%     ii=1;
%     for j=1:step:n      %注释同上
%         tmpx=Ix(i:i+step-1,j:j+step-1);%当前8*8网格下的水平边缘值矩阵
%         tmped=Ied(i:i+step-1,j:j+step-1);%当前8*8网格下的梯度幅值矩阵
%         tmped=tmped/sum(sum(tmped));        %当前8*8网格下的梯度幅值矩阵的各个像素归一化
%         tmpphase=Iphase(i:i+step-1,j:j+step-1);%当前8*8网格下的梯度方向矩阵
%         Hist=zeros(1,orient);               %当前8×8网格下的梯度直方图向量
%         for p=1:step
%             for q=1:step
%                 if isnan(tmpphase(p,q))==1  %0/0会得到nan，如果像素是nan，重设为0
%                     tmpphase(p,q)=0;
%                 end
%                 ang=atan(tmpphase(p,q));    %atan求的是[-90 90]度之间
%                 ang=mod(ang*180/pi,360);    %全部变正，-90变270
%                 if tmpx(p,q)<0              %根据x方向确定真正的角度
%                     if ang<90               %如果是第一象限
%                         ang=ang+180;        %移到第三象限,x的方向大于0的仍然是在第一象限
%                     end
%                     if ang>270              %如果是第四象限
%                         ang=ang-180;        %移到第二象限,x的方向大于0的仍然是在第四象限
%                     end
%                 end
%                 ang=ang+0.0000001;          %防止ang为0
%                 Hist(ceil(ang/jiao))=Hist(ceil(ang/jiao))+tmped(p,q);  %ceil向上取整，求出该角度对应到梯度方向中的位置，然后将其梯度幅值加进去
%             end
%         end
%         Hist=Hist/sum(Hist);    %再一次方向直方图归一化
%         Cell{jj,ii}=Hist;       %将当前的8*8网格的梯度方向直方图向量放入Cell中
%         ii=ii+1;                %横向上计算当前8*8网格的序数
%     end
%     jj=jj+1;                    %纵向上计算当前8*8网格的序数
% end
% 
% 
% %下面是求feature,2*2个网格合成一个block(overlap),现在该block的梯度方向直方图向量为36维.并把每个block以元组细胞的形式放入最终整个图像patch的梯度方向直方图向量中
% [m n]=size(Cell);
% feature=cell(1,(m-1)*(n-1));%计算以8像素重叠滑动后形成的总block数
% for i=1:m-1
%    for j=1:n-1           
%         f=[];
%         f=[f Cell{i,j}(:)' Cell{i,j+1}(:)' Cell{i+1,j}(:)' Cell{i+1,j+1}(:)'];%将当前block中的36维向量放入f中
%         feature{(i-1)*(n-1)+j}=f;%把当前block以元组细胞的形式放入最终整个图像patch的梯度方向直方图向量中
%    end
% end
% 
% 
% 
% %到此结束，feature即为所求
% l=length(feature);
% f=[];
% for i=1:l
%     f=[f feature{i}(:)'];  
% end 
% %figure
% %mesh(f)
