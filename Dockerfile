FROM php:8.2-fpm

WORKDIR /var/www/html

# Force cache bust 
RUN echo "BUILD $(date)"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmagickwand-dev \
    libheif-dev \
    libde265-dev \
    libonig-dev \
    libxml2-dev \
    unzip \
    git \
    curl

# Install MySQL extensions FIRST and separately
RUN docker-php-ext-install pdo_mysql mysqli

# HARD FAIL if not installed
RUN php -m | grep -i mysql

# Install remaining extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        intl \
        zip \
        gd \
        opcache

RUN docker-php-ext-enable opcache

# Install Imagick AFTER deps
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*