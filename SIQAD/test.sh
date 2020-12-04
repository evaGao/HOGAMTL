#!/bin/bash

OUTPUT=outputs


   rm output_.txt
   rm scores_.txt
  
   ./build/tools/caffe test --weights=/media/s408/zz/gr/lab_new/_iter_4000_8.29029.caffemodel --model=/media/s408/zz/gr/lab_new/net/train8.prototxt --iterations=99402 --gpu=all
   cp output_.txt $OUTPUT/output_1.txt
   cp scores_.txt $OUTPUT/scores_1.txt
chmod -R a+rw $OUTPUT
