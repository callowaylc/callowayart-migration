FROM wordpress:4.8.2-php5.6-apache
ARG PORT=80
ENV PORT=${PORT}

WORKDIR /var/www/html
LABEL application=callowayart
EXPOSE ${PORT}

COPY ./build/wordpress ${WORKDIR}
COPY ./src/var /var
COPY ./src/opt/callowayart/start.sh  /opt/callowayart/start.sh
