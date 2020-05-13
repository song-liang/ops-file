#!/bin/bash
##
##tengine一键安装，环境centos7.x x64,其他环境未验证
##
##SongLiang 2020.5.13
##
set 0

TENGINE_URL=http://tengine.taobao.org/download/tengine-2.3.2.tar.gz
BUILD_PATH=/usr/local/src/

check_ok () {
if [ $? != 0 ]
then
    echo "Error, Check the error log."
    exit 1
fi
}

# install dependencies
yum_package () {
	yum install -y epel-release gcc  gcc-c++ make pcre pcre-devel zlib zlib-devel openssl-devel libxslt-devel gd-devel GeoIP-devel
}
 
# clone nginx-module-vts
get_nginx_module_vts () {
	echo "克隆下载 nginx_module_vts 状态监控插件"
	cd ${BUILD_PATH}
	[ -d nginx-module-vts ] || git clone https://github.com/vozlt/nginx-module-vts.git
} 

# clone ngx_brotli
 get_ngx_brotli () {
	echo "克隆下载 ngx_brotli 压缩插件"
	cd ${BUILD_PATH}
	[ -d ngx_brotli ] || git clone https://github.com/google/ngx_brotli
	cd ngx_brotli && git submodule update --init
 }

# wget jemalloc
get_jemalloc () {
	echo "克隆下载 jemalloc 内存优化插件"
	cd ${BUILD_PATH}
	JEMALLOC_URL=https://github.com/jemalloc/jemalloc/releases/download/5.2.1/jemalloc-5.2.1.tar.bz2
	[ -f ${JEMALLOC_URL##*/} ] || wget ${JEMALLOC_URL}
	tar -jxvf ${TENGINE_URL##*/}
}

# wget tengine
get_tengine () {
	cd ${BUILD_PATH}
	[ -f ${TENGINE_URL##*/} ] || wget ${TENGINE_URL}
	tar zxvf ${TENGINE_URL##*/}
	cd `echo ${TENGINE_URL##*/}|sed 's/.tar.gz//g'`
}

##函数:编译安装与配置
nginx_configure_make () {
	./configure \
	--prefix=/usr/local/nginx \
	--user=www-data --group=www-data \
	--with-http_realip_module \
	--with-http_geoip_module \
	--with-http_sub_module \
	--with-http_xslt_module \
	--with-http_image_filter_module \
	--with-http_gzip_static_module \
	--with-http_stub_status_module \
	--with-http_auth_request_module \
	--with-http_ssl_module \
	--with-http_v2_module \
	--with-pcre \
	--with-stream \
	--with-stream_realip_module \
	--with-stream_geoip_module \
	--with-stream_ssl_module \
	--with-stream_ssl_preread_module \
	--with-jemalloc=../jemalloc-5.2.1 \
	--add-module=../nginx-module-vts \
	--add-module=../ngx_brotli
	check_ok
	make && make install
	check_ok
}

##配置启动文件
nginx_seting () {
	if [ -f /etc/init.d/nginx ]
	then
		/bin/mv /etc/init.d/nginx  /etc/init.d/nginx_`date +%s`
	fi
	if [ -f /usr/bin/nginx ]
	then
	    /bin/mv /usr/bin/nginx /usr/bin/nginx_`date +%s`
	fi
	if [ -f /lib/systemd/system/nginx.service ]
	then
		/bin/mv /lib/systemd/system/nginx.service  /lib/systemd/system/nginx.service_`date +%s`
	fi

# 配置systcem启动服务
cat > /lib/systemd/system/nginx.service <<"EOF"
[Unit]
Description=The nginx HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/usr/local/nginx/sbin/nginx -s reload
#ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

# 添加 brotil 压缩配置
sed -i '/#gzip/a\    # br压缩\n\    include brotli;' /usr/local/nginx/conf/nginx.conf
cat > /usr/local/nginx/conf/brotli <<"EOF"
    brotli on;					# 开启br压缩
    brotli_comp_level 6;		# 压缩等级 0 -11
    brotli_static on;			# 启用检查客户端是否支持br压缩
    brotli_types application/atom+xml
                application/javascript
                application/json
                application/rss+xml
                application/vnd.ms-fontobject
                application/x-font-opentype
                application/x-font-truetype
                application/x-font-ttf
                application/x-javascript
                application/xhtml+xml
                application/xml
                font/eot font/opentype font/otf font/ttf font/woff2 font/woff font/truetype
                image/svg+xml image/vnd.microsoft.icon image/x-icon image/x-win-bitmap
                image/jpeg image/gif image/png
                text/css text/javascript text/plain text/xml;
EOF

	sed -i '1,5s/#user/user/' /usr/local/nginx/conf/nginx.conf	
	sed -i '/include brotli;/a\    # nginx-vts\    vhost_traffic_status_zone;\n\    vhost_traffic_status_filter_by_host on;' /usr/local/nginx/conf/nginx.conf

	ln -s /usr/local/nginx/sbin/nginx /usr/bin
	systemctl enable nginx.service
 	systemctl start nginx.service
}


# begin install

cd ${BUILD_PATH}
yum_package
get_nginx_module_vts
get_ngx_brotli
get_jemalloc
get_tengine
nginx_configure_make
nginx_seting

