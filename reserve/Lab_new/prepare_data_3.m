% Author: Adnan Chaudhry
% Date: September 21, 2016
%% Prepare training data for training the NR CNN for IQA


%%
clc;
clear;

% Image will be divided into patchSize x patchSize patches
patchSize = 32;
% window size used in local contrast normalization
% A window of windowSize x windowSize will be used
windowSize = 3;

% Prompt user for the directory holding input images
inputDir = uigetdir('.', 'Select input images'' directory');
inputDir = strcat(inputDir, '/');
% Get all image files in the directory
imageFiles = dir(strcat(inputDir, '*.bmp'));
% Output images' path
outputDir = strcat(inputDir, 'hsi_3/');
% if output directory does not exist then create it
if(exist(outputDir, 'dir') == 0)
    mkdir(outputDir);
end

display('Began preparing training data...');
tic;

%%
% Run through all images
nImages = length(imageFiles);
for i =  1: nImages
    % Read image and convert to a grayscale and double matrix
    imageName = imageFiles(i).name;
    image = imread(strcat(inputDir, imageName));
    image = rgb2hsi(image);
    image = double(image);    
    % Divide the image into patchSize x patchSize size patches
    imagePatches = getImagePatches_3(image, patchSize); 
    % Apply local contrast normalization to image patches
    normalizedPatches = normalizeLocalContrast_3(imagePatches,windowSize,patchSize);
    % Save normalized image patches to disk
    saveImagePatches_3(normalizedPatches, outputDir, imageName);
end

toc;
display('Finished preparing training data.')