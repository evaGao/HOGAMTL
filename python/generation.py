# -*- coding: utf-8 -*-

import numpy as np
import os
import lmdb
from PIL import Image 
import numpy as np 
import sys
import caffe
####################pre-treatment############################
#txt with labels eg. (0001.jpg 2 5)
file_input=open('/home/xiaogao/Downloads/screen_content/SCID/mappings/train.txt','r')
img_list=[]
label_list=[]
num=1
for line in file_input:
    content=line.strip()
    content=content.split(' ')
    img_list.append(content[0])
    label=[]
    for i in range(37):
        label.append(float(content[i+1]))
    label_list.append(label)
    del content
    print(num)
    num=num+1
file_input.close() 

in_db=lmdb.open('/media/xiaogao/zz/gr/SCID/data/train/hog_img/',map_size=int(1e12))
with in_db.begin(write=True) as in_txn:
    for in_idx,in_ in enumerate(img_list):         
        im_file='/home/xiaogao/Downloads/screen_content/SCID/distorted_after/rgb_3/'+in_
        im=Image.open(im_file)
        im=np.array(im)
        im=im[:,:,::-1]
        im=im.transpose((2,0,1))
        im_dat=caffe.io.array_to_datum(im)
        in_txn.put('{:0>10d}'.format(in_idx),im_dat.SerializeToString())   
        print 'data train: {} [{}/{}]'.format(in_, in_idx+1, len(img_list))        
        del im_file, im, im_dat
in_db.close()
print 'train data(images) are done!'

in_db=lmdb.open('/media/xiaogao/zz/gr/SCID/data/train/hog_label/',map_size=int(1e12))
with in_db.begin(write=True) as in_txn:
    for in_idx,in_ in enumerate(img_list):
        target_label=np.zeros((37,1,1))
        for i in range(37):
            target_label[i,0,0]=label_list[in_idx][i]
        label_data=caffe.io.array_to_datum(target_label)
        in_txn.put('{:0>10d}'.format(in_idx),label_data.SerializeToString())
        print 'label train: {} [{}/{}]'.format(in_, in_idx+1, len(img_list))
        del target_label, label_data    
in_db.close()
print 'train labels are done!'
