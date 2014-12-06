#!/usr/bin/env bash

APP_ENV_DOCKERFILE=app_env.dockerfile

if [[ -z "$RUBY_VERSION" ]]; then
  RUBY_VERSION=2.1.4
fi
if [[ -z "$RUBY_ENV_IMAGE_NAME" ]]; then
  RUBY_ENV_IMAGE_NAME=ruby_environment
fi
if [[ -z "$BUNDLE_JOBS" ]]; then
  BUNDLE_JOBS=5
fi

DOCKER_BIN=docker
command -v $DOCKER_BIN >/dev/null 2>&1 || { echo >&2 "I require $DOCKER_BIN but it's not installed. Aborting."; exit 1; }
DOCKER_IMAGE=$(docker images | grep "^$RUBY_ENV_IMAGE_NAME" | awk '{print $2}' | grep $RUBY_VERSION)


# install build docker image with ruby environment if not exist
if [[ -z "$DOCKER_IMAGE" ]]; then
  echo "Image $RUBY_ENV_IMAGE_NAME:$RUBY_VERSION was not found. Aborting."
  exit 1
else
  if [[ -z "$APP_NAME" ]]; then
    echo "APP_NAME was not provided"
    exit 1
  fi
  if [[ -z "$COMMIT_NAME" ]]; then
    echo "COMMIT_NAME was not provided"
    exit 1
  fi

  cat ./contrib/shell_scripts/$APP_ENV_DOCKERFILE |
    sed "s/\[BASE_IMAGE_NAME\]/$RUBY_ENV_IMAGE_NAME:$RUBY_VERSION/g" |
    sed "s/\[BUNDLE_JOBS\]/$BUNDLE_JOBS/g" |
    tee ./Dockerfile

  $DOCKER_BIN build -t $APP_NAME:$COMMIT_NAME --force-rm ./.
fi
