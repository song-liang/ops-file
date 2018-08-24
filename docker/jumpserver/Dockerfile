############################################################
# Dockerfile to build jumpserver-env  container images
# Based on centos 
############################################################

# Set the base image to python
FROM centos

# File Author / Maintainer
MAINTAINER song-liang <1107179995@qq.com>

## 设置中文字符集
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    export LC_ALL=zh_CN.UTF-8 && \
    echo 'LANG="zh_CN.UTF-8"' > /etc/locale.conf

## 安装部分rpm依赖包
RUN yum -y install sqlite-devel xz gcc automake zlib-devel openssl-devel epel-release openldap-devel wget make

## 下载编译安装Python3.6,创建虚拟环境变量
RUN wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tar.xz && \
    tar xvf Python-3.6.6.tar.xz && cd Python-3.6.6 && \
    ./configure && make && make install && \
    rm -rf Python-3.6.6 Python-3.6.6.tar.xz && \
    python3 -m venv /opt/py3 && source /opt/py3/bin/activate

## 安装rpm python环境依赖
COPY requirements requirements
RUN yum -y install $(cat requirements/rpm_requirements.txt)
RUN pip3 install --upgrade pip
RUN	pip3 install -ihttps://pypi.douban.com/simple/ -r requirements/jumpserver_requirements.txt
RUN	pip3 install -ihttps://pypi.douban.com/simple/ -r requirements/coco_requirements.txt && rm -rf requirements

