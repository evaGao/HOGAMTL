function saveImage(imagePatches,imageName,outputDir,patchSize)
[rowDim, colDim,dim] = size(imagePatches);
buffer=cell(rowDim,colDim);
stor=ones(patchSize,patchSize,3);
% Create a sub-directory with the image name which will hold the image
% patches
patchesOutputDir = strcat(outputDir, imageName(1 : end - 4), '/');
% if the directory does not exist then create it
if(exist(patchesOutputDir, 'dir') == 0)
    mkdir(patchesOutputDir);
end

% Run through all patches 
for r = 1 : rowDim
    for c = 1 : colDim
        % form name for the patch image
        patchName = strcat(imageName(1 : end - 4), '_patch_', num2str(((r - 1) * colDim) + c));
        outFile = strcat(patchesOutputDir, patchName, '.bmp');
        % Save to disk
        for i=1:3
            buffer=imagePatches(:,:,i);
            stor(:,:,i)=buffer{r,c};
        end
       % stor=mat2gray(stor);
        %stor=double(stor); 
        %stor=im2double(stor);
         stor=uint8(stor);
       % stor=im2double(stor);
        imwrite(stor, outFile);
    end
end

end