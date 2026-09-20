#!/usr/bin/env bash

#!/usr/bin/env bash
set -euo pipefail

export IMG_V="$(python3 ./opr_v.py)"

# Pull and extract the OpenResty version string using -V (outputs to stderr)
export OPR_V="${IMG_V%-*}"
export NGX_V="${OPR_V%.*}"
export NGX_UI_V="2.5.10"
export S6_V="3.2.3.2"

echo "DOCKER_IMAGE: ${IMG_V}, OpenResty: $OPR_V, NginX: $NGX_V, NginX-UI: $NGX_UI_V, S6-Overlay: $S6_V"

ARG="${1:-''}"

if [ "$ARG" == "-w" ] ; then
    # Update README version references
    sed -i '' -e "s/^\([[:space:]]*-[[:space:]]*Docker[[:space:]]Image:[[:space:]]*\).*$/\1$IMG_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*NginX:[[:space:]]*\).*$/\1$NGX_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*Nginx-UI:[[:space:]]*\).*$/\1$NGX_UI_V/" \
        -e "s/^\([[:space:]]*-[[:space:]]*S6-Overlay:[[:space:]]*\).*$/\1$S6_V/" \
        "${PWD}/README.md"

    echo "README.md updated!"

    # Update Dockerfile version references
    sed -i '' \
      -e "s/^\([[:space:]]*ARG IMG_V=\).*$/\1$IMG_V/" \
      -e "s/^\([[:space:]]*ARG OPR_V=\).*$/\1$OPR_V/" \
      -e "s/^\([[:space:]]*ARG NGX_V=\).*$/\1$NGX_V/" \
      -e "s/^\([[:space:]]*ARG NGX_UI_V=\).*$/\1$NGX_UI_V/" \
      -e "s/^\([[:space:]]*ARG S6_V=\).*$/\1$S6_V/" \
      "${PWD}/Dockerfile"

    echo "Dockerfile updated!"
fi
