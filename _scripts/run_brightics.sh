#!/bin/bash

### Run with CPU ###
docker run -d -p 3000:3000 --privileged=true -v brightics:/brightics-studio/userdata --name brightics brightics/studio:latest


### Run with GPUs ###

# gpus='"device=0,1,2,3,4,5,6,7"'
# docker run -d -p 3000:3000 --privileged=true --gpus=$gpus -v brightics:/brightics-studio/userdata --name brightics brightics/studio:latest

