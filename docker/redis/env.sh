#!/bin/bash
## 消除redis启动时的三个警告

echo "net.core.somaxconn= 1024" >> /etc/sysctl.conf
echo "vm.overcommit_memory=1" >>  /etc/sysctl.conf

sysctl -p 

echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local