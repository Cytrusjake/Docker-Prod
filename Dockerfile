FROM php:8.2-fpm

# System deps
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmagickwand-dev \
    libonig-dev \
    unzip \
    git \
    curl

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        intl \
        pdo \
        pdo_mysql \
        mysqli \
        zip \
        gd

# Imagick
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Opcache
RUN docker-php-ext-install opcache

# IonCube (example, adjust version if needed)
RUN curl -fsSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    | tar xz \
    && mv ioncube/ioncube_loader_lin_8.2.so /usr/local/lib/php/extensions/no-debug-non-zts-*/ \
    && echo "zend_extension=ioncube_loader_lin_8.2.so" > /usr/local/etc/php/conf.d/00-ioncube.ini

# Clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/*