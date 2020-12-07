function normalizedPatches = normalizeLocalContrast(imagePatches, windowSize, patchSize)
% pre-allocate output memory
[nRowPatches, nColPatches] = size(imagePatches);
normalizedPatches = zeros(nRowPatches * patchSize, nColPatches * patchSize);
rowPatchSizeVector = patchSize * ones(1, nRowPatches);
colPatchSizeVector = patchSize * ones(1, nColPatches);
normalizedPatches = mat2cell(normalizedPatches, rowPatchSizeVector, colPatchSizeVector);

gaussian=fspecial('gaussian',windowSize,3);%得到高斯滤波核

% Run through all patches
for r = 1 : nRowPatches
    for c = 1 : nColPatches
        patch = imagePatches{r, c};
        % Compute local mean
        meanPatch=imfilter(patch,gaussian);
        % Compute local standard deviation
        stdDevPatch=sqrt(imfilter((patch-meanPatch).^2,gaussian));
        % Subtract local mean and divide by local standard deviation and add a
        % small constant to denominator in order to avoid division by zero
        normalizedPatches{r,c} = (patch - meanPatch) ./ (stdDevPatch + 1e-8);
    end
end
end