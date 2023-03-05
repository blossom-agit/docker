#!/bin/bash

gpus="all"  # '"device=1,2,3,4"'

# Jupyter 
cmd="jupyter lab --ip='*' --NotebookApp.token='' --NotebookApp.password=''"

docker run -it --rm --name tao --gpus $gpus -v /data:/data -w /data/docker/tao -p 8901:8888 --shm-size 8gb --ipc=host nvcr.io/nvidia/tao/tao-toolkit:4.0.0-pyt

