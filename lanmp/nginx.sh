#!/bin/bash
##
##Ningx一键安装，环境centos6.8_x64,其他环境未验证
##
##SongLiang 2016.7.29
##
##Nginx 版本 1.6，1.8，1.9，下载失败，请修改下载链接

nginx_1_15=http://nginx.org/download/nginx-1.15.12.tar.gz
nginx_1_8=http://nginx.org/download/nginx-1.8.0.tar.gz
nginx_1_14=https://nginx.org/download/nginx-1.14.0.tar.gz


check_ok () {
if [ $? != 0 ]
then
    echo "Error, Check the error log."
    exit 1
fi
}

yum install -y libaio library cmake glibc gcc zlib-devel pcre pcre-devel \
	openssl openssl-devel libxslt-devel gd-devel GeoIP GeoIP-devel GeoIP-data

##函数:编译安装与配置
nginx_configure () {
	./configure \
	--prefix=/usr/local/nginx \
	--with-http_v2_module \
	--with-http_dav_module \
	--with-http_addition_module \
	--with-http_realip_module \
	--with-http_geoip_module \
	--with-http_xslt_module \
	--with-http_image_filter_module \
	--with-http_gzip_static_module \
	--with-http_gunzip_module \
	--with-http_sub_module \
	--with-http_stub_status_module  \
	--with-http_auth_request_module \
	--with-http_ssl_module \
	--with-pcre \
	--with-stream \
	--with-stream_realip_module \
	--with-stream_geoip_module \
	--with-stream_ssl_module \
	--with-stream_ssl_preread_module \
	--with-threads
	check_ok
	make && make install
	check_ok
##配置启动文件
	if [ -f /etc/init.d/nginx ]
	then
		/bin/mv /etc/init.d/nginx  /etc/init.d/nginx_`date +%s`
	fi
	curl http://www.apelearn.com/study_v2/.nginx_init  -o /etc/init.d/nginx
	check_ok
	chmod 755 /etc/init.d/nginx
	chkconfig --add nginx
	chkconfig nginx on
	curl http://www.apelearn.com/study_v2/.nginx_conf -o /usr/local/nginx/conf/nginx.conf
	check_ok
	service nginx start
	check_ok
	echo -e "<?php\n    phpinfo();\n?>" > /usr/local/nginx/html/index.php
	check_ok
}

##选择版本
while :
do
  read -p "Please chose the version of Nginx. (1.15|1.8|1.14)" nginx_v
  if [ "$nginx_x" == "1.15" -o "$nginx_v" == "1.8" -o "$nginx_v == 1.14" ]
  then
     break
  else
     echo "only (1.15) or (1.8) or (1.14)"
  fi
done

#选择版本安装
case $nginx_v in
 	1.15)
		cd /usr/local/src
		[ -f ${nginx_1_15##*/} ] || wget $nginx_1_15
		tar zxvf ${nginx_1_15##*/}
		cd `echo ${nginx_1_15##*/}|sed 's/.tar.gz//g'`

		nginx_configure
		;; 
  
	1.8)
		cd /usr/local/src
		[ -f ${nginx_1_8##*/} ] || wget $nginx_1_8
		tar zxvf ${nginx_1_8##*/}
		cd `echo ${nginx_1_8##*/}|sed 's/.tar.gz//g'`
		
		nginx_configure
		;;
	1.14)
		cd /usr/local/src
		[ -f ${nginx_1_14##*/} ] || wget $nginx_1_14
		tar zxvf ${nginx_1_14##*/}
		cd `echo ${nginx_1_14##*/}|sed 's/.tar.gz//g'`

		nginx_configure
		;;
	*)
		echo "only (1.15) or (1.8) or (1.14)"
		;;
esac
