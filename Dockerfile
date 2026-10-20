# syntax=docker/dockerfile:1

ARG UPSTREAM_IMG_V=1.31.1.1-3
ARG RESTY_SRC_V=1.31.1.1
ARG NGX_V=1.31.1

# Stage 1: Build environment using debian:bookworm-fat
FROM ghcr.io/neomantra/openresty:${UPSTREAM_IMG_V}-bookworm-fat AS builder

ARG RESTY_SRC_V
ARG NGX_V

ENV RESTY_SRC_V="${RESTY_SRC_V}" \
  DEBIAN_FRONTEND="noninteractive"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  libssl-dev

# Build modern Hiredis from source with SSL support
RUN cd /tmp \
  && curl -fsSL https://github.com/redis/hiredis/archive/refs/heads/master.zip -o hiredis-master.zip \
  && unzip -q hiredis-master.zip \
  && rm -f hiredis-master.zip \
  && cd /tmp/hiredis-master \
  && make USE_SSL=1 \
  && make PREFIX=/usr/local USE_SSL=1 install \
  && ldconfig \
  && rm -rf /tmp/hiredis-master

WORKDIR /tmp/modules
RUN curl -fsSL https://github.com/myguard-labs/nginx-autocert-module/archive/refs/tags/v1.3.0.zip -o nginx-autocert-module-1.3.0.zip \
  && unzip -q nginx-autocert-module-1.3.0.zip \
  && mv nginx-autocert-module-1.3.0 autocert-1.3.0 \
  && rm -f nginx-autocert-module-1.3.0.zip

RUN curl -fsSLO https://github.com/61131/nginx-http-auth-totp/releases/download/1.2.0/nginx-http-auth-totp-1.2.0.tar.gz \
  && tar -xzf nginx-http-auth-totp-1.2.0.tar.gz \
  && rm -f nginx-http-auth-totp-1.2.0.tar.gz

RUN mkdir brotli-a71f9312 \
&& cd brotli-a71f9312 \
  && git init \
  && git remote add origin https://github.com/google/ngx_brotli.git \
  && git fetch origin a71f9312c2deb28875acc7bacfdd5695a111aa53 \
  && git checkout FETCH_HEAD \
  && git submodule update --init \
  && cd ..

RUN curl -fsSL https://github.com/nginx-modules/ngx_cache_purge/archive/refs/tags/3.0.4.zip -o ngx_cache_purge-3.0.4.zip \
&& unzip -q ngx_cache_purge-3.0.4.zip \
&& mv ngx_cache_purge-3.0.4 cache-purge-3.0.4 \
&& rm -f ngx_cache_purge-3.0.4.zip

RUN curl -fsSL https://github.com/HanadaLee/ngx_http_cache_dechunk_filter_module/archive/refs/tags/1.0.1.zip -o ngx_http_cache_dechunk_filter_module-1.0.1.zip \
  && unzip -q ngx_http_cache_dechunk_filter_module-1.0.1.zip \
  && mv ngx_http_cache_dechunk_filter_module-1.0.1 cache_dechunk_filter-1.0.1 \
  && rm -f ngx_http_cache_dechunk_filter_module-1.0.1.zip

RUN curl -fsSL https://github.com/HanadaLee/ngx_http_cors_module/archive/refs/tags/0.1.1.zip -o ngx_http_cors_module-0.1.1.zip \
  && unzip -q ngx_http_cors_module-0.1.1.zip \
  && mv ngx_http_cors_module-0.1.1 cors-0.1.1 \
  && rm -f ngx_http_cors_module-0.1.1.zip

RUN mkdir error_abuse-46db3176 \
  && cd error_abuse-46db3176 \
  && git init \
  && git remote add origin https://github.com/myguard-labs/nginx-error-abuse-module.git \
  && git fetch origin 46db31769397ef9781506b277d914f630578c241 \
  && git checkout FETCH_HEAD \
  && cd ..

RUN mkdir extravars-67365591 \
  && cd extravars-67365591 \
  && git init \
  && git remote add origin https://github.com/nginx-modules/ngx_extravars.git \
  && git fetch origin 67365591d7073ea0a630883eb97752b9478cfe7a \
  && git checkout FETCH_HEAD \
  && cd ..

RUN curl -fsSLO https://github.com/aperezdc/ngx-fancyindex/releases/download/v0.6.0/ngx-fancyindex-0.6.0.tar.xz \
  && tar -xJf ngx-fancyindex-0.6.0.tar.xz \
  && rm -f ngx-fancyindex-0.6.0.tar.xz

RUN mkdir geoip2-a607a41a \
  && cd geoip2-a607a41a \
  && git init \
  && git remote add origin https://github.com/leev/ngx_http_geoip2_module.git \
  && git fetch origin a607a41a8115fecfc05b5c283c81532a3d605425 \
  && git checkout FETCH_HEAD \
  && cd ..

RUN mkdir stream-sts-a60cd2fc \
  && cd stream-sts-a60cd2fc \
  && git init \
  && git remote add origin https://github.com/vozlt/nginx-module-stream-sts.git \
  && git fetch origin a60cd2fc2bdd689b8b4e12abcf71f7cf5018424a \
  && git checkout FETCH_HEAD \
  && cd ..

RUN mkdir sts-3c10d42f \
  && cd sts-3c10d42f \
  && git init \
  && git remote add origin https://github.com/vozlt/nginx-module-sts.git \
  && git fetch origin 3c10d42f8c3f78b6310906eab5c8e066ee753330 \
  && git checkout FETCH_HEAD \
  && cd ..

RUN mkdir sysguard-864c491c \
  && cd sysguard-864c491c \
  && git init \
  && git remote add origin https://github.com/vozlt/nginx-module-sysguard.git \
  && git fetch origin 864c491ccfec7a3a5549f0f3d962fca7dee7f620 \
  && git checkout FETCH_HEAD \
  && sed -i 's/#if (NGX_HAVE_SYSINFO)/#if 1/g' /tmp/modules/sysguard-864c491c/src/ngx_http_sysguard_sysinfo.h \
  && sed -i 's/#if (NGX_HAVE_VM_STATS)/#if 0/g' /tmp/modules/sysguard-864c491c/src/ngx_http_sysguard_sysinfo.h \
  && cd ..

RUN mkdir vts-fa36a468 \
  && cd vts-fa36a468 \
  && git init \
  && git remote add origin https://github.com/vozlt/nginx-module-vts.git \
  && git fetch origin fa36a4680d7e3fe2ec3c38d3961fd177d7a0d366 \
  && git checkout FETCH_HEAD \
  && cd ..

RUN mkdir zstd-d2443667 \
&& cd zstd-d2443667 \
  && git init \
  && git remote add origin https://github.com/myguard-labs/nginx-zstd-module.git \
  && git fetch origin d2443667159bf288f7e11e7a5ff1b6cff18afbf3 \
  && git checkout FETCH_HEAD \
  && cd ..

RUN apt-get install -y --no-install-recommends \
  build-essential \
  libbrotli-dev \
  libmaxminddb-dev \
  libpcre3-dev \
  libzstd-dev \
  zlib1g-dev \
  && rm -f /usr/lib/*/libzstd.a

# Download OpenResty source matching the runtime version to compile module .so objects
RUN echo "Running ./configure ... " \
  && cd /tmp \
  && curl -fSL https://openresty.org/download/openresty-${RESTY_SRC_V}.tar.gz -o openresty.tar.gz \
  && tar -zxf openresty.tar.gz \
  && rm -f /tmp/openresty.tar.gz \
  && cd /tmp/openresty-${RESTY_SRC_V} \
  && ./configure \
  --with-compat \
  --with-http_ssl_module \
  --add-dynamic-module=/tmp/modules/nginx-http-auth-totp-1.2.0 \
  --add-dynamic-module=/tmp/modules/autocert-1.3.0 \
  --add-dynamic-module=/tmp/modules/brotli-a71f9312 \
  --add-dynamic-module=/tmp/modules/cache-purge-3.0.4 \
  --add-dynamic-module=/tmp/modules/cache_dechunk_filter-1.0.1 \
  --add-dynamic-module=/tmp/modules/cors-0.1.1 \
  --add-dynamic-module=/tmp/modules/error_abuse-46db3176 \
  --add-dynamic-module=/tmp/modules/extravars-67365591 \
  --add-dynamic-module=/tmp/modules/ngx-fancyindex-0.6.0 \
  --add-dynamic-module=/tmp/modules/geoip2-a607a41a \
  --add-dynamic-module=/tmp/modules/stream-sts-a60cd2fc \
  --add-dynamic-module=/tmp/modules/sts-3c10d42f \
  --add-dynamic-module=/tmp/modules/sysguard-864c491c \
  --add-dynamic-module=/tmp/modules/vts-fa36a468 \
  --add-dynamic-module=/tmp/modules/zstd-d2443667

RUN echo "Running make modules ... " \
  && cd $(ls -d /tmp/openresty-${RESTY_SRC_V}/build/nginx-${NGX_V} | head -n 1) \
  && make -j$(nproc) modules

RUN mkdir -p /tmp/so-modules \
  && find /tmp/openresty-${RESTY_SRC_V}/build/nginx-${NGX_V} -type f -name '*.so' -exec cp {} /tmp/so-modules/ \;  ;\
  rm -rf /var/lib/apt/lists/* /var/cache/debconf/*-old /var/cache/debconf/templates.dat

ARG UPSTREAM_IMG_V=1.31.1.1-3

# Stage 2: Runtime Environment
FROM ghcr.io/neomantra/openresty:${UPSTREAM_IMG_V}-bookworm AS runtime

ARG UPSTREAM_IMG_V=1.31.1.1-3
ARG TZ="Etc/UTC"
ARG S6_V
ARG NGX_UI_V
ARG VERSION

LABEL org.opencontainers.image.authors="Aprilus Lumbantoruan <i@pilus.me>" \
  org.opencontainers.image.title="openresty-crowdsec-bouncer-nginx-ui" \
  org.opencontainers.image.description="My Custom OpenResty w/ Crowdsec Bouncer & Nginx-UI" \
  org.opencontainers.image.licenses="BSD-2-Clause" \
  org.opencontainers.image.version="${VERSION}" \
  org.opencontainers.image.vendor="stoutZero" \
  org.opencontainers.image.source="https://github.com/stoutzero/opr-custom" \
  org.opencontainers.image.documentation="To enable Crowdsec Bouncer, supply 3 env vars: CS_API_URL, CS_API_KEY, CS_APPSEC_URL." \
  maintainer="Aprilus Lumbantoruan <i@pilus.me>" \
  resty_deb_version="$UPSTREAM_IMG_V" \
  nginx_ui_version="$NGX_UI_V" \
  s6_version="$S6_V"

ENV TZ="${TZ:-'Etc/UTC'}" \
  DEBIAN_FRONTEND="noninteractive"

# s6: keep the container env for service run scripts; don't time out waiting for
# longruns; abort the boot if stage2 (our services) fails so a broken config is
# loud, matching the old bootstrap FATAL behaviour.
ENV S6_KEEP_ENV=1 \
  S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
  S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN apt-get update \
  && apt-get install -y --no-install-recommends libmaxminddb0 libbrotli1 libzstd1 curl gettext-base xz-utils
RUN curl -s https://install.crowdsec.net | sh || { echo "Curl not found" ; exit 1 ; }
RUN apt-get update && apt-get install -y --no-install-recommends crowdsec-openresty-bouncer

# Copy compiled dynamic modules into OpenResty's module directory
COPY --from=builder /tmp/so-modules/ /usr/local/openresty/nginx/modules/

# Install Nginx-UI web interface binary
WORKDIR /tmp
RUN curl -fsSLO https://github.com/0xJacky/nginx-ui/releases/download/v${NGX_UI_V}/nginx-ui-linux-64.tar.gz \
  && tar -xzf nginx-ui-linux-64.tar.gz \
  && rm -f nginx-ui-linux-64.tar.gz \
  && mv nginx-ui /usr/local/bin/

COPY ./src/nginx-ui-app.ini /usr/local/nginx-ui/

COPY --chmod=0755 ./src/healthcheck.sh /healthcheck.sh
COPY ./src/healthz.conf /healthz
COPY ./src/s6-rc/ /etc/s6-overlay/s6-rc.d/
COPY ./src/s6-user-bundles/ /etc/s6-overlay/user-bundles.d/
COPY --chmod=0755 ./src/s6-scripts/init-bootstrap.sh /etc/s6-overlay/scripts/init-bootstrap.sh

RUN export _dir="/usr/local/openresty/nginx" ; \
  export _mod="${_dir}/conf/modules-available" ; \
  export _pfx="load_module ${_dir}/modules" ; \
  mkdir -p "${_mod}" ; \
  echo "${_pfx}/ngx_http_auth_totp_module.so;" > "${_mod}/50-auth_totp.conf" \
  echo "${_pfx}/ngx_http_autocert_module.so;" > "${_mod}/50-autocert.conf" \
  echo "${_pfx}/ngx_http_brotli_filter_module.so;" > "${_mod}/50-brotli.conf" \
  echo "${_pfx}/ngx_http_brotli_static_module.so;" >> "${_mod}/50-brotli.conf" \
  echo "${_pfx}/ngx_http_cache_dechunk_filter_module.so;" > "${_mod}/50-cache_dechunk_filter.conf" \
  echo "${_pfx}/ngx_http_cache_purge_module.so;" > "${_mod}/50-cache_purge.conf" \
  echo "${_pfx}/ngx_http_error_abuse_module.so;" > "${_mod}/50-error_abuse.conf" \
  echo "${_pfx}/ngx_http_extravars_module.so;" > "${_mod}/50-extravars.conf" \
  echo "${_pfx}/ngx_http_fancyindex_module.so;" > "${_mod}/50-fancyindex.conf" \
  echo "${_pfx}/ngx_http_geoip2_module.so;" > "${_mod}/50-geoip2.conf" \
  echo "${_pfx}/ngx_http_stream_server_traffic_status_module.so;" > "${_mod}/50-ssts.conf" \
  echo "${_pfx}/ngx_http_sysguard_module.so;" > "${_mod}/50-sysguard.conf" \
  echo "${_pfx}/ngx_http_vhost_traffic_status_module.so;" > "${_mod}/50-vts.conf" \
  echo "${_pfx}/ngx_http_zstd_filter_module.so;" > "${_mod}/50-zstd.conf" \
  echo "${_pfx}/ngx_http_zstd_static_module.so;" >> "${_mod}/50-zstd.conf" \
  echo "${_pfx}/ngx_stream_geoip2_module.so;" > "${_mod}/50-stream_geoip2.conf" \
  echo "${_pfx}/ngx_stream_server_traffic_status_module.so;" > "${_mod}/50-stream_sts.conf" \
  echo DONE

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  set -ex ;\
  rm -f /etc/apt/apt.conf.d/docker-clean ;\
  # Pre-create writable dirs with restrictive perms \
  install -d -m 0750 -o www-data -g www-data /var/cache/nginx /var/log/nginx ;\
  # Drop any setuid/setgid bits the install pulled in
  find /usr -xdev \( -perm -4000 -o -perm -2000 \) -type f -exec chmod a-s {} \; 2>/dev/null || true ;\
  # ---- s6-overlay (PID1 process supervisor) ---- \
  # Fetch the noarch + per-arch tarballs for the build target arch and unpack \
  # to /. dpkg arch -> s6 arch name. \
  S6_ARCH="$(dpkg --print-architecture)" ;\
  case "${S6_ARCH}" in \
  amd64) S6_ARCH=x86_64 ;; \
  arm64) S6_ARCH=aarch64 ;; \
  armhf) S6_ARCH=arm ;; \
  esac ;\
  S6_BASE_URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_V}" ;\
  curl -fsSL -o /tmp/s6-noarch.tar.xz "${S6_BASE_URL}/s6-overlay-noarch.tar.xz" ;\
  curl -fsSL -o /tmp/s6-arch.tar.xz "${S6_BASE_URL}/s6-overlay-${S6_ARCH}.tar.xz" ;\
  tar -C / -Jxpf /tmp/s6-noarch.tar.xz ;\
  tar -C / -Jxpf /tmp/s6-arch.tar.xz ;\
  rm -f /tmp/s6-noarch.tar.xz /tmp/s6-arch.tar.xz ;\
  cd /etc/s6-overlay/s6-rc.d ;\
  chmod 0755 nginx/run nginx-ui/run /etc/s6-overlay/scripts/init-bootstrap.sh ;\
  mkdir -p /usr/local/openresty/nginx/conf/sites-enabled ;\
  install -m 0644 /healthz /usr/local/openresty/nginx/conf/sites-enabled/healthz ;\
  chown -Rh www-data:www-data /usr/local/openresty ;\
  apt-get remove -y g++ ;\
  apt-get purge -y --auto-remove g++ ;\
  find /var/log -type f -name '*.log' -exec truncate -s0 {} \; ;\
  rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/debconf/*-old /var/cache/debconf/templates.dat

WORKDIR /usr/local/openresty

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD /healthcheck.sh || exit 1

EXPOSE 80 443 9000
EXPOSE 443/udp

STOPSIGNAL SIGQUIT

ENTRYPOINT ["/init"]
CMD        []
