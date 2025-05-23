# Base image
FROM php:8.2-apache

# Update package manager and install dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    mariadb-client \
    libicu-dev \
    libgd-dev \
    libonig-dev \
    libxml2-dev \
    bzip2

# Enable required PHP extensions
RUN docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli pdo_mysql zip intl bcmath gd

# Copy the custom Apache configuration file
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Enable mod_rewrite module
RUN a2enmod rewrite

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy source code
COPY . /var/www/html

# Copy .env.example to .env
RUN cp /var/www/html/.env.example /var/www/html/.env

# Copy startup script and make it executable
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port
EXPOSE 80

# Use startup script as entrypoint
ENTRYPOINT ["/usr/local/bin/start.sh"]
CMD ["/usr/local/bin/start.sh"]