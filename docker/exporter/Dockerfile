FROM golang:1.11-alpine

ARG WORKDIR=/opt/callowayart
ARG PORT=8888
WORKDIR ${WORKDIR}

RUN true && \
    apk update && \
    apk add git && \
    go get github.com/kotsis/wordpress_exporter

EXPOSE ${PORT}
CMD wordpress_exporter \
    -host=db \
    -port=3306 \
    -user=${WORDPRESS_DB_USER} \
    -db=wordpress \
    -tableprefix=wp_ \
    -pass=${WORDPRESS_DB_PASS}
