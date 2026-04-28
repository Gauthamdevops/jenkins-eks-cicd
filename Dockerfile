FROM php:8.2-apache

RUN rm -rf /var/www/html/*

COPY app/ /var/www/html

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
