FROM php:8.2-fpm

WORKDIR /var/www/html

# Force cache bust
RUN echo "BUILD $(date)"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    cron \
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
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install MySQL extensions FIRST
RUN docker-php-ext-install \
    pdo_mysql \
    mysqli

# Verify MySQL extensions
RUN php -m | grep -i mysql

# Configure and install remaining extensions
RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install \
        intl \
        zip \
        gd \
        opcache

# Enable OPcache
RUN docker-php-ext-enable opcache

# Install Imagick
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Start PHP-FPM by default
CMD ["php-fpm"]