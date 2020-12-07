%this script is used to calculate the pearson linear correlation
%coefficient and root mean sqaured error after regression

%get the objective scores computed by the IQA metric and the subjective
%scores provided by the dataset
%img = imread(strcat('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/',val{i,1}));
clear;
img = imread('/home/xiaogao/Downloads/screen_content/SCIQAD/DistortedImages/cim13_2_2.bmp');
patchSize=32;
[rows, cols,dim] = size(img);

% scale the number of rows and columns of the image such that a whole
% number of patches can be made out of it
    nRowPatches = double(int32(rows / patchSize));
    nColPatches = double(int32(cols / patchSize));
    exam=zeros(nRowPatches,nColPatches);
    
    nScaledRows = nRowPatches * patchSize;
    nScaledCols = nColPatches * patchSize;
    norPatches = zeros(nRowPatches * patchSize, nColPatches * patchSize);
% resize image according to the new rows and columns
    resizedImage = imresize(img, [nScaledRows nScaledCols]);
    rowPatchSizeVector = patchSize * ones(1, nRowPatches);
    colPatchSizeVector = patchSize * ones(1, nColPatches);
    new(:,:,1)=mat2cell(norPatches, rowPatchSizeVector, colPatchSizeVector);
    new(:,:,2)=mat2cell(norPatches, rowPatchSizeVector, colPatchSizeVector);
    new(:,:,3)=mat2cell(norPatches, rowPatchSizeVector, colPatchSizeVector);
    new(:,:,1)=mat2cell(resizedImage(:,:,1), rowPatchSizeVector, colPatchSizeVector);
    new(:,:,2)=mat2cell(resizedImage(:,:,2), rowPatchSizeVector, colPatchSizeVector);
    new(:,:,3)=mat2cell(resizedImage(:,:,3), rowPatchSizeVector, colPatchSizeVector);
    l1=new(:,:,1);
    l2=new(:,:,2);
    l3=new(:,:,3);
  %dui tuxiang jin xing yu chu li
    gray=rgb2gray(resizedImage);
    entropy=entropyfilt(gray);
    gray=mat2gray(gray);
    gaussian1=fspecial('gaussian',3,0.1);
    gaussian2=fspecial('gaussian',3,25);
%meanFilter(:,:,1) = ones(3, 3) / (3 * 3);
% meanFilter(:,:,2) = ones(3, 3) / (3 * 3);
% meanFilter(:,:,3) = ones(3, 3) / (3 * 3);
    num=gray-imfilter(gray,gaussian2);
%num=im2double(num);
    den=sqrt(imfilter(num.^2,gaussian1));
    %den=mat2gray(den);
% now divide into patches
   % rowPatchSizeVector = patchSize * ones(1, nRowPatches);
   % colPatchSizeVector = patchSize * ones(1, nColPatches);
    localenp = mat2cell(entropy, rowPatchSizeVector, colPatchSizeVector);
    localsta = mat2cell(den, rowPatchSizeVector, colPatchSizeVector);
    large=cellfun(@(x) mean(x(:)),localenp);
    large1=cellfun(@(x) mean(x(:)),localsta);
    T=0.12*max(entropy(:));
    T1=0.25*max(den(:));
    for m=1:nRowPatches
        for n=1:nColPatches
            if large(m,n)<=T && large1(m,n)<=T1
                l1{m,n}(:)=127;
                l2{m,n}(:)=127;
                l3{m,n}(:)=127;
            end
        end
    end
%     result(:,:,1)=cell2mat(new(:,:,1));
%     result(:,:,2)=cell2mat(new(:,:,2));
%     result(:,:,3)=cell2mat(new(:,:,3));
    result(:,:,1)=cell2mat(l1);
    result(:,:,2)=cell2mat(l2);
    result(:,:,3)=cell2mat(l3);
    
    imshow(result);