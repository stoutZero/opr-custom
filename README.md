# OpenResty w/ Crowdsec Bouncer & Nginx‑UI

## Overview
This repository builds a custom **OpenResty** image that bundles:
- **CrowdSec's bouncer** for automated security decisions
- **Nginx‑UI** – a lightweight web UI for managing Nginx configuration
- **s6‑overlay** – a process supervisor (PID 1) that provides reliable service management inside the container.

The image is built with a multi‑stage Dockerfile:
1. **builder** – compiles a set of third‑party Nginx modules as dynamic `.so` files.
2. **prod** – pulls the compiled modules into a clean OpenResty runtime, installs the CrowdSec bouncer and Nginx‑UI, and configures s6‑overlay.

## Software Versions:
- Operating System(s): Debian Bookworm (12) only.
- Docker Image: 1.31.1.1-3
- OpenResty: 1.31.1.1
- NginX: 1.31.1
- Nginx-UI: 2.5.10
- S6-Overlay: 3.2.3.2

Those versions above are generated from `./versions.sh -w` command.

## OpenResty's Pre-included Nginx Modules

| Module | Version | Source |
|--------|---------|--------|
| ngx_devel_kit | 0.3.4 | [simpl](https://github.com/simpl/ngx_devel_kit) |
| array-var-nginx-module | 0.06 | [openresty](https://github.com/openresty/array-var-nginx-module) |
| echo-nginx-module | 0.64 | [openresty](https://github.com/openresty/echo-nginx-module) |
| encrypted-session-nginx-module | 0.09 | [openresty](https://github.com/openresty/encrypted-session-nginx-module) |
| form-input-nginx-module | 0.12 | [calio](https://github.com/calio/form-input-nginx-module) |
| headers-more-nginx-module | 0.39 | [openresty](https://github.com/openresty/headers-more-nginx-module) |
| memc-nginx-module | 0.20 | [openresty](https://github.com/openresty/memc-nginx-module) |
| ngx_coolkit | 0.2 | [FRiCKLE](https://github.com/FRiCKLE/ngx_coolkit/) |
| ngx_lua_upstream | 0.08 | [openresty](hhttps://github.com/openresty/lua-upstream-nginx-module) |
| ngx_lua | 0.10.31rc5 | [openresty](https://github.com/openresty/lua-nginx-module) |
| ngx_stream_lua | 0.0.19rc4 | [openresty](https://github.com/openresty/stream-lua-nginx-module) |
| redis-nginx-module | 0.41 | [openresty](https://github.com/openresty/redis-nginx-module) |
| redis2-nginx-module | 0.15 | [openresty](https://github.com/openresty/redis2-nginx-module) |
| set-misc-nginx-module | 0.33 | [openresty](https://github.com/openresty/set-misc-nginx-module) |
| srcache-nginx-module | 0.33 | [openresty](https://github.com/openresty/srcache-nginx-module) |
| xss-nginx-module | 0.07 | [openresty](https://github.com/openresty/xss-nginx-module) |

---

## External Nginx Modules Included
The Dockerfile downloads and adds the following external modules **as dynamic modules** (the `--add-dynamic-module` flags in the `./configure` step).   
They are shipped in `/usr/local/openresty/nginx/modules/` at runtime.  
These modules are not automatically loaded when the service is run.

Modules config files is in: `/usr/local/openresty/nginx/conf/modules-available`.  
Link any module you want to enable into `/usr/local/openresty/nginx/conf/modules-enabled`.  

### auth-totp
Source: https://github.com/61131/nginx-http-auth-totp  
Load Module Config: `modules-available/50-auth_totp.conf`  
Time-based one-time password (TOTP) authentication for NGINX

### autocert
Source: https://github.com/myguard-labs/nginx-autocert-module  
Load Module Config: `modules-available/50-autocert.conf`  
Automatic certificate management module inside NGINX

### brotli
Source: https://github.com/google/ngx_brotli  
Load Module Config: `modules-available/50-brotli.conf`  
NGINX Brotli dynamic modules

### cache_dechunk_filter
Source: https://github.com/HanadaLee/ngx_http_cache_dechunk_filter_module  
Load Module Config: `modules-available/50-cache_dechunk_filter.conf`  
Allows range request for cached response that was received from upstream with `Transfer-Encoding: chunked`.

### cache-purge
Source: https://github.com/nginx-modules/ngx_cache_purge  
Load Module Config: `modules-available/50-cache_purge.conf`  
Purge FastCGI, proxy, SCGI and uWSGI cache objects by exact key

### cors
Source: https://github.com/HanadaLee/ngx_http_cors_module  
Correct CORS for NGINX, including preflight and Vary
CORS module for NGINX that handles the parts the add_header
recipe gets wrong.

### error_abuse
Source: https://github.com/myguard-labs/nginx-error-abuse-module  
Load Module Config: `modules-available/50-error_abuse.conf`  
Ban users that are abusing your server and / or might be checking non-existent URLs.

### extravars
Source: https://github.com/nginx-modules/ngx_extravars  
Load Module Config: `modules-available/50-extravars.conf`  
A collection of extra variables for nginx that I've found useful.

### fancyindex
Source: https://github.com/aperezdc/ngx-fancyindex  
Load Module Config: `modules-available/50-fancyindex.conf`  
The Fancy Index module makes possible the generation of
file listings, like the built-in autoindex module does,
but adding a touch of style.

### geoip2
Source: https://github.com/leev/ngx_http_geoip2_module  
Load Module Config: `modules-available/50-geoip2.conf`  
Load Module Config: `modules-available/50-stream_geoip2.conf`  
NGINX GeoIP2 module

### sts
Source: https://github.com/vozlt/nginx-module-sts  
Load Module Config: `modules-available/50-ssts.conf`  
Tracks and exposes real-time traffic statistics and connection metrics
for TCP and UDP proxying within NGINX's stream module

### stream-sts
Source: https://github.com/vozlt/nginx-module-stream-sts  
Load Module Config: `modules-available/50-stream_sts.conf`  
Nginx stream server traffic status

### sysguard
Source: https://github.com/vozlt/nginx-module-sysguard  
Load Module Config: `modules-available/50-sysguard.conf`  
Protects backend servers from overload by monitoring system metrics
(like load average, free memory, and swap usage)
and throttling or rejecting requests when thresholds are exceeded.

### vts
Source: https://github.com/vozlt/nginx-module-vts  
Load Module Config: `modules-available/50-vts.conf`  
Nginx virtual host traffic status

### zstd
Source: https://github.com/myguard-labs/nginx-zstd-module  
Load Module Config: `modules-available/50-zstd.conf`  
An nginx module for Zstandard (zstd) compression.

---

## CrowdSec Appsec Bouncer for OpenResty
Source: https://docs.crowdsec.net/u/bouncers/openresty/  
This image also includes a lightweight WAF from Crowdsec,  
a lightweight Lua-based Crowdsec bouncer (remediation component).

---

## s6‑overlay
The image uses **s6‑overlay** (version **3.2.3.2**) as the init system.   
It is fetched and installed in the `prod` stage (see lines 248‑262 of the Dockerfile).  
The overlay provides:
- Supervision of the main OpenResty process and auxiliary services (e.g., the CrowdSec bouncer, health‑check script).
- A clean shutdown sequence via `STOPSIGNAL SIGQUIT`.

---

## Building the Image
```bash
# From the repository root
docker build --build-arg TZ=UTC -f Dockerfile -t opr-custom:latest .
```
The build pulls the OpenResty base image, compiles the dynamic modules, installs the CrowdSec bouncer and Nginx‑UI binary, and sets up s6‑overlay.

---

## Running the Container
To enable Crowdsec Bouncer, supply 3 env vars: CS_API_URL, CS_API_KEY, CS_APPSEC_URL.  

Docker run example:
```bash
docker run -d \
  -p 80:80 -p 443:443 \
  # Nginx‑UI web UI
  # -p 9000:9000 \
  -e CS_API_URL="your_crowdsec_local_api_url" \
  -e CS_API_KEY="your_crowdsec_local_api_key" \
  -e CS_APPSEC_URL="your_crowdsec_appsec_url" \
  --name web \
  https://ghcr.io/stoutzero/opr-custom:latest
```

Docker compose example:
```yaml
  web:
    image: ghcr.io/stoutZero/opr-custom:latest
    platform: linux/amd64
    env_file:
      - .env
    container_name: web
    privileged: true
    volumes:
      - ./letsencrypt:/etc/letsencrypt:rw
      - ./ngx-conf/module-enabled:/usr/local/openresty/nginx/conf/module-enabled
      - ./ngx-conf/sites-available:/usr/local/openresty/nginx/conf/sites-available
      - ./ngx-conf/sites-enabled:/usr/local/openresty/nginx/conf/sites-enabled
      - ./ngx-conf/stream-available:/usr/local/openresty/nginx/conf/stream-available
      - ./ngx-conf/stream-enabled:/usr/local/openresty/nginx/conf/stream-enabled
      - ./ngx-conf/snippets:/usr/local/openresty/nginx/conf/external-snippets
      # - ./ngx-logs:/var/log/nginx
      - ./ngx-conf/ssl:/usr/local/openresty/ssl:ro
      - ./geoip_data:/var/lib/GeoIP
    restart: unless-stopped
    ports:
      - "80:80"
      # udp is required for HTTP/3
      # per docker compose spec, we have to specify both 443/tcp & 443/udp
      - "443:443/tcp"
      - "443:443/udp"
      # - "9000:9000"
    healthcheck:
      interval: 30s
      timeout: 1s
      start_period: 15s
      retries: 2
      test: ["CMD", "/healthcheck.sh"]
```

The container starts under s6‑overlay, which launches:
1. **OpenResty** (Nginx + Lua + Crowdsec Appsec Bouncer)
2. **nginx‑ui** (exposed on port 9000)

---

## Health‑Check
A simple health‑check script (`/healthcheck.sh`) is provided and registered via Docker `HEALTHCHECK`.  It verifies that OpenResty responds on the configured port.

---

## License
This project is released under the **[BSD-2-Clause](https://choosealicense.com/licenses/bsd-2-clause/)**.
