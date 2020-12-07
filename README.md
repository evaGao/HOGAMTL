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

## 前期提示
+ 为了便于理解，可先读paper文件夹下的论文，有英文版和中文版（毕业设计中的基于多任务CNN的无参考屏幕内容图像质量评价一章）
+ 为了方便理解算法流程，下面在算法叙述方面会有部分输出结果的名称为临时拟编，注意不要与代码实际的输出结果名称搞混
+ 实际运行matlab代码时
  * 注意其调用函数文件的齐全，且路径可寻，否则会报错
  * 若当前路径下缺失要调用的函数文件，则在 reserve 文件夹下搜索该函数文件

## 运行步骤
### 处理数据
一、提取图像块的HOG特征并保存</br>

1. 对图像进行分块，分为若干 32\*32\*3 的图像子块，并提取每个子块的HOG特征；</br>
__运行代码__：matlab/hog_rgb_3.m</br>
代码输入：失真图像路径</br>
输出结果：HOG元组</br>
![HOG提取](https://github.com/evaGao/HOGAMTL/blob/main/image/hog.png)</br>

2. 将HOG元组写入文本文件hog.txt中；</br>
__运行代码__：matlab/write_in.m</br>
代码输入：输出文件路径、HOG元组</br>
输出结果：hog.txt（内容为多行数字，每行为图像块的36维HOG特征）</br>

二、制作训练测试所需要的数据格式（lmdb数据，包含图像和对应的标签【质量分数标签和HOG标签】）</br>

1. 对比度归一化图像并分块；</br>
__运行代码__：matlab/prepare_rgb_3.m</br>
代码输入：失真图像路径</br>
输出结果：归一化后的图像块</br>
![归一化图像块](https://github.com/evaGao/HOGAMTL/blob/main/image/normalized.bmp)</br>

>Little Tips:
>+ 这里的输出路径需要自己指定，具体位于代码第22行。默认保存在失真图像路径下，文件夹名称为 “rgb_3_test”，有需要自行修改即可。
>+ 以上代码写的比较繁琐。先对图像进行了分块然后提取了每块的HOG特征，然后对比度归一化了整幅图像，又进行了分块，得到若干对比度归一化图像块。前后相当于重复分块了两次，比较耗时。或许可以精简一下，先整体对图像分块，然后直接基于各个图像块提取其HOG特征，并进行对比度归一化操作。这样前后只需进行一次分块操作即可。至于这样操作是否会影响最终结果，未知，可以尝试一下。

2. 根据前面某步所得到的hog.txt文件来制作 "img_patch_path label" 的训练集和测试集文件；</br>
__运行代码__：matlab/train_val_scoreshog.m</br>
代码输入：参考图像路径、失真图像路径</br>
输出结果：训练和测试集的txt文件 - score_train_1.txt 和 score_val_1.txt（文件每一行内容：训练/测试图像块路径 图像块质量分数 图像块HOG特征）

>Little Tips:
>+ 这里的输出路径需要自己指定，具体位于代码第17行。
>+ 这个代码操作稍有些复杂，包含了:数据分割（根据参考图像将失真图像块按8：2分为训练集和测试集）、将图像块与原整幅失真图像质量分数对应、将图像块路径和质量分数以及对应的HOG特征并列写入txt文件中。为了更方便理解其过程，可以先看一下该代码首行的 __流程__ 注释。

3. 按行打乱步骤2所产生的训练集文件内容 score_train_1.txt；</br>
__运行命令__: </br>
```python
shuf score_train_1.txt的路径 -o score_train_shuf.txt (打乱后的输出路径，具体名称可自行指定)
```

>Little Tips:
>+ 上面的运行命令是Linux命令，直接在shell黑框下运行即可。
>+ 这里不需要打乱测试集，因为在测试的时候，我们要让图像块对应到原整幅图像上。打乱训练集即可。

4. 删除训练/测试集文件中存在NaN的行；</br>
__运行代码__：python/daily.py(删除文件中的NaN)</br>
代码输入：打乱后的训练集/测试集文件路径</br>
输出结果：去除掉NaN的训练/测试集文件</br>

>Little Tips:
>+ NaN产生自HOG特征，有NaN的数据虽不多，但NaN的存在会影响网络训练，导致不收敛或训练中断，需要将其去除。

5. 制作训练集的lmdb数据和测试集的lmdb数据；</br>
__运行代码__：python/generation.py</br>
代码输入：对比度归一化后的图像块路径、训练/测试txt文件路径</br>
输出结果：训练/测试lmdb数据集，可直接用于训练和测试

>Little Tips:
>+ 运行代码是python格式
>+ 制作lmdb的原因是caffe训练测试需要lmdb的数据格式，数据格式与所选取的深度学习框架有关。

### 多任务网络模型训练
+ 网络架构文件：SIQAD/train8.protxt
+ 参数配置文件：SIQAD/solver_val8.protxt
+ 训练启动脚本：SIQAD/train1.sh
+ 测试启动脚本：SIQAD/test.sh</br>
![网络架构](https://github.com/evaGao/HOGAMTL/blob/main/image/architecture.png)</br>

>Little Tips:
>+ 要知道如何跑起来，了解一下caffe运行流程，且各文件里的路径需根据自身情况进行修改
>+ 在训练到测试切换时，记得更换网络架构文件中的输入数据路径，测试的batchsize=1
>+ 以上的路径为SIQAD数据库的训练路径，SCID的文件名与其一致，具体内容位于SCID文件夹下
>+ 可以调参，且可视化训练过程中loss值下降情况等，具体查看caffe使用规则
>+ 经过测试，最终得到两个输出文件，一个是output.txt（内容为网络预测输出的图像块hog特征和图像块质量分数值），另一个是scores.txt（内容为图像块的真实hog特征和真实质量分数值）

### 图像质量预测评估
1. 去除输出的hog结果，只保留预测分数；</br>
__运行代码__：python/daily.py(只保留score)</br>
代码输入：上一步测试后输出的output.txt 和 scores.txt</br>
输出结果：去除hog特征后的output.txt 和 scores.txt</br>

2. 考虑到之前删去了NaN的图像块，导致预测图像块的总数和原图的图像块总数不一致，因此需要补齐预测分数文件和真实分数文件；</br>
__运行代码__：python/daily.py(将NaN的图像块以'0'的形式补充到预测质量分数文件 output.txt 中和将NaN的图像块的真实质量分数补充到真实质量分数文件 scores.txt 中)</br>
输出结果：补齐后的output.txt和scores.txt

3. 根据权重策略预测整幅图像的质量分数；</br>
__运行代码__：matlab/VLSD_find_region.m</br>
输出结果：将图像块分数乘以权重后的质量分数文件 output_weight.txt 和 真实质量分数文件 scores.txt

>Little Tips:
>+ 在运行这段代码时，需要有包含测试图像块名字+分数的文本文件，以及只有测试图像块名字的文本文件，因此需要另外运行一个小脚本（daily.py(去除每行的HOG内容)）

### 计算PLCC和SROCC值
1. 将加权的图像块质量分数求和得到整幅图像预测质量分数；</br>
__运行代码__: matlab/compute_LCC_SROCC.m</br>
代码输入：output_weight.txt 和 scores.txt</br>
输出结果：图像块加权求和后的整幅失真图像预测质量分数 predict.txt 和真实质量分数 real.txt

2. 计算PLCC和SROCC等指标；</br>
__运行代码__：matlab/verify_performance.m</br>
代码输入：predict.txt 和 real.txt</br>
输出结果：SROCC值、KROCC值、PLCC值和RMSE值

### 实验验证
+ 绘制散点图；</br>
__运行代码__：matlab/assessment.m</br>
代码输入：predict.txt 和 real.txt</br>
输出结果：散点图结果</br>
![本文方法散点图](https://github.com/evaGao/HOGAMTL/blob/main/image/scatter.png)</br>

>Little Tips:
>像其它合理性验证，泛化能力验证，单个失真类型验证等代码自行编写，非常容易。这里只提供散点图绘制代码。

## 注意事项
关于算法使用HOG特征，目的是为了提取屏幕内容图像的梯度纹理特征。基于此，本算法还尝试了LBP特征和灰度共生矩阵特征，效果都不如HOG特征好。但这里还是把提取LBP特征和灰度共生矩阵GLCM特征代码提供一下吧，仅供参考
+ LBP特征提取：python/lbp.py
+ GLCM特征提取：python/glcm.py

## 参考
<div id="SIQAD"></div>
[1] Yang H, Fang Y, Lin W. Perceptual quality assessment of screen content images[J]. IEEE Transactions on Image Processing, 2015, 24 (11): 4408–4421.
<div id="SCID"></div>
[2] Wang S, Gu K, Zhang X, et al. Subjective and objective quality assessment of compressed screen content images[J]. IEEE Journal of Emerging and Selected Topics in Circuits and Systems, 2016, 6 (4): 532–543.
