################################################################
# Step1 Dockerfile - install htop:
#
# docker build -t rvm:v1 .
# run shell:  docker run --name rvm rvm:v1 -it --rm rMeditation
# run daemon: docker run --name rvm rvm:v1 -dt rMeditation
# attach: docker attach rvm
# connect: docker exec -it rvm:v1 /bin/bash
# connect: nsenter --target $(docker inspect --format "{{ .State.Pid }}" ruby_env) --mount --uts --ipc --net --pid
#
FROM ubuntu:14.04
MAINTAINER evgenii.s.semenchuk <evgenii.s.semenchuk@gmail.com>

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean

USER daemon

ADD ./README.md ~/README.md
ENV EVAR TEST

CMD ["while sleep 5; do date -u +%T && echo VAR=$EVAR; done"]
