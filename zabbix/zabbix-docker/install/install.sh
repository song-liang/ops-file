#!/bin/bash


##创建本地数据库目录
mkdir /home/data/mysql

##创建mysql容器
cd  mysql-dcoker-compoes
docker-compose up -d
##创建数据库和用户
docker exec -it zabbix-mysql /usr/bin/mysql -uroot -pmysql -e  "create database zabbix character set utf8;"

docker exec -it zabbix-mysql /usr/bin/mysql -uroot -pmysql -e "grant all on zabbix.* to 'zabbix'@'%' identified by 'k*nuPkna0Ssvaxe1';"

##创建zabbix-web and server 容器
cd ../zabbix-server-and-web
docker-compose up -d

cd ../zabbix-agent
docker-compose up -d

docker ps