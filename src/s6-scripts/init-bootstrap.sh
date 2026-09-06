#!/bin/sh
## s6 oneshot: all one-time container setup, split out of the old bootstrap.sh.
## The long-running processes that used to be `&`/`exec` at the tail are now
## separate s6 longruns: nginx, ticket-reload. This script
## must finish (exit 0) before those start; a FATAL config error aborts the boot.
set -eu

## Timezone
if [ -n "${TZ:-}" ]; then rm -f /etc/timezone /etc/localtime
    echo "${TZ}" > /etc/timezone
    ln -s "/usr/share/zoneinfo/${TZ}" /etc/localtime
fi

## Healthz vhost
if [ -f /usr/local/openresty/nginx/conf/sites-enabled/healthz ]; then
    mkdir -p /usr/local/openresty/nginx/conf/sites-enabled
    cp /healthz /usr/local/openresty/nginx/conf/sites-enabled/healthz
fi

cs_local="/etc/crowdsec/bouncers/crowdsec-nginx-bouncer.conf.local"

if [ -n "$CS_API_URL" ] && [ -n "$CS_API_KEY" ] && [ -n "$CS_APPSEC_URL" ]; then
    # Ensure the file exists so cat/grep don't fail on the first run
    [ -f "$cs_local" ] || touch "$cs_local"

    for var in CS_APPSEC_URL CS_API_KEY CS_API_URL; do
        # POSIX-compliant indirect expansion
        eval "val=\$$var"

        # shellcheck disable=SC2154
        TARGET="$var=\"$val\""

        if grep -q "^[[:space:]]*$var=" "$cs_local"; then
            sed -i "s|^[[:space:]]*$var=.*|$TARGET|" "$cs_local"
        else
            { echo "$TARGET"; cat "$cs_local"; } > "$cs_local.tmp" && mv "$cs_local.tmp" "$cs_local"
        fi
    done
fi

echo "[NGINX] init-bootstrap complete; handing off to s6-supervised services."
exit 0
