FROM php:8.2-fpm

WORKDIR /var/www/html

# Install system dependencies (with retry + cleanup in same layer)
RUN apt-get update -o Acquire::Retries=3 && apt-get install -y \
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

# Install MySQL extensions first
RUN docker-php-ext-install pdo_mysql mysqli \
    && php -m | grep -i mysql

# Configure and install remaining PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        intl \
        zip \
        gd \
        opcache

RUN docker-php-ext-enable opcache

# Install Imagick with basic retry fallback
RUN pecl install imagick || pecl install imagick \
    && docker-php-ext-enable imagick

# Optional: set recommended PHP settings (can remove if not needed)
RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "upload_max_filesize=50M" > /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size=50M" >> /usr/local/etc/php/conf.d/uploads.ini