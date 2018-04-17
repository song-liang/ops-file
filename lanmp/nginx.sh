#!/bin/bash
##
##Ningx一键安装，环境centos6.8_x64,其他环境未验证
##
##SongLiang 2016.7.29
##
##Nginx 版本 1.6，1.8，1.9，下载失败，请修改下载链接

nginx_1_6=http://nginx.org/download/nginx-1.6.0.tar.gz
nginx_1_8=http://nginx.org/download/nginx-1.8.0.tar.gz
nginx_1_12=http://nginx.org/download/nginx-1.12.2.tar.gz

check_ok () {
if [ $? != 0 ]
then
    echo "Error, Check the error log."
    exit 1
fi
}

yum install -y libaio library cmake glibc gcc zlib-devel pcre pcre-devel

##nginx 启动脚本
nginx_start_script () {
cat > /etc/init.d/nginx <<EOF
#!/bin/bash
# chkconfig: - 30 21
# description: http service.
# Source Function Library
. /etc/init.d/functions
# Nginx Settings

NGINX_SBIN="/usr/local/nginx/sbin/nginx"
NGINX_CONF="/usr/local/nginx/conf/nginx.conf"
NGINX_PID="/usr/local/nginx/logs/nginx.pid"
RETVAL=0
prog="Nginx"

start() {
        echo -n $"Starting $prog: "
        mkdir -p /dev/shm/nginx_temp
        daemon $NGINX_SBIN -c $NGINX_CONF
        RETVAL=$?
        echo
        return $RETVAL
}

stop() {
        echo -n $"Stopping $prog: "
        killproc -p $NGINX_PID $NGINX_SBIN -TERM
        rm -rf /dev/shm/nginx_temp
        RETVAL=$?
        echo
        return $RETVAL
}

reload(){
        echo -n $"Reloading $prog: "
        killproc -p $NGINX_PID $NGINX_SBIN -HUP
        RETVAL=$?
        echo
        return $RETVAL
}

restart(){
        stop
        start
}

configtest(){
    $NGINX_SBIN -c $NGINX_CONF -t
    return 0
}

case "$1" in
  start)
        start
        ;;
  stop)
        stop
        ;;
  reload)
        reload
        ;;
  restart)
        restart
        ;;
  configtest)
        configtest
        ;;
  *)
        echo $"Usage: $0 {start|stop|reload|restart|configtest}"
        RETVAL=1
esac

exit $RETVAL	
EOF

}

##nginx配置文件

nginx_conf () {
cat > /usr/local/nginx/conf/nginx.conf <<EOF
user nobody nobody;
worker_processes 2;
error_log /usr/local/nginx/logs/nginx_error.log crit;
pid /usr/local/nginx/logs/nginx.pid;
worker_rlimit_nofile 51200;

events
{
    use epoll;
    worker_connections 6000;
}

http
{
    include mime.types;
	server_tokens off; 
    default_type application/octet-stream;
    server_names_hash_bucket_size 3526;
    server_names_hash_max_size 4096;
    log_format combined_realip '$remote_addr $http_x_forwarded_for [$time_local]'
    '$host "$request_uri" $status'
    '"$http_referer" "$http_user_agent"';
    sendfile on;
    tcp_nopush on;
    keepalive_timeout 30;
    client_header_timeout 3m;
    client_body_timeout 3m;
    send_timeout 3m;
    connection_pool_size 256;
    client_header_buffer_size 1k;
    large_client_header_buffers 8 4k;
    request_pool_size 4k;
    output_buffers 4 32k;
    postpone_output 1460;
    client_max_body_size 10m;
    client_body_buffer_size 256k;
    client_body_temp_path /usr/local/nginx/client_body_temp;
    proxy_temp_path /usr/local/nginx/proxy_temp;
    fastcgi_temp_path /usr/local/nginx/fastcgi_temp;
    fastcgi_intercept_errors on;
    tcp_nodelay on;
    gzip on;
    gzip_min_length 1k;
    gzip_buffers 4 8k;
    gzip_comp_level 5;
    gzip_http_version 1.1;
    gzip_types text/plain application/x-javascript text/css text/htm application/xml;
    include vhosts/*.conf;

}
EOF

mkdir -p /usr/local/nginx/conf/vhosts
cat > /usr/local/nginx/conf/vhosts/default.conf  <<EOF
server
{
    listen 80;
    server_name localhost;
    index index.html index.htm index.php;
    root /usr/local/nginx/html;

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/tmp/php-fcgi.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

}
EOF
}


##函数:编译安装与配置
nginx_configure () {
	./configure \
	--prefix=/usr/local/nginx \
	--with-http_realip_module \
	--with-http_sub_module \
	--with-http_gzip_static_module \
	--with-http_stub_status_module  \
	--with-pcre \
	--with-stream
	check_ok
	make && make install
	check_ok
##配置启动文件
	if [ -f /etc/init.d/nginx ]
	then
		/bin/mv /etc/init.d/nginx  /etc/init.d/nginx_`date +%s`
	fi
    nginx_start_script
	#curl http://www.apelearn.com/study_v2/.nginx_init  -o /etc/init.d/nginx
	check_ok
	chmod 755 /etc/init.d/nginx
	chkconfig --add nginx
	chkconfig nginx on
	#curl http://www.apelearn.com/study_v2/.nginx_conf -o /usr/local/nginx/conf/nginx.conf
	nginx_conf
	check_ok
	service nginx start
	check_ok
	echo -e "<?php\n    phpinfo();\n?>" > /usr/local/nginx/html/index.php
	check_ok
}

##选择版本
while :
do
  read -p "Please chose the version of Nginx. (1.6|1.8|1.12)" nginx_v
  if [ "$nginx_x" == "1.6" -o "$nginx_v" == "1.8" -o "$nginx_v == 1.12" ]
  then
     break
  else
     echo "only (1.6) or (1.8) or (1.12)"
  fi
done

#选择版本安装
case $nginx_v in
 	1.6)
		cd /usr/local/src
		[ -f ${nginx_1_6##*/} ] || wget $nginx_1_6
		tar zxvf ${nginx_1_6##*/}
		cd `echo ${nginx_1_6##*/}|sed 's/.tar.gz//g'`

		nginx_configure
		;; 
  
	1.8)
		cd /usr/local/src
		[ -f ${nginx_1_8##*/} ] || wget $nginx_1_8
		tar zxvf ${nginx_1_8##*/}
		cd `echo ${nginx_1_8##*/}|sed 's/.tar.gz//g'`
		
		nginx_configure
		;;
	1.12)
		cd /usr/local/src
		[ -f ${nginx_1_12##*/} ] || wget $nginx_1_12
		tar zxvf ${nginx_1_12##*/}
		cd `echo ${nginx_1_12##*/}|sed 's/.tar.gz//g'`

		nginx_configure
		;;
	*)
		echo "only (1.6) or (1.8) or (1.12)"
		;;
esac
