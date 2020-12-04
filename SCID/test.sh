#!/bin/bash

OUTPUT=outputs


   rm output_.txt
   rm scores_.txt
  
   ./build/tools/caffe test --weights=/media/s408/zz/gr/SCID/_iter_60000_8.44069.caffemodel --model=/media/s408/zz/gr/SCID/net/network_hog_noconcat.prototxt --iterations=289510 --gpu=all
   cp output_.txt $OUTPUT/output_1.txt
   cp scores_.txt $OUTPUT/scores_1.txt
chmod -R a+rw $OUTPUT
