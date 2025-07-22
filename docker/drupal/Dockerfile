FROM php:8.3-apache

# Install PHP extensions required by Drupal
RUN apt-get update && apt-get install -y \
    git unzip zip curl libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd opcache

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set DocumentRoot to /web folder
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/web|' /etc/apache2/sites-available/000-default.conf

# Install Composer globally
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ✅ Install Drush via Composer (official way)
RUN composer global require drush/drush \
 && ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

# Set working directory
WORKDIR /var/www/html

# Copy Drupal code and lock files
COPY composer.* ./
COPY web/ web/

# ✅ Run composer install here since extensions are available
RUN composer install --no-dev --prefer-dist --no-scripts

# Copy entrypoint
COPY docker/drupal/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
