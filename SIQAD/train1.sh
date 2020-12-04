#!/usr/bin/env sh


./build/tools/caffe train --solver=/media/s408/zz/gr/lab_new/net/solver_val8.prototxt --gpu=all 2>&1   | tee /media/s408/zz/gr/lab_new/log/sci_deep_hog.log

#--weights=/home/xiaogao/下载/NR-IQA-CNN-master1/train/model_iter_35000.caffemodel
#--weights=/home/xiaogao/下载/NR-IQA-CNN-master1/again/pair/models/_iter_3200.caffemodel
#--weights=/media/s408/zz/gr/screen_content/model/res/_iter_30000.caffemodel 
#--weights=/media/s408/zz/gr/HOG-SCI/model/_iter_130000.caffemodel
#--weights=/media/s408/zz/gr/lab_new/_iter_30000_8.65316.caffemodel
#--weights=/media/s408/zz/gr/lab_new/_iter_34000_7.85.caffemodel
