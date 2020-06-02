FROM centos:7

RUN  \
    mkdir -p ~/.pip && \
    echo "[global]" > ~/.pip/pip.conf && \
    echo "trusted-host=mirrors.aliyun.com" >> ~/.pip/pip.conf && \
    echo "index-url=http://mirrors.aliyun.com/pypi/simple/"  >> ~/.pip/pip.conf

RUN yum -y install epel-release && \
    yum -y install git python-pip libvirt-python libxml2-python python-websockify supervisor nginx gcc python-devel && \
    yum clean all && \
    pip install numpy==1.16.6

ADD ./ /srv/webvirtmgr/

# 安装 webvirtcloud
RUN cd /srv/webvirtmgr && rm -rf .git && \
    pip install -r requirements.txt


# ./manage.py collectstatic
# ./manage.py syncdb


EXPOSE 8000
EXPOSE 6080

WORKDIR /srv/webvirtmgr
