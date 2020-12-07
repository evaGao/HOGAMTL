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
outputDir = strcat(inputDir, 'hist_data/');
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
    image = rgb2gray(image);
    image = im2double(image);    
    % Divide the image into patchSize x patchSize size patches
    normalizedImage = testlocalnormalize_raw(image);%获得一整幅图像经过对比度归一化后的新图像
    imagePatches = divideImage(normalizedImage, patchSize);%对新图像进行分块
    %imagePatches = getImagePatches(image, patchSize);
    save(imagePatches,imageName,outputDir);%将图像块按照一定规律保存下来
    % Uncomment to visualize the image patches
    %visImagePatches(imagePatches);    
    % Apply local contrast normalization to image patches
   % normalizedPatches = testlocalnormalize(imagePatches,patchSize,outputDir, imageName);
    % Uncomment to visualize the normalized image patches
    %visImagePatches(normalizedPatches);
    % Save normalized image patches to disk
    %saveImagePatches(normalizedPatches, outputDir, imageName);
end

toc;
display('Finished preparing training data.')
