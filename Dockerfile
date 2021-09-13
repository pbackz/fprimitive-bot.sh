FROM alpine:latest

WORKDIR /opt

# need GNU tools and not busybox eponym binaries
RUN apk update && \
    apk --no-cache add util-linux pciutils usbutils coreutils binutils findutils \
    bash git grep wget && \
    git clone https://github.com/pbackz/fprimitive-bot.sh && \
    rm /bin/sh && \
    ln -s /bin/bash /bin/sh

WORKDIR /opt/fprimitive-bot.sh

RUN chmod +x fprimitive-bot.sh

ENTRYPOINT ["bash"]
# Automated test entrypoint
# ENTRYPOINT ["./fprimitive-bot", "data", "output"]