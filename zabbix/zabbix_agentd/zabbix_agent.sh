#!/bin/bash
set -e
###
if ! grep '^zabbix:' /etc/passwd
    then
     groupadd zabbix
     useradd zabbix -s /sbin/nologin -M -g zabbix
fi

yum install -y gcc

##解压，编译，安装
tar zxvf zabbix-3.2.10.tar.gz

cd zabbix-3.2.10

./configure \
--prefix=/usr/local/zabbix \
--enable-agent

make install


##复制启动脚本
cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/zabbix_agentd
##修改启动脚本中的程序路径
sed -i 's#BASEDIR=\/usr\/local#BASEDIR=\/usr\/local\/zabbix#' /etc/init.d/zabbix_agentd

chkconfig zabbix_agentd on


##复制自定义监控脚本
cp -r ../scripts  /usr/local/zabbix

##开启添加用户自定义键，
cat >> /usr/local/zabbix/etc/zabbix_agentd.conf << EOF
UnsafeUserParameters=1
UserParameter=disk.discovery[*],/usr/bin/python /usr/local/zabbix/scripts/disk_discovery.py
UserParameter=disk.status[*],/bin/bash /usr/local/zabbix/scripts/disk_status.sh $1 $2
EOF

