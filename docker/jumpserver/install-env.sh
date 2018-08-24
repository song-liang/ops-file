#!/bin/bash
## WebSocket Server，jumpserver，luna代码下载，python环境镜像

yum install -y vim wget git unzip
##  拉取相应代码
## WebSocket Server: Coco
#git clone https://github.com/jumpserver/coco.git && cd coco && git checkout master
wget https://codeload.github.com/jumpserver/coco/zip/master -O coco.zip
unzip coco.zip && mv `unzip -l coco.zip | awk '{if(NR == 5){ print $4}}'` coco  

## jumpserver
#git clone https://github.com/jumpserver/jumpserver.git && cd jumpserver && git checkout master
wget https://codeload.github.com/jumpserver/jumpserver/zip/master -O jumpserver.zip
unzip jumpserver.zip && mv `unzip -l jumpserver.zip | awk '{if(NR == 5){ print $4}}'` jumpserver

wget https://codeload.github.com/jumpserver/luna/zip/1.4.0 -O luna-1.4.0.zip
unzip luna-1.4.0.zip && mv `unzip -l luna-1.4.0.zip | awk '{if(NR == 5){ print $4}}'` luna

mkdir temp && mv *.zip temp

## 构建python环境镜像
docker build -t jumpserver-env .