# Host CVAT
 - $ export CVAT_HOST=10.20.193.27
 - $ docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
 
# Deploy nuctl models

```
# install nuctl
  $ wget https://github.com/nuclio/nuclio/releases/download/1.8.14/nuctl-1.8.14-linux-amd64
  $ sudo chmod +x nuctl-<version>-linux-amd64
  $ sudo ln -sf $(pwd)/nuctl-<version>-linux-amd64 /usr/local/bin/nuctl
  
# create nuctl project & deploy models
  $ nuctl create project cvat
  $ nuctl deploy --project-name cvat \
  --path serverless/openvino/dextr/nuclio \
  --volume `pwd`/serverless/common:/opt/nuclio/common \
  --platform local
  $ nuctl deploy --project-name cvat \
  --path serverless/openvino/omz/public/yolo-v3-tf/nuclio \
  --volume `pwd`/serverless/common:/opt/nuclio/common \
  --platform local

```
