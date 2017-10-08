FROM ubuntu:16.04

RUN true && \
  apt update && \
  apt install -y \
    mysql-client \
    git \
    libmysqlclient-dev \
    gcc \
    make \
    ruby2.3 ruby2.3-dev ruby-mysql2 && \
  gem install bundler rake && \
  mkdir -p /opt/callowayart

WORKDIR /opt/callowayart

COPY ./src/opt /opt
COPY ./build/*.sql /opt/callowayart/

RUN true && \
  bundle install

CMD [ "./bootstrap.sh" ]
