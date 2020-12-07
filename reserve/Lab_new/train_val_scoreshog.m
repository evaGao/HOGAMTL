%流程：找到所有失真图像和所有参考图像-》通过dmos.mat获取所有失真图像的分数dmosArray，通过info_all.txt获取所有参考图像对应的失真图像
%信息ref2DisMapping-》找到一幅参考图像，根据其名字在ref2DisMapping中定位并求出其位置列表distIdx-》根据distIdx,选取其中的一个值，
%并重新定位到ref2DisMapping中，找到在该项列表值下所对应的某一幅失真图像的位置distImgIdx——》根据distImgIdx求出该位置suo对应的失真图像
%名字distImgId和它的ID号，即distImgName[4:-4]-》根据此ID号在dmosArray中找到其对应的质量分数-》开始给该失真图像的块命名，并将上步
%得到的分数都对应上即可
%%
clc;
clear;
patchSize = 32;
randomSeed = 7;
rng(randomSeed);
trainValIters = 1;
refDataDir = uigetdir('.', 'Select reference image data directory');
refDataDir = strcat(refDataDir, '/');
distDataDir = uigetdir('.', 'Select distortion image data directory');
distDataDir = strcat(distDataDir, '/');
outputDir = strcat('/home/xiaogao/Downloads/screen_content/SCIQAD/','mappings/');
if(exist(outputDir, 'dir') == 0)
    mkdir(outputDir);
end
dmos=load(strcat(distDataDir, 'dmos.mat'));
fNames = fieldnames(dmos);
dmosArray = dmos.(fNames{1});
refImageFiles = dir(strcat(refDataDir, '*.bmp'));
display('Creating training and validation sets'' files ...');
nRefImages = length(refImageFiles);
refImageNames = {refImageFiles.name};
refImNames=sort_nat(refImageNames);
mappingFile = fopen(strcat(distDataDir, 'info_all.txt'), 'r');
if(mappingFile == -1)
    error('Could not open info.txt mapping file');
end
ref2DistMapping = textscan(mappingFile, '%s %s %s');
fclose(mappingFile);
nDistImages = length(ref2DistMapping{2});
if(nDistImages ~= length(dmosArray))
    error('Mismatch in the number of images and the number of corresponding DMOS scores');
end
hog=load('/home/xiaogao/Downloads/screen_content/code/lbp.txt');%有特色的改动
row_deadline=1;%该变量表示在hog特征中已经截止到取第几块图像，即第几行
for i = 1 : trainValIters
    scoresFileTrain = fopen(strcat(outputDir, 'scores_train_', num2str(i), '.txt'), 'wt');
    if(scoresFileTrain == -1)
        error('Could not create/open training file for writing');
    end
    scoresFileVal = fopen(strcat(outputDir, 'scores_val_', num2str(i), '.txt'), 'wt');
    if(scoresFileVal == -1)
        error('Could not create/open validation file for writing');
    end
    for j = 1 : nRefImages
        isTrain = 0;
        if(rand() < 0.8)
            isTrain = 1;
        end
        refName = refImNames{j};
        cellIdx = strfind(ref2DistMapping{1}, refName);
        distIdx = find(~cellfun('isempty', cellIdx));
        nDistIdx = length(distIdx);
        for k = 1 : nDistIdx
            distImgIdx = distIdx(k);
            distImgName = ref2DistMapping{2}{distImgIdx};
            distImgId = str2double(distImgName(4 : end - 4));
            distImg = imread(strcat(distDataDir, distImgName));
            nPatches = calcNumPatches(distImg, patchSize);
            if(isTrain)
                train_val_writeScoreData(scoresFileTrain, distImgName, nPatches, dmosArray(distImgId),hog,row_deadline);%该从row_deadline这一行开始取特征啦
            else
                train_val_writeScoreData(scoresFileVal, distImgName, nPatches, dmosArray(distImgId),hog,row_deadline);
            end
            row_deadline=row_deadline+nPatches;
        end
    end
    fclose(scoresFileTrain);
    fclose(scoresFileVal);
    percentageDone = (i / trainValIters) * 100;
    disp(['Progress = ', num2str(percentageDone), '%']);
end

disp('Done.');
