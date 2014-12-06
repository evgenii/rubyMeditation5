#!/usr/bin/env bash

TEMP_DIR=/tmp
WORKING_DIR=$TEMP_DIR/ruby_env
RUBY_ENV_DOCKERFILE=ruby_env.dockerfile

if [[ -z "$RUBY_VERSION" ]]; then
  RUBY_VERSION=2.1.4
fi
if [[ -z "$RUBY_ENV_IMAGE_NAME" ]]; then
  RUBY_ENV_IMAGE_NAME=ruby_environment
fi

DOCKER_BIN=docker
command -v $DOCKER_BIN >/dev/null 2>&1 || { echo >&2 "I require $DOCKER_BIN but it's not installed. Aborting."; exit 1; }
DOCKER_IMAGE=$(docker images | grep "^$RUBY_ENV_IMAGE_NAME" | awk '{print $2}' | grep $RUBY_VERSION)


# install build docker image with ruby environment if not exist
if [[ -z "$DOCKER_IMAGE" ]]; then
  echo "Image $RUBY_ENV_IMAGE_NAME:$RUBY_VERSION was not found. Creating!..."
  if [ ! -d "$WORKING_DIR" ]; then
    mkdir $WORKING_DIR
  fi

  cat ./contrib/shell_scripts/$RUBY_ENV_DOCKERFILE |
    sed "s/\[RUBY_VERSION\]/$RUBY_VERSION/g" |
    tee $WORKING_DIR/Dockerfile

  $DOCKER_BIN build -t $RUBY_ENV_IMAGE_NAME:$RUBY_VERSION --force-rm $WORKING_DIR/.
  rm -rf $WORKING_DIR
else
  echo "Image $RUBY_ENV_IMAGE_NAME:$RUBY_VERSION already exist."
fi
