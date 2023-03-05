#!/bin/bash

gpus='all'
#gpus='"device=6,7"'
cmd="jupyter lab --ip='*' --NotebookApp.token='' --NotebookApp.password=''" 

docker run -d --restart always --name jupyterlab --gpus $gpus -v /data:/data -v /code:/code -p 8890:8888 -p 6006:6006 --shm-size 16gb agits/jupyterlab:v0.0.1 $cmd


