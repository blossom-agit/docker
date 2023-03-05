#!/bin/bash

# Tensorboard
cmd="tensorboard --logdir=/data/experiments --bind_all"
docker run -d --restart always --name tensorboard -v /data:/data -p 6006:6006 --shm-size 8gb nvcr.io/nvidia/pytorch:21.08-py3 $cmd


