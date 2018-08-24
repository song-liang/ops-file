#!/bin/bash
## docker images构建镜像前的代码拉取初始化设置

yum install -y vim wget git
##  拉取相应代码
## WebSocket Server: Coco
git clone https://github.com/jumpserver/coco.git && cd coco && git checkout master
## jumpserver
git clone https://github.com/jumpserver/jumpserver.git && cd jumpserver && git checkout master

wget https://github.com/jumpserver/luna/releases/download/1.4.0/luna.tar.gz
tar xvf luna.tar.gz
chown -R root:root luna