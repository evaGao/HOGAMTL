# coding=utf-8
'''
Author: gaorui
email: 15735170462@163.com
Date: 2020-10-27 11:54:42
LastEditTime: 2020-11-02 16:19:29
Description: used for extract GLCM texture features
'''
#注意：记得和HOG比较，看要不要归一化啥啥的
import os
import numpy as np
from skimage.feature import greycomatrix, greycoprops
from skimage import io, color, img_as_ubyte
# GLCM properties
#对比度
def contrast_feature(matrix_coocurrence):
   contrast = greycoprops(matrix_coocurrence, 'contrast')
   return contrast
#差异性
def dissimilarity_feature(matrix_coocurrence):
   dissimilarity = greycoprops(matrix_coocurrence, 'dissimilarity')
   return dissimilarity
#协同性
def homogeneity_feature(matrix_coocurrence):
   homogeneity = greycoprops(matrix_coocurrence, 'homogeneity')
   return homogeneity
#熵
def energy_feature(matrix_coocurrence):
   energy = greycoprops(matrix_coocurrence, 'energy')
   return energy
#相关性
def correlation_feature(matrix_coocurrence):
   correlation = greycoprops(matrix_coocurrence, 'correlation')
   return correlation
#角二阶矩
def asm_feature(matrix_coocurrence):
   asm = greycoprops(matrix_coocurrence, 'ASM')
   return asm

def glcm(image):
   #这一步类似于数据压缩，因为8位图像含有256个灰度级，这样会导致计算灰度共生矩阵是的计算量过大，因此将其进行压缩成16级，将灰度进行分区
   bins = np.array([0, 16, 32, 48, 64, 80, 96, 112, 128, 144, 160, 176, 192, 208, 224, 240, 255]) #16-bit
   #返回的是一个和image大小一样的矩阵，只是矩阵元素表示的是image中元素在bins中的区间位置，小于0为0,0-16为1，以此类推
   inds = np.digitize(image, bins)
   max_value = inds.max()+1
   #matrix_coocurrence[i,j,d,theta]返回的是一个四维矩阵，各维代表不同的意义
   matrix_coocurrence = greycomatrix(inds, #需要进行共生矩阵计算的numpy矩阵
                                    [1],#步长
                                    [0, np.pi/4, np.pi/2, 3*np.pi/4],#方向角度
                                    levels=max_value, #共生矩阵阶数
                                    normed=False, symmetric=False)
   return matrix_coocurrence

def main():
   path = '/Users/gloria/Downloads/picture/'
   files = os.listdir(path)
   filenames = []
   for file in files:
      if file.endwith('.bmp'):
         filenames.add(file)
   
   #读取图片
   img = io.imread('/Users/gloria/Downloads/picture/doraemon.jpeg')
   #转为灰度图
   gray = color.rgb2gray(img)
   image = img_as_ubyte(gray)#变成8位无符号整型
   matrix_coocurrence = glcm(image)
   cont = contrast_feature(matrix_coocurrence)
   diss = dissimilarity_feature(matrix_coocurrence)
   homo = homogeneity_feature(matrix_coocurrence)
   ener = energy_feature(matrix_coocurrence)
   corre = correlation_feature(matrix_coocurrence)
   asm = asm_feature(matrix_coocurrence)
   #concat起来
   res = np.concatenate((cont, diss, homo, ener, corre, asm), 1).squeeze(0)
   res = [float(format(i, '.4f')) for i in res]

if __name__ == "__main__":
   main()