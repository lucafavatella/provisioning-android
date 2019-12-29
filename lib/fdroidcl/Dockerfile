FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    fdroidcl \
 && rm -rf /var/lib/apt/lists/*
ARG USE_BY
RUN echo "Use by ${USE_BY:?}" && fdroidcl update
ARG DL=/usr/local/bin/fdroidcl_download
ARG CACHE=/root/.cache/fdroidcl/apks
RUN printf "%b\n" \
    "#!/bin/sh" \
    "fdroidcl download \${1:?} 1>&2 || exit 1" \
    "Files=\$(ls ${CACHE:?}/\${1:?}*.apk) && test 1 -eq \$(echo \"\${Files?}\" | wc -w) && cat \${Files:?}" \
    > ${DL:?} \
 && chmod +x ${DL:?}
ENTRYPOINT ["fdroidcl_download"]
