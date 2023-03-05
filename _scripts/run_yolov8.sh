#!/bin/bash

#gpus='"device=1,2,3,4"'
gpus='all'

#cmd='yolo predict model=yolov8n.pt source="https://ultralytics.com/images/bus.jpg" save=True'
# cmd='yolo detect train data=coco128.yaml model=yolov8n.pt epochs=100 imgsz=640 batch=2'
cmd='yolo detect train data=/code/yolo/data/shapes.yaml model=yolov8n.pt epochs=100 imgsz=640 batch=2'
#cmd='yolo segment train data=/code/yolo/data/shapes.yaml model=yolov8n-seg.pt epochs=300 imgsz=640 batch=2'

docker run -it --rm --name yolov8 -m 8g --shm-size 8gb --cpu-shares=8192 --ipc=host --gpus $gpus -v /data:/data -v $(pwd):/code -w /code/yolo/yolov8 ultralytics/ultralytics:latest $cmd
