
%%% demonstration of how to use simpsal,
%%% the simple matlab implemenation of visual saliency.

%% 1. simplest possible usage : compute standard Itti-Koch Algorithm:
function large=my_simpsal(img)
%map1 = simpsal('lena.jpg');
%mapbig=mat2gray(imresize(map,[size(img,1) size(img,2)]));
% k=1;
% [patch]=textread('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/mappings/scores_val_1.txt','%s%*[^\n]')
% [val]=textread('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/mappings/val.txt','%s');
% output=textread('/home/xiaogao/涓嬭浇/NR-IQA-CNN-master1/outputs/output_1.txt','%s');
% score=textread('/home/xiaogao/涓嬭浇/NR-IQA-CNN-master1/outputs/scores_1.txt','%s');
% len=length(output);
% outputs=zeros(len,1);
% scores=zeros(len,1);
% for i=1:length(val)
 %   img = imread(strcat('/home/xiaogao/涓嬭浇/NR-IQA-CNN-master1/LIVE/gblur/img2.bmp'));
%% 2. more complciated usage:
    patchSize=32;
%img = imread('/home/xiaogao/Downloads/screen_content/SCIQAD/references/references/cim11.bmp');
    p = default_fast_param;
    p.blurRadius = 0.02;     % e.g. we can change blur radius 
    map2 = simpsal(img,p);
    map2=mat2gray(imresize(map2,[size(img,1) size(img,2)]));
%subplot(1,3,1);
%imshow(img);
%title('Original');

%subplot(1,3,2);
%imshow(map1)
%title('Itti Koch');
%imshow(map2);
    [rows, cols] = size(map2);

% scale the number of rows and columns of the image such that a whole
% number of patches can be made out of it
    nRowPatches = double(int32(rows / patchSize));
    nColPatches = double(int32(cols / patchSize));
    nScaledRows = nRowPatches * patchSize;
    nScaledCols = nColPatches * patchSize;

% resize the image according to the new rows and columns
    resizedImage = imresize(map2, [nScaledRows nScaledCols]);

% now divide into patches
    rowPatchSizeVector = patchSize * ones(1, nRowPatches);
    colPatchSizeVector = patchSize * ones(1, nColPatches);
    new = mat2cell(resizedImage, rowPatchSizeVector, colPatchSizeVector);
    large=cellfun(@(x) max(x(:)),new);
%      for m=1:nRowPatches
%          for n=1:nColPatches
%              new{m,n}(:)=large(m,n);
%             if large(m,n)>=0 || large(m,n)<=0.1
%                 row=(m-1)*nRowPatches+n;
%                 pos=strfind(val{i,1},'.');
%                 target=strcat(val{i,1}(1:pos),'/',val{i,1}(1:pos),'_patch_',num2str(row),'.bmp');
%                 [x,y]=find(strcmp(patch,target));
%                 outputs(k,1)=output{x,1};
%                 scores(k,1)=score{x,1};
%                 k=k+1;
%             end
%          end
%      end
%      map2=cell2mat(new);
% %end
% %map2=0.5-map2;
% %subplot(1,3,2);
% imshow(map2);
%title('Itti Koch Simplified');
