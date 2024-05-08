# Use an official PHP runtime as a parent image
FROM php:8.2-cli

# Install mysqli extension
RUN docker-php-ext-install mysqli pcntl

# Install PHP Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Packages
RUN apt-get update && apt-get install -y git unzip

# Set the working directory in the container to /var/www/html
WORKDIR /var/www/html

# Install PHP dependencies
RUN composer require php-mqtt/client

# Copy the app into the container at /var/www/html and set executable permissions
COPY monitor_mesh.php /var/www/html
COPY entrypoint.sh /var/www/html
RUN chmod +x /var/www/html/monitor_mesh.php
RUN chmod +x /var/www/html/entrypoint.sh
RUN chown www-data:www-data /var/www/html/monitor_mesh.php

# Make port 80 available to the world outside this container
EXPOSE 80
USER www-data
# Run the entrypoint script when the container starts
CMD ["/var/www/html/entrypoint.sh"]