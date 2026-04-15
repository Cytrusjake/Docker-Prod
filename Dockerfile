FROM php:8.2-fpm

WORKDIR /var/www/html

# Install system dependencies (HEIC support added)
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

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        intl \
        pdo \
        pdo_mysql \
        mysqli \
        zip \
        gd \
        opcache

RUN docker-php-ext-enable opcache

# Install Imagick AFTER HEIC libs are present
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Verify MySQL extensions
RUN php -m | grep -i mysql

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*