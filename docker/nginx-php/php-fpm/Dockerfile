## 利用官方镜像添加mysql freetype mcrypt gd 模块

FROM php:5.6-fpm
MAINTAINER <song-liangliang@qq.com>
LABEL Description="php-fpm:5.6"

## 字符集环境配置
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
 echo deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib > /etc/apt/sources.list && \
 echo deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib >> /etc/apt/sources.list && \
 echo deb http://mirrors.aliyun.com/debian-security stretch/updates main >> /etc/apt/sources.list && \
 echo deb-src http://mirrors.aliyun.com/debian-security stretch/updates main >>/etc/apt/sources.list && \
 echo deb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib >>/etc/apt/sources.list && \
 echo deb-src http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib >>/etc/apt/sources.list && \
 echo deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib >>/etc/apt/sources.list  && \
 echo deb-src http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib >>/etc/apt/sources.list

RUN apt-get update && apt-get install -y locales \
        && sed -i -e 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen \
        && locale-gen \
        && update-locale LANG=zh_CN.UTF-8 \
        && apt-get clean
ENV LANG=zh_CN.UTF-8 \
        LANGUAGE=zh_CN.UTF-8 \
        LC_ALL=zh_CN.UTF-8
RUN groupmod -g 1100 www-data && usermod -u 1100 www-data
# 安装需要使用的一些模块
RUN apt-get update && apt-get install -y \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libmcrypt-dev \
      libpng-dev \
      libldap2-dev \
    && ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/ \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysql mysqli gettext bcmath sockets ldap zip pcntl \
    && apt-get clean




