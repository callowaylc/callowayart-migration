FROM wordpress:4.8.2-php5.6-apache
ARG PORT=80

LABEL application=callowayart
EXPOSE ${PORT}

COPY ./build/wordpress /var/www/html
COPY ./src/var /var
RUN chmod -R ugo+rw /var/www/html/wp-content
