#!/usr/bin/env bash

BASE_IMAGE=ghcr.io/neomantra/openresty:bookworm-amd64

# Ensure the base image is available (pull for amd64 platform on mac M1/M2)
# Pull for amd64 platform if needed
docker pull --platform linux/amd64 "$BASE_IMAGE" > /dev/null 2>&1 || true

# Pull and extract the OpenResty version string using -V (outputs to stderr)
export OPR_V=$(docker run --rm --platform linux/amd64 "$BASE_IMAGE" openresty -V 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

if [ -z "$OPR_V" ]; then
  echo "Docker run failed! Command =>"
  echo "docker run --rm --platform linux/amd64 \"$BASE_IMAGE\" openresty -V"
  exit 1
fi

export NGX_V="${OPR_V%.*}"
export NGX_UI_V="2.5.10"
export S6_V="3.2.3.2"

if [ "$1" == "-w" ] ; then
    # Update README version references
    sed -i '' -e "s/^\([[:space:]]*-[[:space:]]*OpenResty:[[:space:]]*\).*$/\1$OPR_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*NginX:[[:space:]]*\).*$/\1$NGX_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*Nginx-UI:[[:space:]]*\).*$/\1$NGX_UI_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*S6-Overlay:[[:space:]]*\).*$/\1$S6_V/" \
        "${PWD}/README.md"
    
    echo "README.md updated!"

fi
