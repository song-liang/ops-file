#!/bin/bash
##
##php一键安装，环境CentOS6.8_x64  php和php-fpm
##
##Liang 2016.7.29
##
##php版本5.4，5.6，7.0，下载失败，请修改下载链接

php_5_4=http://cn2.php.net/distributions/php-5.4.45.tar.gz
php_5_6=http://cn.php.net/distributions/php-5.6.37.tar.gz
php_7_0=http://cn2.php.net/distributions/php-7.3.3.tar.gz

##选择PHP OR php-fpm
while :
do
read -p "Please chose the  php(Apache) or php-fpm(Nginx)：( php|php-fpm )" php_
	if [ "$php_" == "php" -o "$php_" == "php-fpm" ]
	then
	    break
	else
		echo "only php(Apache) or php-fpm(Nginx)"
	fi
done		  
##选择PHP version
while :
do
read -p "Please chose the version of php： (5.4|5.6|7.0)" php_v
	if [ "$php_v" == "5.4" -o "$php_v" == "5.6" -o "$php_v" == "7.0" ]
	then
	    break
	else
		echo "only 1(5.4) or 2(5.6) or 3(7.0)"
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

for p in gcc wget vim  perl perl-devel libaio libaio-devel pcre-devel zlib-devel openldap openldap-devel 
do
    myum $p
done

ln -s /usr/lib64/libldap* /usr/lib/

##php编译配置
php_configure () {
    for p in openssl-devel bzip2-devel \
    libxml2-devel curl-devel libpng-devel \
    libjpeg-devel freetype-devel libmcrypt-devel\
    libtool-ltdl-devel perl-devel libzip-devel
    do
      myum $p
    done
    check_ok
		   
    ./configure \
    --prefix=/usr/local/php \
    --with-apxs2=/usr/local/apache2/bin/apxs \
    --with-config-file-path=/usr/local/php/etc  \
    --with-mysql=/usr/local/mysql \
    --with-libxml-dir \
    --with-gd \
    --with-jpeg-dir \
    --with-png-dir \
    --with-freetype-dir \
    --with-iconv-dir \
    --with-zlib-dir \
    --with-bz2 \
    --with-openssl \
    --with-mcrypt \
    --enable-soap \
    --enable-gd-native-ttf \
    --enable-mbstring \
    --enable-sockets \
    --enable-exif \
    --disable-ipv6
	check_ok
    make && make install
    check_ok
    [ -f /usr/local/php/etc/php.ini ] || /bin/cp php.ini-production  /usr/local/php/etc/php.ini
}

##phpfpm编译配置
phpfpm_configure () {
	for p in  openssl-devel bzip2-devel \
    libxml2-devel curl-devel libpng-devel \
    libjpeg-devel freetype-devel libmcrypt-devel\
    libtool-ltdl-devel perl-devel
    do
        myum $p
    done
			
	if ! grep -q '^php-fpm:' /etc/passwd
    then
        useradd -M -s /sbin/nologin php-fpm
        check_ok
    fi
    ./configure \
    --prefix=/usr/local/php-fpm \
    --with-config-file-path=/usr/local/php-fpm/etc \
    --enable-fpm \
    --with-fpm-user=php-fpm \
    --with-fpm-group=php-fpm \
    --with-mysql=/usr/local/mysql \
    --with-mysqli=/usr/local/mysql/bin/mysql_config \
    --with-pdo-mysql \
    --with-mysql-sock=/tmp/mysql.sock \
    --with-libxml-dir \
    --with-gd \
    --with-jpeg-dir \
    --with-png-dir \
    --with-freetype-dir \
    --with-iconv-dir \
    --with-zlib-dir \
    --with-mcrypt \
    --with-gettext \
    --with-ldap \
    --enable-pdo \
    --enable-pcntl \
    --enable-zip \
    --enable-shmop \
    --enable-bcmath \
    --enable-soap \
    --enable-gd-native-ttf \
    --enable-ftp \
    --enable-mbstring \
    --enable-exif \
	--enable-sockets \
    --disable-ipv6 \
    --with-pear \
    --with-curl \
    --with-openssl 
	check_ok
	sed -i 's|^EXTRA_LIBS =|& -llber |g' Makefile
    make && make install
    check_ok		
}

case $php_v in
  5.4)
     cd /usr/local/src/
     [ -f ${php_5_4##*/} ] || wget $php_5_4
     tar zxvf ${php_5_4##*/} && cd `echo ${php_5_4##*/}|sed 's/.tar.gz//g'`
	   
	 ##选择php or php-fpm
	 case $php_ in
		php)
		   php_configure
		   ;;
	    php-fpm)
		   phpfpm_configure
		   ;;
	 esac	 
     ;;
  5.6)
     cd /usr/local/src/
     [ -f ${php_5_6##*/} ] || wget $php_5_6
     tar zxvf ${php_5_6##*/} &&   cd `echo ${php_5_6##*/}|sed 's/.tar.gz//g'`            
	 ##选择php or php-fpm
	 case $php_ in
		php)
		   php_configure
		   ;;
	    php-fpm)
		   phpfpm_configure
		   ;;
	 esac	 
     ;;
  7.0)
     cd /usr/local/src/
     [ -f ${php_7_0##*/} ] || wget $php_7_0
     tar zxvf ${php_7_0##*/} &&   cd `echo ${php_7_0##*/}|sed 's/.tar.gz//g'`            
	 ##选择php or php-fpm
	 case $php_ in
		php)
		   php_configure
		   ;;
	    php-fpm)
		   phpfpm_configure
		   ;;
	 esac	 
     ;;
    *)
     echo "only 1(5.4) or 2(5.6) 3(7.0)"
     ;;
esac

##修改配置PHP
if [ "$php_" == "php" ]
then
  if /usr/local/php/bin/php -i |grep -iq 'date.timezone => no value'
  then
    sed -i '/;date.timezone =$/a\date.timezone = "Asia\/Chongqing"'  /usr/local/php/etc/php.ini
  fi
fi
#修改配置php-fpm
if [ "$php_" == "php-fpm" ]
then
    [ -f /usr/local/php-fpm/etc/php.ini ] || /bin/cp php.ini-production  /usr/local/php-fpm/etc/php.ini
     if /usr/local/php-fpm/bin/php -i |grep -iq 'date.timezone => no value'
     then
        sed -i '/;date.timezone =$/a\date.timezone = "Asia\/Chongqing"'  /usr/local/php-fpm/etc/php.ini
        check_ok
     fi
    [ -f /usr/local/php-fpm/etc/php-fpm.conf ] || curl http://www.apelearn.com/study_v2/.phpfpm_conf -o /usr/local/php-fpm/etc/php-fpm.conf
    [ -f /etc/init.d/php-fpm ] || /bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    chmod 755 /etc/init.d/php-fpm
    chkconfig php-fpm on
    service php-fpm start
    check_ok
fi
