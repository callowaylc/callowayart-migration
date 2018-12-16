FROM ubuntu:16.04
ENV PATH=/opt/callowayart/vendor/bin:${PATH}
WORKDIR /opt/callowayart

RUN true && \
  apt update && \
  apt install -y \
    curl \
    mysql-client \
    git \
    libmysqlclient-dev \
    gcc \
    make \
    netcat \
    software-properties-common python-software-properties \
    ruby2.3 ruby2.3-dev ruby-mysql2 \
    php7.0-cli php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-xml \
    zip unzip php7.0-zip && \
  curl -Lso ${WORKDIR}/installer.php https://getcomposer.org/installer && \
  php ${WORKDIR}/installer.php && \
  gem install bundler rake

COPY ./src/opt /opt
COPY ./build/*.sql /opt/callowayart/
COPY ./build/wordpress /opt/callowayart/

RUN true && \
    php composer.phar install && \
    bundle install

CMD [ "./bootstrap.sh" ]
