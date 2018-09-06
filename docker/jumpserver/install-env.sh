#!/bin/bash
## WebSocket Server，jumpserver，luna代码下载，python环境镜像构建
## songliang 2018.8.27
## 环境Centos7,python3.6.6
## 
set -ex
## 关闭selinux
if [ $(getenforce) == "Enforcing" ];then
    setenforce 0
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
fi
if ! rpm -qa|grep -q docker;then echo "docker is not install"&& exit;fi
yum install -y vim wget git unzip
##  拉取相应代码
## jumpserver
#git clone https://github.com/jumpserver/jumpserver.git && cd jumpserver && git checkout master
if [ -e jumpserver ];then echo "jumpserver目录已存在"
else
    wget https://codeload.github.com/jumpserver/jumpserver/zip/master -O jumpserver.zip
    unzip jumpserver.zip
    mv `unzip -l jumpserver.zip | awk '{if(NR == 5){ print $4}}'` jumpserver
    cp jumpserver/config_example.py jumpserver/config.py
fi

## WebSocket Server: Coco
#git clone https://github.com/jumpserver/coco.git && cd coco && git checkout master
if [ -e coco ];then echo "coco 目录已存在"
else
    wget https://codeload.github.com/jumpserver/coco/zip/master -O coco.zip
    unzip coco.zip
    mv `unzip -l coco.zip | awk '{if(NR == 5){ print $4}}'` coco
    cp coco/conf_example.py coco/conf.py
fi

## jumpserver-luna
if [ -e luna ]; then echo "luna目录已存在"
else
    wget https://github.com/jumpserver/luna/releases/download/1.4.0/luna.tar.gz
    tar xvf luna.tar.gz
    chown -R root:root luna
fi

## 镜像环境构建需求文件
mkdir -p requirements \
&& /usr/bin/cp -rf jumpserver/requirements/requirements.txt requirements/jumpserver_requirements.txt \
&& /usr/bin/cp -rf coco/requirements/requirements.txt requirements/coco_requirements.txt \
&& /usr/bin/cp -rf jumpserver/requirements/rpm_requirements.txt requirements/rpm_requirements.txt
#&& sed -i "s/$/ $(cat coco/requirements/rpm_requirements.txt)/g" requirements/rpm_requirements.txt

## 构建python环境镜像
docker build -t jumpserver-env .
## 拉取guacamole镜像
docker pull jumpserver/guacamole:latest

mkdir -p temp && mv *.zip *.tar.gz -t temp

## 创建表结构，初始化数据库
#docker run --rm -v $PWD/jumpserver:/jumpserver --net="host" jumpserver-env sh -c "cd /jumpserver/utils/ && bash make_migrations.sh"

## 开启防火墙端口
#firewall-cmd --add-port=80/tcp --permanent
#firewall-cmd --add-port=8080-8081/tcp --permanent
#firewall-cmd --add-port=2222/tcp --permanent
#firewall-cmd --add-port=5000/tcp --permanent
#firewall-cmd --add-port=3306/tcp --permanent
#systemctl restart firewalld