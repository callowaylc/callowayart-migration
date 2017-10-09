FROM ubuntu:16.04

RUN true && \
  apt update && \
  apt install -y \
    curl \
    mysql-client \
    git \
    libmysqlclient-dev \
    gcc \
    make \
    software-properties-common python-software-properties \
    ruby2.3 ruby2.3-dev ruby-mysql2 \
    php7.0-cli php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-xml && \
  gem install bundler rake && \
  mkdir -p /opt/callowayart

WORKDIR /opt/callowayart

COPY ./src/opt /opt
COPY ./build/*.sql /opt/callowayart/
COPY ./build/wordpress /opt/callowayart/

RUN true && \
  bundle install

CMD [ "./bootstrap.sh" ]
