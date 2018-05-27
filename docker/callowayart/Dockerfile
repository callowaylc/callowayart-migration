FROM wordpress:4.8.2-php5.6-apache
ARG PORT=80
ENV WORKDIR /var/www/html

LABEL application=callowayart
EXPOSE ${PORT}

COPY ./build/wordpress ${WORKDIR}
COPY ./src/var /var
RUN chmod -R ugo+rw /var/www/html/wp-content
