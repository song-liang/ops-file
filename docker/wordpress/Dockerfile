FROM wordpress:php7.3-apache

WORKDIR /var/www/html

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libldap2-dev \
        libxslt1-dev; \
	rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_mysql calendar pcntl gettext \
    shmop sockets sysvmsg sysvsem sysvshm \
    ldap xsl wddx


COPY php.ini "$PHP_INI_DIR/php.ini"
COPY apache2.conf "$APACHE_CONFDIR/apache2.conf"
COPY wp-config.php /var/www/html/wp-config.php
