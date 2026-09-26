#!/usr/bin/env bash

#!/usr/bin/env bash
set -euo pipefail

export UPSTREAM_IMG_V
UPSTREAM_IMG_V="$(python3 ./opr_v.py)"

# Pull and extract the OpenResty version string using -V (outputs to stderr)
export RESTY_SRC_V="${UPSTREAM_IMG_V%-*}"
export NGX_V="${RESTY_SRC_V%.*}"
export NGX_UI_V="2.6.3"
export S6_V="3.2.3.2"

export VERSION
VERSION="$(date -u +'%y.%m.%d')"

echo "- Upstream IMG: ${UPSTREAM_IMG_V}"
echo "- OpenResty src: $RESTY_SRC_V"
echo "- NginX: $NGX_V"
echo "- NginX-UI: $NGX_UI_V"
echo "- S6-Overlay: $S6_V"
echo
echo "    Final image version: $VERSION"

ARG="${1:-''}"

if [ "$ARG" == "-w" ] ; then
    # Update README version references
    sed -i '' -e "s/^\([[:space:]]*-[[:space:]]*Upstream[[:space:]]Image:[[:space:]]*\).*$/\1$UPSTREAM_IMG_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*OpenResty src:[[:space:]]*\).*$/\1$RESTY_SRC_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*NginX:[[:space:]]*\).*$/\1$NGX_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*Nginx-UI:[[:space:]]*\).*$/\1$NGX_UI_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*S6-Overlay:[[:space:]]*\).*$/\1$S6_V/" \
        "${PWD}/README.md"

    echo "    README.md updated!"

    # Update Dockerfile version references
    sed -i '' \
      -e "s/^\([[:space:]]*ARG UPSTREAM_IMG_V=\).*$/\1$UPSTREAM_IMG_V/" \
      -e "s/^\([[:space:]]*ARG RESTY_SRC_V=\).*$/\1$RESTY_SRC_V/" \
      -e "s/^\([[:space:]]*ARG NGX_V=\).*$/\1$NGX_V/" \
      -e "s/^\([[:space:]]*ARG NGX_UI_V=\).*$/\1$NGX_UI_V/" \
      -e "s/^\([[:space:]]*ARG S6_V=\).*$/\1$S6_V/" \
      "${PWD}/Dockerfile"

    echo "    Dockerfile updated!"
fi
