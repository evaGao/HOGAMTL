#!/usr/bin/env python
import sys
caffe_root='/media/s408/zz/gr/NR-IQA-CNN-master1/'
sys.path.insert(0,caffe_root+'python')
import caffe
import numpy as np
import yaml
import cv2
import os.path as osp
class EqualLayer(caffe.Layer): 
    def setup(self, bottom, top): 
    	pass 
    def reshape(self, bottom, top): 
#    	top[0].reshape(*bottom[0].data.shape) 
        top[0].reshape(1) 
    def forward(self, bottom, top): 
    	top[0].data[...] = bottom[0].data[:] 
    def backward(self, top, propagate_down, bottom): 
    	bottom[...].data=top[0].data
        pass
