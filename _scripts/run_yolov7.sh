#!/bin/bash

gpus="all"

#cmd="python3 detect.py --weights yolov7.pt --conf 0.25 --img-size 640 --source inference/images/horses.jpg"


##### Single GPU Train #####
# train p5 models
cmd="python train.py --workers 8 --device 0 --batch-size 2 --data data/shapes.yaml --img 640 640 --cfg cfg/training/yolov7.yaml --weights '' --name yolov7 --hyp data/hyp.scratch.p5.yaml"

# train p6 models
#cmd="python train_aux.py --workers 8 --device 0 --batch-size 1 --data data/shapes.yaml --img 1280 1280 --cfg cfg/training/yolov7-w6.yaml --weights '' --name yolov7-w6 --hyp data/hyp.scratch.p6.yaml"

##### Multi-GPUs Train #####
# train p5 models
#cmd="python -m torch.distributed.launch --nproc_per_node 4 --master_port 9527 train.py --workers 8 --device 0,1,2,3 --sync-bn --batch-size 128 --data data/coco.yaml --img 640 640 --cfg cfg/training/yolov7.yaml --weights '' --name yolov7 --hyp data/hyp.scratch.p5.yaml"

# train p6 models
#cmd="python -m torch.distributed.launch --nproc_per_node 8 --master_port 9527 train_aux.py --workers 8 --device 0,1,2,3,4,5,6,7 --sync-bn --batch-size 128 --data data/coco.yaml --img 1280 1280 --cfg cfg/training/yolov7-w6.yaml --weights '' --name yolov7-w6 --hyp data/hyp.scratch.p6.yaml"

docker run -it --rm --name yolov7 --gpus $gpus -v $(pwd):/data -w /data/yolo/yolov7 --shm-size 8gb agits/yolo:v8_ultralytics $cmd
