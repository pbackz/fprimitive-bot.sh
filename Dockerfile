FROM alpine:latest

WORKDIR /opt

ENV GLIBC_REPO=https://github.com/sgerrand/alpine-pkg-glibc
ENV GLIBC_VERSION=2.30-r0

# need GNU tools and not busybox eponym binaries
RUN apk update && \
    apk --no-cache add util-linux pciutils usbutils coreutils binutils findutils \
    imagemagick bash git grep wget && \
    git clone https://github.com/pbackz/fprimitive-bot.sh && \
    rm /bin/sh && \
    ln -s /bin/bash /bin/sh

RUN set -ex && \
    apk --update add libstdc++ curl ca-certificates && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION}; \
        do curl -sSL ${GLIBC_REPO}/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib

WORKDIR /opt/fprimitive-bot.sh

RUN chmod +x fprimitive-bot.sh && \
    mkdir output

ENTRYPOINT ["bash"]
# Automated test entrypoint
# ENTRYPOINT ["./fprimitive-bot", "data", "output"]