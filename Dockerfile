# Subimos a la ultimísima versión: PHP 8.4 con Apache
FROM php:8.4-apache

# 1. Instalamos extensiones del sistema y herramientas multimedia vitales para CA
RUN apt-get update && apt-get install -y \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    imagemagick \
    ffmpeg \
    ghostscript \
    && rm -rf /var/lib/apt/lists/*

# 2. Configuramos e instalamos extensiones de PHP (GD, Zip, MySQLi, etc.)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip mysqli pdo pdo_mysql opcache

# 3. Copiamos tu archivo ZIP
COPY providence.zip /tmp/providence.zip

# 4. Descomprimimos de forma dinámica en una carpeta temporal
RUN mkdir -p /tmp/ca_temp \
    && unzip /tmp/providence.zip -d /tmp/ca_temp \
    && if [ "$(ls -1 /tmp/ca_temp | wc -l)" -eq 1 ]; then \
         DIR=$(ls -d /tmp/ca_temp/*/); mv "$DIR"* /var/www/html/; \
       else \
         mv /tmp/ca_temp/* /var/www/html/; \
       fi \
    && rm -rf /tmp/ca_temp /tmp/providence.zip

# 5. Damos los permisos correctos a Apache (www-data)
RUN chown -R www-data:www-data /var/www/html

# 6. Activamos mod_rewrite de Apache (necesario para las URLs amigables)
RUN a2enmod rewrite