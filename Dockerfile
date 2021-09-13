FROM v4tech/imagemagick:latest

WORKDIR /opt

RUN apk update && \
    apk --no-cache add bash git && \
    git clone https://github.com/pbackz/fprimitive-bot.sh

WORKDIR /opt/fprimitive-bot.sh

RUN chmod +x fprimitive-bot.sh && \
    mkdir output

ENTRYPOINT ["bash"]
# Automated test entrypoint
# ENTRYPOINT ["./fprimitive-bot", "data", "output"]