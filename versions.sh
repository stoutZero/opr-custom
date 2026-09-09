#!/usr/bin/env bash

# Pull and extract the OpenResty version string using -V (outputs to stderr)
export OPR_V="$(curl -s https://openresty.org/en/download.html | grep -oE 'openresty-[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | cut -d'-' -f2)"
export NGX_V="${OPR_V%.*}"
export NGX_UI_V="2.5.10"
export S6_V="3.2.3.2"

export LATEST_TAG="${OPR_V}-mainline"

echo "LATEST_TAG: $LATEST_TAG, OpenResty: $OPR_V, NginX: $NGX_V, NginX-UI: $NGX_UI_V, S6-Overlay: $S6_V"

exit 0

if [ "$1" == "-w" ] ; then
    # Update README version references
    sed -i '' -e "s/^\([[:space:]]*-[[:space:]]*OpenResty:[[:space:]]*\).*$/\1$OPR_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*NginX:[[:space:]]*\).*$/\1$NGX_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*Nginx-UI:[[:space:]]*\).*$/\1$NGX_UI_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*S6-Overlay:[[:space:]]*\).*$/\1$S6_V/" \
        "${PWD}/README.md"

    echo "README.md updated!"

    # Update Dockerfile version references
    sed -i '' \
      -e "s/^\([[:space:]]*ARG OPR_V=\).*$/\1$OPR_V/" \
      -e "s/^\([[:space:]]*ARG NGX_V=\).*$/\1$NGX_V/" \
      -e "s/^\([[:space:]]*ARG NGX_UI_V=\).*$/\1$NGX_UI_V/" \
      -e "s/^\([[:space:]]*ARG S6_V=\).*$/\1$S6_V/" \
      "${PWD}/Dockerfile"

    echo "Dockerfile updated!"
fi
