#!/bin/bash
##  yum 安装docker-ce  修改docker数据路径，添加阿里云镜像加速

wget -O /etc/yum.repos.d/docker-ce.repo  https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum install -y docker-ce

mkdir ~/.pip
cat > ~/.pip/pip.conf << EOF
[global]
trusted-host=mirrors.aliyun.com
index-url=http://mirrors.aliyun.com/pypi/simple/
EOF

yum -y install epel-release && yum install -y python-pip && pip install --upgrade pip
pip install docker-compose 

mkdir -p /home/docker && ln -s /home/docker /var/lib

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://nr630v1c.mirror.aliyuncs.com"]
}
EOF

systemctl enable docker
systemctl daemon-reload && sudo systemctl restart docker