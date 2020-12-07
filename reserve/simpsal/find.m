k=1;
p=1;
[patch]=textread('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/mappings/scores_val_1.txt','%s%*[^\n]')
[val]=textread('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/mappings/val.txt','%s');
output=textread('/home/xiaogao/下载/NR-IQA-CNN-master1/outputs/output_1.txt','%s');
score=textread('/home/xiaogao/下载/NR-IQA-CNN-master1/outputs/scores_1.txt','%s');
len=length(output);
outputs=[];
scores=[];
patchSize=32;
for i=1:length(val)
    im = imread(strcat('/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/',val{i,1}));%一张张读取测试图像
    fim=rgb2gray(im);
    [rows, cols] = size(fim);


nRowPatches = double(int32(rows / patchSize));
nColPatches = double(int32(cols / patchSize));
nScaledRows = nRowPatches * patchSize;
nScaledCols = nColPatches * patchSize;


resizedImage = imresize(fim, [nScaledRows nScaledCols]);
rowPatchSizeVector = patchSize * ones(1, nRowPatches);
colPatchSizeVector = patchSize * ones(1, nColPatches);
new = mat2cell(resizedImage, rowPatchSizeVector, colPatchSizeVector);
    [entropy,lsd,T,T1] = findVacancy(im);
%all=sum(sum(large));
for m=1:nRowPatches
	for n=1:nColPatches
		%new{m,n}(:)=large(m,n);
        if entropy(m,n)>T || lsd(m,n)>T1
           % all=all+large(m,n);
            outputs(p,1)=str2double(output{k,1});%待求和的每一块子图像的S值
            scores(p,1)=str2double(score{k,1});
            p=p+1;
        end
        k=k+1;
    end
end

end
%a=cell2mat(outputs);
%b=cell2mat(scores);
[m,n]=size(outputs);
fid1=fopen('/home/xiaogao/下载/NR-IQA-CNN-master1/outputs/outputs_3.txt','wt');
fid2=fopen('/home/xiaogao/下载/NR-IQA-CNN-master1/outputs/scores_3.txt','wt');
for i=1:m
    fprintf(fid1,'%g',outputs(i,:));
    fprintf(fid1,'\n');
end
fclose(fid1);
for i=1:m
    fprintf(fid2,'%g',scores(i,:));
    fprintf(fid2,'\n');
end
fclose(fid2);