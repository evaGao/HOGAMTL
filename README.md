# HOGAMTL
This is a HOG aided multi-task learning model for screen content image quality assessment, shorten as HOGAMTL.
## 环境配置
UBUNTU16.04 + MATLAB2016 + caffe</br>
</br>
安装caffe可参考：[Ubuntu16.04 Caffe 安装步骤记录（超详尽）](https://blog.csdn.net/yhaolpz/article/details/71375762)
## 训练测试数据
SIQAD[<sup>1</sup>](#SIQAD) + SCID[<sup>2</sup>](#SCID)</br>
</br>
百度云链接：https://pan.baidu.com/s/1Tg20HH9V_ddodn1g6_pGsQ
密码：v7bd
## 运行步骤
### 预处理数据
### 提取图像块的HOG特征并保存
1. 对图像进行分块，分为32\*32\*3的图像子块，并提取每个子块的HOG特征。</br>
__运行代码__：Lab_new/hog_rgb_3.m</br>
_代码输入_：失真图像路径</br>
_输出结果_：HOG元组</br>
2. 将HOG元组写入文本文件hog.txt中
__运行代码__：Lab_new/write_in.m</br>
_代码输入_：输出文件路径、HOG元组</br>
_输出结果_：hog.txt（内容为多行数字，每行为图像块的36维HOG特征）</br>
#### 制作训练所需要的数据格式（lmdb数据，包含图像和对应的标签【质量分数标签和HOG标签】）
1. 对比度归一化图像并分块
__运行代码__: 
直接运行代码Lab_new/patches.m，将失真图像分为若干个大小为32\*32\*3的图像子块。代码中输入为失真图像路径，输出路径自行拟定。</br>
>注：输出路径的修改位于代码中第16行。默认在失真图像所在路径下新建一个patches文件夹，并将输出图像块存储在此文件夹中。
#### 

### 获取训练需要的数据格式
### 多任务网络模型训练
### 图像质量预测评估
### 实验验证
## 参考
<div id="SIQAD"></div>
[1] Yang H, Fang Y, Lin W. Perceptual quality assessment of screen content images[J]. IEEE Transactions on Image Processing, 2015, 24 (11): 4408–4421.
<div id="SCID"></div>
[2] Wang S, Gu K, Zhang X, et al. Subjective and objective quality assessment of compressed screen content images[J]. IEEE Journal of Emerging and Selected Topics in Circuits and Systems, 2016, 6 (4): 532–543.


