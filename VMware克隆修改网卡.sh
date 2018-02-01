#!/bin/bash
##
##VMware中克隆后网卡mac更改，eth序号改变，为了使网卡号和正常安装时一样，
##需修改eth*和rules文件中的地址
##
## 2016.6.20

##请将网卡IP段和要分配的IP，网关填入下方
IPadd0=192.168.100.*
IPadd1=192.168.200.*
IP0=192.168.100.20
IP1=192.168.200.20
gateway=192.168.100.2

killall dhclient
dhclient
a=`ifconfig |egrep 'inet addr'|wc -l`
if [ $a != 3 ]
then
  echo 'check network card config'
  ifconfig
  exit 1
fi

##路径变量
ieth0=/etc/sysconfig/network-scripts/ifcfg-eth0
ieth1=/etc/sysconfig/network-scripts/ifcfg-eth1

rules=/etc/udev/rules.d/70-persistent-net.rules

cp $rules $rules`date +%T`

##过虑出eth*中新旧hwaddr值，和rules中的addr值
hw0_new=`ifconfig|grep -B1 $IPadd0|grep 'HWaddr'|awk '{print $5}'`
hw1_new=`ifconfig|grep -B1 $IPadd1|grep 'HWaddr'|awk '{print $5}'`

hw0_old=`cat $ieth0|grep HWADDR|sed 's/HWADDR=//'`
hw1_old=`cat $ieth1|grep HWADDR|sed 's/HWADDR=//'`

addr0=`grep eth0  $rules | awk '{print $4}'|awk -F '==' '{print $2}'|sed 's/"//g'|sed 's/,//g'`
addr1=`grep eth1  $rules | awk '{print $4}'|awk -F '==' '{print $2}'|sed 's/"//g'|sed 's/,//g'`


##替换rules中的addr值
sed -i 's/'$addr0'/'$hw0_new'/' $rules
sed -i 's/'$addr1'/'$hw1_new'/' $rules

##注释UUID
sed -i 's/UUID/#UUID/' $ieth0
sed -i 's/UUID/#UUID/' $ieth1

##替换eth*中的hwaddr值
sed -i 's/'$hw0_old'/'$hw0_new'/' $ieth0
sed -i 's/'$hw1_old'/'$hw1_new'/' $ieth1

##设置为所填IP 网关
ip0_old=`cat $ieth0|grep IPADDR|sed 's/IPADDR=//'`
ip1_old=`cat $ieth1|grep IPADDR|sed 's/IPADDR=//'`
gateway_old=`cat $ieth0|grep GATEWAY|sed 's/GATEWAY=//'`
sed -i 's/'$ip0_old'/'$IP0'/' $ieth0
sed -i 's/'$ip1_old'/'$IP1'/' $ieth1
sed -i 's/'$gateway_old'/'$gateway'/' $ieth0

service network restart