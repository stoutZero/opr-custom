#!/usr/bin/env bash

source versions.sh

docker build \
    --build-arg TZ="Etc/UTC" \
    --build-arg UPSTREAM_IMG_V="$UPSTREAM_IMG_V" \
    --build-arg RESTY_SRC_V="$RESTY_SRC_V" \
    --build-arg NGX_V="$NGX_V" \
    --build-arg NGX_UI_V="$NGX_UI_V" \
    --build-arg S6_V="$S6_V" \
    --build-arg VERSION="$VERSION" \
    --platform linux/amd64 \
    -f Dockerfile \
    -t stoutZero/opr-custom:latest \
    .
