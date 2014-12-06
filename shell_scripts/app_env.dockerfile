#
# Dockerfile to install application environment
# Ver 0.1.0
#
# attach
# $ nsenter --target $(docker inspect --format "{{ .State.Pid }}" ezcall_app) --mount --uts --ipc --net --pid
# build
# $ RUBY_VERSION=2.1.4 APP_NAME=ezcall COMMIT_NAME=v0.1.0 bash ./contrib/shell_scripts/build_app_env_image.sh
# startup as daemon
# $ docker run --name ezcall_app -dt -v /tmp/mtt/shared/system:/home/application/public/system:rw --env-file ./contrib/env.list -p 28080:8080 ezcall:v0.1.0
# startup in bash
# $ docker run --name ezcall_app --rm -it -v /tmp/mtt/shared/system:/home/application/public/system:rw --env-file ./contrib/env.list -p 28080:8080 ezcall:v0.1.0 bash

FROM [BASE_IMAGE_NAME]
MAINTAINER Evgenii S Semenchuk <evgenii.s.semenchuk@gmail.com>


ENV PATH /usr/local/ruby/bin:$PATH
WORKDIR /home/application

COPY ./ /home/application
RUN cd /home/application && \
    cp ./config/app_config.template.yml ./config/app_config.yml && \
    cp ./config/database.template.yml ./config/database.yml && \
    rm -rf ./log ./tmp && mkdir -p ./log ./tmp/pids ./tmp/cache ./tmp/sessions ./tmp/sockets

# configure nginx
ADD ./contrib/shell_scripts/nginx.conf /home/application/config/nginx.conf
# configure supervisord
ADD ./contrib/shell_scripts/supervisord.conf /home/application/config/supervisord.conf

RUN chown daemon -R /home/application && chgrp daemon -R /home/application

USER daemon
RUN bundle install --jobs=[BUNDLE_JOBS] --path=/home/application/.bundle
RUN RAILS_ENV=production DATABASE_URL=mysql2://user:pass@127.0.0.1/dbname bundle exec rake assets:precompile

# Run Supervisor
CMD ["/usr/bin/supervisord", "-c", "/home/application/config/supervisord.conf"]
# Expose ports.
EXPOSE 8080
