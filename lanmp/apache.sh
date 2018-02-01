#!/bin/bash
##
##httpd一键安装，环境centos6.8_x64
##
##Liang 2016.7.29
##
##httpd 2.2，2.4，下载失败请修改下载链接

httpd_2_2=http://mirrors.sohu.com/apache/httpd-2.2.31.tar.gz
httpd_2_4=http://mirrors.sohu.com/apache/httpd-2.4.25.tar.gz
apr=http://mirrors.cnnic.cn/apache/apr/apr-1.5.2.tar.gz
apr_util=http://mirrors.cnnic.cn/apache/apr/apr-util-1.5.4.tar.gz

##选择版本
while :
do
  read -p "Please chose the version of httpd. (2.2|2.4)" httpd_v
  if [ "$httpd_v" == "2.2" -o "$httpd_v" == "2.4" ]
  then
     break
  else
     echo "only (2.2) or (2.4)"
  fi
done

check_ok () {
if [ $? != 0 ]
then
    echo "Error, Check the error log."
    exit 1
fi
}

yum install -y libaio library cmake glibc gcc zlib-devel pcre pcre-devel apr apr-dever

#编译参数和配置
httpd_configure () {
	./configure \
	--prefix=/usr/local/apache2 \
	--with-included-apr \
	--enable-so \
	--enable-deflate=shared \
	--enable-expires=shared \
	--enable-rewrite=shared \
	--with-pcre
	check_ok
	make && make install
	check_ok
		
##开机启动httpd
	[ -f /etc/init.d/httpd ] && /bin/mv /etc/init.d/httpd /etc/init.d/httpd__`date +%s`
	cp /usr/local/apache2/bin/apachectl /etc/init.d/httpd
	sed -i '/\#!\/bin\/sh$/a\#chkconfig: 35 70 30' /etc/init.d/httpd
	check_ok
	sed -i '/\#chkconfig: 35 70 30$/a\#description: Apache' /etc/init.d/httpd
	check_ok
	sed -i '/\#ServerName www.example.com:80/a\ServerName localhost:80' /usr/local/apache2/conf/httpd.conf
	check_ok
	chkconfig --level 35 httpd on
	check_ok
	service httpd start
}

##安装选择的版本
case $httpd_v in
 2.2)
	cd /usr/local/src
	[ -f ${httpd_2_2##*/} ] || wget  $httpd_2_2
	tar zxvf  ${httpd_2_2##*/} && cd `echo ${httpd_2_2##*/}|sed 's/.tar.gz//g'`
	check_ok
			
	httpd_configure			
	;;
 2.4)
	cd /usr/local/src
	[ -f ${httpd_2_4##*/} ] || wget  $httpd_2_4
	[ -f ${apr##*/} ] || wget  $apr
	[ -f ${apr_util##*/} ] || wget  $apr_util
	tar zxvf ${httpd_2_4##*/}
	check_ok
	tar zxvf ${apr##*/} && cp -rf `echo ${apr##*/}|sed 's/.tar.gz//g'`  `echo ${httpd_2_4##*/}|sed 's/.tar.gz//g'`/srclib/apr
	check_ok
	tar zxvf ${apr_util##*/} && cp -rf `echo ${apr_util##*/}|sed 's/.tar.gz//g'`  `echo ${httpd_2_4##*/}|sed 's/.tar.gz//g'`/srclib/apr-util
	check_ok
	cd `echo ${httpd_2_4##*/}|sed 's/.tar.gz//g'`
	check_ok
			
	httpd_configure			
	;;
  *)
	echo "only 1(2.2) or 2(2.4)"
	;;
esac

#解析PHP
sed -i '/AddType .*.gz .tgz$/a\AddType application\/x-httpd-php .php' /usr/local/apache2/conf/httpd.conf
check_ok
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html index.htm/' /usr/local/apache2/conf/httpd.conf
check_ok