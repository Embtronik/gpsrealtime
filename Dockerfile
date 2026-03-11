# syntax=docker/dockerfile:1
# Imagen compatible con AMD64 (x86 server) y ARM64 (OrangePi, Raspberry Pi, Mac M1/M2)
FROM --platform=$BUILDPLATFORM php:8.2-apache

# ── Timezone (America/Bogota = UTC-5, sin DST) ───────────────────
ENV TZ=America/Bogota

# ── System dependencies ───────────────────────────────────────────
RUN apt-get update \
    && apt-get install -y libonig-dev tzdata unzip git \
    && ln -fs /usr/share/zoneinfo/America/Bogota /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# ── PHP extensions ────────────────────────────────────────────────
RUN docker-php-ext-install pdo_mysql mbstring opcache

# ── Apache: mod_rewrite ───────────────────────────────────────────
RUN a2enmod rewrite

# ── Custom configs ────────────────────────────────────────────────
COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker/php/php.ini             /usr/local/etc/php/conf.d/custom.ini

# ── Composer ──────────────────────────────────────────────────────
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Instalar dependencias PHP (sin composer.lock para regenerar en la arquitectura del servidor)
COPY composer.json ./
RUN composer install --no-dev --no-autoloader --no-interaction --ignore-platform-reqs

# ── Application source ────────────────────────────────────────────
COPY . .

# Generar autoloader optimizado una vez que el código fuente está disponible
RUN composer dump-autoload --optimize --no-dev --no-interaction

# ── Permissions ───────────────────────────────────────────────────
RUN mkdir -p logs \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/logs

EXPOSE 80
