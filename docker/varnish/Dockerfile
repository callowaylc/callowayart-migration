FROM thiagofigueiro/varnish-alpine-docker:3.6 as base
ARG PORT=80
ENV PORT=${PORT}

COPY ./src/start.sh /start.sh
COPY ./src/etc/varnish /etc/varnish

EXPOSE ${PORT}
