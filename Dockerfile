FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmagickwand-dev \
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

# Enable opcache explicitly
RUN docker-php-ext-enable opcache

# Install Imagick
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install IonCube (robust path handling)
RUN curl -fsSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -o ioncube.tar.gz \
    && tar -xzf ioncube.tar.gz \
    && EXT_DIR=$(php -i | grep extension_dir | awk '{print $3}') \
    && ls -la ioncube \
    && test -f ioncube/ioncube_loader_lin_8.2.so \
    && cp ioncube/ioncube_loader_lin_8.2.so $EXT_DIR \
    && echo "zend_extension=ioncube_loader_lin_8.2.so" > /usr/local/etc/php/conf.d/00-ioncube.ini \
    && rm -rf ioncube ioncube.tar.gz

# Force build to fail if MySQL extensions are missing
RUN php -m | grep -i mysql


# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/*