function saveImagePatches_3(imagePatches,outputDir,imageName)
[rowDim, colDim,dim] = size(imagePatches);
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
        if ~exist(outFile,'file')
            imwrite(imagePatches{r,c}, outFile);
        end
    end
end

end