#!/bin/bash
##
##基于CentOS6.7系统下修改而成，其他版本没有验证，对于有安装包下载失败，
##请在“##download address update”修改为新的下载链接
##
##宋亮亮 
##version:1.1
##2016.6.18
##
##mysql（5.1|5.6），http(2.2|2.4)，php(5.4|5.6|7.0)  nginx(1.80)

echo "It will install lamp or lnmp."
sleep 1

##check last command is OK or not.
check_ok () {
if [ $? != 0 ]
then
    	echo "Error, Check the error log."
    	exit 1
fi
}

##get the archive of the system,i686 or x86_64.
ar=`arch`
##close seliux
if [ $(getenforce) == "Enforcing" ]
then
    setenforce 0
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
fi
##close iptables
iptables-save > /etc/sysconfig/iptables_`date +%s`
iptables -F
service iptables save

##if the packge installed ,then omit.
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
for p in gcc wget vim  perl perl-devel libaio libaio-devel pcre-devel zlib-devel
do
    myum $p
done

##install epel.
if rpm -qa epel-release >/dev/null
then
    rpm -e epel-release
fi
if ls /etc/yum.repos.d/epel-6.repo* >/dev/null 2>&1
then
    rm -f /etc/yum.repos.d/epel-6.repo*
fi
wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/epel-7.repo

killall mysqld httpd nginx phpfp  >/dev/null 2>&1

##download address update
mysql_5_1=http://mirrors.sohu.com/mysql/MySQL-5.1/mysql-5.1.72-linux-$ar-glibc23.tar.gz
mysql_5_6=http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-$ar.tar.gz
httpd_2_2=http://mirrors.cnnic.cn/apache/httpd/httpd-2.2.31.tar.gz
httpd_2_4=http://mirrors.sohu.com/apache/httpd-2.4.29.tar.gz
apr=http://mirrors.cnnic.cn/apache/apr/apr-1.6.3.tar.gz
apr_util=http://mirrors.cnnic.cn/apache/apr/apr-util-1.6.1.tar.gz
php_5_4=http://cn2.php.net/distributions/php-5.4.45.tar.gz
php_5_6=http://cn2.php.net/distributions/php-5.6.33.tar.gz
php_7_0=http://cn2.php.net/distributions/php-7.0.5.tar.gz
nginx_1_12=http://nginx.org/download/nginx-1.12.0.tar.gz

##function of installing mysqld.
##mysql5.6之前版本编译配置函数
mysql_configure () {
            if ! grep '^mysql:' /etc/passwd
            then
                useradd -M mysql -s /sbin/nologin
                check_ok
            fi
            myum compat-libstdc++-33
            [ -d /data/mysql ] && /bin/mv /data/mysql /data/mysql_`date +%s`
            mkdir -p /data/mysql
            chown -R mysql:mysql /data/mysql
            cd /usr/local/mysql
            ./scripts/mysql_install_db --user=mysql --datadir=/data/mysql
            check_ok
            /bin/cp support-files/my-default.cnf /etc/my.cnf
            check_ok
            sed -i '/^\[mysqld\]$/a\datadir = /data/mysql' /etc/my.cnf
            /bin/cp support-files/mysql.server /etc/init.d/mysqld
            sed -i 's#^datadir=#datadir=/data/mysql#' /etc/init.d/mysqld
            chmod 755 /etc/init.d/mysqld
            chkconfig --add mysqld
            chkconfig mysqld on
            service mysqld start
            check_ok
			touch /etc/profile.d/path.sh
			echo '#!/bin/bash' > /etc/profile.d/path.sh
			echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile.d/path.sh
			source  /etc/profile.d/path.sh
}

install_mysqld() {
case $mysql_v in
        5.1)
            cd /usr/local/src
            [ -f ${mysql_5_1##*/} ] || wget $mysql_5_1
            tar zxvf ${mysql_5_1##*/}
            check_ok
            [ -d /usr/local/mysql ] && /bin/mv /usr/local/mysql /usr/local/mysql_`date +%s`
            mv `echo ${mysql_5_1##*/}|sed 's/.tar.gz//g'` /usr/local/mysql
            check_ok
			
            mysql_configure           
            ;;
        5.6)
            cd /usr/local/src
            [ -f  ${mysql_5_6##*/} ] || wget $mysql_5_6
            tar zxvf ${mysql_5_6##*/}
            check_ok
            [ -d /usr/local/mysql ] && /bin/mv /usr/local/mysql /usr/local/mysql_bak
            mv `echo ${mysql_5_6##*/}|sed 's/.tar.gz//g'` /usr/local/mysql
            
			mysql_configure      
            ;;
         *)
            echo "only 1(5.1) or 2(5.6)"
            ;;
esac
}

##function of install httpd.
##httpd编译配置函数
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

install_httpd() {
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
}

##function of install lamp's php.
##PHP编译配置函数
php_configure () {
            for p in openssl-devel bzip2-devel \
            libxml2-devel curl-devel libpng-devel \
            libjpeg-devel freetype-devel libmcrypt-devel\
            libtool-ltdl-devel perl-devel
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

install_php() { 
case $php_v in
        5.4)
            cd /usr/local/src/
            [ -f ${php_5_4##*/} ] || wget $php_5_4
            tar zxvf ${php_5_4##*/} && cd `echo ${php_5_4##*/}|sed 's/.tar.gz//g'`
			##编译函数
            php_configure           
            ;;
        5.6)
            cd /usr/local/src/
            [ -f ${php_5_6##*/} ] || wget $php_5_6
            tar zxvf ${php_5_6##*/} &&   cd `echo ${php_5_6##*/}|sed 's/.tar.gz//g'`            
			##编译函数
            php_configure            
            ;;
		7.0)
            cd /usr/local/src/
            [ -f ${php_7_0##*/} ] || wget $php_7_0
            tar zxvf ${php_7_0##*/} &&   cd `echo ${php_7_0##*/}|sed 's/.tar.gz//g'`            
			##编译函数
            php_configure
            ;;
         *)
            echo "only 1(5.4) or 2(5.6) or 3(7.0)"
            ;;
esac
}

##function of apache and php configue.
join_httpd_php() {
sed -i '/AddType .*.gz .tgz$/a\AddType application\/x-httpd-php .php' /usr/local/apache2/conf/httpd.conf
check_ok
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html index.htm/' /usr/local/apache2/conf/httpd.conf
check_ok

cat > /usr/local/apache2/htdocs/index.php <<EOF
<?php
   phpinfo();
?>
EOF

if /usr/local/php/bin/php -i |grep -iq 'date.timezone => no value'
then
    sed -i '/;date.timezone =$/a\date.timezone = "Asia\/Chongqing"'  /usr/local/php/etc/php.ini
fi

/usr/local/apache2/bin/apachectl restart
 check_ok
}

##function of check service is running or not, example nginx, httpd, php-fpm.
check_service() {
if [ "$1" == "mysqld" ]
then
    s="php-fpm"
else
    s=$1
fi
n=`ps aux |grep "$s"|wc -l`
if [ $n -gt 1 ]
then
    echo "$1 service is already started."
else
    if [ -f /etc/init.d/$1 ]
    then
        /etc/init.d/$1 start
        check_ok
    else
        install_$1
    fi
fi
}
check_php () {

 if [ -d /usr/local/php ] 
then
	echo "php installed."
else
    install_php
 fi
}

##function of install lamp
lamp() {
check_service mysqld
check_service httpd
check_php
join_httpd_php
echo "LAMP done Please use 'http://your ip/index.php' to access."
}

##function of install nginx
install_nginx() {
cd /usr/local/src
[ -f ${nginx_1_12##*/} ] || wget $nginx_1_12
tar zxvf ${nginx_1_12##*/}
cd `echo ${nginx_1_12##*/}|sed 's/.tar.gz//g'`
myum pcre-devel
./configure \
--prefix=/usr/local/nginx \
--with-http_realip_module \
--with-http_sub_module \
--with-http_gzip_static_module \
--with-http_stub_status_module  \
--with-pcre
check_ok
make && make install
check_ok
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

##function of install php-fpm
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
            --with-mysql-sock=/tmp/mysql.sock \
            --with-libxml-dir \
            --with-gd \
            --with-jpeg-dir \
            --with-png-dir \
            --with-freetype-dir \
            --with-iconv-dir \
            --with-zlib-dir \
            --with-mcrypt \
            --enable-soap \
            --enable-gd-native-ttf \
            --enable-ftp \
            --enable-mbstring \
            --enable-exif \
            --enable-zend-multibyte \
            --disable-ipv6 \
            --with-pear \
            --with-curl \
            --with-openssl
			check_ok
            make && make install
            check_ok
			
}

##php.ini配置函数
phpini_conf() {
		[ -f /usr/local/php-fpm/etc/php.ini ] || /bin/cp php.ini-production  /usr/local/php-fpm/etc/php.ini
            if /usr/local/php-fpm/bin/php -i |grep -iq 'date.timezone => no value'
            then
                sed -i '/;date.timezone =$/a\date.timezone = "Asia\/Chongqing"'  /usr/local/php-fpm/etc/php.ini
                check_ok
            fi
            [ -f /usr/local/php-fpm/etc/php-fpm.conf ] || curl http://www.apelearn.com/study_v2/.phpfpm_conf -o /usr/local/php-fpm/etc/php-fpm.conf
            [ -f /etc/init.d/phpfpm ] || /bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/phpfpm
            chmod 755 /etc/init.d/phpfpm
            chkconfig phpfpm on
            service phpfpm start
            check_ok
}

install_phpfpm() {
echo -e "Install php.\nPlease chose the version of php."
    case $php_v in
        5.4)
            cd /usr/local/src/
            [ -f ${php_5_4##*/} ] || wget $php_5_4
            tar zxvf ${php_5_4##*/} && cd `echo ${php_5_4##*/}|sed 's/.tar.gz//g'`
            
            ##编译函数
			phpfpm_configure
			##php.ini函数
			phpini_conf
            
            ;;
        5.6)
            cd /usr/local/src/
            [ -f ${php_5_6##*/} ] || wget $php_5_6

            tar zxvf ${php_5_6##*/} && cd `echo ${php_5_6##*/}|sed 's/.tar.gz//g'`
            
            ##编译函数
			phpfpm_configure
			##php.ini配置函数
            phpini_conf        
            ;;

		7.0)
            cd /usr/local/src/
            [ -f ${php_7_0##*/} ] || wget $php_7_0
            tar zxvf ${php_7_0##*/} &&   cd `echo ${php_7_0##*/}|sed 's/.tar.gz//g'`            
			##编译函数
            phpfpm_configure
			phpini_conf
            ;;	
        *)
            echo "only 1(5.4) or 2(5.6) 3(7.0)"
            ;;
    esac
}

##function of install lnmp
lnmp() {
check_service mysqld
check_service nginx
check_service phpfpm
echo "The lnmp done, Please use 'http://your ip/index.php' to access."
}

while :
do
  read -p "Please chose which type env you install, (lamp|lnmp)? " t
  if [ "$t" == "lamp" -o "$t" == "lnmp" ]
    then
    case $t in
      lamp)
	      while :
		  do
		  read -p "Please chose the version of mysql. (5.1|5.6)" mysql_v
			if [ "$mysql_v" == "5.1" -o "$mysql_v" == "5.6" ]
			then
			break
			else
				echo "only 1(5.1) or 2(5.6)"
			fi
		  done	
		  
		  while :
		  do
		  read -p "Please chose the version of httpd. (2.2|2.4)" httpd_v
			if [ "$httpd_v" == "2.2" -o "$httpd_v" == "2.4" ]
			then
			 break
			else
				echo "only 1(2.2) or 2(2.4)"
			fi
		  done	
          
		  while :
		  do
		  read -p "Please chose the version of php. (5.4|5.6|7.0)" php_v
			if [ "$php_v" == "5.4" -o "$php_v" == "5.6" -o "$php_v" == "7.0" ]
			then
			break
			else
				echo "only 1(5.4) or 2(5.6) or 3(7.0)"
			fi
		  done
          lamp
          ;;
      lnmp)
	      while :
		  do
		  read -p "Please chose the version of mysql. (5.1|5.6)" mysql_v
			if [ "$mysql_v" == "5.1" -o "$mysql_v" == "5.6" ]
			then
			break
			else
				echo "only 1(5.1) or 2(5.6)"
			fi
		  done		  
          
		  while :
		  do
		  read -p "Please chose the version of php. (5.4|5.6|7.0)" php_v
			if [ "$php_v" == "5.4" -o "$php_v" == "5.6" -o "$php_v" == "7.0" ]
			then
			break
			else
				echo "only 1(5.4) or 2(5.6) or 3(7.0)"
			fi
		  done		  
          lnmp
          ;;
        *)
          echo "Only 'lamp' or 'lnmp' your can input."
          ;;
    esac
   break
  else
		echo "Only 'lamp' or 'lnmp' your can input,please retry. "
  fi
done
