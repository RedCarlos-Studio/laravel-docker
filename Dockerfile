# Use the official PHP 7.4 image with FPM
FROM php:8.1-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    default-mysql-client \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    netcat-openbsd \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql gd zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

# Copy Nginx configuration
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

# Copy VirtualHost configuration
COPY ./nginx/nummy.conf /etc/nginx/conf.d/nummy.conf

# Copy SSL certificates
COPY ./certs/ssl-cert-snakeoil.pem /etc/nginx/ssl/ssl-cert-snakeoil.pem
COPY ./certs/ssl-cert-snakeoil.key /etc/nginx/ssl/ssl-cert-snakeoil.key

# Copy php.ini configuration
COPY ./php-config/php.ini /usr/local/etc/php/php.ini

# Set working directory
WORKDIR /var/www

#COPY composer.json /var/www/

# Copy the rest of the application code
COPY . /var/www

RUN composer install --prefer-dist --no-dev --no-scripts --no-progress --no-interaction

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage

# Expose port
EXPOSE 443

# Start Nginx and PHP-FPM
CMD nginx -t && service nginx start && php-fpm
