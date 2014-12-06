#
# Dockerfile to install Ruby & bundler
# Ver 0.0.6
#
# attach
# $ nsenter --target $(docker inspect --format "{{ .State.Pid }}" ruby_env) --mount --uts --ipc --net --pid
# build
# $ RUBY_VERSION=2.1.4 RUBY_ENV_IMAGE_NAME=ruby_environment bash ./contrib/shell_scripts/build_ruby_env_image.sh
# startup
# $ docker run --name ruby_env -dt ruby_environment:2.1.4

FROM ubuntu:14.04
MAINTAINER Evgenii S Semenchuk <evgenii.s.semenchuk@gmail.com>

ENV RUBY_VERSION [RUBY_VERSION]

# Install tools & libs to compile everything
RUN apt-get update && \
    apt-get install -y build-essential libmysqlclient-dev libssl-dev libffi-dev libreadline-dev wget nodejs && \
    apt-get clean

# Install imagemagick
RUN apt-get install -y imagemagick libmagick++-dev libmagic-dev && apt-get clean

# Install git
RUN apt-get install -y git-core && apt-get clean

# Install nginx
RUN cd /tmp && wget http://nginx.org/download/nginx-1.7.7.tar.gz && \
tar -xvf /tmp/nginx-1.7.7.tar.gz && cd /tmp/nginx-1.7.7 && \
./configure \
    --prefix=/opt/nginx \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    --conf-path=/opt/nginx/conf/nginx.conf \
    --pid-path=/opt/nginx/pids/nginx.pid \
    --error-log-path=/opt/nginx/logs/nginx-error.log \
    --http-log-path=/opt/nginx/logs/nginx-access.log \
    --user=daemon --group=daemon && \
  make && sudo make install && \
  rm -rf /tmp/nginx-* && \
  chown daemon -R /opt/nginx && chgrp daemon -R /opt/nginx

# Install & configure Supervisor
RUN apt-get update && \
    apt-get -y install supervisor && \
    mkdir -p /var/log/supervisor

# Install ruby
RUN cd ~ && git clone https://github.com/sstephenson/ruby-build.git && \
    cd ruby-build && ./install.sh && ruby-build $RUBY_VERSION /usr/local/ruby && \
    ln -s /usr/local/ruby/bin/* /usr/local/bin/

ENV PATH /usr/local/ruby/bin:$PATH

# Install bundler
RUN gem install bundler
