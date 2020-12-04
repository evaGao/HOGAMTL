function  write_in(filename, source)
fid=fopen(filename,'a');
[height,width]=size(source);
for i=1:height
    for j=1:width
        [x,y]=size(source{i,j});
        for k=1:y-1
            fprintf(fid,'%f ',source{i,j}(k));
        end
        fprintf(fid,'%f\n',source{i,j}(y));
    end
end
fclose(fid);
end
    