## 利用官方镜像添加mysql freetype mcrypt gd 模块

FROM php:5.6-fpm
MAINTAINER <song-liangliang@qq.com>
LABEL Description="php-fpm:5.6"

RUN  apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysql
