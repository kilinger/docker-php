FROM index.xxxxx.com/library/php:5.6-apache

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.5
ENV CONFD_VERSION 0.10.0
ENV GOREMAN_VERSION 0.0.7

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && gpg --verify /usr/local/bin/gosu.asc \
  && rm /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && curl -o /usr/local/bin/confd -SL "https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-$(dpkg --print-architecture)" \
  && chmod +x /usr/local/bin/confd \
  && curl -SL "https://github.com/mattn/goreman/releases/download/v$GOREMAN_VERSION/goreman_linux_$(dpkg --print-architecture).tar.gz" | tar zxvf - -C /tmp/ \
  && cp /tmp/goreman_linux_$(dpkg --print-architecture)/goreman /usr/local/bin/ \
  && chmod +x /usr/local/bin/goreman && rm -rf /tmp/goreman_linux_$(dpkg --print-architecture)

# make the "en_US.UTF-8" locale so www will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

# Memory Limit and Time Zone
RUN echo "memory_limit=1024M" > $PHP_INI_DIR/conf.d/memory-limit.ini \
  && echo "date.timezone=${PHP_TIMEZONE:-UTC}" > $PHP_INI_DIR/conf.d/date_timezone.ini

RUN apt-get update \
  && apt-get install -y --no-install-recommends libmcrypt-dev libpq-dev libfreetype6-dev libjpeg62-turbo-dev libpng12-dev libbz2-dev php-pear git \
  && a2enmod rewrite \
  && docker-php-ext-install opcache iconv mcrypt pdo_pgsql pdo_mysql mbstring \
  && docker-php-ext-install zip bz2 \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd \
  && curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/2.2.7.tar.gz \
  && tar xfz /tmp/redis.tar.gz \
  && rm -r /tmp/redis.tar.gz \
  && mv phpredis-2.2.7 /usr/src/php/ext/redis \
  && docker-php-ext-install redis \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/* \
  && usermod -u 1000 www-data

# Environmental Variables
ENV COMPOSER_HOME /root/composer
ENV COMPOSER_VERSION master
ENV PATH $PATH:/root/.composer/vendor/bin

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && composer config -g repositories.packagist composer http://packagist.phpcomposer.com \
  && composer config -g github-oauth.github.com 4e5d4f9cc1285c960fad24fa20c917a44d394679 \ 
  && composer global require "fxp/composer-asset-plugin:~1.1.0" \
  && composer global require "codeception/codeception=2.0.*" \
  && composer global require "codeception/specify=*" \
  && composer global require "codeception/verify=*" 

# Display version information
RUN composer --version

RUN mkdir /docker-entrypoint-init.d
COPY docker-entrypoint.sh /

EXPOSE 5000

COPY apache2.conf /etc/apache2/apache2.conf
WORKDIR /app

VOLUME /app/web/uploadFiles

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["goreman", "start"]
