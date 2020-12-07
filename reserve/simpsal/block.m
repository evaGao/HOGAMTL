%function patches=block(Im,name,filename,height,width)
filename='/home/xiaogao/Downloads/screen_content/';
name='lena';
Im=imread('/home/xiaogao/Downloads/screen_content/lena.jpg');
Im=rgb2gray(Im);
L = size(Im);
height=20;
width=20;
%�ص�
x=28/36;
h_val=height*(1-x);
w_val=width*(1-x);
max_row = (L(1)-height)/h_val+1;
max_col = (L(2)-width)/w_val+1;
%�ж��ܷ�����ֿ�
if max_row==fix(max_row)%�ж��Ƿ��ܹ����
    max_row=max_row;
else
    max_row=fix(max_row+1);
end
if max_col==fix(max_col)%�ж��Ƿ��ܹ����
    max_col=max_col;
else
    max_col=fix(max_col+1);
end
seg = cell(max_row,max_col);
for row = 1:max_row      
    for col = 1:max_col        
        if ((width+(col-1)*w_val)>L(2)&&((row-1)*h_val+height)<=L(1))%�ж����ұ߲�����Ĳ���
    seg(row,col)= {Im((row-1)*h_val+1:height+(row-1)*h_val,(col-1)*w_val+1:L(2),:)};
        elseif((height+(row-1)*h_val)>L(1)&&((col-1)*w_val+width)<=L(2))%�ж����±߲�����Ĳ���
    seg(row,col)= {Im((row-1)*h_val+1:L(1),(col-1)*w_val+1:width+(col-1)*w_val,:)}; 
        elseif((width+(col-1)*w_val)>L(2)&&((row-1)*h_val+height)>L(1))%�ж����һ��
    seg(row,col)={Im((row-1)*h_val+1:L(1),(col-1)*w_val+1:L(2),:)};       
        else
     seg(row,col)= {Im((row-1)*h_val+1:height+(row-1)*h_val,(col-1)*w_val+1:width+(col-1)*w_val,:)}; %���������  
        end
    end
end 
%  imshow(Im);
%  hold on
mkdir(filename,name);%������ͼƬ����ͬ���ļ���������ͼƬ
paths=[filename,name]; %��ȡָ���ļ���Ŀ¼
 %������ͼ
for i=1:max_row
    for j=1:max_col
        imwrite(seg{i,j},[paths,'\',strcat(int2str(i),'row',int2str(j),'col','.bmp')]);   %�ѵ�i֡��ͼƬдΪ'mi.bmp'
    end
end
patches=dir(paths);









