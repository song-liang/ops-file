#!/bin/bash

ar=`arch`
dat=`date +%F-%H-%M`
mysql_5_1=http://mirrors.sohu.com/mysql/MySQL-5.1/mysql-5.1.72-linux-$ar-glibc23.tar.gz
mysql_5_6=http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.36-linux-glibc2.5-$ar.tar.gz
mysql_5_7=http://mirrors.sohu.com/mysql/MySQL-5.7/mysql-5.7.13-linux-glibc2.5-$ar.tar.gz

##选择版本
while :
do
read -p "Please chose the version of mysql. (5.1|5.6|5.7)" mysql_v
   if [ "$mysql_v" == "5.1" -o "$mysql_v" == "5.6" -o "$mysql_v" == "5.7" ]
   then
	break
   else
	echo "only 1(5.1) or 2(5.6) 3(5.7)"
   fi
done

check_ok () {
if [ $? != 0 ]
then
    echo "Error, Check the error log."
    exit 1
fi
}

myum() {
if ! rpm -qa|grep -q "^$1"
then
    yum install -y $1
    check_ok
else
    echo $1 already installed.
fi
}

## install some packges.
echo install some packges
for p in gcc wget vim perl perl-devel libaio libaio-devel pcre-devel zlib-devel autoconf
do
    myum $p
done

##5.6之前二进制配置函数
mysql_configure () {
    if ! grep '^mysql:' /etc/passwd
    then
        useradd -M mysql -s /sbin/nologin
        check_ok
    fi
    myum compat-libstdc++-33
    [ -d /data/mysql ] && /bin/mv /data/mysql /data/mysql_old_$dat
    mkdir -p /data/mysql
    chown -R mysql:mysql /data/mysql
    cd /usr/local/mysql
    ./scripts/mysql_install_db --user=mysql --datadir=/data/mysql
    check_ok
    /bin/cp support-files/my-default.cnf /etc/my.cnf
    check_ok
    sed -i '/^\[mysqld\]$/a\datadir = /data/mysql' /etc/my.cnf
    sed -i '/^\[mysqld\]$/a\basedir = /usr/local/mysql' /etc/my.cnf
    sed -i '/^\[mysqld\]$/a\character-set-server = utf8' /etc/my.cnf
    /bin/cp support-files/mysql.server /etc/init.d/mysqld
    sed -i 's#^datadir=#datadir=/data/mysql#' /etc/init.d/mysqld
    chmod 755 /etc/init.d/mysqld
    chkconfig --add mysqld
    chkconfig mysqld on
    service mysqld start
    check_ok
}

##5.7.6之后的配置
mysql_conf_new () {
    if ! grep '^mysql:' /etc/passwd
    then
        useradd -M mysql -s /sbin/nologin
        check_ok
    fi
    myum compat-libstdc++-33
    [ -d /data/mysql ] && /bin/mv /data/mysql /data/mysql_old_$dat
    mkdir -p /data/mysql
    chown -R mysql:mysql /data/mysql
    cd /usr/local/mysql
##初始化，--initialize-insecure为不生成初始密码，--initialize为生存初始密码
	./bin/mysqld  --initialize-insecure --user=mysql --datadir=/data/mysql
	check_ok
	./bin/mysql_ssl_rsa_setup --datadir=/data/mysql
	check_ok
	cp support-files/my-default.cnf  /etc/my.cnf
	sed -i '/\# log_bin/a\log_bin = mysql-bin' /etc/my.cnf
	sed -i '/\# datadir =/a\datadir = /data/mysql' /etc/my.cnf
	sed -i '/\# basedir =/a\basedir = /usr/local/mysql' /etc/my.cnf
	chkconfig --add mysqld
    chkconfig mysqld on
    service mysqld start
    check_ok
}

##按选的择版本安装
case $mysql_v in
    5.1)
       cd /usr/local/src
       [ -f ${mysql_5_1##*/} ] || wget $mysql_5_1
       tar zxvf ${mysql_5_1##*/}
       check_ok
       [ -d /usr/local/mysql ] && /bin/mv /usr/local/mysql /usr/local/mysql_old_$dat
       mv `echo ${mysql_5_1##*/}|sed 's/.tar.gz//g'` /usr/local/mysql
       check_ok

       mysql_configure
       ;;
    5.6)
       cd /usr/local/src
       [ -f  ${mysql_5_6##*/} ] || wget $mysql_5_6
       tar zxvf ${mysql_5_6##*/}
       check_ok
       [ -d /usr/local/mysql ] && /bin/mv /usr/local/mysql /usr/local/mysql_old_$dat
        mv `echo ${mysql_5_6##*/}|sed 's/.tar.gz//g'` /usr/local/mysql

	    mysql_configure
		;;
    5.7)
       cd /usr/local/src
       [ -f  ${mysql_5_7##*/} ] || wget $mysql_5_7
       tar zxvf ${mysql_5_7##*/}
       check_ok
       [ -d /usr/local/mysql ] && /bin/mv /usr/local/mysql /usr/local/mysql_old_$dat
       mv `echo ${mysql_5_7##*/}|sed 's/.tar.gz//g'` /usr/local/mysql

       mysql_conf_new
       ;;
     *)
       echo "only 1(5.1) or 2(5.6) or (5.7)"
       ;;
esac

echo MySQL$mysql_v installed complete,Please set  password

