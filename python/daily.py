#替换文件夹下图片的名字
import os
import shutil
import os.path
path='/home/xiaogao/下载/NR-IQA-CNN-master1/TID2013/distorted_images/'
copydir='/home/xiaogao/下载/NR-IQA-CNN-master1/TID2013/distorted_after/'
f=os.listdir(path)
n=0
for oldname in f:
    old=path+oldname
    new=copydir+'img'+str(5*24*(int(oldname[1:3])-1)+5*(int(oldname[4:6])-1)+int(oldname[-5]))+'.bmp'
    #print(old)
    shutil.copy(old,new)

#产生类似于live数据集下的info_all.txt文件
readPath='/home/xiaogao/下载/NR-IQA-CNN-master1/TID2013/mos_with_names.txt'
writePath='/home/xiaogao/下载/NR-IQA-CNN-master1/TID2013/info_all.txt'
i=1
with open(readPath, 'r') as fd:
    for line in fd:
        pos1=line.find(' ')+2
        pos2=line.find('_')
       # print(line[:pos])
        with open(writePath, 'a') as ff:
            ff.write('I'+line[pos1:pos2]+'.BMP'+' '+'img'+str(i)+'.bmp'+'\n')
        i=i+1

#删除文件中的NaN
readPath='/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/mappings/scores_val.txt'
writePath='/home/xiaogao/Downloads/screen_content/SCIQAD/distorted_after/mappings/test.txt'
num=0
img_list=[]
with open(readPath, 'r') as f:
    for line in f:
        content=line.strip()
        content=content.split(' ')
        label=[]
        for i in range(324):
            label.append(content[i+2])
        if "NaN" in label:
            img_list.append(content[0])
            num=num+1
            print(num)
            continue   #结束当前循环，进入下一个循环
        else:
            with open(writePath, 'a') as ff:
                        ff.write(line)
    print(num)

#只保留score
lnum=0
with open('/media/xiaogao/GLORIA/SCIQAD/outputs/scores.txt','a')as f1:
    with open('/media/xiaogao/GLORIA/SCIQAD/outputs/scores_1.txt','r')as f2:
        for line in f2:
            lnum+=1
            if lnum%2==0:
                f1.write(line)

#将NaN的图像块以‘0’的形式补充到预测质量分数文件中
readPath='/home/xiaogao/Downloads/screen_content/Lab_new/mappings/mappings_rgb_3/scores_val_1.txt'
writePath='/home/xiaogao/Downloads/screen_content/Lab_new/mappings/mappings_rgb_3/test1.txt'
num=0
row=[]
with open(readPath, 'r') as f:
    for line in f:
        content=line.strip() #删除字符串开头和结尾的字符
        content=content.split(' ')
        label=[]
        
        for i in range(36):
            label.append(content[i+2])
        if "NaN" in label:
            row.append(num)
        num=num+1
        continue   #结束当前循环，进入下一个循环
    print(row)
output=[]
with open('/media/xiaogao/GLORIA/SCIQAD/outputs/origin/output_insert.txt','a')as f1:
    with open('/media/xiaogao/GLORIA/SCIQAD/outputs/origin/output.txt','r')as f2:
        for line in f2:
            s=line.strip()
            output.append(s)
    for i in range(len(row)):
        output.insert(row[i],'0')
    for i in range(len(output)):
        f1.write(output[i]+'\n')
#将NaN的图像块的真实质量分数补充到真实质量分数文件中
readPath='/home/xiaogao/Downloads/screen_content/Lab_new/mappings/mappings_rgb_3/scores_val_1.txt'
num=0
row=[]
score=[]
with open(readPath, 'r') as f:
    for line in f:
        content=line.strip() #删除字符串开头和结尾的字符
        content=content.split(' ')
        label=[]
        
        for i in range(36):
            label.append(content[i+2])
        if "NaN" in label:
            row.append(num)
            score.append(content[1])
        num=num+1
        continue   #结束当前循环，进入下一个循环
    print(score)

output=[]
with open('/media/xiaogao/GLORIA/SCIQAD/outputs/origin/scores_insert.txt','a')as f1:
    with open('/media/xiaogao/GLORIA/SCIQAD/outputs/origin/scores.txt','r')as f2:
        for line in f2:
            s=line.strip()
            output.append(s)
    for i in range(len(row)):
        output.insert(row[i],score[i])
    for i in range(len(output)):
        f1.write(output[i]+'\n')

#去除每行的hog内容
with open('/media/xiaogao/GLORIA/SCIQAD/outputs/test_1.txt','a')as f1:
    with open('/home/xiaogao/Downloads/screen_content/Lab_new/mappings/mappings_rgb_3/test.txt','r')as f2:
        for line in f2:
            s=line.split(' ')
            s=s[0]+' '+s[1]+'\n'
            f1.write(s)

#将各个失真类型分开（7个失真类型，7个水平）
readPath='/media/xiaogao/GLORIA/SCIQAD/new_outputs/result/gtruth.txt'
result=[]
with open(readPath, 'r') as f:
    for line in f:
        x=line.strip()
        result.append(x)
for m in range(1,len(result)-47,49):
    n=m
    with open('/media/xiaogao/GLORIA/SCIQAD/new_outputs/result/GN_truth','a')as f1:
        for i in range(7):
                f1.write(result[n-1+i]+'\n')
    n=n+7
    with open('/media/xiaogao/GLORIA/SCIQAD/new_outputs/result/GB_truth','a')as f2:
        for i in range(7):        
                f2.write(result[n-1+i]+'\n')
    n=n+7
    with open('/media/xiaogao/GLORIA/SCIQAD/new_outputs/result/MB_truth','a')as f3:
        for i in range(7):
                f3.write(result[n-1+i]+'\n')
    n=n+7
    with open('/media/xiaogao/GLORIA/SCIQAD/new_outputs/result/CC_truth','a')as f4:
        for i in range(7):
                f4.write(result[n-1+i]+'\n')
    n=n+7
    with open('/media/xiaogao/GLORIA/SCIQAD/new_outputs/result/JC_truth','a')as f5:
        for i in range(7):
                f5.write(result[n-1+i]+'\n')
    n=n+7
    with open('/media/xiaogao/GLORIA/SCIQAD/new_outputs/result/J2C_truth','a')as f6:
        for i in range(7):
                f6.write(result[n-1+i]+'\n')
    n=n+7
    with open('/media/xiaogao/GLORIA/SCIQAD/new_outputs/result/LSC_truth','a')as f7:
        for i in range(7):
                f7.write(result[n-1+i]+'\n')

#找交叉数据集共同部分（主要是在测试集SCID下找到图像交叉共有失真类型下各失真图像的名字）
readPath='/media/xiaogao/GLORIA/SCID/name_norepetition.txt'
result=[]
with open(readPath, 'r') as f:
    for line in f:
        x=line.strip()
        result.append(x)
for m in range(1,len(result)-43,45):
    n=m
    with open('/media/xiaogao/GLORIA/SCID/cross/GN','a')as f1:
        for i in range(5):
                f1.write(result[n-1+i][:result[n-1+i].find('.')]+'\n')
    n=n+5
    with open('/media/xiaogao/GLORIA/SCID/cross/GB','a')as f2:
        for i in range(5):        
                f2.write(result[n-1+i][:result[n-1+i].find('.')]+'\n')
    n=n+5
    with open('/media/xiaogao/GLORIA/SCID/cross/MB','a')as f3:
        for i in range(5):
                f3.write(result[n-1+i][:result[n-1+i].find('.')]+'\n')
    n=n+5
    with open('/media/xiaogao/GLORIA/SCID/cross/CC','a')as f4:
        for i in range(5):
                f4.write(result[n-1+i][:result[n-1+i].find('.')]+'\n')
    n=n+5
    with open('/media/xiaogao/GLORIA/SCID/cross/JC','a')as f5:
        for i in range(5):
                f5.write(result[n-1+i][:result[n-1+i].find('.')]+'\n')
    n=n+5
    with open('/media/xiaogao/GLORIA/SCID/cross/J2C','a')as f6:
        for i in range(5):
                f6.write(result[n-1+i][:result[n-1+i].find('.')]+'\n')

#从测试图像块中取出特定失真类型的图像块（目的是在SCID测试集中找到各个测试图像子块以及其对应的质量分数和hog特征值）
readPath1='/home/xiaogao/Downloads/screen_content/SCID/mappings/test.txt'
readPath2='/media/xiaogao/GLORIA/SCID/cross/GN'
writePath='/home/xiaogao/Downloads/screen_content/SCID/mappings/test_GN'
with open(readPath2,'r') as f1:
    for line in f1:
        x=line.strip()
        with open(readPath1,'r')as f2:
            for line2 in f2:
                pos=line2.find('/')
                if(line2[:pos]==x):
                    with open(writePath,'a')as f3:
                        f3.write(line2)
