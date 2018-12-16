FROM wordpress:4.8.2-php5.6-apache
ARG HOME=/var/www/html
ARG WORKDIR=/opt/callowayart
ARG PORT=80
ENV PORT=${PORT}
ENV WORKDIR=${WORKDIR}
ENV PATH=/opt/callowayart/vendor/bin:${PATH}

WORKDIR $WORKDIR
LABEL application=callowayart
EXPOSE ${PORT}

RUN true && \
    apt update && \
    apt install -y git zip unzip && \
    curl -Lso ${WORKDIR}/installer.php https://getcomposer.org/installer && \
    php ${WORKDIR}/installer.php && \
    a2enmod headers

COPY ./build/wordpress ${HOME}
COPY ./src/var /var
COPY ./src/opt/callowayart ${WORKDIR}

RUN true && \
    php composer.phar install

WORKDIR $HOME
