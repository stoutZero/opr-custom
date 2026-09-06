#!/usr/bin/env bash

source versions.sh

docker build \
    --build-arg TZ=UTC \
    --build-arg OPR_V="$OPR_V" \
    --build-arg NGX_V="$NGX_V" \
    --build-arg NGX_UI_V="$NGX_UI_V" \
    --build-arg S6_V="$S6_V" \
    --platform linux/amd64 \
    -f Dockerfile \
    -t stoutZero/opr-custom:latest \
    .
