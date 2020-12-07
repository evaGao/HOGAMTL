%流程：找到所有失真图像和所有参考图像-》通过dmos.mat获取所有失真图像的分数dmosArray，通过info_all.txt获取所有参考图像对应的失真图像
%信息ref2DisMapping-》找到一幅参考图像，根据其名字在ref2DisMapping中定位并求出其位置列表distIdx-》根据distIdx,选取其中的一个值，
%并重新定位到ref2DisMapping中，找到在该项列表值下所对应的某一幅失真图像的位置distImgIdx——》根据distImgIdx求出该位置多对应的失真图像
%名字distImgId和它的ID号，即distImgName[4:-4]-》根据此ID号在dmosArray中找到其对应的质量分数-》开始给该失真图像的块命名，并将上步
%得到的分数都对应上即可
%%
clc;
clear;

% Every training image is patchSize x patchSize patch of the original
% images in the dataset
patchSize = 32;

% It is recommended to seed the random number generator using rng()
% function if you want the same sequence of files to be allocated to the
% training and validation sets every time you run this script
randomSeed = 7;
rng(randomSeed);

% The number of training and validation set allocation files you want to
% generate (the number if train-validate iterations in k fold cross
% validation
trainValIters = 1;

% Prompt user to naviagte to the refernce image data directory
refDataDir = uigetdir('.', 'Select reference image data directory');
refDataDir = strcat(refDataDir, '/');

% Prompt user to naviagte to the distortion image data directory
% For example 'fastfading' directory
distDataDir = uigetdir('.', 'Select distortion image data directory');
distDataDir = strcat(distDataDir, '/');
% output directory 
outputDir = strcat(distDataDir, 'mappings/');
% if output directory does not exist then create it
if(exist(outputDir, 'dir') == 0)
    mkdir(outputDir);
end

% load dmos scores
dmos=load(strcat(distDataDir, 'dmos.mat'));
fNames = fieldnames(dmos);
dmosArray = dmos.(fNames{1});

% Get all image files in the reference image data directory
refImageFiles = dir(strcat(refDataDir, '*.bmp'));

display('Creating training and validation sets'' files ...');

%%
nRefImages = length(refImageFiles);
% Get list of reference images' names
refImNames = {refImageFiles.name};
% Load mappings of the reference images to their corresponding distorted
% versions
mappingFile = fopen(strcat(distDataDir, 'info_all.txt'), 'r');
if(mappingFile == -1)
    error('Could not open info.txt mapping file');
end
ref2DistMapping = textscan(mappingFile, '%s %s %s');
fclose(mappingFile);

% Some error checking
nDistImages = length(ref2DistMapping{2});
if(nDistImages ~= length(dmosArray))
    error('Mismatch in the number of images and the number of corresponding DMOS scores');
end

% For all train-validate iterations
for i = 1 : trainValIters
    % scores' File for training
    scoresFileTrain = fopen(strcat(outputDir, 'scores_train_', num2str(i), '.txt'), 'wt');
    if(scoresFileTrain == -1)
        error('Could not create/open training file for writing');
    end
    % scores' File for validation
    scoresFileVal = fopen(strcat(outputDir, 'scores_val_', num2str(i), '.txt'), 'wt');
    if(scoresFileVal == -1)
        error('Could not create/open validation file for writing');
    end
    % Run thorugh all reference images and assign 80% of the reference images
    % and their distorted versions to the training set and the rest 20% to the
    % validation set
    for j = 1 : nRefImages
        isTrain = 0;
        if(rand() < 0.8)
            % assign to training set
            isTrain = 1;
        end
        refName = refImNames{j};
        % Find distorted images corresponding to the current reference
        % image
        cellIdx = strfind(ref2DistMapping{1}, refName);
        distIdx = find(~cellfun('isempty', cellIdx));
        nDistIdx = length(distIdx);
        for k = 1 : nDistIdx
            % Index in the mapping table
            distImgIdx = distIdx(k);
            distImgName = ref2DistMapping{2}{distImgIdx};
            % distorted image ID i.e. the number xx in imgxx.bmp
            distImgId = str2double(distImgName(4 : end - 4));
            distImg = imread(strcat(distDataDir, distImgName));
            nPatches = calcNumPatches(distImg, patchSize);
            % Write image patch names alongwith their dmos score to the output
            % training or validation files
            if(isTrain)
                writeScoreData(scoresFileTrain, distImgName, nPatches, dmosArray(distImgId));
            else
                writeScoreData(scoresFileVal, distImgName, nPatches, dmosArray(distImgId));
            end
        end
    end
    fclose(scoresFileTrain);
    fclose(scoresFileVal);
    percentageDone = (i / trainValIters) * 100;
    disp(['Progress = ', num2str(percentageDone), '%']);
end

disp('Done.');
