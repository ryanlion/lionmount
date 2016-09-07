FROM ruby:2.1.2
MAINTAINER Lion Trade <liontradecom@gmail.com>

RUN apt-get update && apt-get install -y build-essential nodejs libpq-dev mysql mysql-client

ENV INSTALL_PATH /lionmount

RUN mkdir -p /lionmount

WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile
RUN bundle install

COPY . .

VOLUME ["$INSTALL_PATH/public"]

CMD rails s
