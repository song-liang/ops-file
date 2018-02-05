#!/bin/bash

##系统安装后的简单设置，

##关闭SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

##设置别名
cat >> /root/.bashrc <<EOF
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias l.='ls -d .* --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color'
EOF

##安装简单工具
yum install -y vim wget lrzsz psmisc systat

##安装阿里epel源
wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all
yum makecache
yum install -y epel-release

##设置本地时区
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime