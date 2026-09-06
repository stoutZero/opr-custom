#!/bin/sh
# Container healthcheck = liveness + readiness.
#
# Liveness:  nginx answers on the loopback healthz vhost (127.0.0.1:8181).
# Readiness: on PHP images, php-fpm must actually ANSWER a FastCGI request. We
#            curl the healthz vhost's /fpm-ping, which fastcgi_passes to the pool
#            ping.path (=> "pong"). A real round-trip: fails on dead master,
#            stale socket, AND a wedged pool — none of which the old "socket file
#            exists" check caught (that let a 10h all-502 outage report healthy).
set -eu

# --- liveness ---
curl -fsS --max-time 3 -o /dev/null http://127.0.0.1:8181/healthz || exit 1

exit 0
