#!/bin/bash

## yum 安装 apache php mysql epel源  centos6.8
## liang
## 2016.10.17

yum install -y epel-release

##yum安装lamp
yum install -y  httpd php php-mysql mariadb mariadb-server mysql-devel php-gd  libjpeg libjpeg-devel libpng libpng-devel

##安装cacti  net-snmp  rrdtool
yum install -y cacti  net-snmp  net-snmp-utils  rrdtool

yum install -y net-snmp

##编辑http配置文件
sed -i 's/Deny from all/Allow from all/' /etc/httpd/conf.d/cacti.conf
sed -i '/\#ServerName www.example.com:80/a\ServerName localhost:80' /etc/httpd/conf/httpd.conf
sed -i '/;date.timezone/a\date.timezone = Asia/Chongqing' /etc/php.ini

##启动服务
/etc/init.d/mysqld start;\
/etc/init.d/httpd  start;\
/etc/init.d/snmpd start
service  snmpd  start

#centos7
#systemctl enable mariadb
#systemctl enable httpd

##创建cacti数据库，导入数据
mysql -uroot  -e "create database cacti"
mysql -uroot -e "grant all on cacti.* to 'cacti'@'localhost' identified by 'cacti'"

mysql -uroot cacti < /usr/share/doc/cacti-*/cacti.sql

sed -i 's/cactiuser/cacti/g' /usr/share/cacti/include/config.php

##生成图形
/usr/bin/php /usr/share/cacti/poller.php

echo '*/5 * * * *  /usr/bin/php /usr/share/cacti/poller.php' >> /var/spool/cron/root

echo  'Access http://your-ip/cacti to Complete installation'

