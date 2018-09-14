## 利用官方镜像添加mysql freetype mcrypt gd 模块

FROM php:5.6-fpm
MAINTAINER <song-liangliang@qq.com>
LABEL Description="php-fpm:5.6"

## 字符集环境配置
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
    && docker-php-ext-install mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install gettext \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install sockets \
    && docker-php-ext-install ldap \
	&& apt-get clean



