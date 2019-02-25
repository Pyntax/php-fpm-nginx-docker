FROM php:7.3-fpm

MAINTAINER "SahilSharmaMIT2013@gmail.com"

RUN apt update;
RUN apt install -y git unzip

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer