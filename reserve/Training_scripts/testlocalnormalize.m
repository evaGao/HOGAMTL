function ln=testlocalnormalize(imagePatches,patchSize,outputDir, imageName)
[nRowPatches, nColPatches,dim] = size(imagePatches);
norPatches = zeros(nRowPatches * patchSize, nColPatches * patchSize);
rowPatchSizeVector = patchSize * ones(1, nRowPatches);
colPatchSizeVector = patchSize * ones(1, nColPatches);
normalizedPatches(:,:,1) = mat2cell(norPatches, rowPatchSizeVector, colPatchSizeVector);
normalizedPatches(:,:,2) = mat2cell(norPatches, rowPatchSizeVector, colPatchSizeVector);
normalizedPatches(:,:,3) = mat2cell(norPatches, rowPatchSizeVector, colPatchSizeVector);
ln1=normalizedPatches(:,:,1);
ln2=normalizedPatches(:,:,2);
ln3=normalizedPatches(:,:,3);
i1=imagePatches(:,:,1);
i2=imagePatches(:,:,2);
i3=imagePatches(:,:,3);
for r = 1 : nRowPatches
    for c = 1 : nColPatches
        patch(:,:,1) = i1{r, c};
        patch(:,:,2) = i2{r, c};
        patch(:,:,3) = i3{r, c};
        im=patch;
        fim=mat2gray(im);
%fim=rgb2gray(im);
        gaussian1=fspecial('gaussian',3,0.1);
        gaussian2=fspecial('gaussian',3,25);
%meanFilter(:,:,1) = ones(3, 3) / (3 * 3);
% meanFilter(:,:,2) = ones(3, 3) / (3 * 3);
% meanFilter(:,:,3) = ones(3, 3) / (3 * 3);
        num=fim-imfilter(fim,gaussian2);
%num=im2double(num);
        den=sqrt(imfilter(num.^2,gaussian1));
%den=rgb2gray(den);
%den=mat2gray(den);
%imshow(den);
        lnfim=num./(den+1e-8);
%lnfim=localnormalize(fim,4,4);
        lnfim=mat2gray(lnfim);
        ln(:,:,1) =lnfim(:,:,1);
        ln(:,:,2) =lnfim(:,:,2);
        ln(:,:,3) =lnfim(:,:,3);
%         ln{:,:,1}=ln1{r,c};
%         ln{:,:,2}=ln2{r,c};
%         ln{:,:,3}=ln3{r,c};
        saveImagePatches(ln, nColPatches,outputDir, imageName,r,c)
    end
end
%figure,imshow(lnfim);