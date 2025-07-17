# Use PHP 8.3 with Apache – required for Drupal 11
FROM php:8.3-apache

# Install PHP extensions and system dependencies required by Drupal
RUN apt-get update && apt-get install -y \
    git curl unzip zip libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mbstring xml pdo pdo_mysql zip opcache

# Enable Apache mod_rewrite for clean URLs
RUN a2enmod rewrite

# Set Apache DocumentRoot to /var/www/html/web
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/web|g' /etc/apache2/sites-available/000-default.conf

# Set working directory (matches Drupal Composer project root)
WORKDIR /var/www/html

# Copy Drupal source and Composer config into container
COPY ./web/ ./web/
COPY ./vendor/ ./vendor/
COPY ./composer.* ./

# Set secure file and folder permissions for Apache
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# Expose HTTP port
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
