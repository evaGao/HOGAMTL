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
一、提取图像块的HOG特征并保存</br>

1. 对图像进行分块，分为32\*32\*3的图像子块，并提取每个子块的HOG特征</br>
__运行代码__：Lab_new/hog_rgb_3.m</br>
代码输入：失真图像路径</br>
输出结果：HOG元组

2. 将HOG元组写入文本文件hog.txt中</br>
__运行代码__：Lab_new/write_in.m</br>
代码输入：输出文件路径、HOG元组</br>
输出结果：hog.txt（内容为多行数字，每行为图像块的36维HOG特征）

二、制作训练所需要的数据格式（lmdb数据，包含图像和对应的标签【质量分数标签和HOG标签】）</br>

1. 对比度归一化图像并分块</br>
__运行代码__：Lab_new/prepare_rgb_3.m</br>
代码输入：失真图像路径</br>
输出结果：归一化后的图像块

>Little Tips:
>+ 这里的输出路径需要自己指定，具体位于代码第22行。默认保存在失真图像路径下，文件夹名称为“rgb_3_test”，有需要自行修改即可。
>+ 以上代码写的比较繁琐。先对图像进行了分块然后提取了每块的HOG特征，然后对比度归一化了整幅图像，又进行了分块，得到若干对比度归一化图像块。前后相当于重复分块了两次，比较耗时。或许可以精简一下，先整体对图像分块，然后直接基于各个图像块提取其HOG特征，并进行对比度归一化操作。这样前后只需进行一次分块操作即可。至于这样操作是否会影响最终结果，未知，可以尝试一下。

2. 根据前面某步所得到的hog.txt文件来制作"img label"的训练测试集文件</br>
__运行代码__：Lab_new/train_val_scoreshog.m</br>
代码输入：参考图像路径、失真图像路径</br>
输出结果：训练和测试集的txt文件 score_train_1.txt和score_val_1.txt（文件每一行内容：训练/测试图像块路径 图像块质量分数 图像块HOG特征）

>Little Tips:
>+ 这里的输出路径需要自己指定，具体位于代码第17行。
>+ 这个代码操作稍有些复杂，包含了:数据分割（根据参考图像将失真图像块按8：2分为训练集和测试集）、将图像块与原整幅失真图像质量分数对应、将图像块路径和质量分数以及对应的HOG特征并列写入txt文件中。为了更方便理解其过程，可以先看一下该代码首行的__流程__注释。

3. 按行打乱步骤2所产生的训练集文件内容score_train_1.txt</br>
__运行命令__: 
'''python
shuf score_train_1.txt的路径 -o score_train_shuf.txt(打乱后的输出路径，具体名称可自行指定)
'''

>Little Tips:
>+ 上面的运行命令是Linux命令，直接在shell黑框下运行即可。
>+ 这里不需要打乱测试集，因为在测试的时候，我们要让图像块对应到原整幅图像上。打乱训练集即可。

4. 删除训练/测试集文件中存在NaN的行</br>
__运行代码__：python/daily.py(删除文件中的NaN)</br>
代码输入：打乱后的训练集/测试集文件路径</br>
输出结果：去除掉NaN的训练/测试集文件</br>

>Little Tips:
>+ NaN产生自HOG特征，有NaN的数据虽不多，但NaN的存在会影响网络训练，导致不收敛或训练中断，需要将其去除。

5. 制作训练集的lmdb数据和测试集的lmdb数据</br>
__运行代码__：python/generation.py</br>
代码输入：对比度归一化后的图像块路径、训练/测试txt文件路径</br>
输出结果：训练/测试lmdb数据集，可直接用于训练和测试

>Little Tips:
>+ 运行代码是python格式
>+ 制作lmdb的原因是caffe训练测试需要lmdb的数据格式，数据格式与所选取的框架有关。

### 获取训练需要的数据格式
### 多任务网络模型训练
### 图像质量预测评估
### 实验验证
## 参考
<div id="SIQAD"></div>
[1] Yang H, Fang Y, Lin W. Perceptual quality assessment of screen content images[J]. IEEE Transactions on Image Processing, 2015, 24 (11): 4408–4421.
<div id="SCID"></div>
[2] Wang S, Gu K, Zhang X, et al. Subjective and objective quality assessment of compressed screen content images[J]. IEEE Journal of Emerging and Selected Topics in Circuits and Systems, 2016, 6 (4): 532–543.


