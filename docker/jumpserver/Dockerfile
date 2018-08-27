############################################################
# Dockerfile to build jumpserver-env  container images
# Based on centos 
############################################################

# Set the base image to python
FROM centos

# File Author / Maintainer
MAINTAINER song-liang <1107179995@qq.com>

# 修改时区,安装中文支持 配置显示中文
RUN rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && yum -y install kde-l10n-Chinese \
    && yum -y reinstall glibc-common && yum clean all \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8

# 设置环境变量
ENV LANG=zh_CN.utf8 \
    LC_ALL=zh_CN.utf8 \
    TERM=xterm

## 安装部分rpm依赖包
COPY requirements requirements
RUN yum -y install $(cat requirements/rpm_requirements.txt) \
    && yum -y install sqlite-devel gcc automake zlib-devel openssl-devel epel-release openldap-devel wget make xz \
	&& yum clean all

## 下载编译安装Python3.6,创建虚拟环境变量
RUN wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tar.xz \
    && tar xvf Python-3.6.6.tar.xz \
    && cd Python-3.6.6 \
    && ./configure && make && make install \
    && cd .. && rm -rf Python-3.6.6 Python-3.6.6.tar.xz \
    && python3 -m venv /opt/py3 \
    && source /opt/py3/bin/activate

## 安装python环境依赖包
RUN pip3 install --upgrade pip \
    && pip3 install -ihttps://pypi.douban.com/simple/ -r requirements/jumpserver_requirements.txt \
    && pip3 install -ihttps://pypi.douban.com/simple/ -r requirements/coco_requirements.txt \
    && rm -rf requirements \
    && rm -rf /root/.cache

WORKDIR /opt
