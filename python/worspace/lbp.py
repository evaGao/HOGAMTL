# coding=utf-8
'''
Author: gaorui
email: 15735170462@163.com
Date: 2020-10-27 21:07:32
LastEditTime: 2020-11-01 19:41:11
Description: used for extract LBP features
'''
#注意：记得和HOG比较，看要不要归一化啥啥的
import numpy as np
from skimage.feature import local_binary_pattern
from skimage import io, color, img_as_ubyte

radius = 1;
n_point = radius * 8;

def texture_detect(image):
    #使用LBP方法提取图像的纹理特征.
    lbp=local_binary_pattern(image,8,1,'default');
    #概率*密度*函数的值，经过归一化，使范围内的*积分*为1
    #前面是[m,n),最后一个是[m,n]
    hist, _ = np.histogram(lbp, normed=True, bins=36)
    return hist
def main():
    img = io.imread('/Users/gloria/Downloads/picture/doraemon.jpeg')
    #转为灰度图
    gray = color.rgb2gray(img)
    image = img_as_ubyte(gray)#变成8位无符号整型
    hist = texture_detect(image)
    hist = [float(format(i, '.4f')) for i in hist]
    print(hist)
    
if __name__=="__main__":   
    main()
