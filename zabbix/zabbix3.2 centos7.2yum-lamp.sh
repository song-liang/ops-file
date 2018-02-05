#!/bin/bash
##
##zabbix3.2
##测试环境yum安装lamp:Centos7.2x64  httpd2.4  mariadb5.5  php5.4
##
##liang 2016.9.19

#zabbix_3_2=http://120.52.73.45/nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.2.0/zabbix-3.2.6.tar.gz
zabbix_3_2=zabbix-3.2.6.tar.gz

##check last command is OK or not.
check_ok () {
if [ $? != 0 ]
then
    	echo "Error, Check the error log."
    	exit 1
fi
}

##关闭seliux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
selinux_s=`getenforce`
if [ $selinux_s == "Enforcing" ]
then
    setenforce 0
fi

##添加用户和用户组
if ! grep '^zabbix:' /etc/passwd
    then
     groupadd zabbix
     useradd zabbix -s /sbin/nologin -M -g zabbix
     check_ok
fi

##yum安装lamp环境，和需要的库文件
yum install -y vim wget gcc epel-release make
yum install -y httpd
yum install -y mariadb mariadb-server mysql-devel
yum install -y php php-gd php-bcmath php-mysql php-mbstring php-xmlwriter php-xmlreader
yum install -y openldap openldap-devel OpenIPMI OpenIPMI-devel
yum install -y net-snmp net-snmp-devel curl-devel libxml2-devel

##启动httpd,mariadb
apachectl start
systemctl start mariadb
check_ok

##开机启动
systemctl enable mariadb
systemctl enable httpd

##解压后的目录
z_dir=`echo ${zabbix_3_2##*/}|sed 's/.tar.gz//g'`
##编译安装
cd /usr/local/src
[ -f ${zabbix_3_2##*/} ] || wget $zabbix_3_2
[ -d $z_dir ]||tar zxvf ${zabbix_3_2##*/} && cd $z_dir
check_ok

./configure \
--prefix=/usr/local/zabbix \
--enable-server \
--enable-agent \
--with-mysql \
--enable-ipv6 \
--with-net-snmp \
--with-libcurl \
--with-libxml2 \
--with-openipmi \
--with-ldap

check_ok

make install
check_ok

##添加开机启动脚本
cd /usr/local/src/$z_dir/misc/init.d/fedora/core/

cp zabbix_server /etc/init.d/zabbix_server
cp zabbix_agentd /etc/init.d/zabbix_agentd
check_ok
sed -i 's#BASEDIR=\/usr\/local#BASEDIR=\/usr\/local\/zabbix#' /etc/init.d/zabbix_server
check_ok
sed -i 's#BASEDIR=\/usr\/local#BASEDIR=\/usr\/local\/zabbix#' /etc/init.d/zabbix_agentd
check_ok

chkconfig zabbix_server on
chkconfig zabbix_agentd on

##mariadb密码为空，导入数据,授权登录，
mysql -uroot -e "create database zabbix character set utf8;"
check_ok
mysql -uroot -e "use zabbix;\n source /usr/local/src/$z_dir/database/mysql/schema.sql;"
check_ok
mysql -uroot -e "use zabbix;\n source /usr/local/src/$z_dir/database/mysql/images.sql;"
check_ok
mysql -uroot -e "use zabbix;\n source /usr/local/src/$z_dir/database/mysql/data.sql;"
check_ok
mysql -uroot -e "grant all on zabbix.* to 'zabbix'@'localhost' identified by 'zabbix';"
check_ok

##修改配置文件
sed -i '/# DBHost=localhost/a\DBHost=localhost' /usr/local/zabbix/etc/zabbix_server.conf
check_ok
sed -i '/# DBPassword=/a\DBPassword=zabbix' /usr/local/zabbix/etc/zabbix_server.conf
check_ok
sed -i '/# ListenIP=127.0.0.1/a\ListenIP=127.0.0.1' /usr/local/zabbix/etc/zabbix_server.conf
check_ok

#echo "/usr/local/mysql/lib" >> /etc/ld.so.conf
#ldconfig

##复制web文件
mkdir -p /var/www/html/zabbix
cp -r /usr/local/src/$z_dir/frontends/php/* /var/www/html/zabbix
check_ok
chown zabbix /var/www/html/zabbix

##启动
service zabbix_server start
check_ok
service zabbix_agentd start
check_ok
a=`netstat -lnp | grep zabbix_server |wc -l`
if a=0 
then 
  echo "######### zabbix_server not running ,check zabbix_server error.log #########"
fi


##配置php.ini
sed -i 's/post_max_size = 8M/post_max_size = 16M/' /etc/php.ini
check_ok
sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php.ini
check_ok
sed -i 's/max_input_time = 60/max_input_time = 300/' /etc/php.ini
check_ok
sed -i '/;date.timezone =/a\date.timezone = "Asia\/Chongqing"' /etc/php.ini
check_ok

apachectl restart
check_ok

iptables -I INPUT -p tcp --dport 80 -j ACCEPT
systemctl iptables save

echo "Now,Please access 'http://your ip/zabbix' to  Complete the installation"


